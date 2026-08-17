# MyWhoosh ESP32-C3 Handlebar Controller

A printable Bluetooth Low Energy keyboard controller for **MyWhoosh on macOS**. Choose either a compact two-button shifter or a four-button shifter with steering. Both variants pair directly with a MacBook and require no companion app or keyboard remapping.

## Choose a variant

| Variant | Controls | Printed width | Folder |
| --- | --- | ---: | --- |
| Two button | Shift down `k`, shift up `i` | 64 mm | [`variants/two-button`](variants/two-button/) |
| Four button | Left Arrow, shift down `k`, shift up `i`, Right Arrow | 80 mm | [`variants/four-button`](variants/four-button/) |

Each variant folder contains its own firmware, parametric OpenSCAD enclosure, ready-to-slice bottom and lid STLs, and variant-specific instructions. Do not mix a bottom and lid from different variants because their lengths and snap positions differ.

## What you need

| Item | Two button | Four button | Notes |
| --- | ---: | ---: | --- |
| ESP32-C3 SuperMini | 1 | 1 | USB-C version; approximately 23.5 × 18.5 mm |
| 12 × 12 × 7.3 mm tactile switch | 2 | 4 | Common switches with coloured caps |
| Thin stranded or silicone wire | 3 conductors | 5 conductors | Buttons share one ground connection |
| Zip tie, up to 5 mm wide | 2 | 2 | Enclosure saddle is sized for a 31.8 mm handlebar |
| USB-C cable and USB power source | 1 | 1 | Used for flashing and power |

You will also need a soldering iron and VS Code with the PlatformIO extension, or the PlatformIO CLI.

## Repository layout

```text
.
├── platformio.ini                    # Two separate firmware environments
├── lib/ESP32_BLE_Keyboard/           # Shared vendored BLE HID library
└── variants/
    ├── two-button/
    │   ├── README.md
    │   ├── firmware/main.cpp
    │   └── mechanical/
    │       ├── enclosure.scad
    │       └── stl/{bottom,lid}.stl
    └── four-button/
        ├── README.md
        ├── firmware/main.cpp
        └── mechanical/
            ├── enclosure.scad
            └── stl/{bottom,lid}.stl
```

## Wiring

Every button connects its GPIO to GND when pressed. The firmware uses `INPUT_PULLUP`, so no external resistors are needed.

| Function | GPIO | MyWhoosh keystroke | Variant |
| --- | ---: | --- | --- |
| Shift up | 3 | `i` | Both |
| Shift down | 4 | `k` | Both |
| Steer left | 5 | Left Arrow | Four button only |
| Steer right | 6 | Right Arrow | Four button only |

On a four-leg tactile switch, the two legs on each side are already connected internally. Connect the GPIO to one side and GND to the opposite side. All buttons can share one GND wire.

GPIO 3–6 avoid the ESP32-C3 SuperMini's usual boot-strapping pins. The four-button firmware deliberately uses arrow keys rather than `a` and `d` for steering.

## Build and flash

Open the repository root in PlatformIO, connect the ESP32-C3 SuperMini over USB-C, then upload the firmware matching the enclosure you printed.

Two-button firmware:

```sh
pio run -e two-button --target upload
```

Four-button firmware:

```sh
pio run -e four-button --target upload
```

The four-button environment is the default when `-e` is omitted. The first build downloads the pinned Espressif platform; the BLE keyboard library is already included.

If uploading does not start, hold **BOOT**, tap **RESET**, release **BOOT**, and upload again. Serial diagnostics are available at 115200 baud with `pio device monitor`.

## Pair with the MacBook

1. Power the controller and open **System Settings → Bluetooth** on the Mac.
2. Select **MyWhooshShift** and complete pairing. If Keyboard Setup Assistant opens, identify it as a standard ANSI keyboard.
3. Test in TextEdit. Shift buttons type `i` and `k`; the four-button steering controls move the cursor left and right.
4. Open MyWhoosh, start a ride, keep the game focused, and test the controls.

Each input is debounced for 30 ms and sends one keystroke per physical press. A held button does not repeat. If an old pairing causes problems, choose **Forget This Device**, restart the controller, and pair it again.

## Print and assemble

Use the `bottom.stl` and `lid.stl` from the same variant folder. Recommended slicer settings:

- PETG preferred; PLA is suitable for an indoor trainer
- 0.20 mm layer height
- 3 walls/perimeters
- 25–30% infill
- No supports
- Bottom open side facing up
- Lid flat outside face on the build plate

The SCAD sources are parameterized for common 23.5 × 18.5 mm SuperMini boards, 12 mm switches, 5 mm zip ties, and 31.8 mm handlebars. Measure clone boards and switch caps before a full print.

Assembly is the same for either variant:

1. Flash and pair the board before soldering it into the enclosure.
2. Solder each GPIO to its assigned switch and connect the opposite switch terminals to a shared GND.
3. Fit switches into the guides beneath the labelled lid. Add a small spot of hot glue only if needed.
4. Slide the ESP32 into its rails with USB-C facing the side opening.
5. Route wires clear of the lid skirt and snap the matching lid into the bottom.
6. Pass two zip ties through the floor slots and tighten the saddle evenly against the handlebar.

The enclosure is not waterproof. Consider PCB conformal coating and a thin lid gasket for heavy indoor use.

## Power

The included cases are compact USB-powered designs. A small USB power bank is the simplest cordless source.

Do **not** connect a bare LiPo directly to `5V`, and do not use a TP4056 charger alone as a 5 V regulator. An internal battery version requires a protected cell, charger/power-path circuit, and suitable regulated output; battery dimensions vary and are not included in either enclosure.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Device does not appear | Confirm power and look for the ready message in the serial monitor |
| Controls do not work | Test in TextEdit and ensure MyWhoosh has keyboard focus |
| Shift direction is reversed | Swap GPIO 3/4 wires or the up/down key constants |
| Steering is reversed | Swap GPIO 5/6 wires or the left/right key constants |
| Actions occur without pressing | Check for GPIO-to-GND shorts and switch terminal orientation |
| Enclosure is too tight | Adjust `fit_clearance` or `board_clearance` in that variant's SCAD file |

## Credits

BLE HID support is based on [T-vK's ESP32-BLE-Keyboard](https://github.com/T-vK/ESP32-BLE-Keyboard), vendored here for reproducible builds.
