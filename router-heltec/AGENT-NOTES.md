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
