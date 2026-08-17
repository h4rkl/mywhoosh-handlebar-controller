# Two-button MyWhoosh shifter

This compact variant provides shifting only.

| Lid position | GPIO | Action |
| --- | ---: | --- |
| Left, `-` | 4 | Shift down (`k`) |
| Right, `+` | 3 | Shift up (`i`) |

Build and upload from the repository root:

```sh
pio run -e two-button --target upload
```

Print both files in `mechanical/stl/`; the matching parametric source is `mechanical/enclosure.scad`. Connect each button between its GPIO and the shared GND connection.
