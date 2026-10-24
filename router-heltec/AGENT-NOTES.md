# Pi 3 / Heltec router variant — 24 October 2026

Current work is an independent `router-heltec/` variant. The user requested a Pi 3
with Heltec WiFi LoRa 32 V4R8, a close-fitting screen opening, GPS holder, identical
latest Pi port access, and a second rear Wi-Fi antenna hole mirrored from LoRa.
They reviewed the first RDP interior preview and said it looked good. They asked
to be shown the completed update on RDP. They then approved the finished design
and explicitly requested committing and pushing this variant.

User-confirmed dimensions: factory screen cover 33 × 18.6 mm; PCB underside to
display top 7.1 mm; GPS PCB 18 × 16 mm; total GPS connector-to-antenna stack 7 mm;
approximately 38 mm from Heltec PCB end to far end of the plugged-in GPS module.
The 17 mm GPS height was explicitly corrected to 7 mm. Factory cover is retained.
USB-C plug dimensions remain provisional: 20 × 12 × 8 mm. This results in a 1.2 mm
screen recess; reducing plug thickness to 6 mm permits a 0.3 mm recess. The lid
relief retains a minimum 1.2 mm roof and cradle height follows the same calculation.

The Heltec USB end faces the right cable bay. Four tall spring arms latch only
the PCB edges; annular support pads clear factory screw tails. GPS-end supports
have reliefs for the 12 mm-wide connector envelope. The GPS module faces antenna
upward in a removable tray with a fixed rear lip and two-screw retaining bridge.
The bridge bears on its own posts and clears the module. Rear bulkhead centres
are X=28/112, Z=20; holes are independently adjustable, currently 6.5 mm each,
with 4 mm reinforced panels and internal nut/tail clearance.

Pi mounting coordinates, port access and the reinforced clip design are
preserved. The original `router/` is untouched. The new alignment revision below
intentionally enlarges the HDMI and USB openings and their covers. The original
recessed Mariko tree remains; no wording or Reality2 logo is added.

Reference facts and limitations are recorded in `references/dimensions.json`.
V4 STEP was inspected locally with OpenCascade, but omits the display assembly
and is not the exact populated R8 board. The screen/cover placement therefore
uses the drawing plus user measurements. Manufacturer files are not redistributed.

Physical fit, spring forces, GPS lead routing, bulkhead thread lengths, actual
USB-C moulding, antenna performance and thermal testing remain unverified.
Print the screen coupon and holders before the full case. See README for screws,
orientation, build command and parameter coupling.

Tooling: `r2-3dprint-tools:local` provides OpenSCAD 2021.01 and Python. Use Docker
`--init` for Xvfb, UID:GID 1000:1000, repository bind-mounted at `/work`.
RDP is display :10 with /home/roycdavies/.Xauthority. The preview container is
`r2-router-heltec-preview`; use the host hostname for Xauthority authentication.

Validation for the initially committed variant: all nine parts are connected, watertight and on Z=0. All
hardware/holder/cable/screen/antenna and port-access interference checks passed;
each cover preloads and retains independently. Cradle uplift retention is
2.8 mm³, GPS retention 2.22 mm³. Inherited Pi interfaces and all three cover
meshes compare identical to `router/`. Results: `test/validation.json`.

Initial delivery: the live rear CAD scene `test/rear.scad` is open and visibly verified
on RDP, showing both symmetric antenna bulkheads. The main editable source is
also open in a second OpenSCAD window. The rear preview is the foreground window
(81788934 at delivery); the container remains running. All exported files and
renders are current. No tests are still running. The user approved this version
for commit and push after reviewing it on RDP.


## Committed revision — port-edge alignment

The user requested aligned HDMI/power bottoms and aligned Ethernet/USB tops and
bottoms, explicitly for the Heltec variant only. HDMI now extends down 0.6 mm to
Z=7.4, retaining its Z=20 top (24 × 12.6 opening). USB extends to the unchanged
Ethernet edges Z=6.4..28.4 (15 × 22 opening). Matching HDMI and USB covers retain
the same filleted clip profile, preload and reduced hooks. Power, Ethernet, SD,
Pi mounts, lid and internal holders are unchanged. Reprint only the base, HDMI
cover and USB cover. After reviewing the assembly on RDP, the user explicitly
requested committing and pushing this alignment revision.

