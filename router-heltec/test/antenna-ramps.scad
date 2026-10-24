// Interior view of both reinforcement pads and their sloping undersides.
use <../src/router_heltec_case.scad>
$vpt = [70,139,18];
$vpr = [110,0,20];
$vpd = 270;
color("#d8ddd9") render(convexity=10) intersection() {
    base();
    // Section omits the floor so the sloping undersides remain visible.
    translate([12,130,5]) cube([116,15,27]);
}
