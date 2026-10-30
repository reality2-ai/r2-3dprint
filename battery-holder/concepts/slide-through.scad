// Visual concept for discussion, NOT a qualified replacement print file.
// Taller walls carry rigid bars through slots above the cells.
// A bar stop/lock and actual removal access remain to be decided.
cells = 2;
view = "assembled"; // assembled, withdrawn, empty, interference
$fn = 96;
length = 66.8;
width = 19.9 + (cells-1)*19.1;
height = 22.8;
bar_centres = [length/4,3*length/4];
withdrawal = width+4;

assert(cells>=1 && cells<=3 && floor(cells)==cells);

// Wall grows inward above the cell shoulder, strengthening the slot surround
// without increasing the tray footprint. Both end contact walls stay separate.
module outer_wall(right=false) {
    module left_wall() {
        translate([1.8,0,0]) rotate([90,0,90]) linear_extrude(length-3.6)
            polygon([[0,0],[0.8,0],[0.8,14],[1.8,15],[1.8,height],[0,height]]);
    }
    if(right) translate([0,width,0]) mirror([0,1,0]) left_wall();
    else left_wall();
}

module contact_wall(right=false) {
    // Seated 0.8 mm contact wall, matching the current contact-fit envelope.
    translate([right ? length-0.8 : 0,0,0]) cube([0.8,width,12]);
}

module tray() {
    difference() {
        union() {
            cube([length,width,1]);
            outer_wall(); outer_wall(true);
            contact_wall(); contact_wall(true);
            if(cells>1) for(i=[1:cells-1]) {
                y=0.8+i*18.3+(i-1)*0.8;
                translate([1.8,y,0]) cube([length-3.6,0.8,10]);
                // Local supports at each bar limit its unsupported span to
                // one cell, rather than the full multi-cell holder width.
                for(x=bar_centres)
                    translate([x-5,y,0]) rotate([90,0,90]) linear_extrude(10)
                        polygon([[0,0],[0.8,0],[0.8,14],[1.3,15],
                                 [1.3,height],[-0.5,height],[-0.5,15],[0,14]]);
            }
        }
        for(x=bar_centres) translate([x-3.2,-0.01,19.2])
            cube([6.4,width+0.02,2.4]);
    }
}

module bar(x, distance=0) {
    translate([x,-distance,19.4]) union() {
        translate([-3,-0.2,0]) cube([6,width+0.7,2]);
        // Outside pull head also stops over-insertion. No locking detent yet.
        translate([-4,-2,0]) cube([8,2,2]);
    }
}

module cell_envelopes(lift=0) {
    // 65 mm = original reported 64 mm + the retained 1 mm print-fit allowance.
    for(i=[0:cells-1]) translate([0.9,9.95+i*19.1,10+lift])
        rotate([0,90,0]) cylinder(d=18,h=65);
}

module copper() {
    for(x=[0.8,length-0.9]) translate([x,0.4,8.2]) cube([0.1,width-0.8,3.6]);
}

module board() {
    translate([-4,-4,-1]) cube([length+8,width+8,1]);
}

if(view=="interference") intersection() {
    tray(); union() { cell_envelopes(); for(x=bar_centres) bar(x); }
}
else {
    color([0.68,0.72,0.70]) board();
    color("SteelBlue") tray();
    color("DarkOrange") copper();
    if(view!="empty") color([0.27,0.29,0.32])
        cell_envelopes(view=="withdrawn" ? 16 : 0);
    for(x=bar_centres) color([0.95,0.54,0.1])
        bar(x,view=="withdrawn" ? withdrawal : 0);
}
