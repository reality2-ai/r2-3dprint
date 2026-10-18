// Reality2 home router — Raspberry Pi Model B+ V1.2 + DFR1195.
// Millimetres. Prototype: check the actual cable and bulkhead before printing.

part = "assembly"; // base, lid, hdmi-cover, sd-cover, layout, assembly, closed, service
$fn = 48;
wall = 2.4;
floor_h = 2.4;
base_h = 32;
lid_h = 2.4;
main_w = 102;
cable_bay = 38;
outer_w = main_w + cable_bay;
outer_d = 144;
ethernet_step_y = 29;
corner_r = 4;
pcb_z = 8.4; // board underside; 6 mm air space above floor
pcb_t = 1.6;
pi_xy = [10, 5];
radio_xy = [10, 90]; // same reading direction as Pi and lid lettering
radio_z = 20.4; // raised PCB underside, leaving room for ~8.5 mm headers
board_pilot = 2.1; // M2.5 screws into plastic; tune using test coupon
lid_pilot = 2.6;   // M3 screws into plastic
antenna_hole = 6.5; // provisional SMA bulkhead clearance — MEASURE yours
antenna_panel = 4; // total local wall thickness, including reinforcement
antenna_x = 112; // cable bay: connector tail must not pass through raised radio
antenna_z = 20;
display_window = true;
// Estimated from manufacturer's annotated image; confirm against the actual LCD.
screen_xy = [35,98];
screen_size = [26,16]; // aperture includes margin around nominal 22 x 11 mm LCD
eps = 0.02;
hdmi_xy = [pi_xy[0]+32,14]; // centre in front panel: X,Z
hdmi_size = [24,12];
sd_xy = [pi_xy[1]+28,7]; // centre in left panel: Y,Z
sd_size = [20,8];
cover_face = 1.2;
cover_flange = 1.2;
clip_height_clearance = 0.1; // clearance at both top and bottom of the opening
sd_clip_preload = 0.15; // intentional spring deflection per edge in the original hole
sd_clip_hook = 0.65; // side-hook reach beyond the nominal opening
hdmi_clip_preload = 0.15;
hdmi_clip_hook = 0.65;
clip_depth = 4.8; // full-height fingers must stop before the Pi PCB at Y=5

lid_screws = [[6,6],[98,4],[134,35],[134,138],[6,138],[6,76]];
// Fill the pockets behind round bosses, joining each to its adjacent wall(s).
// Screw centres stay fixed so the existing lid still fits.
lid_boss_corners = [[0,0],[main_w,0],[outer_w,ethernet_step_y],
                    [outer_w,outer_d],[0,outer_d]];
pi_holes = [for(x=[3.5,61.5],y=[3.5,52.5]) [pi_xy[0]+x,pi_xy[1]+y]];
// Official DFRobot layout: 66 x 38 mounting centres, 3.5 mm edge offsets.
radio_holes = [for(x=[3.5,69.5],y=[3.5,41.5])
    [radio_xy[0]+x,radio_xy[1]+y]];

module rounded_rect(w,d,r) {
    hull() for(x=[r,w-r], y=[r,d-r]) translate([x,y]) circle(r=r);
}
module outline() {
    union() {
        rounded_rect(main_w,outer_d,corner_r);
        translate([main_w-2*corner_r,ethernet_step_y])
            rounded_rect(cable_bay+2*corner_r,outer_d-ethernet_step_y,corner_r);
    }
}
module prism(x,y,z,w,d,h) { translate([x,y,z]) cube([w,d,h]); }
module radio_frame() { translate([radio_xy[0],radio_xy[1],0]) children(); }

