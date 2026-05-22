# Changelog

All notable changes to DCS (Digital Circuit Simulation) are recorded
here. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Section conventions:
- **Added** — new capabilities.
- **Changed** — modifications to existing capabilities.
- **Fixed** — bug fixes.
- **Removed** — capabilities taken out (none yet).

---

## [1.0.0] - TBD

<!-- Date is set at tag time; see docs/step3-implementation-plan.md Stage 13. -->

The first numbered release: teacher-demo ready. Combines the Step 2
supplement refinement work (R-* items) with the Step 3 v1.0.0
engineering scope (U-* items) — layer-rule cleanup, app-layer tests,
visible undo descriptions, channelled auto-layout, IEC/ANSI gate
shapes via a shape DSL, gate-shape toolbar icons, and four new
primitive gates.

### Added

- **NAND / NOR / XOR / XNOR primitives** (U-45). Four new
  `component_kind_t` values with their own gate files. Toolbar grows
  from 5 to 9 place buttons; XOR demo collapses from 6 components
  to 1. `# XOR a b` parses; `y = xor(a, b)` round-trips.
- **ANSI/IEEE gate shapes via shape DSL** (U-21). New
  `src/framework/shape.{h,c}` (`LINE`, `CIRCLE`, `ARC` ops) renders
  every primitive via a `static const shape_op_t[]` table accessed
  through `component_vt_t::shape()`. AND semicircle, OR concave back
  + convex front, NOT triangle + inversion bubble, plus NAND/NOR/
  XOR/XNOR variants all draw from data, not switch statements.
- **Gate-shape toolbar icons** (U-26). Each place button renders a
  32×24 miniature of its gate shape on the left of the label;
  INPUT/OUTPUT get filled circles matching their canvas appearance.
- **Per-mutation undo descriptions** (U-33). Each canvas mutation
  emits a labelled snapshot (`"wired"`, `"deleted gate"`, `"nudged"`,
  …), so the Edit menu / status bar shows `Undid: wired` instead of
  a generic `Undid: edit`.
- **Channelled hierarchical auto-layout** (U-41). Auto-layout now
  computes V/H channel rects between component columns/rows; the
  wire router consults them and uses a dynamic obstacle-aware y
  finder (`find_clear_y_for_h_stub`) plus 16 px clearance padding so
  H stubs detour around gates that sit on the natural channel line.
  Column overflow into adjacent sub-columns (`LAYOUT_MAX_PER_COL = 128`)
  lets wide circuits scale without piling.
- **Wire router obstacle avoidance** (U-40). V-bus midpoints and
  Z-route mid-x positions shift outward in routing-grid steps when
  they would otherwise land inside a component bounding box. Combined
  with U-41 above, eliminates wire-through-gate visual errors on the
  primitive demos.
- **App-layer test scaffold** (U-5). New `test/test_dcs_app.c`
  driving `dcs_app_t` through a stub `iplatform_t*` + stub
  `igraph_t*` — exercises init/release, dirty-flag tracking,
  command-stack state, title-bar formatting. 14 cases.
- **XOR regression fixture + no-crossings invariant** (Stage 4B.5).
  `test_circuit_canvas_supplement` loads each `circuits/*.dcs`, runs
  `auto_layout` + `reseat_wires` through the canvas, and asserts
  that no wire segment's strict interior intersects any component
  bbox. 8 / 8 small fixtures pass.
- **Ctrl+Z / Ctrl+Y + Edit menu** (R-5). Command-pattern undo stack
  with snapshot-based undo/redo covering every canvas mutation site.
- **Save-on-close prompt** (R-11). New
  `iplatform_t::confirm_yes_no_cancel` seam (Windows `MB_YESNOCANCEL`)
  and quit-manager `on_attempt` callback gate the quit decision when
  the dirty flag is set.
- **Window title shows current file + dirty marker** (R-10). New
  `igraph_t::set_window_title` seam; canvas mutation funnel refreshes
  the title and status bar on every structural / geometric change.
- **Ctrl+A select-all + Del delete-selection + Arrow-key 1-px nudge**
  (R-12, R-13, R-19). Three new canvas operations dispatched as
  global shortcuts from `dcs_app::poll_global_shortcuts`.
- **Help menu + F1 reference dialog** (R-14). In-GUI keyboard /
  mouse reference; uses the framework's `label` + `panel` widgets.
- **Version system + tamper signature + About menu** (R-15).
  `src/version.h` (manual) + generated `src/build_info.c` (commit
  hash, build date, SHA-256 over source tree). `build.sh` wraps the
  Makefile to set the build mode and embed the signature. CLI has
  `--version`; GUI has Help → About.
