// Rear view without antenna hardware, exposing both circular mounting bores.
use <../src/router_heltec_case.scad>
$vpt = [70,90,16];
$vpr = [65,0,145];
$vpd = 360;
// Resolve the solid for preview too; avoid OpenCSG artefacts in the stepped wall.
color("#d8ddd9") render(convexity=10) base();
