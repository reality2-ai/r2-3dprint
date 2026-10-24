// Mariko router — Raspberry Pi 3 + Heltec WiFi LoRa 32 V4R8 + GNSS.
// Independent variant; aligned port edges with matching strengthened covers.
// Millimetres. Prototype: check the actual cable and bulkhead before printing.
// Original Mariko tree only, read from above without mirroring.
use <mariko_logo_vector.scad>

part = "assembly"; // [assembly, closed, flashing, service, ports, holders, base, lid, heltec-cradle, gps-holder, gps-keeper, screen-fit, usb-cover, hdmi-cover, sd-cover, layout]
$fn = 48;
wall = 2.4;
floor_h = 2.4;
base_h = 32;
lid_h = 2.4;
main_w = 106; // room behind the recess for a nano Wi-Fi dongle
cable_bay = 34; // overall width remains 140 mm
outer_w = main_w + cable_bay;
outer_d = 144;
ethernet_step_y = 43; // expose the USB pair beside Ethernet; retain the other pair inside
corner_r = 4;
pcb_z = 8.4; // board underside; 6 mm air space above floor
pcb_t = 1.6;
pi_xy = [10, 5];
// Factory screen cover stays fitted. User confirmed its size and total stack.
screen_cover = [33,18.6];
screen_stack = 7.1; // PCB underside to top of protected display
screen_clearance = 0.3; // per side, tune with screen-fit coupon
screen_recess_target = 0.3;
usb_c_plug_height = 8; // provisional moulded plug envelope; measure yours
usb_c_plug_width = 12;
usb_c_plug_length = 20;
usb_c_axis_above_pcb = 1.2;
usb_c_clearance = 0.3;
usb_pocket_roof = 1.2; // minimum plastic above the internal USB-C plug
heltec_size = [51.689,25.4,1.6];
heltec_origin = [97,117.4]; // USB end; board rotates 180 degrees in XY
heltec_top = min(base_h+lid_h-screen_recess_target-(screen_stack-heltec_size[2]),
    base_h+lid_h-usb_pocket_roof-usb_c_clearance-usb_c_axis_above_pcb-usb_c_plug_height/2);
heltec_bottom = heltec_top-heltec_size[2];
cradle_z = floor_h+3;
cradle_plate = 1.8;
// STEP V4.3.1 positions; V4R8 drawing differs on hole diameter. These are
// support pads with clearance bores, NOT screw fasteners into the Heltec PCB.
heltec_pads = [for(u=[16.879,45.879],v=[5.7,19.7]) [u,v]];
cradle_mounts = [[25.845,-5.5],[25.845,30.9]];
// User measurements: 18 x 16 mm PCB, 7 mm total stack; antenna upward.
gps_size = [18,16,7];
gps_extension = 38; // Heltec edge to far end of connected GPS, measured
gps_origin = [heltec_origin[0]-heltec_size[0]-gps_extension,104.7-gps_size[1]/2];
gps_z = 18;
gps_fit = 0.3;
gps_plate = 1.8;
gps_retainer_z = gps_plate+gps_size[2]+gps_fit;
gps_mounts = [[gps_size[0]/2,-4],[gps_size[0]/2,gps_size[1]+4]];
gps_keeper_screws = [[gps_size[0]+3.8,-3],[gps_size[0]+3.8,gps_size[1]+3]];
board_pilot = 2.1; // M2.5 screws into plastic; tune using test coupon
lid_pilot = 2.6;   // M3 screws into plastic
antenna_hole = 6.5; // provisional SMA bulkhead clearance — MEASURE yours
antenna_fn = 128; // smooth bores independently of the general model resolution
antenna_panel = 4; // total local wall thickness, including reinforcement
antenna_x = 112; // cable bay: connector tail must not pass through raised radio
antenna_z = 20;
wifi_antenna_x = outer_w-antenna_x; // symmetric rear mounting, 28 mm from left
wifi_antenna_hole = 6.5; // independent tuning for the actual Wi-Fi bulkhead
display_window = true;
lid_logo = true;
logo_width = 80; // double the original tree's width and branch sizes
logo_depth = 0.8; // deeper seating recess; 1.6 mm of lid remains underneath
logo_xy = [main_w/2,47.5]; // balance clearance to the front edge and display
logo_margin = 3; // minimum separation from lid edges, screen and screw holes
// Cover position from the dimensional drawing; verify along-board offset.
screen_local = [15,3.4];
screen_xy = [heltec_origin[0]-screen_local[0]-screen_cover[0]/2,
             heltec_origin[1]-screen_local[1]-screen_cover[1]/2];