- **Rich CLI `--help-format`** (R-16). Emits a structured prompt
  describing the `.dcs` grammar — usable for AI-assisted circuit
  authoring.
- **Display-name first-class** (R-1 part 1). Title bar and status
  bar show display-name (`# @display_name`) when set, basename
  otherwise. (In-GUI edit deferred to a later release.)

### Changed

- **`DOMAIN_MAX_IO`** raised from 16 to **32** (U-39 step 1). Enough
  for 8-bit adder / 8-bit multiplier demos. Cap stays static; a
  dynamic-allocation refactor is deferred to v1.2.0.
- **`circuit_io_serialize` uses a growable buffer.** Replaces the
  static `4096 + N·256 + (in+out)·96` cap with a doubling buffer
  applying the realloc-and-NULL-check pattern at every push site
  (U-2).
- **OR-gate shape geometry rederived** so back-arc input pins and
  front-arc output pin are visually sealed. Two short LINE stubs
  added on the input side so the canvas pins read as real input
  leads crossing the OR's concave back. (U-21 visual iteration.)
- **AND / OR body shrunk for NAND / NOR** so the inversion bubble
  fills the (+0.7, +1.0) range with its right edge at the output
  pin position. Pin positions stay identical across all 7 gate
  kinds; routing math is kind-agnostic.
- **Sidebar BLACK-BOX toggle prominence** (R-2). Larger button,
  clearer state indication.
- **`ccw_mutated_fn_t`** signature widened to
  `(void *user, const char *label)`. Twelve canvas mutation sites
  each pass an action-specific label; `snapshot_describe` returns it.
- **Native dialogs centred on the GUI window** via Win32 CBT hook +
  owner HWND. Save-on-close and File-Open / Save-As dialogs no
  longer pop in the screen centre away from the app window.
- **`tagt_` prefix** applied to remaining struct typedefs (U-1) for
  consistency with the convention in CLAUDE.md §4.2.

### Fixed

- **Silent placement failure when `wire_cap` is exhausted.** The
  canvas now reports the limit instead of dropping the placement
  attempt silently.
- **ESC quitting the program** caused by raylib's built-in
  `WindowShouldClose() == ESC` behaviour. `SetExitKey(KEY_NULL)`
  + global routing through `cancel_mode` fix it.
- **Del / ESC key dispatch** — the framework's
  `focus_manager`-driven event routing was never wired up
  (`focus_manager_set` is never called anywhere); both keys are now
  routed globally from `dcs_app`. The dead-code finding is tracked
  as R-18 for proper Step-3 resolution.
- **`waveform_get_track` / `set_value` NULL guards** (U-3) — callers
  that build a waveform with zero steps no longer crash.
- **Auto-align invisible on file open** — stale `@wires` masked the
  effect; now reseated after auto-align too.

### Known limitations (intentionally deferred)

- `circuits/adder2bit.dcs`, `adder4bit.dcs`, `adder8bit.dcs` are NOT
  in the no-crossings fixture set — they expose multi-obstacle
  routing cases the dynamic finder doesn't yet resolve. Tracked for
  post v1.0.0-rc2.
- Multi-delete still emits N snapshots (one per deleted node); a
  single undo step covering the whole multi-delete is deferred.
- Layout and routing are still single hard-coded implementations
  (U-46 makes them pluggable strategies in v1.1.0).
- `DOMAIN_MAX_IO` remains static at 32; dynamic cap is v1.2.0.

### Stats

| Metric | v0.3 | v1.0.0 |
|---|---|---|
| Tests | 518 | **931** (+413) |
| Test suites | 8 | 9 (+ `test_shape`) |
| Source files in `src/` | 29 | 36 |
| Primitive gate kinds | 3 | 7 |
| Toolbar place buttons | 5 | 9 |

---

## [0.3.0] - 2026-04 (Step 2 supplement, Phases 1–13)

Adds orthogonal wire routing, persisted wire geometry, internal /
external display modes, and overall move toward IEC schematic
convention. Implementation tracked in
[`docs/step2-supplement-implementation-summary.md`](docs/step2-supplement-implementation-summary.md).

### Added

- **Wire-geometry sidecar** (`src/app/wire_geometry.{h,c}`). Per-net
  segment lists with H/V invariant, atomicity on rejection,
  capacity growth, double-release safety.
- **Z-router** (`auto_route_wire`) — H, V, or three-segment Z with
  midpoint x snapped to the 8 px routing grid.
- **Renderer uses geometry.** Two-pass wire pass: routed segments
  first, direct-line fallback for any consumer whose net has no
  geometry.
