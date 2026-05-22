# DCS Quickstart

Five minutes from a working binary to your first simulated circuit.
If you haven't built DCS yet, see [INSTALL.md](./INSTALL.md) first.

## Your first circuit

1. **Launch the GUI:**
   ```
   ./dcs_gui.exe
   ```
2. **Open a demo.** *File → Open* → pick `circuits/01-and-gate.dcs`.
   You should see two `INPUT` boxes on the left, an AND gate in the
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

The numbered files in `circuits/` form a curated tour from one gate
to a full 8-bit array multiplier. See
[`circuits/README.md`](./circuits/README.md) for the full index.
Suggested order:

| # | File | What it shows |
|---|---|---|
| 01 | `01-and-gate.dcs` | The simplest possible circuit. |
| 03 | `03-half-adder.dcs` | Two-bit addition (sum + carry). |
| 04 | `04-multiplexer-2to1.dcs` | The digital "if/else". |
| 05 | `05-xor-from-primitives.dcs` | XOR built from AND/OR/NOT. |
| 06 | `06-full-adder.dcs` | Building block of every multi-bit adder. |
| 08 | `08-eight-bit-adder.dcs` | The largest 1-D demo. |
| 09 | `09-eight-bit-multiplier.dcs` | The largest demo overall. |

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
./dcs_cli.exe circuits/03-half-adder.dcs
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
