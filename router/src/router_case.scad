// Reality2 home router — Raspberry Pi Model B+ V1.2 + DFR1195.
// Millimetres. Prototype: check the actual cable and bulkhead before printing.
// Shared, original Mariko artwork; deliberately NOT mirrored on this top face.
use <../../branding/logos/mariko_logo_traced.scad>

part = "assembly"; // base, lid, hdmi-cover, sd-cover, layout, assembly, closed, service
$fn = 48;
wall = 2.4;
floor_h = 2.4;
base_h = 32;
lid_h = 2.4;
emboss_h = 0.6;
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
clip_clearance = 0.25;
clip_bump = 0.4; // 0.15 mm nominal retention; tune after a PETG fit print
clip_thickness = 0.8;
clip_depth = 6;

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
    for(y=[38:6:62]) prism(-1,y,17,wall+2,3,10);
    for(y=[85:6:121]) prism(outer_w-wall-1,y,17,wall+2,3,10);
}

// Covers print outer face down, two spring fingers upwards. The shoulder sits
// behind the wall. Opposite ramps permit removal by levering the outside flange.
// No text on the bed-facing surface; the different sizes identify the covers.
module service_cover(size) {
    linear_extrude(cover_face)
        translate([-size[0]/2-cover_flange,-size[1]/2-cover_flange])
            rounded_rect(size[0]+2*cover_flange,size[1]+2*cover_flange,1);
    for(side=[-1,1]) scale([side,1,1]) {
        translate([size[0]/2-clip_clearance-clip_thickness,-2,cover_face-eps])
            cube([clip_thickness,4,clip_depth+eps]);
        // A ramped detent on the outer surface of each spring finger.
        translate([size[0]/2-clip_clearance,-2,cover_face])
            rotate([-90,0,0]) linear_extrude(4)
                polygon([[-eps,-(wall+0.1)],[clip_bump,-(wall+0.6)],
                         [-eps,-(wall+1.8)]]);
    }
}
module installed_covers(pull=0) {
    multmatrix([[1,0,0,hdmi_xy[0]],[0,0,1,-cover_face-pull],
                [0,1,0,hdmi_xy[1]],[0,0,0,1]]) service_cover(hdmi_size);
    multmatrix([[0,0,1,-cover_face-pull],[1,0,0,sd_xy[0]],
                [0,1,0,sd_xy[1]],[0,0,0,1]]) service_cover(sd_size);
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
        // Floor air inlets, clear of standoffs; add adhesive feet for airflow.
        for(x=[28:6:76]) prism(x,23,-1,3,23,floor_h+2);
        for(y=[102:6:120]) prism(25,y,-1,40,3,floor_h+2);
    }
}

module reality2_mark() {
    difference() { circle(r=6,$fn=6); circle(r=5.2,$fn=6); }
    circle(r=0.8);
    for(a=[30,150,210,270,330]) {
        hull() { circle(r=0.35); translate([2.7*cos(a),2.7*sin(a)]) circle(r=0.35); }
        translate([2.7*cos(a),2.7*sin(a)]) circle(r=0.65);
    }
}
module lid() {
    // Flat underside: print this face on bed, embossing upwards. No skirt/supports.
    difference() {
        union() {
            linear_extrude(lid_h) outline();
            translate([48,46,lid_h-eps]) linear_extrude(emboss_h+eps) mariko_logo2d(34);
            translate([48,20,lid_h-eps]) linear_extrude(emboss_h+eps)
                text("MARIKO",size=5,halign="center",font="DejaVu Sans:style=Bold");
            translate([48,13,lid_h-eps]) linear_extrude(emboss_h+eps)
                text("EARTHGRIDS",size=3,halign="center",font="DejaVu Sans");
            translate([107,68,lid_h-eps]) linear_extrude(emboss_h+eps) rotate(90) reality2_mark();
            translate([107,55,lid_h-eps]) linear_extrude(emboss_h+eps)
                text("Reality2",size=3.6,halign="center",font="DejaVu Sans");
            translate([107,49,lid_h-eps]) linear_extrude(emboss_h+eps)
                text("ROUTER",size=2.7,halign="center",font="DejaVu Sans");
        }
        for(p=lid_screws) translate([p[0],p[1],-1]) cylinder(d=3.4,h=lid_h+3);
        // Exhaust openings, away from the logo.
        for(x=[18:6:78]) prism(x,67,-1,3,14,lid_h+2);
        for(y=[94:6:124]) prism(101,y,-1,22,3,lid_h+2);
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
else if(part=="sd-cover") service_cover(sd_size);
else if(part=="service") service_scene();
else if(part=="closed") assembly(0);
else if(part=="layout") {
    base(); translate([outer_w+10,0,0]) lid();
    translate([20,outer_d+15,0]) service_cover(hdmi_size);
    translate([55,outer_d+15,0]) service_cover(sd_size);
}
else if(part=="cover-interference") intersection() {
    installed_covers(); union() { base(); hardware(); }
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