module port_cuts() {
    // Ethernet: open above and below socket for boot and latch access.
    // Socket at x~97; case wall at x102 gives a shallow 5 mm recess.
    prism(main_w-wall-1,pi_xy[1]+1,pcb_z-2,wall+4,21,22);
    // Micro-USB power: generous moulded-plug opening, directly at Pi edge.
    prism(pi_xy[0]+10.6-7,-1,pcb_z-1,14,wall+2,10);
    // Full-size HDMI and microSD service openings, each with a removable cap.
    prism(hdmi_xy[0]-hdmi_size[0]/2,-1,hdmi_xy[1]-hdmi_size[1]/2,
          hdmi_size[0],wall+2,hdmi_size[1]);
    prism(-1,sd_xy[0]-sd_size[0]/2,sd_xy[1]-sd_size[1]/2,
          wall+2,sd_size[0],sd_size[1]);
    // Panel connector axis is along Y, at the rear.
    translate([antenna_x,outer_d+1,antenna_z]) rotate([90,0,0])
        cylinder(d=antenna_hole,h=antenna_panel+2);
    // Vertical vents have short 3 mm bridges; continuous material at top/bottom.
    // Two left banks leave the mid-side screw boss at Y=76 intact.
    for(bank=[[14,62],[86,128]])
        for(y=[bank[0]:6:bank[1]]) prism(-1,y,17,wall+2,3,10);
    // Keep clear of the front cable-bay corner and both right screw bosses.
    for(y=[41:6:125]) prism(outer_w-wall-1,y,17,wall+2,3,10);
}

// Covers print outer face down. Four spring fingers preload the original hole;
// side hooks seat immediately behind its 2.4 mm wall. Tips taper for insertion.
module cover_finger(half_span, breadth, thickness, preload, hook_reach=0) {
    translate([half_span,-breadth/2,cover_face-eps])
        rotate([-90,0,0]) linear_extrude(breadth)
            polygon(concat(
                [[-0.1,0], [preload,-(wall-0.2+eps)],
                 [preload,-(wall+0.02+eps)]],
                hook_reach>0 ? [[hook_reach,-(wall+0.12+eps)]] : [],
                [[-0.3,-(clip_depth+eps)],
                 [-0.3-thickness,-(clip_depth+eps)],
                 [preload-thickness,-(wall-0.2+eps)],
                 [-0.1-thickness,0]]));
}
module service_cover(size, preload=hdmi_clip_preload, hook_reach=hdmi_clip_hook) {
    linear_extrude(cover_face)
        translate([-size[0]/2-cover_flange,-size[1]/2-cover_flange])
            rounded_rect(size[0]+2*cover_flange,size[1]+2*cover_flange,1);
    for(side=[-1,1]) scale([side,1,1])
        cover_finger(size[0]/2,size[1]-2*clip_height_clearance,0.8,preload,hook_reach);
    for(side=[-1,1]) rotate([0,0,side*90])
        cover_finger(size[1]/2,8,0.6,preload);
}
module sd_cover() { service_cover(sd_size,sd_clip_preload,sd_clip_hook); }
// These are validation masks only: they never cut or modify the case.
// Only four narrow wall-contact regions per cover may intersect relaxed springs.
// This is a deflection allowance, not a simulation of spring force.
module spring_contact_zones(size, preload) {
    for(side=[-1,1]) {
        x=side*size[0]/2;
        prism(x-(side<0?preload:0),-size[1]/2,0,preload,size[1],wall);
        y=side*size[1]/2;
        prism(-4,y-(side<0?preload:0),0,8,preload,wall);
    }
}
module sd_spring_contact_zones() {
    multmatrix([[0,0,1,0],[1,0,0,sd_xy[0]],
                [0,1,0,sd_xy[1]],[0,0,0,1]])
        spring_contact_zones(sd_size,sd_clip_preload);
}
module cover_spring_contact_zones() {
    sd_spring_contact_zones();
    multmatrix([[1,0,0,hdmi_xy[0]],[0,0,1,0],
                [0,1,0,hdmi_xy[1]],[0,0,0,1]])
        spring_contact_zones(hdmi_size,hdmi_clip_preload);
}
module installed_covers(pull=0) {
    multmatrix([[1,0,0,hdmi_xy[0]],[0,0,1,-cover_face-pull],
                [0,1,0,hdmi_xy[1]],[0,0,0,1]]) service_cover(hdmi_size);
    multmatrix([[0,0,1,-cover_face-pull],[1,0,0,sd_xy[0]],
                [0,1,0,sd_xy[1]],[0,0,0,1]]) sd_cover();
}
module lid_bosses() {
    translate([0,0,floor_h-eps]) linear_extrude(base_h-floor_h+eps)
        intersection() {
            outline(); // retain the outside corner radii
            union() for(i=[0:len(lid_screws)-1]) {
                p=lid_screws[i];
                r=p==[98,4]?3:4;
                hull() {
                    translate(p) circle(r=r);
                    if(i<len(lid_boss_corners)) {
                        c=lid_boss_corners[i];
                        translate([min(p[0],c[0]),min(p[1],c[1])])
                            square([abs(p[0]-c[0]),abs(p[1]-c[1])]);
                    } else {
                        // Mid-side boss: full-width attachment to the left wall.
                        translate([0,p[1]-r]) square([p[0],2*r]);
                    }
                }
            }
        }
}
module base() {
    difference() {
        union() {
            difference() {
                linear_extrude(base_h) outline();
                translate([0,0,floor_h]) linear_extrude(base_h)
                    offset(delta=-wall) outline();
            }
            for(p=pi_holes) translate([p[0],p[1],floor_h-eps])
                cylinder(d=6,h=pcb_z-floor_h+eps);
            for(p=radio_holes) translate([p[0],p[1],floor_h-eps])
                cylinder(d=6,h=radio_z-floor_h+eps);
            lid_bosses();
            // Antenna pad is separated from electronics, with room for washer/nut.
            prism(antenna_x-10,outer_d-antenna_panel,antenna_z-9,20,antenna_panel,18);
        }
        port_cuts();
        for(p=pi_holes) translate([p[0],p[1],pcb_z-5]) cylinder(d=board_pilot,h=6);
        for(p=radio_holes) translate([p[0],p[1],radio_z-5]) cylinder(d=board_pilot,h=6);
        for(p=lid_screws) translate([p[0],p[1],base_h-12])
            cylinder(d=lid_pilot,h=13);
        // Floor air inlets, clear of standoffs; add feet for airflow.
        for(x=[28:6:76]) prism(x,23,-1,3,23,floor_h+2);
        for(y=[102:6:120]) prism(25,y,-1,40,3,floor_h+2);
    }
}