The build additionally samples actual wall voids to verify the four opening
bounds, edge alignment, original horizontal locations and preserved clearances.
It still compares the SD cover, Pi mounts and clip design to the DFR1195 variant;
HDMI and USB size equality is deliberately replaced by the alignment checks.
All nine meshes have passed the manifold checks. Direct wall-void measurements
confirm power/HDMI bottoms at 7.4 and Ethernet/USB edges at 6.4/28.4. Full
clearance/retention validation passed, including individual HDMI/SD/USB preload
and hook retention, closed-lid plug access and internal holder checks. Results
are current in `test/validation.json`; no tests remain running. The six unchanged printable
parts were compared triangle-for-triangle with HEAD, then their original export
bytes restored to avoid unrelated STL ordering changes. Only base, HDMI cover
and USB cover geometry changes.

Renders have been refreshed. The user approved the bare-opening RDP view, then
requested covers and internal boards too. `test/assembly.scad` is now open and
visibly verified in RDP (window 83886086), with covers fitted, electronics visible
and the lid raised. The earlier `test/ports.scad` view remains behind it.


## Committed revision — original 40 mm flush logo inlay

The user requested an insert matching the existing recessed Earthgrids/Mariko
tree, to print in a contrasting colour. They want it snug enough to stay in, and
explicitly allow a tiny spot of superglue if necessary. The inlay uses the same
traced profile and dimensions via `lid_logo_profile()` and `lid_logo_spec()` in
the enclosure source. All nine original enclosure meshes, including the lid, were compared
triangle-for-triangle with HEAD and are unchanged; their original export bytes
were retained to avoid unrelated mesh ordering differences.

`src/logo_inlay.scad` produces a single connected 0.4 mm-thick tree, flush with
the existing recess. It has 0.05 mm clearance around most edges and six local
0.04 mm grip patches: three on the root, one on each outer side leaf, one on the
top leaf. The first 0.1 mm is a clearance lead-in; print all layers at 0.1 mm.
The cropped root test piece is also a single connected solid, with the same
three root contacts. Actual friction, fit and thin-part handling require a
print trial. Glue is a fallback; there is no snap undercut in the shallow recess.

`scripts/build_inlay.py` exports/checks both parts and verifies clearance against
the actual lid, allowing interference only in the six grip spots and measuring
each spot independently. The full enclosure build invokes it too. The full build passed, including the inlay checks and CAD-derived fit parameters.
Both new meshes are single connected, watertight solids at Z=0, 0.4 mm thick.
Core and unexpected contact are zero; all six grip spots independently contact
the nominal recess, totalling 0.102303 mm³ of intentional interference. This
is geometric evidence only, not a force/durability measurement. Results are in
`test/inlay-validation.json`; no build or validation process remains running.
`test/logo-inlay.scad` is open in RDP (window 88080390). The session is currently
locked, so the rendered preview is also saved as `images/logo-inlay.png` and the
user has been told it will be available when they unlock. Do not bypass the
screen lock. Existing lids can be reused. The user subsequently asked whether
this revision was committed and pushed as `6f43060`.


## Current revision — enlarged original-vector logo inlay

The user found the original 40 mm inlay too fiddly. The tree is now 80 mm wide
at [53,47.5], with a 0.8 mm recess leaving 1.6 mm of lid. The matching inlay is
1.2 mm thick: 0.8 mm seated and 0.4 mm proud. Print the matching new lid and
inlay together. The eight other enclosure parts and original DFR1195 variant
remain unchanged. The 3 mm logo layout margin is checked against lid edges,
the display opening and screw holes.

A first attempt rounded the old bitmap-traced polygon, but the user still saw
raster artefacts and requested the original SVG. Website/GitHub searches did
not find the tree SVG (the supplied Reality2 website repo only had its hexagon
favicon). The user then placed `mariko-sticker.svg` in this repository's root.
This is the authoritative source now; do not redraw or refit its curves.

