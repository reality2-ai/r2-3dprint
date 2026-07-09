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
