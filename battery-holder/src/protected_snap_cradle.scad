// Protected-cell variant: user-confirmed 69 mm overall cell length including cap.
// Diameter remains the previous 18 mm assumption; cap shape is not modeled.
// Single cell only: raising two cells above the thermistor prevents lid closure.
// The shallow 2 mm step provides an overhang, not clearance above that connector.
cells = 1;
occupied_cells = 1;
part = "assembly"; // assembly, section, empty, tray, interference, unexpected-interference, relieved-interference, retention, footprint, overhang-clearance
cell_d = 18;
cell_l = 69;
length_clearance = 0.6; // total allowance carried over from successful short holder
mount_lift = 2; // shallow step under overhang; verify single-cell lid clearance
radial_clearance = 0.05;
shell_t = 1.6;
floor_t = 1.8;
base_l = 67; // shortened 1 mm after physical fit between components
rib_w = 24;
end_t = 1;
end_relief = 1.2; // keep curved sides separate from the contact walls
tape_t = 0.1; // illustrative only; actual tape thickness unmeasured
tape_band_h = 6;
contact_bump_h = 1; // deliberate end-wall preload, requested after physical trial
contact_bump_d = 5; // shallow rounded cap, centred on the flush-end terminal
mark_h = 0.5; // raised polarity marks on the outside end flaps
mark_size = 5;
mark_stroke = 0.8;
lip_angle = 20; // degrees above the equator; a small undercut for retention
tip_round = 0.3;
between_shells = 0.8;
$fn = 128;

upper_l = cell_l+length_clearance+2*(end_t+tape_t);
inside_r = cell_d/2+radial_clearance;
outside_r = inside_r+shell_t;
pitch = 2*outside_r+between_shells;
base_w = 2*outside_r+(cells-1)*pitch;
cell_z = floor_t+cell_d/2;
end_h = cell_z+4;
contact_preload = max(0,contact_bump_h-length_clearance);
// Centre the cell between contacts; negative clearance represents end-wall flex.
cell_start = end_t+tape_t+contact_bump_h+(length_clearance-contact_bump_h)/2;
stations = [end_t+end_relief+rib_w/2,upper_l-end_t-end_relief-rib_w/2];
function cy(i)=outside_r+i*pitch;
assert(cells==1 && occupied_cells>=0 && occupied_cells<=cells,
       "Protected-cell version is single only: two cells cannot clear the lid");
assert(2*(end_t+end_relief+rib_w)<upper_l, "Leave a central access gap");
assert(contact_bump_h>0 && contact_bump_h<=1,
       "Bump heights above the requested 1 mm need another preload review");

module contact_bump() {
    // Revolve the cap profile directly to avoid sliver facets from cutting a sphere.
    r = (pow(contact_bump_d/2,2)+pow(contact_bump_h,2))/(2*contact_bump_h);
    for(i=[0:cells-1])
        translate([end_t,cy(i),cell_z]) rotate([0,90,0])
            rotate_extrude($fn=96) polygon(concat(
                [[0,-0.1],[contact_bump_d/2,-0.1]],
                [for(j=[0:24]) let(rad=contact_bump_d/2*(1-j/24))
                    [rad,contact_bump_h-r+sqrt(r*r-rad*rad)]]));
}

module section_profile() {
    // Round the cut lip corners. Inner contact surface remains a smooth arc.
    offset(r=tip_round) offset(delta=-tip_round)
        polygon(concat(
            [for(a=[180-lip_angle:1:360+lip_angle])
                [outside_r*cos(a),cell_z+outside_r*sin(a)]],
            [for(a=[360+lip_angle:-1:180-lip_angle])
                [inside_r*cos(a),cell_z+inside_r*sin(a)]]));
}

assert(mount_lift>0 && upper_l>=base_l);

module polarity_marks(end_spread=0) {
    for(i=[0:cells-1]) {
        // Minus: flush end, beside the raised negative contact on the inside.
        translate([-mark_h-end_spread,cy(i)-mark_size/2,cell_z-mark_stroke/2])
            cube([mark_h+0.1,mark_size,mark_stroke]);
        // Plus: opposite end. Both strokes embed 0.1 mm into the wall.
        translate([upper_l-0.1+end_spread,cy(i)-mark_size/2,cell_z-mark_stroke/2])
            cube([mark_h+0.1,mark_size,mark_stroke]);
        translate([upper_l-0.1+end_spread,cy(i)-mark_stroke/2,cell_z-mark_size/2])
            cube([mark_h+0.1,mark_stroke,mark_size]);
    }
}

