# Xiao + LoRa Phone-Mount Case — Mariko Earthgrids

Parametric OpenSCAD enclosure for a Seeed Xiao + LoRa board, mounting on a
phone back via a short right-angle USB-C cable. Branded Mariko Earthgrids
device with Reality2 hallmark. Developed iteratively with physical print
feedback from Roy; the design decisions below are settled — do not revisit
without new evidence from a print.

## Files
- `src/xiao_case.scad` — the design. All parameters at top.
- `branding/logos/mariko_logo_traced.scad` — REQUIRED dependency (traced logo polygons).
- `scripts/check_fit.py` — snap-fit interference test. See workflow below.
- `test/interference.scad`, `test/seated.scad` — test/preview scenes.
- `stl/` — current exports. `images/` — product renders. `branding/images/` — logo trace reference.

## Non-negotiable invariants
1. **Run `python3 scripts/check_fit.py` after ANY geometry change, before
   exporting STLs.** closed ≈ 0 mm³ AND lifted > 2 mm³ or the lid is broken.
2. `LID_Z0` in check_fit.py must equal `outer_h - seat - lid_h`
   (currently 11.4). Update it if any height parameter changes.
3. The case mounts INVERTED: print-floor = visible outer face; rim/lid face
   the phone. Therefore: floor face carries ALL branding, must stay
   unbroken (no cuts through it), and bottom-face marks can only be
   DEBOSSED (recessed) — raised features on the print bed cannot print.
4. Asymmetric bottom-face graphics (the tree) are MIRRORED in the model so
   they read correctly after the installation flip. Keep `mirror([1,0])`.
   The R2 hexagon's five-spoke motif is X-symmetric — no mirror needed.
5. Feature-size floor: nothing (stroke or gap) below ~0.45 mm — 0.4 nozzle.
   Text: DejaVu Sans Bold width = 5.92 × size. MEASURE, don't estimate.
6. Everything prints flat, cavity-up, no supports. Keep it that way.

## Geometry architecture (how the meander works)
- Channel follows `ch_px(t) = ant_curve·sin(360t/L)·sin(180t/L)` — an
  S-curve with zero slope at both ends (clean square join at the box,
  straight finish). `at_path(t)` places children in the local path frame.
- Outer solid = single 2D `outline()` extruded with a smooth quarter-round
  top rim (`body_solid()`, sliced offsets). Box back face is FLAT
  (front-rounded corners only) so the channel meets it with no notch.
- Six snap clips: 2 box + 4 channel (channel ones in path frames, 6 mm
  long — longer clips lose engagement on the curve). Ramped bump underside,
  square top; recesses cut INTO wall material from the inner face.
- Closed-position interference of ~0.17 mm³ at channel clip corners is
  KNOWN and fine (wall curvature vs straight clip; within FDM tolerance).

## Refuted approaches — do not retry
- Curved fillets / chamfers at channel-box join: every variant either cut
  into the body, overshot the box, or looked like a defect. The clean
  answer was a flat back face + square join. (User confirmed.)
- Deep-skirt lid with plate on top: too thick, clips never engaged
  (disjoint Z bands). Replaced by flat inset click-in plate.
- Recesses cut on the cavity side of walls: no-op subtractions — "no clips".
  Recesses go INTO wall material, outward from the inner face.
- USB slot open through the floor / through the rim: superseded. It is now
  a closed stadium window (plug inserts from outside; USB-C reversible).
- Coordinate-arithmetic-only fit checks: missed a disjoint-Z bug. Boolean
  interference (check_fit.py) is the only accepted verification.

## Tuning knobs (physical print feedback)
- Snap tightness: `tol` (0.3), `snap_depth` (0.7).
- USB window: `usb_w` 12.6 / `usb_h` 7.0 / `usb_z0` 3.0 — calliper the
  actual Adafruit 6367 overmold; FDM holes print ~0.2–0.4 undersize.
- Meander drama: `ant_curve` (5). Branding: `deboss` (0.4), `wave_*`,
  `hex_R` (4.2), `r2_*`. Logo size: `mariko_logo2d(w=18)` — larger = more
  koru detail survives.

## Open items
- [ ] Print-verify koru spirals + R2 spokes survive the first layer
      (finest features, ~0.45 mm). Widen logo or `deboss` if muddy.
- [ ] Calliper USB plug; tune window to overmold + 0.5 mm.
- [ ] Optional: MagSafe magnet pocket (coupling is through lid+seat,
      1.7 mm, since inversion). Optional: board-locating posts.
- [ ] Replace traced logo with official SVG if one exists (import(),
      but the trace is already at print parity — IoU 0.93).
- [ ] LICENSE — Mariko's call, deliberately not chosen.
