# Four-button MyWhoosh shifter and steering controller

This 82 × 38 mm variant provides shifting plus left/right steering.

| Lid position | Pro Micro pin | nRF52840 pin | Action |
| --- | --- | --- | --- |
| Far left, `<` | D2 | P0.17 | Steer left (Left Arrow) |
| Centre left, `−` | D3 | P0.20 | Shift down (`k`) |
| Centre right, `+` | D4 | P0.22 | Shift up (`i`) |
| Far right, `>` | D5 | P0.24 | Steer right (Right Arrow) |

```text
[ steer < ] [ shift down − ] [ shift up + ] [ steer > ]
```

Build the `mywhoosh_four_button` shield or download `mywhoosh-four-button.uf2` from the firmware artifact. Flashing, battery wiring, safety, printing, and assembly instructions are in the [root README](../../README.md).

Print both files in [`mechanical/stl`](mechanical/stl/). The parametric source is [`mechanical/enclosure.scad`](mechanical/enclosure.scad); it targets a nice!nano v2-compatible board and a nominal 301230 LiPo.

All controls use internal pull-ups, connect to shared GND, and can wake ZMK from deep sleep. No external pull-up resistor is required.