module upper_cradle(end_spread=0) {
    union() {
        cube([upper_l,base_w,floor_t]);
        // Unbroken backing across every cell, with a flat top for tape wrap-over.
        for(x=[-end_spread,upper_l-end_t+end_spread])
            translate([x,0,0]) cube([end_t,base_w,end_h]);
        translate([-end_spread,0,0]) contact_bump();
        polarity_marks(end_spread);
        for(i=[0:cells-1]) for(x=stations)
            translate([x-rib_w/2,cy(i),0]) rotate([90,0,90])
                linear_extrude(rib_w) section_profile();
    }
}

module cradle(end_spread=0) {
    union() {
        // 67 mm mounting face, flush at X=0; upper tray overhangs only at +X.
        cube([base_l,base_w,mount_lift+floor_t]);
        translate([0,0,mount_lift]) upper_cradle(end_spread);
    }
}

module contact_masks(lift=0) {
    // Only the small axial overlaps at the two terminal faces are intentional.
    translate([cell_start-0.001,0,mount_lift+floor_t+lift-0.001])
        cube([max(0,end_t+contact_bump_h-cell_start)+0.002,base_w,cell_d+0.002]);
    translate([upper_l-end_t-0.001,0,mount_lift+floor_t+lift-0.001])
        cube([max(0,cell_start+cell_l-(upper_l-end_t))+0.002,base_w,cell_d+0.002]);
}

module cell_sections(lift=0, count=occupied_cells) {
    if(count>0) for(i=[0:count-1])
        translate([cell_start,cy(i),cell_z+mount_lift+lift]) rotate([0,90,0])
            cylinder(d=cell_d,h=cell_l);
}

module tape_preview() {
    // Illustrative tape pressed over the bump; actual tape forming is untested.
    translate([0,0,mount_lift]) {
        difference() {
            union() {
                translate([end_t,0,cell_z-tape_band_h/2])
                    cube([tape_t,base_w,tape_band_h]);
                translate([tape_t,0,0]) contact_bump();
            }
            contact_bump();
            translate([-1,-1,-1]) cube([end_t+1,base_w+2,end_h+2]);
        }
        translate([upper_l-end_t-tape_t,0,cell_z-tape_band_h/2])
            cube([tape_t,base_w,tape_band_h]);
    }
}

if(part=="interference") intersection() { cradle(); cell_sections(count=cells); }
else if(part=="unexpected-interference") difference() {
    intersection() { cradle(); cell_sections(count=cells); }
    contact_masks();
}
else if(part=="relieved-interference") intersection() {
    // Geometric clearance proxy only: translate each end by half the preload.
    // This does not simulate the wall's bend, contact force or fatigue.
    cradle(contact_preload/2); cell_sections(count=cells);
}
else if(part=="retention") difference() {
    intersection() { cradle(); cell_sections(0.8,count=cells); }
    contact_masks(0.8); // end pressure alone must not count as curved-lip capture
}
else if(part=="tray") cradle();
else if(part=="footprint") intersection() {
    cradle(); translate([-1,-1,0]) cube([upper_l+2,base_w+2,0.01]);
}
else if(part=="overhang-clearance") intersection() {
    cradle(); translate([base_l+0.01,-1,-0.01])
        cube([upper_l-base_l+1,base_w+2,mount_lift]);
}
else if(part=="section") {
    color("SteelBlue") render() intersection() {
        cradle(); translate([stations[0]-rib_w/2,-1,-1]) cube([rib_w,base_w+2,cell_d+mount_lift+10]);
    }
    color([0.3,0.32,0.35]) render() intersection() {
        cell_sections(); translate([stations[0]-rib_w/2,-1,-1]) cube([rib_w,base_w+2,cell_d+mount_lift+10]);
    }
}
else {
    color("SteelBlue") render() cradle();
    color([0.72,0.38,0.18]) tape_preview();
    if(part!="empty") color([0.3,0.32,0.35]) cell_sections();
}
