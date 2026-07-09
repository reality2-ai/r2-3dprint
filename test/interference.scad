use <../src/xiao_case.scad>
lift = 0;
// lid_z0 = outer_h - seat - lid_h = 14.0 - 0.4 - 2.0 = 11.6
intersection(){
    case_body();
    translate([0,0,11.4 + lift]) lid();
}
