// Logo deboss detail render
// Shows the case floor face (visible outer face when installed)
// The debossed logos are on the floor (the face that prints on the bed)

use <../src/xiao_case.scad>

// Position camera to look at the floor face from below
$vpd = 150;  // camera distance
$vpt = [10, 45, 0];  // look at floor center
$vpr = [0, 0, 0];  // camera rotation (looking straight down)

// Case in normal orientation - floor at z=0, debossed from below
case_body();