module lid() {
    // Plain, solid lid; print the flat underside on the bed.
    difference() {
        linear_extrude(lid_h) outline();
        for(p=lid_screws) translate([p[0],p[1],-1]) cylinder(d=3.4,h=lid_h+3);
        if(display_window) translate([screen_xy[0],screen_xy[1],-eps])
            linear_extrude(lid_h+2*eps,scale=[screen_size[0]/(screen_size[0]+4),screen_size[1]/(screen_size[1]+4)])
                square([screen_size[0]+4,screen_size[1]+4],center=true);
    }
}

// Simplified mechanical envelopes, not full component models.
module hardware() {
    color("seagreen") difference() {
        prism(pi_xy[0],pi_xy[1],pcb_z,85,56,pcb_t);
        for(p=pi_holes) translate([p[0],p[1],pcb_z-1]) cylinder(d=2.75,h=4);
    }
    color("silver") {
        prism(pi_xy[0]+65.5,pi_xy[1]+2.5,pcb_z+pcb_t,21.5,16,13.5);
        for(y=[29,47]) prism(pi_xy[0]+69,pi_xy[1]+y-6.6,pcb_z+pcb_t,18,13.2,16);
        prism(pi_xy[0]+6.6,pi_xy[1]-1.2,pcb_z+pcb_t,8,6,3);
        prism(pi_xy[0]+32-7.5,pi_xy[1]-1.4,pcb_z+pcb_t,15,12,6.5);
    }
    // Conservative underside SD socket/card envelope, aligned with the slot.
    color("#555555") prism(pi_xy[0]-2,pi_xy[1]+28-6,pcb_z-2.5,15,12,2.5);
    color("black") prism(pi_xy[0]+7,pi_xy[1]+50,pcb_z+pcb_t,51,5,8.5);
    color("#303538") difference() {
        radio_frame() prism(0,0,radio_z,73,45,pcb_t);
        for(p=radio_holes) translate([p[0],p[1],radio_z-1]) cylinder(d=3,h=4);
    }
    color("silver") radio_frame() prism(41.5,-1,radio_z+pcb_t,9,7,3.5);
    color("#12394f") radio_frame() prism(14,2.5,radio_z+pcb_t,22,11,4);
    color("#303538") radio_frame() prism(8,1,radio_z+pcb_t,31,43,3);
    color("#d1c174") radio_frame() prism(62,11,radio_z+pcb_t,9,27,8.5);
}
module cable_envelopes() {
    // Example straight plug envelopes and a soft U bend. VERIFY actual cable.
    color("#444444") {
        prism(97,pi_xy[1]+47-6,18.5,24,12,9);
        prism(radio_xy[0]+45.8-6,70,radio_z+pcb_t-1,12,20,8);
        hull() { translate([121,52,23]) sphere(d=4); translate([126,62,23]) sphere(d=4); }
        hull() { translate([126,62,23]) sphere(d=4); translate([116,71,25]) sphere(d=4); }
        hull() { translate([116,71,25]) sphere(d=4); translate([67,64,25]) sphere(d=4); }
        hull() { translate([67,64,25]) sphere(d=4); translate([55.8,70,25]) sphere(d=4); }
    }
}
module assembly(explode=18) {
    color("#d8ddd9") base();
    color("#aebdb4") installed_covers();
    hardware();
    cable_envelopes();
    color("#e6e8df",explode>0?0.65:1) translate([0,0,base_h+explode]) lid();
}
module keyboard_envelope() {
    // Lower socket of the stack furthest from Ethernet; radio uses upper socket.
    // Run keyboard cable past radio's plug before turning upwards.
    prism(97,pi_xy[1]+47-6,9.5,32,12,8);
    hull() {
        translate([129,pi_xy[1]+47,13.5]) sphere(d=5);
        translate([132,pi_xy[1]+47,19]) sphere(d=5);
    }
    translate([132,pi_xy[1]+47,19]) cylinder(d=5,h=31);
}
module service_scene() {
    color("#d8ddd9") base();
    hardware();
    cable_envelopes();
    color("#cf8c3b") keyboard_envelope();
}

