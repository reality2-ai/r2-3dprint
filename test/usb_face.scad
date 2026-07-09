// USB face view - shows the -Y side with USB window
use <../src/xiao_case.scad>

translate([0, 0, 14])
    rotate([90, 0, 0])
        case_body();
