#include <Arduino.h>
#include <BleKeyboard.h>

namespace {

constexpr uint8_t kUpshiftPin = 3;
constexpr uint8_t kDownshiftPin = 4;
constexpr char kUpshiftKey = 'i';
constexpr char kDownshiftKey = 'k';
constexpr uint32_t kDebounceMs = 30;

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

void sendShift(char key, const char* label) {
  if (!keyboard.isConnected()) {
    return;
  }

  keyboard.write(static_cast<uint8_t>(key));
  Serial.printf("%s (%c)\n", label, key);
}

}  // namespace

void setup() {
  Serial.begin(115200);
  upshift.begin();
  downshift.begin();

  keyboard.setDelay(10);
  keyboard.begin();
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

  if (upshift.pressed(now)) {
    sendShift(kUpshiftKey, "Upshift");
  }
  if (downshift.pressed(now)) {
    sendShift(kDownshiftKey, "Downshift");
  }

  delay(2);
}