`scripts/import_logo.py` extracts only path id="tree", preserving all 411 cubic
Bezier segments and the two closed contours. It omits sticker text, ring, bleed
and cutline. Exact cubic bounds set the width to 80 mm and height to 88.322 mm;
SVG Y is converted to CAD Y without mirroring X. Adaptive subdivision keeps
chord error within 0.005 mm. Generated outputs:
- `src/mariko_logo_vector.scad`: shared lid/inlay profile and six grip centres.
- `references/mariko-tree.svg`: original tree path text preserved verbatim.
- `references/logo-source.json`: source hash, dimensions and sampling details.
The former smoothing generator and its outputs were removed. The supplied
sticker and original shared branding files are unchanged. Generation is
reproducible and the extracted SVG path was compared exactly with the source.

Fit remains 0.05 mm edge clearance and six local 0.04 mm interference spots.
Grip centres are reprojected onto the original vector outline. The 0.2 mm
lead-in and 0.6 mm grip band end at the lid surface. Print 0.2 mm layers: four
seated and two raised. The root fit piece follows the same three root contacts.
Actual fit/handling still needs a print trial; a tiny glue spot is permitted.

The full build exited successfully. All nine enclosure exports passed mesh
checks, all assembly clearances and retention checks passed, and the actual
logo maintains the 3 mm margin. Both inlay meshes are watertight, single
connected solids at Z=0, 1.2 mm thick. Core contact and unexpected contact are
zero; all six grip spots engage, totalling 0.408039 mm³. Reports are current in
`test/validation.json` and `test/inlay-validation.json`. No validation process
remains running. The eight unchanged parts were compared triangle-for-triangle
with HEAD and their original STL bytes retained.

All six lid-containing renders are refreshed. `test/logo-inlay.scad` was freshly
opened in Docker `r2-router-heltec-preview` on RDP display :10. The session is
locked; do not bypass it. The rendered `images/logo-inlay.png` has been visually
checked, but the live desktop view cannot be verified until unlocked. The user
has authorized committing and pushing the accumulated changes.

## Current follow-up — antenna roundness and printable port webs

The user says the antenna holes are not quite round and both power/HDMI and
USB/Ethernet pillars are too thin for printing. The user confirmed the
holes become flattened/oval after printing. Current nozzle is 0.6 mm (they
initially said 0.4 and mentioned 0.2); layer height was not provided. They will
try supports on the next print. Keep circular bores for slicer-generated
supports; do not add modeled sacrificial webs. Do not claim printed ovality is
solved by increasing CAD resolution. The user reiterated that the port webs
need actual extra width; confirmed both are now 3 mm rather than just deeper.

Both antenna bores now use local `antenna_fn=128` (formerly global 48), retaining
6.5 mm diameter, centres and panel thickness. A test samples the actual bore void
through 3.8 mm of the 4 mm panel, checking centre, radius and facet count. Binary
STL avoids ASCII coordinate rounding at X=112. Both pass, with radial facet error
about 0.00098 mm. This addresses faceting only; print distortion remains unverified.

Both port webs are now 3 mm wide (formerly front 2.4, side 1.5), wall depth still
2.4 mm so existing clip hooks can latch. Power unchanged. HDMI narrows from 24 to
22.8 mm, Ethernet 19 to 18.5 mm, USB 15 to 12.5 mm; socket centres and aligned
Z edges are retained. Matching HDMI and USB covers resize automatically. The
22 mm HDMI housing has 0.4 mm side clearance; 12 mm USB housings and 18 mm Ethernet
boot have 0.25 mm each side. Larger plugs need physical checking. These changes
are Heltec-only. The logo, lid and internal holders are unchanged by this follow-up.

Focused wall-void measurement and antenna tests passed. The USB cover's
top/bottom fingers now use 6.5 mm
breadth rather than 8, leaving 0.9 mm between adjacent roots. A new actual-geometry
check probes 0.8 mm clear channels at all four corners above the continuous face.
The clip-root profile itself is unchanged. All nine enclosure meshes, assembly
clearances, port insertion paths, corner gaps, individual cover retention,
holder retention, 3 mm webs and antenna bores passed the final full build.
The full build exited successfully, including both inlay meshes and all contact
checks: core/unexpected overlap zero, six grip spots totalling 0.408039 mm³.
Reports are current. No build or validation process remains running.
Independent collision tests now run in three isolated OpenSCAD processes, as do
the three inlay contact tests, retaining every assertion and deterministic report
order. This reduces the long serial waits for the detailed SVG geometry.
The five unchanged enclosure parts (SD, Heltec cradle, GPS holder/keeper,
screen-fit) retain HEAD bytes after canonical triangle comparison.
All case/cover renders refreshed; holders image stays unchanged. New bare-bore
view: `test/antenna-bores.scad`, `images/antenna-bores.png`. CAD ports and bare-bore
views opened in the existing preview Docker container on RDP. The desktop is
locked; do not bypass the lock.

