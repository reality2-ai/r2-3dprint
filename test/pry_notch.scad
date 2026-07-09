// Pry notch detail render
// Shows the channel far-end with the half-round scoop for lid removal

use <../src/xiao_case.scad>

// Rotate to view the channel end from above, showing the pry notch
translate([0, 0, 14])
    rotate([0, -90, 0])
        case_body();
