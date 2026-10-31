// Experimental soldered-wire contact alternative to protected_snap_cradle.scad.
// User: 69 mm cell, insulated wire about 1 mm, only bare wire through the wall.
// Bare conductor diameter, solder shape and electrical performance are unmeasured.
part = "assembly"; // tray, empty, assembly, contacts, section and build probes
cell_d = 18;
cell_l = 69;
wire_hole_d = 1.2; // passes ~1 mm insulated body when installing a cold formed head
pocket_d = 3;
pocket_depth = 0.5;
head_d = 2.8; // illustrative formed solder head, with clearance inside pocket
head_proud = 0.6; // each head projects this far from the inner wall
bare_wire_d = 0.5; // preview only, not a measurement
mount_lift = 2;
base_l = 67;
upper_l = 71.8;
end_t = 1;
floor_t = 1.8;
shell_t = 1.6;
radial_clearance = 0.05;
rib_w = 24;
end_relief = 1.2;
lip_angle = 25;
tip_round = 0.3;
mark_h = 0.5;
mark_size = 5;
mark_stroke = 0.8;
mark_offset = 6; // move both symbols beside the central wire paths
$fn = 128;

inside_r = cell_d/2+radial_clearance;
outside_r = inside_r+shell_t;
base_w = 2*outside_r;
cy = outside_r;
cell_z = floor_t+cell_d/2;
end_h = cell_z+4;
cell_start = (upper_l-cell_l)/2;
preload = cell_l-(upper_l-2*end_t-2*head_proud);
stations = [end_t+end_relief+rib_w/2,upper_l-end_t-end_relief-rib_w/2];
assert(wire_hole_d>1 && wire_hole_d<pocket_d-0.8,
       "Allow the approximately 1 mm insulated body through for cold head assembly");
assert(pocket_depth>0 && end_t-pocket_depth>=0.4);
assert(head_d<pocket_d && bare_wire_d<wire_hole_d && preload>=0);
assert(cy+mark_offset+mark_size/2<base_w && mount_lift>0);

module section_profile() {
    offset(r=tip_round) offset(delta=-tip_round)
        polygon(concat(
            [for(a=[180-lip_angle:1:360+lip_angle])
                [outside_r*cos(a),cell_z+outside_r*sin(a)]],
            [for(a=[360+lip_angle:-1:180-lip_angle])
                [inside_r*cos(a),cell_z+inside_r*sin(a)]]));
}

// Map the negative-end contact into either end, pointing into the battery space.
module at_end(positive=false, spread=0) {
    if(positive) translate([upper_l+spread,0,0]) mirror([1,0,0]) children();
    else translate([-spread,0,0]) children();
}

module x_cylinder(x,d,h) {
    translate([x,cy,cell_z]) rotate([0,90,0]) cylinder(d=d,h=h);
}

module end_flap(positive=false) {
    difference() {
        union() {
            cube([end_t,base_w,end_h]);
            translate([-mark_h,cy+mark_offset-mark_size/2,cell_z-mark_stroke/2])
                cube([mark_h+0.1,mark_size,mark_stroke]);
            if(positive)
                translate([-mark_h,cy+mark_offset-mark_stroke/2,cell_z-mark_size/2])
                    cube([mark_h+0.1,mark_stroke,mark_size]);
        }
        x_cylinder(-0.1,wire_hole_d,end_t+0.2);
        x_cylinder(end_t-pocket_depth,pocket_d,pocket_depth+0.1);
    }
}

module cradle(spread=0) {
    union() {
        cube([base_l,base_w,mount_lift+floor_t]);
        translate([0,0,mount_lift]) {
            cube([upper_l,base_w,floor_t]);
            for(positive=[false,true]) at_end(positive,spread) end_flap(positive);
            for(x=stations) translate([x-rib_w/2,cy,0]) rotate([90,0,90])
                linear_extrude(rib_w) section_profile();
        }
    }
}

module solder_head() {
    // Geometric target for a pre-formed wire end; this metal is NOT printed.
    r = (pow(head_d/2,2)+pow(head_proud,2))/(2*head_proud);
    x_cylinder(end_t-pocket_depth,head_d,pocket_depth+0.001);
    translate([end_t,cy,cell_z]) rotate([0,90,0])
        rotate_extrude($fn=96) polygon(concat(
            [[0,-0.1],[head_d/2,-0.1]],
            [for(j=[0:24]) let(rad=head_d/2*(1-j/24))
                [rad,head_proud-r+sqrt(r*r-rad*rad)]]));
}

module heads(spread=0) {
    translate([0,0,mount_lift])
        for(positive=[false,true]) at_end(positive,spread) solder_head();
}

module wires() {
    translate([0,0,mount_lift])
        for(positive=[false,true]) at_end(positive)
            x_cylinder(-3,bare_wire_d,3+end_t-pocket_depth);
}

module cell(lift=0) {
    translate([cell_start,cy,cell_z+mount_lift+lift]) rotate([0,90,0])
        cylinder(d=cell_d,h=cell_l);
}

if(part=="tray") cradle();
else if(part=="heads") heads();
else if(part=="interference") intersection() { cradle(); cell(); }
else if(part=="retention") intersection() { cradle(); cell(0.8); }
else if(part=="head-interference") intersection() { cradle(); heads(); }
else if(part=="wire-interference") intersection() { cradle(); wires(); }
else if(part=="contact-preload") intersection() { heads(); cell(); }
else if(part=="relieved-interference") intersection() {
    union() { cradle(preload/2); heads(preload/2); } cell();
}
else if(part=="footprint") intersection() {
    cradle(); translate([-1,-1,0]) cube([upper_l+2,base_w+2,0.01]);
}
else if(part=="overhang-clearance") intersection() {
    cradle(); translate([base_l+0.01,-1,-0.01])
        cube([upper_l-base_l+1,base_w+2,mount_lift]);
}
else if(part=="section") {
    color("SteelBlue") render() intersection() {
        cradle(); translate([-1,cy-0.2,0]) cube([upper_l+2,0.4,30]);
    }
    color("Silver") heads();
    color([0.72,0.38,0.18]) wires();
}
else {
    color("SteelBlue") render() cradle();
    if(part!="empty") {
        color("Silver") render() heads();
        color([0.72,0.38,0.18]) wires();
    }
    if(part=="assembly") color([0.3,0.32,0.35]) cell();
}
