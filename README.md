# MyWhoosh ESP32-C3 Handlebar Shifter

A compact two-button Bluetooth Low Energy keyboard for shifting in **MyWhoosh on macOS**. The controller pairs directly with a MacBook and sends MyWhoosh's standard keyboard shortcuts:

- Upshift: `i`
- Downshift: `k`

No companion app or key remapping is required. The firmware, vendored BLE keyboard library, parametric enclosure source, and ready-to-slice STL files are all included.

## What you need

| Item | Qty | Notes |
| --- | ---: | --- |
| ESP32-C3 SuperMini | 1 | USB-C version; approximately 23.5 × 18.5 mm |
| 12 × 12 × 7.3 mm tactile switch | 2 | The common switches supplied with coloured caps |
| Thin stranded or silicone wire | — | Three conductors are enough when the buttons share ground |
| Zip tie, up to 5 mm wide | 2 | For the included 31.8 mm handlebar mount |
| USB-C cable and USB power source | 1 | Used for flashing and powering the controller |
| Printed bottom and lid | 1 each | PETG recommended |

You will also need a soldering iron and a computer with VS Code plus the PlatformIO extension (or the PlatformIO CLI).

## Repository layout

```text
.
├── platformio.ini                       # Reproducible ESP32-C3 build configuration
├── src/main.cpp                         # MyWhoosh shifter firmware
├── lib/ESP32_BLE_Keyboard/              # Vendored BLE HID keyboard library
└── mechanical/
    ├── mywhoosh-shifter-enclosure.scad  # Parametric enclosure source
    └── stl/
        ├── bottom.stl                   # Ready-to-slice handlebar body
        └── lid.stl                      # Ready-to-slice two-button lid
```

## Wiring

The firmware enables the ESP32's internal pull-up resistors, so each button connects its GPIO pin to ground when pressed.

| Function | ESP32-C3 SuperMini pin | Other switch terminal | Keystroke |
| --- | --- | --- | --- |
| Upshift | GPIO 3 | GND | `i` |
| Downshift | GPIO 4 | GND | `k` |

On a four-leg tactile switch, the two legs on each side are already connected internally. Use a leg from one side for GPIO and a leg from the opposite side for GND. The two switches may share one GND wire.

```text
GPIO 3 ─── [ UP button ] ───┐
                            ├── GND
GPIO 4 ── [ DOWN button ] ──┘
```

GPIO 3 and GPIO 4 avoid the ESP32-C3 SuperMini's usual boot-strapping pins. If you change the wiring, update `kUpshiftPin` and `kDownshiftPin` near the top of `src/main.cpp`.

## Build and flash

1. Clone or download this repository and open its root folder in VS Code.
2. Install the **PlatformIO IDE** extension if it is not already installed.
3. Connect the ESP32-C3 SuperMini over USB-C.
4. Select **PlatformIO: Upload**, or run:

   ```sh
   pio run --target upload
   ```

The first build downloads the pinned Espressif platform. The BLE keyboard library is already in this repository.

If uploading does not start, hold the board's **BOOT** button, tap **RESET**, release **BOOT**, and upload again. Serial diagnostics are available at 115200 baud:

```sh
pio device monitor
```

## Pair with the MacBook

1. Power the controller. USB from the Mac, a USB charger, or a small USB power bank all work.
2. On the Mac, open **System Settings → Bluetooth**.
3. Select **MyWhooshShift** when it appears and complete pairing. If Keyboard Setup Assistant opens, identify it as a standard ANSI keyboard.
4. Open TextEdit and press each shifter button once. The buttons should type `i` and `k`.
5. Open MyWhoosh, start a ride, keep the game window focused, and test both shifts.

The firmware sends one keystroke per physical press. Its 30 ms debounce logic prevents switch bounce and deliberately does not repeat when a button is held.

If the Mac has an older pairing saved under the same name, choose **Forget This Device**, restart the controller, and pair it again.

## Print the enclosure

Ready-to-slice files are in `mechanical/stl/`. The model is sized for a typical 23.5 × 18.5 mm ESP32-C3 SuperMini, 12 mm switches, 5 mm zip ties, and a 31.8 mm handlebar.

Recommended slicer settings:

- PETG for better heat and impact resistance; PLA is suitable for an indoor trainer
- 0.20 mm layer height
- 3 walls/perimeters
- 25–30% infill
- No supports
- Bottom: open side facing up
- Lid: flat outside face on the build plate

Print a small fit test if the dimensions of your ESP32 clone or button caps differ. The principal clearances are named at the top of `mechanical/mywhoosh-shifter-enclosure.scad`. To regenerate the supplied STLs with OpenSCAD:

```sh
openscad -o mechanical/stl/bottom.stl -D 'part="bottom"' mechanical/mywhoosh-shifter-enclosure.scad
openscad -o mechanical/stl/lid.stl -D 'part="lid"' mechanical/mywhoosh-shifter-enclosure.scad
```

## Assembly

1. Flash the ESP32 and confirm that it pairs before soldering it into the housing.
2. Solder GPIO 3 and GPIO 4 to their respective switches, then connect the opposite terminal of both switches to GND.
3. Press the switches into the guides on the underside of the lid. Use a small spot of hot glue if your switch bodies are undersized.
4. Slide the ESP32 into the board rails with its USB-C socket facing the case opening.
5. Route wires away from the lid skirt and snap the lid into the bottom.
6. Pass two zip ties through the paired floor slots, place the curved feet against the handlebar, and tighten evenly.

The enclosure is not waterproof. Sweat-resistant coating on the PCB and a thin gasket around the lid are sensible additions for heavy indoor use; do not block the USB opening if it remains your power connection.

## Battery power

The supplied enclosure is the compact USB-powered version. A small USB power bank is the simplest cordless power source.

Do **not** connect a bare LiPo directly to the ESP32's `5V` pin, and do not treat a TP4056 charger alone as a 5 V regulator. A built-in LiPo version needs a protected cell, a charger/power-path circuit, and a suitable regulated output (typically a 5 V boost supply into `5V`, or a board-specific battery input). Battery dimensions and protection boards vary, so they are intentionally not included in this fixed-size enclosure.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Device does not appear in Bluetooth | Confirm the board is powered; open the serial monitor and look for the ready message |
| It pairs but does not shift | Test in TextEdit, confirm lowercase `i`/`k`, and ensure MyWhoosh has keyboard focus |
| A button works backwards | Swap the GPIO 3/GPIO 4 wires or exchange `kUpshiftKey` and `kDownshiftKey` |
| Shifts happen without pressing | Check for a GPIO-to-GND short and verify the switch uses terminals from opposite sides |
| Upload port is missing | Use the BOOT/RESET sequence above and try a known data-capable USB cable |
| Lid or board fit is too tight | Increase `fit_clearance` or `board_clearance` in the SCAD file and regenerate the STL |

## Credits

BLE HID support is based on [T-vK's ESP32-BLE-Keyboard](https://github.com/T-vK/ESP32-BLE-Keyboard), vendored here so the firmware can be built from a clean checkout.
