# Router enclosure — 24 October 2026

The USB-access and recessed-logo changes were approved and pushed in commit
`26a4f3a`. The current update reinforces all three port covers after the
user reported PLA clips breaking at the joint with the flat face. Their next
print will use PETG; strength and durability remain to be checked physically.
The user reviewed the reinforced covers and approved committing and pushing them.

- The USB pair nearest Ethernet is accessible with the lid closed, with a new
  removable cover. The other pair remains internal: DFR1195 above and optional
  nano Wi-Fi dongle below. Dongle allowance: 6 × 16 × 8 mm exposed body.
- Overall footprint and board mounts are unchanged. Print the new base and lid
  together when upgrading from the case without external USB because the recess
  and one lid screw position changed. The current clip update changes only the
  three covers; base and lid STL geometry was compared with the committed meshes
  and is identical.
- Every cover finger has a 1.2 mm inward root fillet and 0.4 mm embed into the
  face. Side roots widen from 0.8 to 2.0 mm; tab roots from 0.6 to 1.8 mm.
  Thin arms, 4.8 mm depth, face dimensions and 0.15 mm preload are retained.
  Hook projection is reduced from 0.65 to 0.45 mm to reduce required deflection.
- The original Mariko tree alone is recessed 0.4 mm into the lid, 40 mm wide,
  with 2 mm of plastic remaining. No words, Reality2 mark or mirroring.
- The user has used the previous case with Pi 2B and Pi 3. New geometry still
  needs a physical fit check, including USB cover spring force and actual plugs.

`scripts/build.py` passed after the final geometry change: all five STL meshes
are watertight single solids; hardware, cover, service-port, Ethernet, external
USB insertion and internal USB envelopes have no volumetric collisions. Cover
spring contact and retention pass individually for all three covers. Retention
checks count only hook engagement beyond the spring-preload allowance.
Results are in `test/validation.json`; current renders are in `images/`.

OpenSCAD is available in the locally built Docker image
`r2-3dprint-tools:local` (OpenSCAD 2021.01, Python 3, Xvfb). From the repository root:

```sh
docker run --rm --init --user "$(id -u):$(id -g)" \
  --mount type=bind,src="$PWD",dst=/work --workdir /work/router \
  r2-3dprint-tools:local python3 scripts/build.py
```

The source uses the shared artwork in `branding/logos/mariko_logo_traced.scad`.
STLs are standalone. `test/covers.scad` and `images/covers.png` show the reinforced
roots, HDMI/SD/USB from left to right. RDP preview uses display `:10`.