screen_size = screen_cover+[2*screen_clearance,2*screen_clearance];
eps = 0.02;
front_opening_bottom = pcb_z-1; // power and HDMI share Z=7.4
hdmi_top = 20; // retain all existing HDMI plug clearance
hdmi_xy = [pi_xy[0]+32,(front_opening_bottom+hdmi_top)/2]; // X,Z
hdmi_size = [22.8,hdmi_top-front_opening_bottom]; // 22 mm plug envelope + 0.4 mm per side
sd_xy = [pi_xy[1]+28,7]; // centre in left panel: Y,Z
sd_size = [20,8];
side_opening_bottom = pcb_z-2; // Ethernet and USB share Z=6.4..28.4
side_opening_height = 22;
ethernet_width = 18.5; // 18 mm boot/latch envelope + 0.25 mm per side
usb_socket_y = pi_xy[1]+29; // socket centre stays fixed when the cover shifts
usb_opening_y = [pi_xy[1]+10.5+ethernet_width/2,42.25]; // remove divider; cut 2 mm towards corner
usb_xy = [(usb_opening_y[0]+usb_opening_y[1])/2,side_opening_bottom+side_opening_height/2];
usb_size = [usb_opening_y[1]-usb_opening_y[0],side_opening_height];
usb_plug_width = 16; // user measured 15 mm; check an extra 1 mm overall
usb_corner_flange = 0.6; // clear the cable-bay wall after the 2 mm cutback
port_web_min = 3; // retain the solid power/HDMI divider only
wifi_size = [6,16,8]; // exposed nano-dongle body: X protrusion, Y width, Z height
cover_face = 1.2;
cover_flange = 1.2;
clip_height_clearance = 0.1; // clearance at both top and bottom of the opening
sd_clip_preload = 0.15; // intentional spring deflection per edge in the original hole
sd_clip_hook = 0.45; // reduced insertion deflection; still engages behind the wall
hdmi_clip_preload = 0.15;
hdmi_clip_hook = 0.45;
usb_clip_preload = 0.15;
usb_clip_hook = 0.45;
clip_depth = 4.8; // full-height fingers must stop before the Pi PCB at Y=5
clip_root_radius = 1.2; // inward fillet spreads the root into the face
clip_root_embed = 0.4; // root continues into the face, without changing its underside

lid_screws = [[6,6],[98,4],[134,ethernet_step_y+6],[134,138],[6,138],[6,76]];
// Fill the pockets behind round bosses, joining each to its adjacent wall(s).
// The cable-bay front screw moves with the recess; print the matching new lid.
lid_boss_corners = [[0,0],[main_w,0],[outer_w,ethernet_step_y],
                    [outer_w,outer_d],[0,outer_d]];
pi_holes = [for(x=[3.5,61.5],y=[3.5,52.5]) [pi_xy[0]+x,pi_xy[1]+y]];
function heltec_point(p) = [heltec_origin[0]-p[0],heltec_origin[1]-p[1]];
cradle_case_holes = [for(p=cradle_mounts) heltec_point(p)];
gps_case_holes = [for(p=gps_mounts) gps_origin+p];

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
module heltec_frame(z=0) {
    translate([heltec_origin[0],heltec_origin[1],z]) rotate([0,0,180]) children();
}
module gps_frame(z=0) { translate([gps_origin[0],gps_origin[1],z]) children(); }

module port_cuts() {
    // Ethernet: open above and below socket for boot and latch access.
    // Socket at x~97; case wall at x106 leaves 9 mm for plug insertion.
    // Ethernet and USB now form one opening, matching the user's hand-cut base.
    // Reach the socket face so the corner boss cannot obstruct a wide boot.
    prism(97,pi_xy[1]+10.5-ethernet_width/2,side_opening_bottom,
          main_w-97+2,ethernet_width,side_opening_height);
    prism(main_w-wall-1,usb_opening_y[0]-eps,usb_xy[1]-usb_size[1]/2,
          wall+4,usb_size[0]+eps,usb_size[1]);
    // Micro-USB power: generous moulded-plug opening, directly at Pi edge.
    prism(pi_xy[0]+10.6-7,-1,front_opening_bottom,14,wall+2,10);
    // Full-size HDMI and microSD service openings, each with a removable cap.
    prism(hdmi_xy[0]-hdmi_size[0]/2,-1,hdmi_xy[1]-hdmi_size[1]/2,
          hdmi_size[0],wall+2,hdmi_size[1]);
    prism(-1,sd_xy[0]-sd_size[0]/2,sd_xy[1]-sd_size[1]/2,
          wall+2,sd_size[0],sd_size[1]);
    // Panel connector axis is along Y, at the rear.
    translate([antenna_x,outer_d+1,antenna_z]) rotate([90,0,0])
        cylinder(d=antenna_hole,h=antenna_panel+2,$fn=antenna_fn);
    // Vertical vents have short 3 mm bridges; continuous material at top/bottom.
    // Two left banks leave the mid-side screw boss at Y=76 intact.
    for(bank=[[14,62],[86,128]])
        for(y=[bank[0]:6:bank[1]]) prism(-1,y,17,wall+2,3,10);
    // Keep clear of the front cable-bay corner and both right screw bosses.
    for(y=[ethernet_step_y+12:6:125]) prism(outer_w-wall-1,y,17,wall+2,3,10);
}
module wifi_antenna_cut() {
    translate([wifi_antenna_x,outer_d+1,antenna_z]) rotate([90,0,0])
        cylinder(d=wifi_antenna_hole,h=antenna_panel+2,$fn=antenna_fn);
}