- **Mutation hooks reseat geometry** on place / connect / disconnect
  / delete / drag-end so wires stay routed during interactive use.
- **Junction dots at electrical joins** drawn where ≥3 segments
  meet at a net point.
- **Click-to-highlight a net** — clicking any segment selects the
  whole net; renders in highlight colour until cancelled.
- **`# @wires` annotation** persists per-net segment lists in `.dcs`
  files. Round-trips byte-identical for legacy files (no `@wires`
  block emitted when geometry matches auto-route).
- **Internal / external display modes** with per-component
  `# @display_mode` and per-pin `# @pin_style` annotations.
  External view collapses a component to a single labelled box with
  configurable pin styles (e.g. clock-edge triangle).
- **Wire bend-point drag** — users can grab any wire segment vertex
  and move it; the renderer re-routes the affected segments live.
- **Shared trunks for fan-out wires** (Phase 13). One V bus per net,
  per-consumer H stub into the pin (Steiner Z arrival).
- **IEC-style schematic refresh** (Phase 11). Component bodies, pin
  hashes, junction dots, label placement all moved toward IEC
  visual convention.

### Changed

- Wire data model shifted from "consumer → producer direct line" to
  per-net segment lists, opening the door to user-routed wires and
  multi-consumer fan-out.

### Fixed

- Snap-collapse edge case in `auto_route_wire`: when the snapped
  midpoint lands exactly on producer or consumer x, the path is
  nudged one grid step so all three segments stay non-degenerate.

---

## [0.2.0] - 2026-02 (Step 2 layered refactor, Phases 2.0–2.6)

Rebuilds the prototype on a three-layer architecture
(`framework/` / `domain/` / `app/`) with platform and graphics
abstracted behind `iplatform_t` and `igraph_t` interfaces. The
prototype is preserved verbatim under `prototype_version/`. Details
in [`docs/step2-refactor-design.md`](docs/step2-refactor-design.md).

### Added

- **`framework/core/`** — OO macros (`class`, `interface`), `rect_t`,
  `color_t`, `message_t`, `focus_manager`, `quit_manager`.
- **`framework/platform/`** — `iplatform_t` interface + Windows
  implementation (`platform_windows.c`). Linux skeleton for future
  port.
- **`framework/graphics/`** — `igraph_t` interface + raylib
  implementation (`graph_raylib.c`).
- **`framework/widgets/`** — widget base, `panel`, `button`,
  `label`, `menu`, `splitter`, `frame`, `canvas_widget`,
  `divider_widget`.
- **`domain/`** — pure-logic rewrite of `component`, `circuit`,
  `simulation`, `circuit_io`. Headlessly testable.
- **`app/`** — DCS-specific composition (`dcs_app`,
  `circuit_canvas_widget`, `input_panel`). The only layer that
  knows both framework and domain.
- **`# @layout` annotation block** in `.dcs` — round-trip tested.
- **Entry points.** `gui/main.c` wires platform + graph + dcs_app;
  `cli/main.c` wires platform + domain. New CLI executable.
- **Test suites.** `test_circuit`, `test_circuit_io`, `test_widgets`,
  `test_iplatform`, `test_igraph`, `test_cli.sh`.

### Changed

- All app code stripped of direct raylib / Win32 references — every
  OS / drawing call now goes through the interface seams.
- File format gains the `# @<name>` annotation grammar; the parser
  is forward-compatible (ignores unknown annotations silently).

---

## [0.1.0] - 2026-01 (Step 1 prototype)

Initial prototype, frozen at commit `4a24207` under
`prototype_version/`. Self-contained — `cd prototype_version &&
make test` runs 98 tests. Reference baseline; **not modified
after the snapshot**.

### Added

- **Phase 1 simulation engine.** AND / OR / NOT primitives, fixed
  combinational evaluation, basic timing.
- **Phase 1.2 `.dcs` parser + serializer** with fixture circuits.
- **Phase 1.3 CLI executable** with timing-table output.
- **Phase 1.4 raylib GUI viewer** with auto-layout canvas.
- **Phase 1.5 interactive GUI editor** — sidebar, Ctrl+S save,
  marquee selection, group move, native File menu, draggable
  canvas / panel divider.
- **Phase 1.6 inputs panel, RUN action, timing-diagram waveform.**

---

[1.0.0]: https://github.com/tommy2lion/dcs/releases/tag/v1.0.0
[0.3.0]: https://github.com/tommy2lion/dcs/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/tommy2lion/dcs/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/tommy2lion/dcs/releases/tag/v0.1.0