assert(antenna_panel>=wall && antenna_panel<10,"Check SMA thread length against panel");
assert(cable_bay>=30,"Straight USB plugs need cable space");
assert(base_h>pcb_z+pcb_t+18,"Lid must clear Pi USB stack");
assert(base_h>radio_z+pcb_t+8.5,"Lid must clear radio headers");
if(part=="base") base();
else if(part=="lid") lid();
else if(part=="hardware") hardware();
else if(part=="hdmi-cover") service_cover(hdmi_size);
else if(part=="sd-cover") sd_cover();
else if(part=="service") service_scene();
else if(part=="closed") assembly(0);
else if(part=="layout") {
    base(); translate([outer_w+10,0,0]) lid();
    translate([20,outer_d+15,0]) service_cover(hdmi_size);
    translate([55,outer_d+15,0]) sd_cover();
}
else if(part=="cover-interference") union() {
    intersection() { installed_covers(); hardware(); }
    difference() {
        intersection() { installed_covers(); base(); }
        cover_spring_contact_zones();
    }
}
else if(part=="cover-spring-contact") intersection() {
    installed_covers(); base(); cover_spring_contact_zones();
}
else if(part=="cover-retention") intersection() { installed_covers(0.6); base(); }
else if(part=="port-interference") intersection() {
    base();
    union() {
        // Generous HDMI moulded housing and SD card extraction path.
        prism(hdmi_xy[0]-11,-30,9,22,34,10);
        prism(-20,sd_xy[0]-6,5.9,30,12,2.3);
    }
}
else if(part=="keyboard-interference") intersection() {
    keyboard_envelope(); union() { base(); installed_covers(); cable_envelopes(); }
}
else if(part=="interference") intersection() {
    union() { base(); translate([0,0,base_h]) lid(); }
    hardware();
}
else assembly();