The user also requested a plain lid. `src/plain_lid.scad` uses the existing
`lid_logo=false` switch, preserving the shared screen aperture, fasteners and
USB-C underside relief. `scripts/build_plain_lid.py` exports
`stl/router-heltec-lid-plain.stl`; the full build now invokes it after the inlay
checks. It passed separately while the original full build was finishing:
one watertight solid, Z=0..2.4 mm, matching 140 x 144 mm overall bounds.
Results are in `test/plain-lid-validation.json`. Both lid choices remain available.
The plain-lid render was visually checked and its editable source opened in the
existing RDP CAD container. The user reviewed the result and said all looks good.

The user explicitly authorized committing and pushing the accumulated
original-SVG logo, port-web and plain-lid revision. All requested implementation
and digital validation are complete; physical print fit remains unverified.


## Current revision — joined USB/Ethernet opening and three-sided cover

The previous port-web revision was committed and pushed as `035168d`. The user
found its 12.5 mm USB opening too small for their measured 15 mm plug. They
clipped 1–2 mm towards the cable-bay corner and removed the Ethernet/USB divider.
The CAD base now follows that modification with a 2 mm cutback: joined opening
Y=6.25..42.25, Z=6.4..28.4. Socket centres remain fixed at Y=34 for external USB.
Two 16 mm-wide plug envelopes are checked, giving 0.25 mm corner clearance
(0.75 mm for the measured 15 mm plug). The front power/HDMI web stays 3 mm.

The USB cover fills Y=24.75..42.25, including the former divider gap, leaving
Ethernet accessible. It has three hooked fingers: top, bottom and corner side;
none on the Ethernet edge. The corner flange is 0.6 mm to clear the stepped
wall. Strengthened root profile is unchanged. Tests check all three hook
contacts, the open cover edge, corner gaps, wider USB insertion and Ethernet
access with the cover fitted. HDMI/SD covers, lids and holders are unchanged.

The final full build has passed all nine mesh checks, every assembly/access
clearance, all cover and holder retention checks, measured opening bounds and
antenna bores. All overlap checks are zero. Individual USB hook engagement is
0.876192 mm³ at each top/bottom hook and 2.387623 mm³ at the corner hook.
The complete build exited successfully, including inlay core/unexpected
contact (zero), six grip contacts (0.408039 mm³ total), and the plain lid.
No build or validation process remains running. The log is retained at
`/tmp/r2-heltec-usb-build.log`.
Earlier focused sessions were lost across a system restart; the current full
build is the final evidence. All nine case/cover renders are refreshed.
Validation report prose was corrected to say three USB contact zones; no
measured results were changed.

The new RDP session is display :10. CAD is open in `r2-router-heltec-preview`
with ports, covers and closed views; screenshot visually verified. The user
reviewed it, said it looks good, and explicitly requested commit and push.
All ten unchanged STL exports retain their original bytes after canonical
triangle comparison; only the base and USB cover geometry changed. The full
validation report and documentation are current. Publication is authorized. A hand-cut existing base may need
cover adjustment because its cutback was approximate; the exported base/cover
are a matching pair. Physical fit/retention of the new cover remains untested.


## Current revision — sloping antenna-pad undersides

The USB revision was committed and pushed as `72ca1d6`. The user now reports
the bottom of the wider antenna reinforcement section drooping during printing
and asks for an angled underside. Both interior pads now have 45-degree ramps
from the 2.4 mm wall to their 4 mm mounting thickness. Each ramp adds 1.6 mm
inward over Z=9.4..11, across the full 20 mm pad width. The existing flat
washer/nut seat, top, bore size and bore centres are unchanged. Only the base
requires reprinting. No bore-shape or cover changes are intended.

