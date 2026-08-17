# Four-button MyWhoosh shifter and steering controller

This variant provides shifting plus left/right steering.

| Lid position | GPIO | Action |
| --- | ---: | --- |
| Far left, `<` | 5 | Steer left (Left Arrow) |
| Centre left, `-` | 4 | Shift down (`k`) |
| Centre right, `+ / power` | 3 | Shift up (`i`) and wake |
| Far right, `>` | 1 | Steer right (Right Arrow) |

```text
[ steer < ] [ shift down - ] [ shift up + / power ] [ steer > ]
```

All four buttons sit in one line over the handlebar axis. This rectangular layout reduces rocking when an outside button is pressed.

Build and upload from the repository root:

```sh
pio run -e four-button --target upload
```

Print both files in `mechanical/stl/`; the matching parametric source is `mechanical/enclosure.scad`. Connect each button between its GPIO and the shared GND connection.

After 15 minutes without a button press, the firmware enters deep sleep. Only the Shift Up control marked `+ / power` wakes it. The first press is wake-only; release it, wait for Bluetooth to reconnect, then press again to shift. Add a 10 kΩ pull-up from GPIO3 to `3V3` for reliable wake-up; the other three controls use their internal pull-ups.

This is a battery-powered build. Follow the root README's battery wiring and safety section: the protected TP4056 output must feed a regulated 5 V boost converter before the ESP32 `5V` pin. Confirm the chosen cell and power modules fit without pressure on the LiPo pouch before printing or final assembly.
