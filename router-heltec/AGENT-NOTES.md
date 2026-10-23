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

All existing Pi openings/mount coordinates and reinforced service-cover geometry
are preserved. The original `router/` is untouched. The new build verifies copied
Pi interface definitions and compares all three cover meshes with the original.
The original recessed Mariko tree remains; no wording or Reality2 logo is added.

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

Validation completed: all nine parts are connected, watertight and on Z=0. All
hardware/holder/cable/screen/antenna and port-access interference checks passed;
each cover preloads and retains independently. Cradle uplift retention is
2.8 mm³, GPS retention 2.22 mm³. Inherited Pi interfaces and all three cover
meshes compare identical to `router/`. Results: `test/validation.json`.

Delivery: the live rear CAD scene `test/rear.scad` is open and visibly verified
on RDP, showing both symmetric antenna bulkheads. The main editable source is
also open in a second OpenSCAD window. The rear preview is the foreground window
(81788934 at delivery); the container remains running. All exported files and
renders are current. No tests are still running. The user approved this version
for commit and push after reviewing it on RDP.
