// Radar Sensor Box: 64 x 18 mm reported cells, plus retained 1 mm print-fit allowance.
// Sliding bars rest on the cells; forked far-end catches prevent withdrawal.
// Units: mm. Contact force, latch durability and actual box fit remain unverified.
cells = 2;
part = "tray"; // tray, bar, contact-fit, assembly, service, tape-preview, latch-detail
cell_l = 64;
cell_d = 18;
length_fit_allowance = 1.0;
outside_l = 66.8; // user-approved 67 mm maximum, with 0.2 mm print margin
tape_t = 0.10;
end_t = 0.8;
preload = 0.2;
floor_t = 1.0;
side_t = 0.8;
divider_t = 0.8;
diametral_clearance = 0.3;
end_relief = 0.8;
bar_w = 6;
bar_t = 2;
bar_clearance = 0.2; // slot clearance, not a gap above the battery
slot_roof = 1.0;
rib_projection = 1.0;
rib_w = 1.2;
rib_head_gap = 0.3;
head_w = 8;
head_l = 2;
tail_l = 3;
fork_root_inset = 7;
fork_arm_w = 1.2;
fork_root_r = 0.6;
catch_projection = 0.6;
catch_end_gap = 0.3;
release_squeeze = 0.9; // inward free-tip movement per fork; geometric proxy
nose_r = 0.4;
check_index = 0;
check_side = 0;
check_cell = 0;
$fn = 96;

n = part=="contact-fit" ? 1 : cells;
lane = cell_d + diametral_clearance;
pitch = lane + divider_t;
// Use a common exact binary datum for the far face in 2D extrusions and 3D
// transforms; avoids microscopic CGAL seams (rounding is below 0.000008 mm).
tray_w = round((2*side_t + n*lane + (n-1)*divider_t)*65536)/65536;
cell_z = floor_t + cell_d/2;
packed_h = floor_t + cell_d;
fit_l = cell_l + length_fit_allowance;
cell_x = (outside_l-fit_l)/2;
travel = end_t + preload + tape_t - cell_x;
leaf_top = cell_z + 2;
land_z = cell_z - 2;
bar_centres = [outside_l/4,3*outside_l/4];
bar_z = packed_h; // EXACT nominal contact with the top of the cells
slot_bottom = bar_z - bar_clearance;
slot_top = bar_z + bar_t + bar_clearance;
wall_h = slot_top + slot_roof;
rail_start = round((end_t + preload + end_relief)*65536)/65536;
fork_root = tray_w - fork_root_inset;
tail_end = tray_w + tail_l;
withdrawal = tray_w + tail_l + 0.5;
function cy(i) = side_t + lane/2 + i*pitch;

assert(n>=1 && n<=3 && floor(n)==n);
assert(outside_l<=67,"Outside length exceeds the revised user limit");
assert(length_fit_allowance>=0);
assert(cell_x>=end_t+tape_t-0.0001,
       "Fit envelope + contact walls + tape exceed the length budget");
assert(travel>0 && travel<=preload+0.0001);
assert(floor_t>=1 && end_relief>=0.6);
assert(catch_projection>bar_clearance);
assert(fork_arm_w>=1 && fork_root_r>0 && fork_root_r<bar_w/2-fork_arm_w);
assert(nose_r<bar_t && nose_r>0);
assert(slot_roof>=1);
echo(cells=n, tray_mm=[outside_l,tray_w+2*rib_projection,wall_h],
     assembled_mm=[outside_l,tray_w+head_l+tail_l,wall_h],
     reported_cell_l_mm=cell_l, fit_envelope_l_mm=fit_l,
     relaxed_taped_gap_mm=outside_l-2*(end_t+preload+tape_t),
     battery_top_mm=packed_h, bar_underside_mm=bar_z,
     side_withdrawal_mm=withdrawal);

module end_wall(right=false,seated=false) {
    inset=preload-(seated ? travel : 0);
    module left_wall() {
        translate([0,tray_w,0]) rotate([90,0,0]) linear_extrude(tray_w)
            polygon([[0,0],[end_t,0],[end_t,2],[end_t+inset,land_z],
                     [end_t+inset,leaf_top],[inset,leaf_top],[inset,land_z],[0,2]]);
    }
    if(right) translate([outside_l,0,0]) mirror([1,0,0]) left_wall();
    else left_wall();
}