The actual exported base is watertight. A direct mesh check found both ramp
faces on plane Y+Z=151 with full expected area 45.2550 mm² each, confirming
the 45-degree slope and 20 mm width. Base volume increased by 51.2003 mm³,
matching the two triangular ramps (51.2 mm³ expected). The antenna-only
full build passed enclosure checks but was stopped during inlay validation
when the cradle follow-up below was added. Its retained log is
`/tmp/r2-heltec-antenna-ramp-build.log`; the combined run below supersedes it.
Interior section scene `test/antenna-ramps.scad` omits the floor to show the
undersides; it does not alter the exported base. It is open in RDP :10 using
`r2-router-heltec-preview`. The render `images/antenna-ramps.png` and live RDP preview were visually
checked; the user said the change should work. Internal assembly/service
renders are refreshed. Eight unchanged enclosure STLs retain original bytes
after canonical triangle comparison. Physical print behaviour remains unverified.


## Active follow-up — cradle overhangs

While the antenna-ramp full build was running, the user reported unsupported
features on the main Heltec mount, especially the clips, and wants to avoid
large amounts of slicer support. The antenna build passed all enclosure,
clearance, retention, port and bore checks, but was stopped during unchanged
inlay checks so the final combined geometry can be checked in one full build.
Do not cite the stopped run as a complete build.

The four spring-arm hooks now grow inward along 45-degree undersides instead
of flat ledges. Their outer 0.5 mm PCB overlap and overall top height remain.
The underside starts at [0.3,top-0.2], reaches [-0.5,top+0.6], and meets the
upper lead-in at [-0.5,top+1]. The rear support-post relief now continues
through the seat (6.5+eps high), removing the unsupported 0.6 mm caps and
leaving C-shaped bearing faces at the same board height. Front pads unchanged.

Focused mesh check passed: single watertight cradle. New check
`check_cradle_overhangs` inspects actual downward mesh faces above the bed;
minimum slope is 45 degrees (10 faces). Original flat hooks/caps would fail.
Direct mesh measurements find all four bearing faces at Z=20.7 mm relative
to the cradle base: front annuli 8.552 mm² each, rear C-shaped seats 4.840 mm²
each. All remain connected to the base; physical bearing/strength is untested.
Cradle retention at 0.6 mm lift is 0.5 mm³ (previously 2.8), still positive;
this is geometric contact, not measured grip force. Focused holder clearance
passed with effectively zero overlap (6e-13 mm³), and the focused run exited
successfully. Its log is `/tmp/r2-heltec-cradle-focus.log`. The combined final
full build exited successfully. All 12 meshes are single watertight solids
on Z=0; all assembly overlaps are zero, all cover/holder retention checks pass,
and measured ports/bores are correct. The cradle underside minimum is 45°.
The inlay has zero core/unexpected contact and 0.408039 mm³ grip contact.
Plain lid verification passed. Reports are current in `test/validation.json`,
`test/inlay-validation.json` and `test/plain-lid-validation.json`. The log is
`/tmp/r2-heltec-printability-build.log`. No validation process remains running.

New scene/render: `test/heltec-cradle.scad`, `images/heltec-cradle.png`; render
visually checked. CAD reopened in `r2-router-heltec-preview` on :10. The
antenna-ramp source/render remain. Holders and internal/assembly renders completed successfully; log
`/tmp/r2-heltec-cradle-renders.log`. Seven unchanged enclosure STLs retain
HEAD bytes after canonical comparison. Only base and cradle geometry changes
are intended in the combined revision. README/CLAUDE describe the changes.
Full build, mesh hygiene and notes are complete. All ten unchanged STL
exports retain HEAD bytes after canonical comparison; only the base and
Heltec cradle differ. The user explicitly authorized committing and pushing
these antenna/cradle changes after validation. The preceding USB revision
was published in `72ca1d6`.


## Active revision — PETG cradle grip

Antenna/cradle printability changes were committed and pushed as `c01c373`.
The user physically tried the cradle in PETG: the board sits loosely, the
clips flex too easily, and the main issue is their spacing. No measured PCB
width was supplied; retain nominal 25.4 mm. The old arms had 0.3 mm clearance
each side and approximately 0.35 mm free lift before their sloped hooks met
the board. Passing the old geometric lift test did not establish usable grip.

