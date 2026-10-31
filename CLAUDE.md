# Mariko Earthgrids & Reality2 Device Cases

Parametric OpenSCAD enclosures for Mariko Earthgrids field devices, branded with the Reality2 network hallmark. This repository hosts designs for multiple devices.

**Repository:** https://github.com/reality2-ai/r2-3dprint

## Project Structure

```
r2-3dprint/
├── branding/           # Shared branding assets (logos, images)
├── xiao/              # Xiao + LoRa device case
│   ├── src/          # Source SCAD files
│   ├── test/         # Test and preview scenes
│   ├── stl/          # Ready-to-print exports
│   ├── scripts/      # Verification tools
│   ├── images/       # Device-specific renders
│   └── README.md     # Device-specific documentation
├── CLAUDE.md         # This file - overall project context
└── README.md         # Multi-device overview
```

## Devices

### Xiao + LoRa Phone-Mount Case

Located in `xiao/` - parametric enclosure for Seeed Xiao + LoRa board.

**Key files:**
- `xiao/src/xiao_case.scad` — the design. All parameters at top.
- `xiao/src/mariko_logo_traced.scad` — REQUIRED dependency (traced logo polygons).
- `xiao/scripts/check_fit.py` — snap-fit interference test.
- `xiao/test/interference.scad`, `xiao/test/seated.scad` — test/preview scenes.

**Non-negotiable invariants:**
1. **Run `cd xiao && python3 scripts/check_fit.py` after ANY geometry change, before exporting STLs.** closed ≈ 0 mm³ AND lifted > 2 mm³ or the lid is broken.
2. `LID_Z0` in check_fit.py must equal `outer_h - seat - lid_h` (currently 11.4). Update it if any height parameter changes.
3. The case mounts INVERTED: print-floor = visible outer face; rim/lid face the phone. Therefore: floor face carries ALL branding, must stay unbroken (no cuts through it), and bottom-face marks can only be DEBOSSED (recessed).
4. Asymmetric bottom-face graphics (the tree) are MIRRORED in the model so they read correctly after the installation flip.
5. Feature-size floor: nothing (stroke or gap) below ~0.45 mm — 0.4 nozzle.
6. Everything prints flat, cavity-up, no supports.

**Geometry architecture:**
- Channel follows `ch_px(t) = ant_curve·sin(360t/L)·sin(180t/L)` — an S-curve with zero slope at both ends.
- Channel width = box width (~21mm), split by central divider into two 8mm lanes.
- Outer solid = single 2D `outline()` extruded with smooth quarter-round top rim.
- Six snap clips: 2 box + 4 channel.
- Closed-position interference of ~0.17 mm³ at channel clip corners is KNOWN and fine.

**Tuning knobs:**
- Snap tightness: `tol` (0.3), `snap_depth` (0.7).
- USB window: `usb_w` 12.6 / `usb_h` 7.0 / `usb_z0` 3.0.
- Meander drama: `ant_curve` (5). Branding: `deboss` (0.4), `wave_*`, `hex_R` (4.2), `r2_*`.

### Router enclosure geometry checks

The router source is `router/src/router_case.scad`; run
`cd router && python3 scripts/build.py` after geometry changes. It exports and
validates the base, matching lid, and HDMI, SD and USB covers. Keep all five
parts connected and watertight, the closed-lid USB insertion paths clear, and
the internal DFR1195 cable plus optional nano Wi-Fi dongle clear of the shell.
Intentional cover spring preload is allowed only within the explicit contact
masks; each cover also has its own contact and retention checks.
PLA cover fingers previously broke at the face. Their roots now have an inward
1.2 mm fillet and 0.4 mm embed into the face; side hooks project 0.45 mm. Preserve
clearance around the thin spring arms. Physical PETG strength testing is pending.

The USB pair nearest Ethernet is external, with one removable cover. The pair
furthest from Ethernet stays internal: DFR1195 above, optional nano Wi-Fi below.
Board mounts are unchanged from the case the user has used with Pi 2B and Pi 3.
The USB access revision needs a new base and matching lid; see `router/README.md`
for dimensions, assumptions and physical checks still required.
The lid carries only the original Mariko tree, recessed 0.4 mm into the top
face with 2 mm of plastic beneath it. Use the shared traced artwork without
mirroring; do not restore the wording or Reality2 mark.

### Heltec router variant