// Covers print outer face down. Four spring fingers preload the original hole;
// side hooks seat immediately behind its 2.4 mm wall. Tips taper for insertion.
// Only the inward side of each root is flared: the port-contact profile stays
// clear of the wall. The quarter-circle blends into the sloping thin arm.
module cover_finger(half_span, breadth, thickness, preload, hook_reach=0) {
    translate([half_span,-breadth/2,cover_face])
        rotate([-90,0,0]) linear_extrude(breadth)
            polygon(concat(
                [[-0.1,clip_root_embed], [-0.1,0],
                 [preload,-(wall-0.2)], [preload,-(wall+0.02)]],
                hook_reach>0 ? [[hook_reach,-(wall+0.12)]] : [],
                [[-0.3,-clip_depth], [-0.3-thickness,-clip_depth],
                 [preload-thickness,-(wall-0.2)]],
                [for(a=[90:-7.5:0])
                    let(z=clip_root_radius*(1-cos(a)),
                        flare=clip_root_radius*(1-sin(a)))
                    [-0.1+(preload+0.1)*z/(wall-0.2)-thickness-flare,-z]],
                [[-0.1-thickness-clip_root_radius,clip_root_embed]]));
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
module usb_cover() {
    // Three clips: corner, top and bottom. The Ethernet edge has no flange
    // or finger, so a network plug can still pass with this cover installed.
    linear_extrude(cover_face)
        translate([-usb_size[0]/2,-usb_size[1]/2-cover_flange])
            rounded_rect(usb_size[0]+usb_corner_flange,usb_size[1]+2*cover_flange,1);
    cover_finger(usb_size[0]/2,usb_size[1]-2*clip_height_clearance,
                 0.8,usb_clip_preload,usb_clip_hook);
    for(side=[-1,1]) rotate([0,0,side*90])
        cover_finger(usb_size[1]/2,8,0.6,usb_clip_preload,usb_clip_hook);
}
module covers_scene() {
    // Print orientation, inside faces visible: HDMI, SD, USB from left to right.
    color("#b6c5cf") service_cover(hdmi_size);
    translate([32,0,0]) color("#b8c8ae") sd_cover();
    translate([62,0,0]) color("#d7c7a6") usb_cover();
}
module usb_cover_frame(outset=0) {
    multmatrix([[0,0,-1,main_w+outset],[1,0,0,usb_xy[0]],
                [0,1,0,usb_xy[1]],[0,0,0,1]]) children();
}
module installed_usb_cover(pull=0) { usb_cover_frame(cover_face+pull) usb_cover(); }
// These are validation masks only: they never cut or modify the case.
// Only narrow wall-contact regions may intersect relaxed springs: four for
// HDMI/SD, three for USB because its Ethernet-side divider is removed.
// This is a deflection allowance, not a simulation of spring force.
module spring_contact_zones(size, preload) {
    end_width=8;
    for(side=[-1,1]) {
        x=side*size[0]/2;
        prism(x-(side<0?preload:0),-size[1]/2,0,preload,size[1],wall);
        y=side*size[1]/2;
        prism(-end_width/2,y-(side<0?preload:0),0,end_width,preload,wall);
    }
}
module sd_spring_contact_zones() {
    multmatrix([[0,0,1,0],[1,0,0,sd_xy[0]],
                [0,1,0,sd_xy[1]],[0,0,0,1]])
        spring_contact_zones(sd_size,sd_clip_preload);
}
module usb_spring_contact_zones() {
    prism(usb_size[0]/2,-usb_size[1]/2,0,usb_clip_preload,usb_size[1],wall);
    for(side=[-1,1])
        prism(-4,side*usb_size[1]/2-(side<0?usb_clip_preload:0),0,8,usb_clip_preload,wall);
}
module cover_spring_contact_zones() {
    sd_spring_contact_zones();
    multmatrix([[1,0,0,hdmi_xy[0]],[0,0,1,0],
                [0,1,0,hdmi_xy[1]],[0,0,0,1]])
        spring_contact_zones(hdmi_size,hdmi_clip_preload);
    usb_cover_frame() usb_spring_contact_zones();
}
// Retention must come from the hooks, not just the relaxed spring preload.
// These masks lie beyond that preload, in the side walls of each opening.
module hook_contact_zones(size,preload) {
    for(side=[-1,1]) scale([side,1,1])
        prism(size[0]/2+preload+eps,-size[1]/2,0,1,size[1],wall);
}
module usb_hook_contact_zones() {
    prism(usb_size[0]/2+usb_clip_preload+eps,-usb_size[1]/2,0,1,usb_size[1],wall);
    for(side=[-1,1]) scale([1,side,1])
        prism(-4,usb_size[1]/2+usb_clip_preload+eps,0,8,1,wall);
}
module cover_hook_contact_zones() {
    multmatrix([[1,0,0,hdmi_xy[0]],[0,0,1,0],
                [0,1,0,hdmi_xy[1]],[0,0,0,1]])
        hook_contact_zones(hdmi_size,hdmi_clip_preload);
    multmatrix([[0,0,1,0],[1,0,0,sd_xy[0]],
                [0,1,0,sd_xy[1]],[0,0,0,1]])
        hook_contact_zones(sd_size,sd_clip_preload);
    usb_cover_frame() usb_hook_contact_zones();
}
module installed_covers(pull=0,usb=true,which="all") {
    if(which=="all" || which=="hdmi") multmatrix([[1,0,0,hdmi_xy[0]],[0,0,1,-cover_face-pull],
                [0,1,0,hdmi_xy[1]],[0,0,0,1]]) service_cover(hdmi_size);
    if(which=="all" || which=="sd") multmatrix([[0,0,1,-cover_face-pull],[1,0,0,sd_xy[0]],
                [0,1,0,sd_xy[1]],[0,0,0,1]]) sd_cover();
    if(usb && (which=="all" || which=="usb")) installed_usb_cover(pull);
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
module antenna_pad(x) {
    // Keep the flat washer/nut seat and full panel thickness. Build the
    // inward projection gradually from the wall with a 45-degree underside.
    projection=antenna_panel-wall;
    bottom=antenna_z-9;
    translate([x-10,0,0]) rotate([90,0,90]) linear_extrude(20)
        polygon([[outer_d,bottom-projection],
                 [outer_d-wall,bottom-projection],
                 [outer_d-antenna_panel,bottom],
                 [outer_d-antenna_panel,antenna_z+9],
                 [outer_d,antenna_z+9]]);
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
            for(p=cradle_case_holes) translate([p[0],p[1],floor_h-eps])
                cylinder(d=8,h=cradle_z-floor_h+eps);
            for(p=gps_case_holes) translate([p[0],p[1],floor_h-eps])
                cylinder(d=8,h=gps_z-floor_h+eps);
            lid_bosses();
            // Antenna pad is separated from electronics, with room for washer/nut.
            antenna_pad(antenna_x);
            antenna_pad(wifi_antenna_x);
        }
        port_cuts();
        wifi_antenna_cut();
        for(p=pi_holes) translate([p[0],p[1],pcb_z-5]) cylinder(d=board_pilot,h=6);
        for(p=cradle_case_holes) translate([p[0],p[1],floor_h-0.8]) cylinder(d=board_pilot,h=5);
        for(p=gps_case_holes) translate([p[0],p[1],gps_z-6]) cylinder(d=board_pilot,h=7);
        for(p=lid_screws) translate([p[0],p[1],base_h-12])
            cylinder(d=lid_pilot,h=13);
        // Floor air inlets, clear of standoffs; add feet for airflow.
        for(x=[28:6:76]) prism(x,23,-1,3,23,floor_h+2);
        difference() {
            for(y=[102:6:120]) prism(25,y,-1,40,3,floor_h+2);
            // Keep the bases of the new tall GPS bosses intact.
            for(p=gps_case_holes) translate([p[0],p[1],-2]) cylinder(r=5,h=8);
        }
    }
}

