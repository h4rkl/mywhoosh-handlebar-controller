#include <Arduino.h>
#include <BleKeyboard.h>
#include <esp_sleep.h>

namespace {

constexpr uint8_t kUpshiftPin = 3;
constexpr uint8_t kDownshiftPin = 4;
constexpr uint8_t kUpshiftKey = 'i';
constexpr uint8_t kDownshiftKey = 'k';
constexpr uint32_t kDebounceMs = 30;
constexpr uint32_t kSleepTimeoutMs = 15UL * 60UL * 1000UL;
constexpr uint64_t kWakePinMask = 1ULL << kUpshiftPin;

BleKeyboard keyboard("MyWhooshShift", "DIY", 100);

class DebouncedButton {
 public:
  explicit DebouncedButton(uint8_t pin) : pin_(pin) {}

  void begin() {
    pinMode(pin_, INPUT_PULLUP);
    raw_state_ = digitalRead(pin_);
    stable_state_ = raw_state_;
    changed_at_ = millis();
  }

  bool pressed(uint32_t now) {
    const bool reading = digitalRead(pin_);

    if (reading != raw_state_) {
      raw_state_ = reading;
      changed_at_ = now;
    }

    if (stable_state_ != raw_state_ && now - changed_at_ >= kDebounceMs) {
      stable_state_ = raw_state_;
      return stable_state_ == LOW;
    }

    return false;
  }

 private:
  const uint8_t pin_;
  bool raw_state_ = HIGH;
  bool stable_state_ = HIGH;
  uint32_t changed_at_ = 0;
};

DebouncedButton upshift(kUpshiftPin);
DebouncedButton downshift(kDownshiftPin);
bool was_connected = false;
uint32_t last_activity_at = 0;

void sendAction(uint8_t key, const char* label) {
  if (!keyboard.isConnected()) {
    return;
  }

  keyboard.write(key);
  Serial.println(label);
}

void handleButton(DebouncedButton& button, uint8_t key, const char* label,
                  uint32_t now) {
  if (!button.pressed(now)) {
    return;
  }

  last_activity_at = now;
  sendAction(key, label);
}

bool allButtonsReleased() {
  return digitalRead(kUpshiftPin) == HIGH &&
         digitalRead(kDownshiftPin) == HIGH;
}

void sleepIfInactive(uint32_t now) {
  if (now - last_activity_at < kSleepTimeoutMs) {
    return;
  }

  // Never enter a low-level wake sleep while a button is already held.
  if (!allButtonsReleased()) {
    last_activity_at = now;
    return;
  }

  if (keyboard.isConnected()) {
    keyboard.releaseAll();
  }

  const esp_err_t result = esp_deep_sleep_enable_gpio_wakeup(
      kWakePinMask, ESP_GPIO_WAKEUP_GPIO_LOW);
  if (result != ESP_OK) {
    Serial.printf("Unable to configure button wake-up: %d\n", result);
    last_activity_at = now;
    return;
  }

  Serial.println("Inactive for 15 minutes; entering deep sleep.");
  Serial.flush();
  delay(20);
  esp_deep_sleep_start();
}

}  // namespace

void setup() {
  Serial.begin(115200);
  upshift.begin();
  downshift.begin();

  keyboard.setDelay(10);
  keyboard.begin();
  last_activity_at = millis();
  if (esp_sleep_get_wakeup_cause() == ESP_SLEEP_WAKEUP_GPIO) {
    Serial.println("Woken by Shift Up; release it, then press again to shift.");
  }
  Serial.println("MyWhoosh shifter ready; pair Bluetooth device 'MyWhooshShift'.");
}

void loop() {
  const uint32_t now = millis();
  const bool connected = keyboard.isConnected();

  if (connected != was_connected) {
    Serial.println(connected ? "Mac connected." : "Mac disconnected; advertising again.");
    if (connected) {
      keyboard.releaseAll();
    }
    was_connected = connected;
  }

  handleButton(upshift, kUpshiftKey, "Upshift (i)", now);
  handleButton(downshift, kDownshiftKey, "Downshift (k)", now);
  sleepIfInactive(now);
  delay(2);
}
