# DCS demo circuits

A curated tour from one gate to a 16-bit-output multiplier. Each file
starts with a `# Demo:` header explaining what it shows. Open any of
them in `dcs_gui.exe` (*File → Open*) or pass them to `dcs_cli.exe`
for a headless truth table.

## The numbered tour

| # | File | Inputs / Outputs | What it demonstrates |
|---|---|---|---|
| 01 | [`01-and-gate.dcs`](./01-and-gate.dcs) | 2 / 1 | The simplest two-input primitive. |
| 02 | [`02-not-gate.dcs`](./02-not-gate.dcs) | 1 / 1 | One-input inverter. |
| 03 | [`03-half-adder.dcs`](./03-half-adder.dcs) | 2 / 2 | First composite: sum + carry from two bits. |
| 04 | [`04-multiplexer-2to1.dcs`](./04-multiplexer-2to1.dcs) | 3 / 1 | The digital "if/else": select between two inputs. |
| 05 | [`05-xor-from-primitives.dcs`](./05-xor-from-primitives.dcs) | 2 / 1 | XOR built from AND/OR/NOT — compare with the `xor()` primitive. |
| 06 | [`06-full-adder.dcs`](./06-full-adder.dcs) | 3 / 2 | Adds three bits using XOR — the building block of bits 1..7 of the larger adders. |
| 07 | [`07-four-bit-adder.dcs`](./07-four-bit-adder.dcs) | 9 / 5 | Four full-adders chained: A[3..0] + B[3..0] + Cin. |
| 08 | [`08-eight-bit-adder.dcs`](./08-eight-bit-adder.dcs) | 16 / 9 | Same pattern at 8 bits — the largest 1-D demo. |
| 09 | [`09-eight-bit-multiplier.dcs`](./09-eight-bit-multiplier.dcs) | 16 / 16 | 8×8 unsigned array multiplier. Largest curated demo — exercises the v1.0.0 DOMAIN_MAX_IO bump (16→32) and the channelled auto-layout (U-41). |

## Recommended order

1. **01 → 03** — feel out the GUI: place, wire, toggle, save.
2. **04** — see how selection logic falls out of primitives.
3. **05** — same XOR truth-table, two implementations. Try replacing
   the chain with the `xor()` toolbar button.
4. **06 → 08** — the adder family. Each step roughly doubles in size;
   notice how auto-layout keeps the carry chain readable.
5. **09** — open in the GUI and zoom out. The 8-bit multiplier is the
   stress test for layout and routing at the v1.0.0 scale ceiling.

## Supplementary fixtures

Files at the original primitive names (`or_gate.dcs`, `nand_gate.dcs`,
`nor_gate.dcs`, `xor_gate.dcs`, `demo1-and3.dcs`, `adder2bit.dcs`,
`dff_stub.dcs`) remain in this directory. They double as test fixtures
(see `test/test_circuit_canvas_supplement.c`'s no-crossings invariant
and `test/test_cli.sh`) and serve as additional per-primitive
references; they are not part of the curated tour.

`adder2bit.dcs` is intentionally excluded from the no-crossings
fixture set — its nested carry chain exposes multi-obstacle routing
cases the v1.0.0 dynamic H-stub detour doesn't yet resolve. Tracked
as a follow-up.