New parameters: `cradle_clip_preload=0.1`, `cradle_clip_thickness=1.8`,
`cradle_clip_hook=0.7`, `cradle_clip_lift_gap=0.05`. Opposing upper contact
faces are 25.2 mm apart (0.8 mm closer than before); lower arms stay outside
headers. At the PCB underside a 45° neck transitions inward over 0.4 mm.
The arm thickness rises from 1.2 to 1.8 mm, with existing flared roots.
Hook undersides remain 45°. Relaxed overlap 0.7 mm becomes 0.6 mm when the
tip is displaced outward by the nominal preload. Board seats and mounts stay.

`cradle_spring_contact_zones` masks only PCB-edge regions above its underside.
The holder collision test excludes these intended preload regions, retaining
all other checks. New individual contact checks require all four seated
contacts and all four hooks at 0.2 and 0.6 mm lift. The retention scene shifts
tips outward by 0.1 mm before lifting the board, so seated squeeze alone
cannot satisfy retention. This is a position proxy, not a force simulation.

Focused mesh: single watertight cradle, 3884 triangles, Z=0..23.85. All downward
surfaces above bed are at least 45° (18 faces). Seated contact ~0.5 mm³ per
clip; at 0.2 mm lift 0.045 mm³ per hook; at 0.6 mm ~0.605 mm³ per hook.
Focused holder clearance passed with effectively zero unintended overlap
(6e-13 mm³). Log: `/tmp/r2-heltec-grip-focus.log`. The final full build exited
successfully. All 12 exports are single watertight solids on Z=0. All assembly
clearance checks pass with zero unintended overlap. All four clips pass
seated preload, 0.2 mm lift and 0.6 mm lift checks. Minimum downward surface
slope is 45°. Covers, holders, ports and bores also pass; inlay core/unexpected
contact is zero, grip contact 0.408039 mm³, and plain lid checks pass.
Log: `/tmp/r2-heltec-grip-build.log`. Reports are current. All eleven unchanged
STLs retain original bytes after canonical comparison; only cradle export
changes. No validation process remains running.
Close-up render completed and was visually checked. Other cradle-containing
images are regenerated; log `/tmp/r2-heltec-grip-renders.log`.
Full build, mesh hygiene and final notes are complete. The cradle
preview was reopened in `r2-router-heltec-preview` on :10; screenshot verified
and window maximized.
Only cradle needs reprinting; physical PETG grip of this revision is unverified.
No commit/push authorization yet for this new grip revision.


## Pending measurement — raise the screen into the lid opening

The user reports the printed display sits lower than desired and wants a slightly
taller Heltec cradle. Current model: PCB underside Z=26.1, screen top Z=33.2,
lid underside/top Z=32/34.4. A 0.9 mm lift puts the display 0.3 mm below the top.
The limiting factor is the provisional 8 mm-thick USB-C moulding, not the screen.
With the existing 1.2 mm-deep pocket and 0.3 mm cable clearance, that lift requires
a centred USB-C plug body no thicker than 6.2 mm. Asked for its measured thickness;
no geometry changed pending the answer. Preserve the existing lid pocket (the
user explicitly chose to keep it), its 1.2 mm roof, and the tighter PETG clips.
After a measurement, update the cable envelope and cradle height consistently,
verify hardware clearances and retention, and run the required full build. The
previous PETG grip revision remains validated and uncommitted.

The user additionally reports the Heltec holder is still a bit loose. Asked
whether the board moves between clips or the whole holder moves on mounting
screws, and whether the print uses the latest 1.8 mm arms / 25.2 mm contact
spacing revision. Do not assume that uncommitted revision has been physically
tested, or blindly increase preload before identifying which fit is loose.
Combine the resulting fit correction with the pending height adjustment.


## Active revision — second PETG grip correction