`router-heltec/` is independent of `router/`. Run its `scripts/build.py` after
geometry changes and keep all nine exports connected and watertight. Preserve
the latest Pi mounting positions, external/internal USB split, HDMI/SD/power and
Ethernet access, reinforced covers and recessed Mariko tree. The build compares
unchanged mounts, SD cover and clip design with the original variant. The
Heltec-only alignment revision puts HDMI and power bottoms at Z=7.4 mm and
Ethernet/USB bottoms/tops at Z=6.4/28.4 mm. Keep the power/HDMI web at 3 mm
and HDMI at 22.8 × 12.6 mm. The user found the 12.5 mm USB opening too small for
a measured 15 mm plug: remove the Ethernet/USB divider and extend the USB end
2 mm towards the corner, to Y=42.25. The joined opening is Y=6.25..42.25,
36 × 22 mm. Keep socket centres fixed; check two 16 mm-wide USB housings.
The new USB cover fills Y=24.75..42.25 plus its corner flange, leaving Ethernet
accessible. It has three hooked fingers (top, bottom and corner), no Ethernet
finger/flange, and 0.6 mm corner flange to clear the stepped wall. Preserve the
22 mm HDMI and 18 mm Ethernet plug envelopes, with at least 0.25 mm clearance.
Verify the actual continuous wall void and each of the three USB hooks.
Antenna bores use
128 segments, verified on the actual void through the reinforced panel; this
addresses CAD faceting, not print-process ovality. Do not apply these changes
to the DFR1195 router unless requested.
The USB cover uses 8 mm end fingers; the build probes clear channels between
the roots and the open Ethernet edge. The individual finger/root profile is
identical to the original, with matching three-sided spring-contact masks.

Use the user-confirmed screen cover 33 × 18.6 mm, PCB underside-to-screen height
7.1 mm, GPS PCB 18 × 16 mm, total GPS thickness 7 mm and approximately 38 mm
extension from the Heltec end. The factory display cover stays fitted. Retain
by the PCB, without clamping the glass. USB-C plug height drives both cradle
height and the lid relief. The user measured USB-C thickness at about 6.5 mm
and requested a deeper pocket: 1.35 mm deep with a minimum 1.05 mm roof. This
raises the cradle seat by 0.9 mm, leaving the display 0.3 mm below the lid top
and 0.3 mm nominal clearance above a centred plug. Update both lid variants
and the cradle together; retain the tighter PETG arms. GPS antenna
faces upward in a removable tray, retained by a screw-on bridge. Both rear
antenna positions are symmetrical, X=28/112 and Z=20, with independent hole sizes.
Their 4 mm reinforcement pads transition from the 2.4 mm wall with 45° underside
ramps: 1.6 mm inward growth over Z=9.4..11 mm. Preserve the flat washer/nut seats
and circular bores; the ramps address the pad's hanging lower ledge, not bore sag.
The source uses simplified envelopes; physical fit, spring durability, antenna
routing and thermal validation remain necessary. See its README and
`references/dimensions.json` for measured versus provisional dimensions.
The user's second PETG trial found the tightened cradle still loose. Its
2.0 mm-thick arms now have 0.2 mm nominal PCB-edge preload per side: faces 25.0 mm
apart for the 25.4 mm board. Keep the lower arms outside the headers; the
45° neck moves inward only above the PCB underside. Hook overlap is 0.8 mm
relaxed, 0.6 mm after nominal deflection, with 0.05 mm lift clearance.
Only the explicit PCB-edge masks may contain relaxed spring interference.
Check all four seated contacts and individual retention at 0.2 and 0.6 mm
lift, shifting tips outward by the nominal preload so squeeze alone cannot
count as hook retention. This proxy does not simulate spring force.
The cradle's clip undersides still slope at 45°.
The rear support-post connector reliefs continue through the top, leaving
C-shaped bearing faces at the calculated seating height instead of unsupported
caps. Preserve connector and screw clearance. The build checks that downward
surfaces above the print bed are at least 45° and that the clips still retain
the PCB when lifted. This checks geometry, not retention force or print quality.

The optional logo inlay is `router-heltec/src/logo_inlay.scad`. It reads the
shared profile and dimensions from its matching lid. The current Heltec tree is
80 mm wide at [53,47.5], with a 0.8 mm recess leaving 1.6 mm of lid beneath it.
The inlay stands 0.4 mm proud (1.2 mm total thickness). Preserve a 3 mm margin
from lid edges, the display opening and screw holes. The old 40 mm lid/inlay
are not compatible; this enlargement is Heltec-only.
Both parts use `router-heltec/src/mariko_logo_vector.scad`, generated by
`scripts/import_logo.py` from the original `tree` path in the user-supplied
root-level `mariko-sticker.svg`. Preserve the original cubic curves: no bitmap
tracing or curve refitting. Sampling error is at most 0.005 mm at 80 mm width.
The generator also projects grip centres onto the outline and exports a
tree-only SVG plus source hash/provenance. Keep the supplied sticker, shared
branding assets and other variants unchanged. Rebuild the lid and inlay
together after changing this profile.
The full build also runs `scripts/build_inlay.py`; use that focused script for
inlay-only fit tuning. Both inlay and cropped root fit piece must be single,
watertight solids with thickness equal to recess depth plus proud height. The default is 0.05 mm
edge clearance with six local 0.04 mm interference spots above a 0.2 mm lead-in.
Grip patches must stop at the lid surface; use 0.2 mm print layers.
Check each grip spot and exclude any other lid interference. Geometric contact
does not validate friction/holding force; the user permits a tiny glue spot if
needed. Print-fit and handling of the thin tree remain physical checks.