// Shared by the optional contrasting-colour inlay; keep one source of truth.
function lid_logo_spec() = [logo_width,logo_depth,logo_xy,lid_h,base_h];
function lid_logo_grip_points() = vector_logo_grip_points(logo_width);
module lid_logo_profile() { mariko_logo_vector(logo_width); }
module lid() {
    // Flat underside on the bed, recessed tree on top. No text or other marks.
    difference() {
        linear_extrude(lid_h) outline();
        if(lid_logo) translate([logo_xy[0],logo_xy[1],lid_h-logo_depth])
            linear_extrude(logo_depth+eps) lid_logo_profile();
        for(p=lid_screws) translate([p[0],p[1],-1]) cylinder(d=3.4,h=lid_h+3);
        if(display_window) screen_aperture();
        // A shallow underside pocket clears the moulded USB-C plug. Its
        // roof stays at least 1.2 mm thick; the board height adapts to the plug.
        translate([0,0,-base_h]) usb_c_lid_pocket();
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
    heltec_hardware();
    gps_hardware();
    antenna_fittings();
}
module antenna_fittings() {
    // Conservative identical SMA-family bulkheads. Measure thread length and
    // confirm SMA/RP-SMA choice for each pigtail. Hole diameters are independent.
    for(x=[antenna_x,wifi_antenna_x]) color("#b5a276") {
        translate([x,outer_d-antenna_panel-10,antenna_z]) rotate([-90,0,0])
            cylinder(d=6.2,h=antenna_panel+15);
        translate([x,outer_d-antenna_panel-2,antenna_z]) rotate([-90,0,0])
            cylinder(d=11,h=2,$fn=6);
    }
}
module cable_envelopes() {
    color("#444444") {
        prism(97,pi_xy[1]+47-6,18.5,24,12,9);
        heltec_frame(heltec_top) prism(-0.972-usb_c_plug_length,12.7-usb_c_plug_width/2,
            usb_c_axis_above_pcb-usb_c_plug_height/2,
            usb_c_plug_length,usb_c_plug_width,usb_c_plug_height);
        cable_path([[121,52,23],[127,64,23],[127,96,23],
                    [119,104.7,heltec_top+usb_c_axis_above_pcb]],4);
    }
    color("#c0a04b") gps_cable();
}
module cable_path(points,d) {
    for(i=[0:len(points)-2]) hull() {
        translate(points[i]) sphere(d=d);
        translate(points[i+1]) sphere(d=d);
    }
}

module assembly(explode=18) {
    color("#d8ddd9") base();
    color("#aebdb4") installed_covers();
    hardware();
    installed_holders();
    cable_envelopes();
    // Pi 3 has onboard Wi-Fi; lower internal USB remains free.
    color("#e6e8df",explode>0?0.65:1) translate([0,0,base_h+explode]) lid();
}
module wifi_envelope() {
    // Lower internal socket remains usable; Heltec cable uses the upper socket.
    // User's nano dongle protrudes ~5 mm; reserve 6 mm plus a 16 x 8 mm body.
    prism(97,pi_xy[1]+47-wifi_size[1]/2,13.5-wifi_size[2]/2,
          wifi_size[0],wifi_size[1],wifi_size[2]);
}
module external_usb_plugs(sweep=false) {
    // Two simultaneous 32 x 16 x 8 mm housings; user measured a 15 mm plug.
    for(z=[9.5,18.5]) {
        prism(97,usb_socket_y-usb_plug_width/2,z,sweep?outer_w+25-97:32,usb_plug_width,8);
        if(!sweep) translate([129,usb_socket_y,z+4]) rotate([0,90,0]) cylinder(d=5,h=30);
    }
}
module keyboard_envelope() {
    // A keyboard now uses the lower externally accessible socket.
    prism(97,usb_socket_y-usb_plug_width/2,9.5,32,usb_plug_width,8);
    translate([129,usb_socket_y,13.5]) rotate([0,90,0]) cylinder(d=5,h=30);
}
module service_scene() {
    color("#d8ddd9") base();
    hardware();
    installed_holders();
    cable_envelopes();
    // Pi 3 has onboard Wi-Fi; lower internal USB remains free.
    color("#cf8c3b") external_usb_plugs();
}
module flashing_scene() {
    color("#d8ddd9") base();
    color("#aebdb4") installed_covers(usb=false);
    hardware();
    installed_holders();
    cable_envelopes();
    // Pi 3 has onboard Wi-Fi; lower internal USB remains free.
    color("#cf8c3b") external_usb_plugs();
    color("#e6e8df") translate([0,0,base_h]) lid();
}
module closed_shell(usb=true) {
    base(); translate([0,0,base_h]) lid(); installed_covers(usb=usb);
}
module ports_scene() {
    // Bare openings with lid fitted, so the aligned edges are easy to inspect.
    color("#d8ddd9") base();
    color("#e6e8df") translate([0,0,base_h]) lid();
}

// The lid surrounds the existing plastic bezel with clearance. All retention
// acts on the PCB cradle; nothing clamps the glass or loads the screen cover.
module screen_aperture() {
    translate([screen_xy[0]-screen_size[0]/2,screen_xy[1]-screen_size[1]/2,-eps])
        linear_extrude(lid_h+2*eps) rounded_rect(screen_size[0],screen_size[1],0.15);
}
module usb_c_lid_pocket() {
    ceiling=heltec_top+usb_c_axis_above_pcb+usb_c_plug_height/2+usb_c_clearance;
    heltec_frame() prism(-0.972-usb_c_plug_length-1,12.7-usb_c_plug_width/2-0.6,
        base_h-1,usb_c_plug_length+2,usb_c_plug_width+1.2,ceiling-base_h+1);
}
module screen_fit_coupon() {
    difference() {
        linear_extrude(lid_h) rounded_rect(screen_size[0]+8,screen_size[1]+8,2);
        translate([4,4,-eps]) linear_extrude(lid_h+2*eps)
            rounded_rect(screen_size[0],screen_size[1],0.15);
    }
}
module heltec_hardware() {
    heltec_frame(heltec_bottom) color("#333f40") difference() {
        cube(heltec_size);
        for(p=heltec_pads) translate([p[0],p[1],-eps]) cylinder(d=2.8,h=2);
    }
    heltec_frame(heltec_top) {
        color("silver") prism(-0.9713,7.0301,-0.7,7.5977,11.34,3.8854);
        color("#efdfbc") prism(37.8884,5.2005,-5.2,5.3,15,3.6);
        color("#25282b") for(v=[0,22.86]) prism(2.159,v,-4.1,47,2.54,2.5);
        color("#cfb77a") for(u=[3.429:2.54:46.609],v=[1.27,24.13])
            prism(u-0.32,v-0.32,-10.1,0.64,0.64,11.55);
        color("#1d2025") prism(screen_local[0],screen_local[1],0,
            screen_cover[0],screen_cover[1],screen_stack-heltec_size[2]);
        // Visual OLED area only; it is inside the protected-cover envelope.
        color("#508999") prism(screen_local[0]+(screen_cover[0]-22)/2,
            screen_local[1]+(screen_cover[1]-11.4)/2,
            screen_stack-heltec_size[2]-0.03,22,11.4,0.04);
    }
}
module gps_hardware() {
    // Conservative full package envelope uses user dimensions. Colour split
    // indicates antenna up; component/PCB heights within this are illustrative.
    gps_frame(gps_z+gps_plate) {
        color("#929b91") cube([gps_size[0],gps_size[1],gps_size[2]-2.2]);
        color("seagreen") prism(0,0,gps_size[2]-2.2,gps_size[0],gps_size[1],0.8);
        color("#d4bd8a") prism(0,0,gps_size[2]-1.4,gps_size[0],gps_size[1],1.4);
    }
}
module gps_cable() {
    // 12 mm wide harness envelope, hanging below the antenna-up GPS board.
    // Bow length approximates the stock 26.5 mm lead across the measured gap.
    x0=gps_origin[0]+gps_size[0];
    x1=heltec_origin[0]-heltec_size[0];
    y=104.7;
    for(i=[0:1]) hull() {
        p0=i==0?[x0,y,22.5]:[(x0+x1)/2,y+1,22];
        p1=i==0?[(x0+x1)/2,y+1,22]:[x1+7,y,heltec_top-3.5];
        translate(p0) cube([0.4,12,2],center=true);
        translate(p1) cube([0.4,12,2],center=true);
    }
}
module cradle_outline() {
    union() {
        translate([-3,-3]) rounded_rect(heltec_size[0]+6,heltec_size[1]+6,2);
        for(p=cradle_mounts) hull() {
            translate(p) circle(r=3.5);
            translate([p[0],p[1]<0?0:heltec_size[1]]) circle(r=3.5);
        }
    }
}
module cradle_spring(u,side) {
    // Long, lightly deflected arms with flared roots. Hook overlaps only the
    // outer 0.5 mm of the PCB, clear of headers and the factory screen casing.
    // A 45-degree underside grows the hook from the arm without a flat ledge.
    seat=heltec_bottom-cradle_z;
    top=seat+heltec_size[2]+0.25;
    translate([u,side<0?0:heltec_size[1],0]) scale([1,side,1])
        rotate([0,0,90]) rotate([90,0,0]) linear_extrude(4,center=true)
            polygon([[0.3,cradle_plate-0.2],[2.8,cradle_plate-0.2],
                [1.5,5],[1.5,top+1.5],[0.3,top+1.5],[-0.5,top+1],
                [-0.5,top+0.6],[0.3,top-0.2]]);
}
module heltec_cradle() {
    seat=heltec_bottom-cradle_z;
    difference() {
        union() {
            linear_extrude(cradle_plate) cradle_outline();
            for(p=heltec_pads) translate([p[0],p[1],cradle_plate-eps]) {
                cylinder(d=6,h=seat-cradle_plate-6+eps);
                translate([0,0,seat-cradle_plate-6]) cylinder(d1=6,d2=4.6,h=1);
                translate([0,0,seat-cradle_plate-5-eps]) cylinder(d=4.6,h=5+2*eps);
            }
            for(u=[7,34],side=[-1,1]) cradle_spring(u,side);
        }
        for(p=cradle_mounts) translate([p[0],p[1],-eps]) cylinder(d=2.8,h=cradle_plate+1);
        for(p=heltec_pads) translate([p[0],p[1],cradle_plate]) cylinder(d=3.2,h=seat+1);
        prism(20,8.7,-eps,20,8,cradle_plate+1);
        // GNSS plug passes between the rear pads. Keep the inner relief open
        // through the top, removing the unsupported caps. The remaining outer
        // C-shaped seats support the PCB at the same height and clear screws.
        prism(43.3,6.1,seat-6.5,6,13.2,6.5+eps);
    }
}
module gps_holder_outline() {
    union() {
        translate([-1.9,-1.9]) rounded_rect(gps_size[0]+7.7,gps_size[1]+3.8,1);
        for(p=concat(gps_mounts,gps_keeper_screws)) hull() {
            translate(p) circle(r=3);
            translate([p[0],p[1]<0?0:gps_size[1]]) circle(r=3);
        }
    }
}
module gps_holder() {
    difference() {
        union() {
            linear_extrude(gps_plate) offset(delta=0.2) gps_holder_outline();
            // Bottom tray and low side guides; no assumption about PCB-edge
            // clearance or which components lie on the underside.
            for(y=[-gps_fit-1.6,gps_size[1]+gps_fit])
                prism(-gps_fit-1.6,y,gps_plate-eps,gps_size[0]+2*gps_fit+3.2,1.6,3.2);
            prism(-gps_fit-1.6,-gps_fit-1.6,gps_plate-eps,1.6,
                gps_size[1]+2*gps_fit+3.2,gps_retainer_z-gps_plate+1.4+eps);
            for(y=[-gps_fit,gps_size[1]-1.2])
                prism(gps_size[0]+gps_fit,y,gps_plate-eps,1.6,1.5,3.2);
            // Rear lip sits above the module, not against the antenna.
            prism(-gps_fit-1.6,-gps_fit-1.6,gps_retainer_z,2.3,
                gps_size[1]+2*gps_fit+3.2,1.4);
            for(p=gps_keeper_screws) translate([p[0],p[1],gps_plate-eps])
                cylinder(d=6,h=gps_retainer_z-gps_plate+eps);
        }
        for(p=gps_mounts) translate([p[0],p[1],-eps]) cylinder(d=2.8,h=gps_plate+1);
        for(p=gps_keeper_screws) translate([p[0],p[1],gps_retainer_z-5])
            cylinder(d=board_pilot,h=6);
    }
}
module gps_keeper() {
    // Prints flat. Two M2.5 screws hold this bridge above the cable connector.
    // Remove it to slide the module out; no small snap tabs on the GPS holder.
    difference() {
        linear_extrude(1.6) union() {
            hull() for(p=gps_keeper_screws) translate(p) circle(r=3);
            for(y=[-0.6,gps_size[1]-1])
                translate([gps_size[0]-0.5,y]) square([4.5,1.6]);
        }
        for(p=gps_keeper_screws) translate([p[0],p[1],-eps]) cylinder(d=2.8,h=2);
    }
}
module installed_holders() {
    color("#839eab") heltec_frame(cradle_z) heltec_cradle();
    color("#b1b69d") gps_frame(gps_z) gps_holder();
    color("#b4c6a0") gps_frame(gps_z+gps_retainer_z) gps_keeper();
}
module holders_scene() {
    color("#839eab") heltec_cradle();
    translate([70,0,0]) color("#b1b69d") gps_holder();
    translate([105,0,0]) color("#b4c6a0") gps_keeper();
}

assert(antenna_panel>=wall && antenna_panel<10,"Check SMA thread length against panel");
assert(hdmi_xy[0]-hdmi_size[0]/2-(pi_xy[0]+10.6+7)>=port_web_min-0.001,
       "Power/HDMI web must remain printable");
assert(usb_opening_y[0]<=pi_xy[1]+10.5+ethernet_width/2,
       "USB opening must join Ethernet without a divider");
assert(usb_opening_y[1]-(usb_socket_y+usb_plug_width/2)>=0.25,
       "Wider USB plug must clear the corner side");
assert(cable_bay>=30,"Straight USB plugs need cable space");
assert(base_h>pcb_z+pcb_t+18,"Lid must clear Pi USB stack");
assert(heltec_bottom-cradle_z>12,"Cradle must clear downward header pins");
assert(screen_stack>heltec_size[2] && usb_c_plug_height>=3.5,"Check measured stack and USB plug");
assert(heltec_top+screen_stack-heltec_size[2]>base_h,"Screen should enter the lid opening");
assert(usb_pocket_roof>=1.2,"USB relief must leave a printable roof");
assert(!lid_logo || (logo_depth>0 && lid_h-logo_depth>=1.2),
       "Recessed logo must leave at least 1.2 mm of lid thickness");
assert(usb_opening_y[1]+usb_corner_flange<ethernet_step_y,
       "USB cover must clear the cable-bay front wall");
assert(97+wifi_size[0]<main_w-wall,"Nano dongle must fit behind the recessed wall");
assert(clip_root_radius>0 && clip_root_radius<wall-0.2,
       "Clip fillet must end before the thin spring's wall-contact section");
assert(clip_root_embed>0 && clip_root_embed<cover_face,
       "Clip roots must embed within the cover face");
if(part=="base") base();
else if(part=="lid") lid();
else if(part=="hardware") hardware();
else if(part=="heltec-cradle") heltec_cradle();
else if(part=="gps-holder") gps_holder();
else if(part=="gps-keeper") gps_keeper();
else if(part=="screen-fit") screen_fit_coupon();
else if(part=="holders") holders_scene();
else if(part=="hdmi-cover") service_cover(hdmi_size);
else if(part=="sd-cover") sd_cover();
else if(part=="usb-cover") usb_cover();
else if(part=="service") service_scene();
else if(part=="ports") ports_scene();
else if(part=="flashing") flashing_scene();
else if(part=="closed") assembly(0);
else if(part=="layout") {
    base(); translate([outer_w+10,0,0]) lid();
    translate([20,outer_d+15,0]) service_cover(hdmi_size);
    translate([55,outer_d+15,0]) sd_cover();
    translate([85,outer_d+15,0]) usb_cover();
    translate([15,outer_d+45,0]) heltec_cradle();
    translate([90,outer_d+45,0]) gps_holder();
    translate([120,outer_d+45,0]) gps_keeper();
    translate([160,outer_d+45,0]) screen_fit_coupon();
}
else if(part=="cover-interference") union() {
    intersection() { installed_covers(); union() { hardware(); cable_envelopes(); wifi_envelope(); translate([0,0,base_h]) lid(); } }
    difference() {
        intersection() { installed_covers(); base(); }
        cover_spring_contact_zones();
    }
}
else if(part=="cover-spring-contact") intersection() {
    installed_covers(); base(); cover_spring_contact_zones();
}
else if(part=="cover-retention") intersection() { installed_covers(0.6); base(); cover_hook_contact_zones(); }
else if(part=="hdmi-cover-retention") intersection() { installed_covers(0.6,which="hdmi"); base(); cover_hook_contact_zones(); }
else if(part=="sd-cover-retention") intersection() { installed_covers(0.6,which="sd"); base(); cover_hook_contact_zones(); }
else if(part=="hdmi-cover-spring-contact") intersection() {
    installed_covers(which="hdmi"); base(); cover_spring_contact_zones();
}
else if(part=="sd-cover-spring-contact") intersection() {
    installed_covers(which="sd"); base(); cover_spring_contact_zones();
}
else if(part=="usb-cover-retention") intersection() { installed_usb_cover(0.6); base(); cover_hook_contact_zones(); }
else if(part=="usb-cover-spring-contact") intersection() {
    installed_usb_cover(); base(); usb_cover_frame() usb_spring_contact_zones();
}
else if(part=="port-interference") intersection() {
    base();
    union() {
        // Generous HDMI moulded housing and SD card extraction path.
        prism(hdmi_xy[0]-11,-30,9,22,34,10);
        prism(-20,sd_xy[0]-6,5.9,30,12,2.3);
    }
}
else if(part=="port-alignment") difference() {
    // Sample the actual wall openings, including the effects of bosses/cuts.
    // Separate slabs isolate power/HDMI and the joined Ethernet/USB opening.
    union() {
        prism(12,0.8,5,44,0.4,17);
        prism(104,5,4,0.4,37.5,26);
    }
    base();
}
else if(part=="antenna-bore-check") difference() {
    // Sample the actual void through almost the entire reinforced panel.
    // Separate blocks exclude vents and the other wall features.
    for(x=[antenna_x,wifi_antenna_x])
        prism(x-4,outer_d-antenna_panel+0.1,antenna_z-4,8,antenna_panel-0.2,8);
    base();
}
else if(part=="usb-cover-corner-interference") intersection() {
    // Probe 0.8 mm-wide free channels between adjacent clip roots, above
    // the continuous face. These gaps must survive a 0.6 mm nozzle print.
    usb_cover();
    for(sy=[-1,1]) scale([1,sy,1])
        prism(4.05,usb_size[1]/2-1.85,
              cover_face+0.02,0.8,1.7,0.2);
}
else if(part=="usb-cover-open-side-interference") intersection() {
    usb_cover();
    prism(-usb_size[0]/2-eps,-usb_size[1]/2-2,cover_face+0.02,
          2.5,usb_size[1]+4,clip_depth);
}
else if(part=="keyboard-interference") intersection() {
    keyboard_envelope(); union() { closed_shell(usb=false); hardware(); cable_envelopes(); wifi_envelope(); }
}
else if(part=="usb-access-interference") intersection() {
    external_usb_plugs(sweep=true);
    union() { closed_shell(usb=false); hardware(); cable_envelopes(); wifi_envelope(); }
}
else if(part=="ethernet-access-interference") intersection() {
    prism(97,pi_xy[1]+1.5,7,outer_w+25-97,18,20);
    closed_shell();
}
else if(part=="internal-usb-interference") union() {
    intersection() { union() { cable_envelopes(); wifi_envelope(); } closed_shell(); }
    intersection() { wifi_envelope(); union() { cable_envelopes(); hardware(); } }
}
else if(part=="holder-interference") union() {
    intersection() { installed_holders(); union() { hardware(); cable_envelopes(); closed_shell(); } }
    intersection() { heltec_frame(cradle_z) heltec_cradle(); gps_frame(gps_z) gps_holder(); }
    intersection() { gps_frame(gps_z) gps_holder(); gps_frame(gps_z+gps_retainer_z) gps_keeper(); }
}
else if(part=="antenna-clearance-interference") intersection() {
    union() { base(); translate([0,0,base_h]) lid(); installed_holders(); }
    antenna_fittings();
}
else if(part=="screen-clearance-interference") intersection() {
    translate([0,0,base_h]) lid();
    heltec_frame(heltec_top+screen_stack-heltec_size[2]-1)
        prism(screen_local[0]-0.25,screen_local[1]-0.25,0,screen_cover[0]+0.5,screen_cover[1]+0.5,2);
}
else if(part=="logo-layout-interference") intersection() {
    // The actual logo perimeter, expanded by the required margin, must not
    // reach the edge of the lid, display opening or any screw hole.
    translate([logo_xy[0],logo_xy[1],0]) linear_extrude(lid_h)
        offset(delta=logo_margin) lid_logo_profile();
    union() {
        difference() {
            prism(-10,-10,-1,outer_w+20,outer_d+20,lid_h+2);
            translate([0,0,-2]) linear_extrude(lid_h+4) outline();
        }
        screen_aperture();
        for(p=lid_screws) translate([p[0],p[1],-1]) cylinder(d=3.4,h=lid_h+2);
    }
}
else if(part=="cradle-retention") intersection() {
    heltec_frame(cradle_z) heltec_cradle();
    translate([0,0,0.6]) heltec_frame(heltec_bottom) cube(heltec_size);
}
else if(part=="gps-retention") intersection() {
    installed_holders();
    gps_frame(gps_z+gps_plate+0.6) cube(gps_size);
}
else if(part=="interference") intersection() {
    union() { base(); translate([0,0,base_h]) lid(); }
    hardware();
}
else assembly();