User confirms the latest 1.8 mm-arm / 25.2 mm-spacing cradle was printed and
the PCB still moves between the clips; the holder itself is firmly mounted.
Increase nominal preload from 0.1 to 0.2 mm per side (25.0 mm contact spacing),
arm thickness from 1.8 to 2.0 mm, and relaxed hook overlap from 0.7 to 0.8 mm
to retain 0.6 mm overlap after nominal deflection. Preserve the 0.05 mm lift
gap and sloping neck/hook undersides. Physical grip is still a trial; no
measured PCB width was supplied. Screen-height change remains pending the
USB-C plug thickness; do not silently reduce the assumed cable envelope.
Validation and exports/renders completed below. No commit/push requested.

Focused and full validation completed successfully; no validation processes
remain running. Logs: /tmp/r2-heltec-grip2-focus.log and
/tmp/r2-heltec-grip2-build.log. The cradle is a single watertight solid with
3884 triangles, 5012.68 mm³ volume, height 23.85 mm and minimum downward
underside angle 45°. Each seated contact is ~0.96 mm³; each hook engages
0.045 mm³ at 0.2 mm lift and ~0.605 mm³ at 0.6 mm lift. Holder interference
is zero. All assembly clearance, cover/GPS retention, port and bore checks
passed. Inlay core/unexpected contact zero, grip contact 0.408039 mm³; plain
lid checks passed. All 12 exports are single watertight solids at Z=0.
All eleven unchanged STL exports retained HEAD bytes after canonical mesh
comparison; only the cradle STL differs. Cradle, holders, assembly and service
images updated; close-up visually inspected. No GUI preview was opened this
turn. README/CLAUDE and validation reports are current.

This second grip correction is ready for a PETG print trial, not physically
validated and not committed/pushed. The requested screen-height increase
remains pending the USB-C plug thickness. A 0.9 mm lift requires a centred
plug body at most 6.2 mm thick with the current pocket and 0.3 mm clearance.


## Active revision — raised screen and deeper USB-C pocket

User measured USB-C moulding thickness at approximately 6.5 mm, resolving the
pending measurement. They additionally requested deepening the lid pocket.
Set measured thickness 6.5 mm, minimum roof 1.05 mm (user's deeper-pocket
request supersedes former 1.2 mm design constraint). Result: pocket depth
1.35 mm, 0.15 mm deeper; cradle/PCB seat 0.9 mm higher (local Z21.6, installed
PCB underside Z27.0), screen top Z34.1, 0.3 mm below lid top. Plug ceiling
Z33.05 leaves 0.3 mm nominal headroom beneath pocket ceiling Z33.35. Retain
the latest 2.0 mm arms, 25.0 mm contact spacing and sloped clip undersides.
USB-C length/width and moulding centring still provisional. Change both lids
and cradle; no base or cover change intended. Full build and renders pending.
No commit/push requested for these accumulated changes.

Full build completed successfully (exit 0); no validation process remains
running. Log: /tmp/r2-heltec-height-build.log. All 12 printable exports are
single watertight solids at Z=0. All assembly, screen, cable, port-access,
cover/holder-retention and antenna-bore checks passed. Cradle height is
24.75 mm, volume 5114.10 mm³; minimum downward underside angle remains 45°.
Each seated contact ~0.96 mm³; each hook engages ~0.045 mm³ at 0.2 mm lift
and ~0.605 mm³ at 0.6 mm lift. Inlay core/unexpected contact zero, grip
contact 0.408039 mm³; plain lid matches logo-lid bounds. Reports current.

Direct mesh measurements confirm support-seat faces at local Z21.6
(total bearing area 26.7831 mm²). Both lids have pocket-ceiling faces at
Z1.35 (290.4 mm²) and each loses only 43.56 mm³ from the deeper pocket.
Nine unchanged STL exports retained HEAD bytes after canonical comparison;
only cradle, logo lid and plain lid geometry changes. All relevant
assembly/holder/lid renders refreshed, plus new `test/screen-section.scad`
and `images/screen-section.png`; cutaway visually inspected. Render
processes exited successfully. Only X0 was available this turn; no active
RDP X10 socket, so no live RDP preview opened.

The user explicitly requested committing and pushing these accumulated
tighter-cradle, raised-screen and deeper-pocket changes after validation.
All implementation, documentation, exports and checks are complete; ready
for publication on the existing branch. Reprint the cradle and chosen lid
together. Physical PETG grip and measured-cable fit require a print trial.