The optional plain lid is `router-heltec/src/plain_lid.scad`, using the shared
design's existing `lid_logo=false` switch. Keep its screen opening, screw holes
and underside USB-C relief identical. The full build also runs
`scripts/build_plain_lid.py`, checking its watertight mesh and matching overall
dimensions, and exports `stl/router-heltec-lid-plain.stl` separately.

### Compact radar battery holders

The user has now confirmed that the reinforced curved holder works for the
shorter unprotected cells. Preserve that working geometry and its exports; the
next task is a separate longer protected-cell version with the same retention.

**Latest scope: one longer protected cell only.** The user confirms that raising
batteries above the thermistor would prevent lid closure, ruling out the raised
two-cell layout. Three cells also cannot fit. The protected battery is **69 mm
including its cap**; diameter remains assumed 18 mm. The latest mounting base is
**67 mm** (shortened from 68 mm after a tight physical fit between components),
flush with one end of the upper cradle, with the entire overhang at
the other end. Retain only a shallow step for that overhang, not a lift above
the thermistor. The reported 70 mm plug-to-pin distance is along the board, not
connector height; the user subsequently estimated 69 mm available for the body.
The full upper tray still needs extra space beyond the mounting footprint.
Do not alter the working short-cell exports or develop another protected two-
or three-cell holder unless the user changes the installation constraints.
Latest retention proposal: curve the holder's upper sides inward for a press-in
snap cradle, replacing the separate bars. The latest concept uses two independent
24 mm-long retaining sections per cell, smooth entry/contact edges and top removal with
the base still fixed. `battery-holder/concepts/snap-cradle.scad` is a visual
retention study using the old 18 mm diameter only; it is not a protected-cell
fit or strength qualification. Final lips need the new cell diameter and a
physical PETG test. The concept includes continuous 1 mm end walls for copper
tape, separated from the curved sides by 1.2 mm relief gaps. Its 66.8 mm length
is the old holder envelope, not a new-cell fit. Longer sections need a physical
removal-force trial. The separate protected-cell source now uses the confirmed
69 mm length; lift and cap contact fit remain to be verified.
`battery-holder/scripts/build_snap_cradle.py` exports the current concept as
`battery-{1,2}-snap-fit-test.stl`, checking connected, watertight meshes and
dimensions. These are short-cell fit tests (64.8 mm plastic gap, 18 mm diameter
placeholder), not protected-cell replacements. The curved shells are now
1.6 mm and the floor 1.8 mm following feedback about flimsiness. Centre the
inner and outer arcs on cell_z so floor/shell changes preserve radial clearance.
Outside dimensions are 66.8 × 21.3/43.4 × 14.8 mm; cell tops are at 19.8 mm.
The exporter also checks seated clearance and retention at 0.8 mm lift; physical
force/fatigue remain unverified. Keep these fit-test files distinct from the
historical bar-retained trays and from the eventual longer-cell revision.
The separate `battery-holder/src/protected_snap_cradle.scad` uses a 67 mm
mounting plinth and a 71.8 mm upper tray (4.8 mm overhang at +X, flush at X=0).
The flat wall spacing is 69.8 mm. A 5 mm-wide, **1 mm-high** rounded bump
backs the negative copper contact at the flush end. The nominal plastic/taped
gaps at its centre are **68.8/68.6 mm**. The user explicitly wants the 69 mm cell
to push the ends outward for tape contact: 0.4 mm total nominal preload, shared
as 0.2 mm per end in a geometric clearance proxy. Keep the walls continuous.
The build permits relaxed interference only within narrow terminal masks;
all other interference is rejected. It also checks clearance after translating
each end outward by half the nominal preload. This proxy does not simulate
wall bending, holding force or fatigue. Curved-lip retention must pass after
excluding axial contact masks, so end pressure cannot masquerade as retention.

Raised outside polarity marks are 0.5 mm proud, 5 mm wide with 0.8 mm strokes:
minus at the flush/bumped end, plus at the overhanging end. They embed 0.1 mm into
the flaps. Body length remains 71.8 mm; relaxed overall length including marks
is **72.8 mm**, and the footprint remains 67 mm. End-wall flex further increases
installed length; physical fit is pending. `scripts/build_protected_cradle.py`
exports a 72.8 × 21.3 × 16.8 mm STL including the marks, using the existing 2 mm
step, and checks the exported bump and plus/minus geometry. Cell-top height
is 21.8 mm. Print supports are needed under the 4.8 mm cantilever; marking
print quality also needs inspection. Do not overwrite working short-cell STLs.
The user also suggests a diagonal single-cell layout. Compare it with the raised
layout using the complete holder and bar-service envelopes. Do not assume the
66 × 54 mm reservation's diagonal guarantees fit: simple rectangular screening
already rejects 69 × 18 mm bare cells and the current 66.8 × 21.9 mm tray within
that strict rectangle. Actual cell size and usable space outside the reservation
remain unknown; a narrower/reshaped holder or overhang may still be needed.

