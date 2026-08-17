# Four-button MyWhoosh shifter and steering controller

This variant provides shifting plus left/right steering.

| Lid position | GPIO | Action |
| --- | ---: | --- |
| Far left, `<` | 5 | Steer left (Left Arrow) |
| Centre left, `-` | 4 | Shift down (`k`) |
| Centre right, `+` | 3 | Shift up (`i`) |
| Far right, `>` | 1 | Steer right (Right Arrow) |

```text
[ steer < ] [ shift down - ] [ shift up + ] [ steer > ]
```

All four buttons sit in one line over the handlebar axis. This rectangular layout reduces rocking when an outside button is pressed.

Build and upload from the repository root:

```sh
pio run -e four-button --target upload
```

Print both files in `mechanical/stl/`; the matching parametric source is `mechanical/enclosure.scad`. Connect each button between its GPIO and the shared GND connection.

After 15 minutes without a button press, the firmware enters deep sleep. Any of the four controls wakes it. The first press is wake-only; release it, wait for Bluetooth to reconnect, then press again for the action. Add a 10 kΩ pull-up from GPIO1, GPIO3, GPIO4, and GPIO5 to `3V3` for reliable wake-up.

This is a battery-powered build. Follow the root README's battery wiring and safety section: the protected TP4056 output must feed a regulated 5 V boost converter before the ESP32 `5V` pin. Confirm the chosen cell and power modules fit without pressure on the LiPo pouch before printing or final assembly.
