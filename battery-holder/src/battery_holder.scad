// Radar Sensor Box: user-measured 64 x 18 mm cells, parallel, 66 mm HARD limit.
// Units: mm. Prototype: contact force, tape thickness and print fit unverified.
// OPENSCAD -D 'cells=3' -D 'part="tray"' ...
cells = 2;
part = "tray"; // tray, band, assembly, contact-fit; verification scenes below
cell_l = 64;
cell_d = 18;
outside_l = 65.8; // leaves 0.2 mm nominal manufacturing margin to 66
tape_t = 0.10; // provisional TOTAL copper + adhesive thickness on EACH contact
end_t = 0.8;
preload = 0.2; // inward position of each relaxed end wall at terminal height
floor_t = 1.0;
side_t = 0.8;
divider_t = 0.8;
diametral_clearance = 0.3;
end_relief = 0.8; // gap between the moving end wall and longitudinal rails
band_w = 5;
band_t = 0.8;
band_clearance = 0.2; // each side, above and below tray/cells
groove_depth = 0.35;
groove_slack = 0.4;
rib_h = 0.45;
$fn = 96;

n = part == "contact-fit" ? 1 : cells;
lane = cell_d + diametral_clearance;
pitch = lane + divider_t;
tray_w = 2*side_t + n*lane + (n-1)*divider_t;
cell_z = floor_t + cell_d/2;
packed_h = floor_t + cell_d;
cell_x = (outside_l-cell_l)/2;
// Required outward travel to seat the measured cell with the assumed tape.
travel = end_t + preload + tape_t - cell_x;
leaf_top = cell_z + 2;
land_z = cell_z - 2;
band_centres = [outside_l/4, 3*outside_l/4];
function cy(i) = side_t + lane/2 + i*pitch;

assert(n >= 1 && n <= 3 && floor(n)==n);
assert(outside_l <= 66, "Outside length exceeds the user limit");
assert(cell_x >= end_t+tape_t-0.0001,
       "Cell + two end walls + tape exceed the length budget; do not grow past 66");
assert(travel > 0 && travel <= preload+0.0001,
       "Contact travel must stay within the recessed leaf allowance");
assert(floor_t-groove_depth >= 0.6);
assert(end_relief >= 0.6);
assert(band_clearance < rib_h && rib_h-band_clearance < groove_depth);

echo(cells=n, tray_mm=[outside_l,tray_w,leaf_top],
     loaded_with_bands_mm=[outside_l,tray_w+2*(band_clearance+band_t),
                          packed_h+2*(band_clearance+band_t)],
     per_contact_travel_mm=travel, tape_assumption_mm=tape_t);

// One continuous 0.8 mm end wall across ALL cells, rooted along the floor.
// Rails stop short so they cannot brace the moving wall. The uninterrupted
// upper land supports one copper strip per end. 'seated' is a clearance proxy,
// NOT a beam simulation; a common wall no longer gives independent cell travel.
module end_wall(right=false, seated=false) {
    inset = preload - (seated ? travel : 0);
    module left_leaf() {
        translate([0,tray_w,0]) rotate([90,0,0])
            linear_extrude(tray_w)
                polygon([[0,0],[end_t,0],[end_t,2],
                         [end_t+inset,land_z],[end_t+inset,leaf_top],
                         [inset,leaf_top],[inset,land_z],[0,2]]);
    }
    if (right) translate([outside_l,0,0]) mirror([1,0,0]) left_leaf();
    else left_leaf();
}

module tray(seated=false) {
    difference() {
        union() {
            cube([outside_l,tray_w,floor_t]);
            for (y=[0,tray_w-side_t])
                translate([end_t+preload+end_relief,y,0])
                    cube([outside_l-2*(end_t+preload+end_relief),side_t,cell_z]);
            end_wall(false,seated);
            end_wall(true,seated);
            if (n>1) for (i=[1:n-1])
                translate([end_t+preload+end_relief,
                           side_t+i*lane+(i-1)*divider_t,0])
                    cube([outside_l-2*(end_t+preload+end_relief),divider_t,cell_z]);
        }
        // The band rib engages these underside grooves without extra length.
        for (x=band_centres)
            translate([x-(band_w+groove_slack)/2,-0.01,-0.01])
                cube([band_w+groove_slack,tray_w+0.02,groove_depth+0.01]);
    }
}

