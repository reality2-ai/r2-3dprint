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
