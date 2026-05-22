# DCS Quickstart

Five minutes from a working binary to your first simulated circuit.
If you haven't built DCS yet, see [INSTALL.md](./INSTALL.md) first.

## Your first circuit

1. **Launch the GUI:**
   ```
   ./dcs_gui.exe
   ```
2. **Open a demo.** *File → Open* → pick `circuits/and_gate.dcs`. You
   should see two `INPUT` boxes on the left, an AND gate in the
   middle, and one `OUTPUT` box on the right, all wired up.
3. **Toggle inputs.** Click each `INPUT` in the side panel to flip
   it between 0 and 1. The output updates as soon as both inputs go
   high.
4. **Place a new gate.** Click an OR / NAND / XOR / … button in the
   toolbar, then click on the canvas where you want it to land.
5. **Connect wires.** Click an output pin, then click an input pin.
   DCS auto-routes the wire (orthogonal segments, snapped to an 8 px
   grid).
6. **Run a timing simulation.** Press the **Run** button. The bottom
   panel draws the waveform for every input combination.
7. **Save.** `Ctrl+S` writes the circuit (components + wires +
   layout) back to a `.dcs` file. The format is plain text — open it
   in any editor and have a look.

## Demos to explore next

| File | What it shows |
|---|---|
| `circuits/and_gate.dcs` | The simplest possible circuit. |
| `circuits/or_gate.dcs`, `nor_gate.dcs`, `xor_gate.dcs` | Each primitive in isolation. |
| `circuits/half_adder.dcs` | Two-bit addition (sum + carry). |
| `circuits/adder2bit.dcs` | Two-bit adder built from primitives. |
| `circuits/adder8bit.dcs` | The largest packaged demo. |

## Handy keys & shortcuts

- **F1** — open the in-GUI keyboard / mouse reference.
- **Ctrl+S** — save.
- **Ctrl+Z** / **Ctrl+Y** — undo / redo (every mutation is labelled,
  so the menu shows what you're undoing).
- **Ctrl+A** — select all.
- **Del** — delete the current selection.
- **Arrow keys** — nudge the selection 1 px.
- **ESC** — cancel the current mode (placement / wire / marquee).

## Headless / batch use

For automated runs (regression scripts, CI, AI-assisted authoring):

```
./dcs_cli.exe circuits/half_adder.dcs
```

Sweeps every input combination and prints the truth table. Run
`./dcs_cli.exe --help` for options, or `--help-format` for an
AI-friendly spec of the `.dcs` grammar.

## Where to go from here

- Edit a demo, save, then open the `.dcs` file in a text editor to
  see how DCS persists components, wires, and layout.
- Read [history.md](./history.md) for the design trail behind every
  feature you just used.
- See `CHANGELOG.md` for what landed in this release and what's
  planned next.