module cell_envelopes(lift=0) {
    for (i=[0:n-1]) translate([cell_x,cy(i),cell_z+lift])
        rotate([0,90,0]) cylinder(d=cell_d,h=cell_l);
}

// A complete ring, printed flat on its broad rim, slides over the end of the
// loaded tray. A small underside rib seats in the tray groove. Print two rings.
module band_installed(x=0) {
    translate([x-band_w/2,0,0]) union() {
        difference() {
            translate([0,-band_clearance-band_t,-band_clearance-band_t])
                cube([band_w,tray_w+2*(band_clearance+band_t),
                      packed_h+2*(band_clearance+band_t)]);
            translate([-0.01,-band_clearance,-band_clearance])
                cube([band_w+0.02,tray_w+2*band_clearance,
                      packed_h+2*band_clearance]);
        }
        translate([0,2,-band_clearance-0.05])
            cube([band_w,tray_w-4,rib_h+0.05]);
    }
}

module band_print() {
    translate([packed_h+band_clearance+band_t,band_clearance+band_t,band_w/2])
        rotate([0,-90,0]) band_installed();
}

module bands(shift=0) {
    for (x=band_centres) band_installed(x+shift);
}

// Only a small central terminal patch is exposed. Routing tails must be
// insulated and run sideways; wrapping tape over the OUTSIDE ends adds length.
module contact_patches() {
    for (i=[0:n-1]) for (x=[cell_x-tape_t,cell_x+cell_l])
        translate([x,cy(i)-2,cell_z-1.5]) cube([tape_t,4,3]);
}

// Illustrative continuous copper tape, before insulating all but the terminal
// patches. Kept wholly on the inner face to preserve the hard outside length.
module copper_strips(seated=true) {
    inset = preload - (seated ? travel : 0);
    for (x=[end_t+inset,outside_l-end_t-inset-tape_t])
        translate([x,0.4,land_z+0.2]) cube([tape_t,tray_w-0.8,3.6]);
}

module preload_masks() {
    for (x=[0,outside_l-1.3])
        translate([x,-0.01,floor_t]) cube([1.3,tray_w+0.02,leaf_top]);
}

// Probe every point of each tape land for uninterrupted backing material.
module tape_land_probe() {
    for (x=[end_t+preload-0.1,outside_l-end_t-preload])
        translate([x,0.4,land_z+0.2]) cube([0.1,tray_w-0.8,3.6]);
}

// Above the shared floor, there must be a real gap between end walls and rails.
module end_relief_probe() {
    for (x=[end_t+preload+0.01,
            outside_l-end_t-preload-end_relief+0.01])
        translate([x,-0.01,floor_t+0.01])
            cube([end_relief-0.02,tray_w+0.02,leaf_top]);
}

if (part=="tray" || part=="contact-fit") tray();
else if (part=="band") band_print();
else if (part=="assembly") {
    color("SteelBlue") tray(true);
    color([0.3,0.32,0.35]) cell_envelopes();
    color("DarkOrange") contact_patches();
    color([0.12,0.5,0.6,0.8]) bands();
}
else if (part=="tape-preview") {
    color("SteelBlue") tray(true);
    color("DarkOrange") copper_strips();
}
else if (part=="tape-land-missing") difference() { tape_land_probe(); tray(); }
else if (part=="end-relief-interference") intersection() { end_relief_probe(); tray(); }
else if (part=="seated-interference") intersection() { tray(true); cell_envelopes(); }
else if (part=="unexpected-interference") difference() {
    intersection() { tray(); cell_envelopes(); }
    preload_masks();
}
else if (part=="preload-interference") intersection() { tray(); cell_envelopes(); }
else if (part=="band-interference") intersection() {
    bands(); union() { tray(true); cell_envelopes(); }
}
else if (part=="band-retention") intersection() { bands(0.5); tray(true); }
else if (part=="cell-retention") intersection() { bands(); cell_envelopes(0.5); }
else assert(false,"Unknown part");
