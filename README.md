# MyWhoosh nRF52840 handlebar controller

A printable, rechargeable Bluetooth Low Energy keyboard controller for **MyWhoosh on macOS**. It uses a nice!nano v2-compatible nRF52840 Pro Micro board and ZMK firmware. Choose either a compact two-button shifter or a four-button shifter with steering.

![Wiring schematic](wiring-schematic.png)

## Variants

| Variant | Controls | Printed footprint | Firmware shield | Folder |
| --- | --- | ---: | --- | --- |
| Two button | Shift down `k`, shift up `i` | 80 × 38 mm | `mywhoosh_two_button` | [`variants/two-button`](variants/two-button/) |
| Four button | Left Arrow, `k`, `i`, Right Arrow | 82 × 38 mm | `mywhoosh_four_button` | [`variants/four-button`](variants/four-button/) |

Do not mix a bottom and lid from different variants. Their lengths, button positions, and snap locations differ.

## Parts

| Item | Two button | Four button | Notes |
| --- | ---: | ---: | --- |
| nice!nano v2-compatible nRF52840 Pro Micro board | 1 | 1 | USB-C, onboard single-cell LiPo charging, UF2-compatible bootloader required; enclosure assumes the bare board without the supplied straight headers |
| 12 × 12 × 7.3 mm tactile switch with cap | 2 | 4 | Normally-open through-hole type |
| Protected rechargeable 3.7 V LiPo | 1 | 1 | Reference enclosure bay is for a nominal 301230 cell, about 30 × 12 × 3 mm; use it only after confirming the clone's charge current is allowed by the cell datasheet |
| Matching 2-pin battery pigtail | 1 | 1 | Optional but preferable to permanently soldering the battery; verify polarity |
| Thin stranded or silicone wire | as needed | as needed | One wire per input plus a shared ground |
| Zip tie, up to 5 mm wide | 2 | 2 | Enclosure saddle is sized for a 31.8 mm handlebar |
| USB-C data cable | 1 | 1 | Used for flashing and charging |

The TP4056 charger, 5 V boost converter, external wake resistor, and ESP32-C3 board used by the earlier design are not required.

## Electrical design

Every button connects one input pin to GND when pressed. ZMK enables the internal pull-ups, debounces both edges for 30 ms, and configures the inputs as wake sources.

| Function | Pro Micro pin | nRF52840 pin | Clone silkscreen | MyWhoosh keystroke | Variant |
| --- | --- | --- | --- | --- | --- |
| Steer left | D2 | P0.17 | `017` | Left Arrow | Four button only |
| Shift down | D3 | P0.20 | `020` | `k` | Both |
| Shift up | D4 | P0.22 | `022` | `i` | Both |
| Steer right | D5 | P0.24 | `024` | Right Arrow | Four button only |

The key actions are short taps rather than held HID keys, so holding a physical button does not cause keyboard repeat. After 15 minutes without an input, ZMK enters deep sleep. Pressing **any** control wakes it; the wake press may also be delivered after reconnection, so test this behavior with the exact clone and host before riding.

On a four-leg tactile switch, the two legs on each side are connected internally. Attach the input to one side and GND to the opposite side. All controls share one GND wire.

## Battery and charging

Use only a rechargeable single-cell 3.7 V LiPo with the board's battery input. The photographed clone marks positive as `B+` and negative as `B−`; charge through USB-C after the completed wiring has been checked. Its listing confirms charge management but does not specify the charge current, so do not assume the genuine nice!nano v2 value applies and do not bridge any unidentified charger-current jumper.

The specified board is a compatible clone, so identify and verify these points before assembly:

- Confirm the board is actually an nRF52840 nice!nano v2 pinout-compatible design.
- Confirm the charger IC and charge current from a seller schematic, component markings, or a controlled measurement before choosing the cell.
- Check battery-connector polarity with a multimeter. Matching JST housings do not guarantee matching polarity.
- Use a cell whose manufacturer permits the board's confirmed charge current. `301230` describes the approximate physical size, not a guaranteed capacity or safe charge rate; the label and cell datasheet take precedence.
- Never connect a CR2032 or another non-rechargeable battery to `B+`/`B−`; USB would make the onboard circuit attempt to charge it.
- Do not connect a TP4056 or 5 V boost converter to the battery pads.
- Do not bend, crush, puncture, solder directly to, or tightly clamp the pouch. Stop using a swollen, damaged, hot, or leaking cell.

The battery bay is a loose locator, not a press fit. Measure the complete protected pouch, protection tab, leads, and connector before printing. Adjust `battery_length`, `battery_width`, `battery_height`, and `battery_clearance` in the selected `enclosure.scad` if necessary; `battery_height` automatically raises the case when the standard 15 mm body is no longer tall enough.

## Firmware

The repository is a ZMK user-config module. The custom shield definitions are in [`boards/shields/mywhoosh_shifter`](boards/shields/mywhoosh_shifter/), and [`build.yaml`](build.yaml) produces:

- `mywhoosh-two-button.uf2`
- `mywhoosh-four-button.uf2`
- `nice-nano-settings-reset.uf2`

### Build with GitHub Actions

