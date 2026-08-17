# Two-button MyWhoosh shifter

This 74 × 38 mm variant provides shifting only.

| Lid position | Pro Micro pin | nRF52840 pin | Action |
| --- | --- | --- | --- |
| Left, `−` | D3 | P0.20 | Shift down (`k`) |
| Right, `+` | D4 | P0.22 | Shift up (`i`) |

Build the `mywhoosh_two_button` shield or download `mywhoosh-two-button.uf2` from the firmware artifact. Flashing, battery wiring, safety, printing, and assembly instructions are in the [root README](../../README.md).

Print both files in [`mechanical/stl`](mechanical/stl/). The parametric source is [`mechanical/enclosure.scad`](mechanical/enclosure.scad); it targets a nice!nano v2-compatible board and a nominal 301230 LiPo.

Both controls use internal pull-ups, connect to shared GND, and can wake ZMK from deep sleep. No external pull-up resistor is required.
