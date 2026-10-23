# Pi 3 / Heltec V4R8 router enclosure

A separate variant of the [original router](../router/), using a Raspberry Pi 3,
Heltec WiFi LoRa 32 V4R8 with its factory screen cover, and a GPS accessory.
The case remains **140 × 144 × 34.4 mm**, excluding cover flanges and connectors.
The latest Pi mounting positions, port openings, recessed Mariko tree and
reinforced HDMI, SD and USB covers are retained.

**Digital prototype: a physical fit and temperature test is still required.**
The original `router/` design is unchanged.

![Interior, including the two removable board holders](images/service.png)
![Closed enclosure with the protected screen visible](images/closed.png)
![Rear wall with symmetrical Wi-Fi and LoRa antenna mounts](images/rear.png)

## Design

The Heltec sits on a removable cradle, with its USB-C connector facing the right
cable bay. Four long spring arms retain the PCB edges independently of the lid.
Four hollow support pads clear the factory screen fasteners; reliefs beneath the
GPS-end pads let the connector pass between them. The factory screen cover stays
fitted. The lid surrounds that cover with **0.3 mm clearance per side**; it does
not clamp the display or rely on the glass for retention.

The screen opening is **33.6 × 19.2 mm**. With the provisional 8 mm-thick USB-C plug,
the screen cover top sits **1.2 mm below the lid surface**. A local recess beneath
the lid clears the plug while retaining a **1.2 mm roof**. Changing the plug height
parameter automatically adjusts the cradle height and lid pocket together.
A 6 mm-thick plug allows the display to sit 0.3 mm below the surface.

The GPS holder sits at the Heltec expansion end, allowing the user's measured
**38 mm extension** from the Heltec PCB edge to the far end of the GPS. Its tray
holds an **18 × 16 × 7 mm** module, with the ceramic antenna facing upward.
A rear lip and removable two-screw bridge retain the module with clearance;
the cable leaves through the open end. The antenna's central face is uncovered.
No fragile snap fingers are used on the GPS holder.

Two rear antenna holes are at **X=28 and X=112 mm**, both **Z=20 mm**, so each is
28 mm from its nearest side. Both currently use **6.5 mm clearance holes** and
**4 mm reinforced panels**, with room for an 11 mm nut and 10 mm internal tail.
The left position is for Wi-Fi; the right is for LoRa. Each hole diameter can be
adjusted independently to match the actual bulkhead. Confirm connector type and
usable thread length for each pigtail; the printed case has no RF connector threads.

The two USB sockets nearest Ethernet remain accessible with the lid closed.
Their shared opening accepts the existing reinforced cover. The other USB stack
stays internal: upper socket for the Heltec cable, lower socket free. Pi 3 has
onboard Wi-Fi; the inherited nano-dongle envelope is still checked for clearance.
HDMI, SD, Ethernet and micro-USB power access match the latest original router.

## Files and printing

- [Editable CAD](src/router_heltec_case.scad)
- [Base](stl/router-heltec-base.stl) and [lid](stl/router-heltec-lid.stl)
- [Heltec cradle](stl/router-heltec-heltec-cradle.stl)
- [GPS holder](stl/router-heltec-gps-holder.stl) and [retaining bridge](stl/router-heltec-gps-keeper.stl)
- [HDMI](stl/router-heltec-hdmi-cover.stl), [SD](stl/router-heltec-sd-cover.stl) and [USB](stl/router-heltec-usb-cover.stl) covers
- [Screen fit coupon](stl/router-heltec-screen-fit.stl)
- [Validation report](test/validation.json) and [dimension provenance](references/dimensions.json)

Print the screen coupon and holders first to check the actual components before
printing the full enclosure. All exported parts sit on Z=0 in their print
orientation. Base cavity, cradle arms, GPS tray and port-cover clips point upward;
the lid prints with its recessed logo upward. The USB relief in the lid requires
a short bridge. Check this bridge and the small ledges over the GPS connector
reliefs in the cradle when slicing.