// Keep the entire cell-lifting path full-width. Outside ribs stiffen the tall
// rails without narrowing the opening above the cells or blocking the pull head.
module outer_rail(right=false) {
    y0=right ? tray_w-side_t : 0;
    y1=right ? tray_w : side_t;
    ry0=right ? tray_w-side_t : -rib_projection;
    ry1=right ? tray_w+rib_projection : side_t;
    linear_extrude(wall_h) union() {
        polygon([[rail_start,y0],[outside_l-rail_start,y0],
                 [outside_l-rail_start,y1],[rail_start,y1]]);
        for(x=bar_centres) for(dx=[-head_w/2-rib_head_gap-rib_w,
                                  head_w/2+rib_head_gap])
            polygon([[x+dx,ry0],[x+dx+rib_w,ry0],
                     [x+dx+rib_w,ry1],[x+dx,ry1]]);
    }
}

module tray(seated=false) {
    difference() {
        union() {
            linear_extrude(floor_t) square([outside_l,tray_w]);
            outer_rail(); outer_rail(true);
            end_wall(false,seated); end_wall(true,seated);
            if(n>1) for(i=[1:n-1]) {
                y=side_t+i*lane+(i-1)*divider_t;
                translate([rail_start,y,0])
                    cube([outside_l-2*rail_start,divider_t,cell_z]);
                for(x=bar_centres)
                    translate([x-5,y,0]) cube([10,divider_t,wall_h]);
            }
        }
        for(x=bar_centres)
            translate([x-bar_w/2-bar_clearance,-0.01,slot_bottom])
                cube([bar_w+2*bar_clearance,tray_w+0.02,bar_t+2*bar_clearance]);
    }
}

module one_cell(i,lift=0,include_fit_allowance=true) {
    length=include_fit_allowance ? fit_l : cell_l;
    translate([(outside_l-length)/2,cy(i),cell_z+lift])
        rotate([0,90,0]) cylinder(d=cell_d,h=length);
}
module cell_envelopes(lift=0,include_fit_allowance=true) {
    for(i=[0:n-1]) one_cell(i,lift,include_fit_allowance);
}

// The two prongs flex sideways in the print-layer plane. The central bar and
// head are rigid; only the last 10 mm fork is relieved. Rounded slot roots
// avoid a sharp-ended stress notch. This release shape does not simulate force.
module bar_profile(squeeze=0) {
    function deflect(y)=squeeze*max(0,(y-fork_root)/(tail_end-fork_root));
    function p(x,y)=[x-deflect(y),y];
    inner=bar_w/2-fork_arm_w;
    module right_prong() {
        polygon(concat([
            p(bar_w/2,fork_root-0.01),
            p(bar_w/2,tray_w+catch_end_gap),
            p(bar_w/2+catch_projection,tray_w+catch_end_gap),
            p(bar_w/2+catch_projection,tray_w+0.8),
            p(bar_w/2,tail_end-0.6),
            p(bar_w/2,tail_end),
            p(inner,tail_end),
            p(inner,fork_root+fork_root_r)],
            [for(a=[-10:-10:-90])
                p(inner-fork_root_r+fork_root_r*cos(a),
                  fork_root+fork_root_r+fork_root_r*sin(a))],
            [p(inner-fork_root_r,fork_root-0.01)]));
    }
    union() {
        translate([-head_w/2,-head_l]) square([head_w,head_l-0.2]);
        translate([-bar_w/2,-0.3]) square([bar_w,fork_root+0.31]);
        right_prong();
        mirror([1,0,0]) right_prong();
    }
}

module bar_local(squeeze=0) {
    // Round the bottom of the leading tip while retaining a flat bearing face.
    intersection() {
        linear_extrude(bar_t) bar_profile(squeeze);
        union() {
            translate([-head_w,-head_l,0])
                cube([2*head_w,tail_end-nose_r+head_l,bar_t]);
            translate([-head_w,tail_end-nose_r,nose_r])
                cube([2*head_w,nose_r,bar_t-nose_r]);
            translate([-head_w,tail_end-nose_r,nose_r])
                rotate([0,90,0]) cylinder(r=nose_r,h=2*head_w,$fn=32);
        }
    }
}
module bar_installed(x=0,shift=0,squeeze=0,lift=0) {
    translate([x,shift,bar_z+lift]) bar_local(squeeze);
}
module bars(shift=0,squeeze=0,lift=0) {
    for(x=bar_centres) bar_installed(x,shift,squeeze,lift);
}
module bar_print() {
    translate([head_w/2,head_l,0]) bar_local();
}
module board() {
    translate([-4,-4,-1]) cube([outside_l+8,tray_w+8,1]);
}