Push the repository to GitHub and open the **Build ZMK firmware** workflow. Download the `firmware` artifact after the workflow succeeds.

### Build locally with Docker

With Docker running:

```sh
./scripts/build-firmware.sh
```

The UF2 files are written to `build/firmware/`. The first build downloads the pinned ZMK `v0.3` workspace and can take several minutes.

### Flash

1. Flash the bare, unwired board before attaching buttons or the battery. The supplied factory `Blink-All-IO` program toggles every GPIO and is not safe to leave running with button-to-GND wiring attached.
2. Connect the board to the Mac with a USB-C data cable.
3. Enter the bootloader by briefly bridging the adjacent `RST` and `GND` pads twice within 0.5 seconds. A reset button can be double-pressed only if a separate keyboard carrier provides one; none is visible on the bare board shown.
4. Copy the correct UF2 to the USB storage volume exposed by the bootloader. A genuine board names it `NICENANO`; clones may use another name.
5. Wait for the board to reboot, then unplug USB.

If old bonding data prevents pairing, flash `nice-nano-settings-reset.uf2` once and then immediately flash the normal variant UF2 again.

## Pair and test

1. Open **System Settings → Bluetooth** on the Mac.
2. Select **MyWhooshShift** and complete pairing.
3. Test in TextEdit: shift buttons type `k` and `i`; the four-button steering controls move the cursor left and right.
4. Let the controller sleep for at least 15 minutes, then confirm every control wakes and reconnects correctly.
5. Open MyWhoosh, start a ride, keep the game focused, and test all actions before mounting the controller.

If firmware changes alter the HID descriptor or pairing becomes stale, forget the device on macOS, clear the board settings with the reset UF2, and pair again.

## Print and assemble

Use `bottom.stl` and `lid.stl` from the same variant. Suggested slicer settings:

- PETG preferred; PLA is suitable for an indoor trainer
- 0.20 mm layer height
- 3 walls/perimeters
- 25–30% infill
- No supports
- Bottom open side facing up
- Lid flat outside face on the build plate

The OpenSCAD sources use a 34 × 18.5 × 5 mm maximum board envelope and a 30.5 × 12.5 × 3.5 mm battery locator. Compatible clones and protected cells vary, so measure both before printing. The board is installed with USB-C at the case opening and the PCB antenna at the battery-facing end; keep the designed air gap free of foil, metal, and excess wire.

Assembly order:

1. Flash and test the bare controller over USB.
2. Prototype the buttons without the battery and confirm the expected keys.
3. Solder D2–D5 as applicable and one shared GND. Keep joints and clipped leads away from the LiPo.
4. If using a battery pigtail, solder it to `B+` and `B−`, insulate both joints, and verify its polarity before connecting the cell.
5. Fit the switches into the lid guides. Add only a small amount of hot glue if a switch is loose.
6. Slide the controller into its rails with USB-C facing the end opening.
7. Place the measured battery loosely within its bay, with the wire end facing the controller. Use a small piece of thin removable foam tape if restraint is needed; do not compress the pouch.
8. Route every wire clear of the snap skirt, USB connector, board antenna, and battery surface. Snap the lid on without force.
9. Pass two zip ties through the floor slots and tighten the saddle evenly against the handlebar.

Keep the antenna end of the controller clear of foil, metal fasteners, and bundled wiring. The enclosure is not waterproof.

## Regenerate printed files

Set `part` in the selected SCAD source or override it on the command line:

```sh
openscad -D 'part="bottom"' -o bottom.stl enclosure.scad
openscad -D 'part="lid"' -o lid.stl enclosure.scad
```

## Repository layout

```text
.
├── .github/workflows/build.yml
├── boards/shields/mywhoosh_shifter/    # ZMK hardware and keymap definitions
├── build.yaml                           # Two controllers plus settings-reset UF2
├── config/west.yml                      # Pinned ZMK manifest
├── scripts/build-firmware.sh            # Reproducible local Docker build
├── wiring-schematic.{svg,png}
└── variants/
    ├── two-button/
    │   └── mechanical/{enclosure.scad,stl/}
    └── four-button/
        └── mechanical/{enclosure.scad,stl/}
```

## Troubleshooting

| Symptom | Check |
| --- | --- |
| No bootloader drive | Use a data cable; bridge `RST` to adjacent `GND` twice within 0.5 seconds; check whether the clone shipped with a UF2 bootloader |
| Device does not appear in Bluetooth | Flash the correct UF2, disconnect USB, verify battery polarity/voltage, and clear settings if necessary |
| Wrong or missing control | Check the D2–D5 table, shared GND continuity, and switch terminal orientation |
| Repeated random actions | Check for GPIO-to-GND shorts, pinched wires, moisture, or an incorrectly fitted switch |
| Battery does not charge | Disconnect immediately if anything heats; verify clone charger design, USB cable, cell polarity, and allowed charge current |
| Enclosure does not close freely | Do not force it; measure the clone and cell, then adjust the corresponding SCAD dimensions |

ZMK firmware is provided by the [ZMK project](https://zmk.dev/). Board power guidance is based on the [nice!nano documentation](https://nicekeyboards.com/docs/nice-nano/); verify clone-specific differences with the seller's schematic.
