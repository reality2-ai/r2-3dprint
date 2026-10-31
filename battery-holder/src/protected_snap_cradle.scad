// Protected-cell variant: user-confirmed 69 mm overall cell length including cap.
// Diameter remains the previous 18 mm assumption; cap shape is not modeled.
// Single cell only: raising two cells above the thermistor prevents lid closure.
// The shallow 2 mm step provides an overhang, not clearance above that connector.
cells = 1;
occupied_cells = 1;
part = "assembly"; // assembly, section, empty, tray, interference, retention, footprint, overhang-clearance
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
cell_start = end_t+tape_t+length_clearance/2;
stations = [end_t+end_relief+rib_w/2,upper_l-end_t-end_relief-rib_w/2];
function cy(i)=outside_r+i*pitch;
assert(cells==1 && occupied_cells>=0 && occupied_cells<=cells,
       "Protected-cell version is single only: two cells cannot clear the lid");
assert(2*(end_t+end_relief+rib_w)<upper_l, "Leave a central access gap");

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

module upper_cradle() {
    union() {
        cube([upper_l,base_w,floor_t]);
        // Unbroken backing across every cell, with a flat top for tape wrap-over.
        for(x=[0,upper_l-end_t])
            translate([x,0,0]) cube([end_t,base_w,end_h]);
        for(i=[0:cells-1]) for(x=stations)
            translate([x-rib_w/2,cy(i),0]) rotate([90,0,90])
                linear_extrude(rib_w) section_profile();
    }
}

module cradle() {
    union() {
        // 67 mm mounting face, flush at X=0; upper tray overhangs only at +X.
        cube([base_l,base_w,mount_lift+floor_t]);
        translate([0,0,mount_lift]) upper_cradle();
    }
}

module cell_sections(lift=0, count=occupied_cells) {
    if(count>0) for(i=[0:count-1])
        translate([cell_start,cy(i),cell_z+mount_lift+lift]) rotate([0,90,0])
            cylinder(d=cell_d,h=cell_l);
}

module tape_preview() {
    // Illustrative flat contact bands; terminal/cap contact is not qualified.
    for(x=[end_t,upper_l-end_t-tape_t])
        translate([x,0,cell_z+mount_lift-tape_band_h/2])
            cube([tape_t,base_w,tape_band_h]);
}

if(part=="interference") intersection() { cradle(); cell_sections(count=cells); }
else if(part=="retention") intersection() { cradle(); cell_sections(0.8,count=cells); }
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