The reinforced port covers are geometrically identical to the current `router/`
covers, so existing copies can be reused. This variant needs its own base and lid.
PETG is the intended next trial material for the flexible arms and covers; neither
spring force nor fatigue has been physically verified. Start with the existing
router's 0.2 mm layers, 0.4 mm nozzle and four perimeters, then inspect the slicer
preview around the narrow support rings and spring roots.

![Cradle, GPS tray and removable retaining bridge](images/holders.png)

## Assembly

1. Install both antenna bulkheads with their supplied nuts and washers. Keep
   pigtails clear of the screen and GPS antenna; verify connector compatibility.
2. Fit the Pi to its four posts using M2.5 × 6 mm screws. Fit the microSD card.
3. Screw the empty Heltec cradle to its two short base bosses using two
   M2.5 × 5 mm screws. The pilot holes are 2.1 mm; check thread fit in spare plastic.
4. Fit the Heltec, display up and USB-C toward the right cable bay. Gently spread
   the long arms and seat the PCB on the support rings. Check that the factory
   screws, underside connectors and headers clear the supports. Release the arms
   to latch over the PCB edges, keeping force off the display.
5. Screw the GPS tray to its two tall base bosses using two M2.5 × 6 mm screws.
   With its antenna upward, tuck the GPS's far edge beneath the rear lip, then
   lower the connector end into the tray. Connect the lead without tension.
   Fit the retaining bridge with two M2.5 × 6 mm screws; it stops against its own
   posts, leaving clearance above the module.
6. Connect the internal USB data cable to the upper internal Pi socket and route
   it through the right bay to the Heltec. Current envelopes allow a 24 × 12 × 9 mm
   USB-A housing and a 20 × 12 × 8 mm USB-C housing. These are provisional cable
   dimensions, not a guarantee for all plugs.
7. Check the screen cover fits the coupon and lid opening freely. Close with six
   M3 × 10 mm screws. Install the port covers as needed. Add feet for floor airflow.

The Heltec is rotated 180 degrees in the case; adjust display orientation in the
application if needed. Thermal performance, GPS reception and Wi-Fi/LoRa antenna
routing require checks with the actual operating hardware.

## Measurements and tuning

The user confirmed the factory screen cover at **33 × 18.6 mm**, and **7.1 mm**
from Heltec PCB underside to the top of the display. They measured the GPS PCB at
**16 × 18 mm**, its complete connector-to-antenna stack at **7 mm**, and the plugged-in
assembly's extension at about **38 mm**. These override the generic GPS accessory
drawing. Other board positions come from the references listed in
[dimensions.json](references/dimensions.json).

The manufacturer's V4 STEP model omits the OLED and its cover, and is not an exact
populated V4R8 model. The drawing and STEP also differ on mounting-hole diameter.
The CAD therefore uses measured/display envelopes and support pads with 3.2 mm
clearance bores, rather than assuming a particular board fastening screw.
Verify screen position along the board and underside support-pad clearance on
the actual unit. No manufacturer CAD or PDF is redistributed here.

Useful top-level parameters: `screen_cover`, `screen_stack`, `screen_local`,
`screen_clearance`, `usb_c_plug_height`, `gps_size`, `gps_extension`,
`antenna_hole` and `wifi_antenna_hole`. Use the Customizer's `part` selector for
assembly, closed case, service access, separate holders or individual printable parts.
Rebuild all exports after changing parameters: the lid and cradle heights are coupled.

## Build and verification

With OpenSCAD available:

```sh
cd router-heltec
python3 scripts/build.py
```

Or from the repository root with the local tooling image:

```sh
docker run --rm --init --user "$(id -u):$(id -g)" \
  --mount type=bind,src="$PWD",dst=/work --workdir /work/router-heltec \
  r2-3dprint-tools:local python3 scripts/build.py
```

The build exports nine meshes and checks connected, watertight geometry;
hardware, holders, antenna fittings and cable envelopes; screen clearance;
closed-lid USB insertion; HDMI/SD and Ethernet access; and individual cover
preload/retention. It also checks that the cradle and GPS retainers engage when
their boards are lifted, and compares inherited cover meshes and Pi interface
source definitions against `router/`. Geometric retention does not establish
material strength or insertion force. The results apply to the simplified
envelopes and parameters in the source.
