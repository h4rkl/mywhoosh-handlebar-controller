# Four-button MyWhoosh shifter and steering controller

This variant provides shifting plus left/right steering.

| Lid position | GPIO | Action |
| --- | ---: | --- |
| Far left, `<` | 5 | Steer left (Left Arrow) |
| Centre left, `-` | 4 | Shift down (`k`) |
| Centre right, `+` | 3 | Shift up (`i`) |
| Far right, `>` | 6 | Steer right (Right Arrow) |

Build and upload from the repository root:

```sh
pio run -e four-button --target upload
```

Print both files in `mechanical/stl/`; the matching parametric source is `mechanical/enclosure.scad`. Connect each button between its GPIO and the shared GND connection.
