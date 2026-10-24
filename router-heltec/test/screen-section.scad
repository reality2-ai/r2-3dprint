// Front half removed through the display and USB-C centreline.
// Preview only: shows the raised screen and clearance beneath the lid pocket.
use <../src/router_heltec_case.scad>
$vpt=[80,110,28];
$vpr=[75,0,0];
$vpd=155;
intersection() {
    assembly(explode=0);
    translate([40,104.7,18]) cube([86,30,18]);
}
