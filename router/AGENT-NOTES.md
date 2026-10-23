# Router enclosure — 24 October 2026

The USB-access and recessed-logo changes are implemented and reviewed by the
user, who approved the design and requested that it be committed and pushed.

- The USB pair nearest Ethernet is accessible with the lid closed, with a new
  removable cover. The other pair remains internal: DFR1195 above and optional
  nano Wi-Fi dongle below. Dongle allowance: 6 × 16 × 8 mm exposed body.
- Overall footprint and board mounts are unchanged. Print the new base and lid
  together because the recess and one lid screw position have changed. Existing
  HDMI/SD covers are unchanged.
- The original Mariko tree alone is recessed 0.4 mm into the lid, 40 mm wide,
  with 2 mm of plastic remaining. No words, Reality2 mark or mirroring.
- The user has used the previous case with Pi 2B and Pi 3. New geometry still
  needs a physical fit check, including USB cover spring force and actual plugs.

`scripts/build.py` passed after the final geometry change: all five STL meshes
are watertight single solids; hardware, cover, service-port, Ethernet, external
USB insertion and internal USB envelopes have no volumetric collisions. Cover
spring contact and retention pass, including individual USB-cover checks.
Results are in `test/validation.json`; current renders are in `images/`.

OpenSCAD is available in the locally built Docker image
`r2-3dprint-tools:local` (OpenSCAD 2021.01, Python 3, Xvfb). From the repository root:

```sh
docker run --rm --init --user "$(id -u):$(id -g)" \
  --mount type=bind,src="$PWD",dst=/work --workdir /work/router \
  r2-3dprint-tools:local python3 scripts/build.py
```

The source uses the shared artwork in `branding/logos/mariko_logo_traced.scad`.
STLs are standalone. RDP preview uses display `:10`; the final lid image was
opened there in Gwenview.