// The wide head never passes through a slot. Sweep it separately from the
// squeezed shaft so a convex hull cannot invent a wider bar inside the holder.
module bar_removal_sweep() {
    for(x=bar_centres) for(head=[true,false]) hull() {
        intersection() {
            bar_installed(x,0,release_squeeze);
            translate([x-head_w,head ? -head_l-0.01 : -0.19,bar_z-0.01])
                cube([2*head_w,head ? head_l-0.18 : tail_end+0.2,bar_t+0.02]);
        }
        intersection() {
            bar_installed(x,-withdrawal,release_squeeze);
            translate([x-head_w,(head ? -head_l-0.01 : -0.19)-withdrawal,bar_z-0.01])
                cube([2*head_w,head ? head_l-0.18 : tail_end+0.2,bar_t+0.02]);
        }
    }
}
module cell_removal_sweep() {
    for(i=[0:n-1]) hull() { one_cell(i); one_cell(i,30); }
}
module hook_mask() {
    x=bar_centres[check_index];
    translate([x+(check_side==0 ? -bar_w/2-catch_projection-0.1 : bar_w/2),
               tray_w-side_t-0.01,bar_z-0.01])
        cube([catch_projection+0.1,side_t+1,bar_t+0.02]);
}
module contact_patches() {
    for(i=[0:n-1]) for(x=[cell_x-tape_t,cell_x+fit_l])
        translate([x,cy(i)-2,cell_z-1.5]) cube([tape_t,4,3]);
}
module copper_strips(seated=true) {
    inset=preload-(seated ? travel : 0);
    for(x=[end_t+inset,outside_l-end_t-inset-tape_t])
        translate([x,0.4,land_z+0.2]) cube([tape_t,tray_w-0.8,3.6]);
}
module preload_masks() {
    for(x=[0,outside_l-1.3])
        translate([x,-0.01,floor_t]) cube([1.3,tray_w+0.02,leaf_top]);
}
module tape_land_probe() {
    for(x=[end_t+preload-0.1,outside_l-end_t-preload])
        translate([x,0.4,land_z+0.2]) cube([0.1,tray_w-0.8,3.6]);
}
module end_relief_probe() {
    for(x=[end_t+preload+0.01,outside_l-end_t-preload-end_relief+0.01])
        translate([x,-0.01,floor_t+0.01])
            cube([end_relief-0.02,tray_w+0.02,wall_h]);
}

if(part=="tray" || part=="contact-fit") tray();
else if(part=="bar") bar_print();
else if(part=="assembly") {
    color("SteelBlue") render() tray(true);
    color([0.3,0.32,0.35]) cell_envelopes();
    color("DarkOrange") contact_patches();
    color([0.95,0.54,0.1]) bars();
}
else if(part=="service") {
    color("SteelBlue") render() tray(true);
    color([0.3,0.32,0.35]) cell_envelopes(16);
    color([0.95,0.54,0.1]) bars(-withdrawal,release_squeeze);
    color([0.6,0.65,0.65]) board();
}
else if(part=="latch-detail") {
    translate([-bar_centres[0],-tray_w,-bar_z]) {
        color("SteelBlue") render() intersection() {
            tray(true);
            translate([bar_centres[0]-6,tray_w-10,16]) cube([12,15,8]);
        }
        color([0.95,0.54,0.1]) render() intersection() {
            bars();
            translate([bar_centres[0]-6,tray_w-10,16]) cube([12,15,8]);
        }
    }
}
else if(part=="tape-preview") {
    color("SteelBlue") render() tray(true);
    color("DarkOrange") copper_strips();
}
else if(part=="tape-land-missing") difference() { tape_land_probe(); tray(); }
else if(part=="end-relief-interference") intersection() { end_relief_probe(); tray(); }
else if(part=="seated-interference") intersection() { tray(true); cell_envelopes(); }
else if(part=="nominal-cell-interference") intersection() {
    tray(); cell_envelopes(include_fit_allowance=false);
}
else if(part=="unexpected-interference") difference() {
    intersection() { tray(); cell_envelopes(); }
    preload_masks();
}
else if(part=="preload-interference") intersection() { tray(); cell_envelopes(); }
else if(part=="bar-interference") intersection() {
    bars(); union() { tray(true); cell_envelopes(); }
}
else if(part=="bar-retention") intersection() {
    bars(-0.6); tray(true); hook_mask();
}
else if(part=="head-stop") intersection() { bars(0.4); tray(true); }
else if(part=="cell-contact") intersection() { bars(); one_cell(check_cell,0.05); }
else if(part=="cell-retention") intersection() {
    bars(lift=bar_clearance); one_cell(check_cell,0.4);
}
else if(part=="bar-lift-retention") intersection() { bars(lift=0.4); tray(true); }
else if(part=="bearing-height") bars();
else if(part=="bar-removal-interference") intersection() {
    bar_removal_sweep(); union() { tray(true); cell_envelopes(); board(); }
}
else if(part=="cell-removal-interference") intersection() {
    cell_removal_sweep(); union() { tray(true); board(); }
}
else if(part=="board-interference") intersection() { bars(); board(); }
else assert(false,"Unknown part");