The following describes the existing short-cell files:

`battery-holder/` contains one-, two- and three-cell variants for user-measured
64 mm-long, 18 mm-diameter cells, side by side and wired in parallel by the user.
**The user revised the outside length limit to 67 mm** after the 65.8 mm first
print was about 1 mm tight and the end walls splayed. The revised model is
66.8 mm long, adding exactly 1 mm between the contacts. Keep the original
reported 64 mm cell length separate from `length_fit_allowance=1.0`: the 65 mm
fit envelope is an empirical print correction, not a new battery measurement.
The relaxed plastic/taped gaps are now 64.8/64.6 mm. The user needs to replace
batteries while the tray stays fixed to the board. The user rejected long
flexible U clips and chose taller walls with slide-through bars. Each bar now
has a forked snap catch at the far end: squeeze both prongs and withdraw sideways.
The rigid bar underside MUST be at the nominal cell top (19 mm), with no intended
gap or wrapper preload. Bars are 2 mm thick; slot roofs make the tray 22.2 mm high.
Do not restore slide-on rings, U clips or underside grooves. Reprint tray and bars
together. Outside ribs support the tall rails; do not thicken the inside walls
above the cells, since that blocks vertical battery removal.
Keep 0.8 mm continuous end walls and provisional 0.1 mm copper tape at
each terminal. Tape thickness, chemistry and actual terminal geometry remain
unconfirmed. Do not substitute nominal 18650 dimensions for the measurements,
exceed the revised 67 mm limit, or claim electrical/charger compatibility.
Run `python3 battery-holder/scripts/build.py` after geometry changes. Keep all
tray and bar exports and the one-cell fit piece single connected, watertight
solids. Both ends must offer uninterrupted tape backing across all cells, as
requested by the user. Longitudinal rails stop 0.8 mm short of the relaxed
contact lands, allowing the walls to flex from the floor; keep these gaps clear.
Check tape-land continuity, relief gaps, cell/bar clearance, intended relaxed-wall
interference, each far-end hook, the head stop and every cell's contact/retention.
Verify exported bar underside height, retention with full upward slot clearance,
flat floor/rib feet and bar/cell removal sweeps above a fixed board.
Released forks use a geometric proxy with 0.9 mm inward free-tip movement each;
actual release force, side/tool access and fatigue require physical checks. The
shared end wall couples all contacts; full-width
contact pressure must be tested with every actual cell. Printed wall force,
creep, tape performance and physical fit remain
unverified. Assembly widths with bars are 24.9/44/63.1 mm and height is 22.2 mm,
excluding mounting adhesive and service access. Side withdrawal travel is about
23.4/42.5/61.6 mm, plus grip access. The three-cell assembly exceeds the
PCB's recorded 54 mm battery reservation and is confirmed not to fit the box.
Use the user's XRDP display for previews when available; see its render script.

## Adding a New Device

When adding a new device case:

1. Create a new directory under the repo root (e.g., `new-device/`)
2. Follow the same structure as `xiao/`:
   ```
   new-device/
   ├── src/          # Source SCAD files
   ├── test/         # Test and preview scenes
   ├── stl/          # STL exports
   ├── scripts/      # Any verification tools
   ├── images/       # Renders
   └── README.md     # Device documentation
   ```
3. Update the main README.md to include the new device
4. Add device-specific invariants to this CLAUDE.md if needed

## Branding Assets

The `branding/` directory contains shared assets used across all devices:

- `branding/logos/` - Logo source files (SCAD traces, SVGs)
- `branding/images/` - Reference images, comparisons, and examples

### Branding Elements

All Mariko Earthgrids devices carry the Reality2 hallmark and may include:

- **Mariko tree mark** - Auto-traced from the official logo, mirrored to read correctly after installation flip
- **Reality2 hexagon** - Pointy-top ring with hub-and-five-spokes node network (top vertex direction empty)
- **Braided river waves** - Decorative element flowing along device features

Branding is debossed ~0.4mm into visible faces (prints as crisp first-layer engraving). Feature sizes are kept above ~0.45mm for 0.4mm nozzle compatibility.

### Logo Tracing

When tracing logos for new devices:
- Use high-resolution source images
- Maintain feature sizes above 0.45mm for printability
- Consider the installation flip when placing asymmetric elements
- Test print before committing to production
