// Logo deboss detail render
// Shows the case floor face (visible outer face when installed)
// with lighting that highlights the debossed branding

use <../src/xiao_case.scad>

// Rotate to show the floor face (the print bed becomes visible outer surface)
rotate([180, 0, 0])
    case_body();
