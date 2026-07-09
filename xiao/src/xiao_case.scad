// =====================================================================
use <mariko_logo_traced.scad>
// Xiao + LoRa phone-mount case  (parametric, OpenSCAD)
// Main box with click-in lid + separate enclosed antenna channel with its
// own click-in lid. USB-C slot (open through floor) on one short side.
// Everything prints flat, opening up -> no supports.
//
// Orientation: board lies flat (X = width 18, Y = length 21, Z = height).
// USB-C on -Y short side; antennas exit +Y short side.
// =====================================================================

// ---------- Board dimensions ----------
board_w      = 18;   // X, short side (with USB / antennas)
board_l      = 21;   // Y, long side
board_h      = 10;   // Z, tallest component clearance

// ---------- USB-C opening ----------
// The case mounts INVERTED on the phone: the solid floor is the visible
// outer face; the lid/rim side faces the phone. The USB opening is a
// closed stadium-shaped window (rounded ends, like the plug's own
// cross-section) in the -Y wall, snug around the slim right-angle USB-C
// plug (Adafruit 6367 / DigiKey 1528-6367-ND), inserted from outside
// after the board is seated. Calliper your plug's overmold and set these
// to overmold + ~0.5mm; FDM holes print slightly undersize.
usb_w        = 12.6; // window width (X), across the rounded ends
usb_h        = 7.0;  // window height (Z) = end radius x 2
usb_z0       = 3.0;  // window lower edge above print-floor

// ---------- Antenna channel (+Y short side) ----------
// The channel is the SAME OUTER WIDTH as the box, split lengthwise by a
// central divider into two lanes -- one per antenna (LoRa | WiFi/BLE).
ant_channel_len = 75;  // how far the channel extends past the case body
divider_w       = 1.6; // central divider wall thickness

// ---------- Case shell ----------
wall         = 1.6;   // side wall thickness
floor        = 1.2;   // base thickness (thin -> stronger magnet coupling)
clearance    = 0.4;   // gap around board on each side (fit tolerance)

// ---------- Click-in lid ----------
// The lid is a single flat plate that drops INSIDE the walls and clicks
// flush, seated slightly below the rim so the wall tops frame it. Snap
// bumps on the plate edges (ramped underside for press-in, square top for
// retention) engage recesses in the inner wall faces.
lid_h        = 1.5;   // lid plate thickness
seat         = 0.2;   // how far below the rim the lid top sits
snap_depth   = 0.7;   // how far bumps stick out / recesses are cut
snap_h       = 1.0;   // bump/recess height (Z)
snap_z0      = 0;     // bump bottom at the lid underside (max ledge above)
snap_len     = 6;     // bump/recess length along the wall (short: follows curve)
tol          = 0.3;   // clearance between lid edge and wall

// ---------- Print / render ----------
$fn          = 48;
part         = "both";  // "case" | "lid" | "both"

// ---------- Derived ----------
inner_w = board_w + 2*clearance;
inner_l = board_l + 2*clearance;
inner_h = board_h + seat + lid_h + 0.2;  // room above board for the lid
outer_w = inner_w + 2*wall;
outer_l = inner_l + 2*wall;
outer_h = floor + inner_h;               // case body height (rim = top)
lid_z0  = outer_h - seat - lid_h;        // lid underside when seated

// antenna channel: same outer width and height as the box, so box and
// channel form one continuous meandering body with no join step at all
chan_ow  = outer_w;                      // channel outer width == box
chan_oh  = outer_h;                      // channel outer height == box
chan_iw  = outer_w - 2*wall;             // channel interior width (== inner_w)
chan_ih  = outer_h - floor;              // channel interior depth
lane_w   = (chan_iw - divider_w)/2;      // width of each antenna lane

// ---------- Antenna channel meander path ----------
// The channel follows a gentle S-curve (the antennas are flexible wires, so
// the holder can flow like a river). Path parameter t runs 0..ant_channel_len
// from the box back face; lateral offset px(t) has zero slope at both ends
// so the channel leaves the box straight and finishes straight.
ant_curve = 5;   // meander amplitude (max lateral swing ~0.77 * this)

function ch_px(t)  = t <= 0 ? 0 :        // straight & centred inside the box
                     ant_curve * sin(360*t/ant_channel_len)
                               * sin(180*t/ant_channel_len);
function ch_ang(t) = atan(ch_px(t+0.5) - ch_px(t-0.5));  // local tangent (deg)

// 2D strip of width w following the meander from t0 to t1, drawn in the
// channel-local frame (origin at the box back-face centre, +y = along path).
// o = constant lateral offset of the strip centreline from the path.
module ch_strip(w, t0, t1, o=0, endr=0){
    n = 96;
    pts = concat(
        [for(i=[0:n]) let(t=t0+(t1-t0)*i/n, a=ch_ang(t))
            [ch_px(t) - (o+w/2)*cos(a), t + (o+w/2)*sin(a)]],
        [for(i=[n:-1:0]) let(t=t0+(t1-t0)*i/n, a=ch_ang(t))
            [ch_px(t) - (o-w/2)*cos(a), t + (o-w/2)*sin(a)]]);
    if(endr>0) offset(r=endr) offset(delta=-endr) polygon(pts);
    else polygon(pts);
}

// place children in the local path frame at parameter t (x = lateral,
// y = along-path), in world coordinates
module at_path(t){
    translate([outer_w/2 + ch_px(t), outer_l + t, 0])
        rotate([0,0,-ch_ang(t)])
            children();
}

// ---------- Branding (debossed into the floor's outer face) ----------
deboss     = 0.4;   // engraving depth into the 1.2mm floor (0.8 remains)
wave_amp   = 1.6;   // river wave amplitude
wave_per   = 18;    // river wave period (mm)
wave_w     = 0.9;   // river line width
brand_font = "DejaVu Sans:style=Bold";

// 2D river wave following the meander path: a strip whose centreline sits
// at lateral offset o0 + wave_amp*sin(...) from the path, from t0 to t1
module wave_band(o0, ph, t0, t1){
    n = 90;
    pts = concat(
        [for(i=[0:n]) let(t=t0+(t1-t0)*i/n, a=ch_ang(t),
                          o=o0 + wave_amp*sin(360*t/wave_per + ph))
            [ch_px(t) - (o+wave_w/2)*cos(a), t + (o+wave_w/2)*sin(a)]],
        [for(i=[n:-1:0]) let(t=t0+(t1-t0)*i/n, a=ch_ang(t),
                          o=o0 + wave_amp*sin(360*t/wave_per + ph))
            [ch_px(t) - (o-wave_w/2)*cos(a), t + (o-wave_w/2)*sin(a)]]);
    polygon(pts);
}

// Reality2 hexagon mark, rebuilt from the supplied logo image: a thin
// pointy-top hexagon ring containing a hub-and-spoke node network --
// central node with five spokes radiating toward five of the six vertices
// (the top vertex direction left empty, as in the original). The motif is
// mirror-symmetric in X, so it is unaffected by the installation flip.
hex_R      = 4.2;   // hexagon circumradius (vertex); mark ~8.4mm tall
hex_w      = 0.5;   // ring line width
r2_node_r  = 0.45;  // satellite node radius
r2_hub_r   = 0.55;  // central node radius
r2_spoke_w = 0.45;  // spoke line width
r2_sat_d   = 0.45;  // satellite distance as fraction of hex_R
module hex_mark2d(){
    rotate([0,0,90])   // pointy-top hexagon ring
        difference(){
            circle(r=hex_R,        $fn=6);
            circle(r=hex_R-hex_w,  $fn=6);
        }
    // hub, spokes, satellite nodes (top direction 90 deliberately empty)
    circle(r=r2_hub_r);
    for(ang=[30,150,210,270,330]){
        hull(){
            circle(r=r2_spoke_w/2);
            rotate([0,0,ang]) translate([hex_R*r2_sat_d,0])
                circle(r=r2_spoke_w/2);
        }
        rotate([0,0,ang]) translate([hex_R*r2_sat_d,0])
            circle(r=r2_node_r);
    }
}

// ---------- Mariko tree mark (reconstructed from the logo) ----------
// A stylised tree whose branches end in node-dots, rooted in a half-disc
// mound containing koru spirals (kept as uncut ridges within the debossed
// mound). All strokes >= 0.55mm for 0.4 nozzle printability.
// Natural size: ~13mm wide, ~17mm tall, origin at the mound's flat top.

// recursive branch: strip of length l, width w, node dots at final tips
module twig(l, w, depth){
    hull(){ circle(w/2); translate([0,l]) circle(w*0.4); }
    translate([0,l]){
        if(depth==0) circle(0.9);              // node dot
        else for(a=[-34,34]) rotate(a) twig(l*0.66, w*0.75, depth-1);
    }
}

// koru spiral band (this is the CUT kept clear within the mound)
module koru(rmax=1.7, gap=0.55, turns=1.6){
    n=48; b=rmax/(turns*360);
    pts = concat(
      [for(i=[0:n]) let(th=turns*360*i/n, r=b*th)      [r*cos(th), r*sin(th)]],
      [for(i=[n:-1:0]) let(th=turns*360*i/n, r=b*th+gap)[r*cos(th), r*sin(th)]]);
    polygon(pts);
}

module mariko_tree2d(){
    // mound: lower half-disc, flat top at y=0, minus the koru spirals
    difference(){
        intersection(){
            circle(r=6);
            translate([-7,-7]) square([14,7]);
        }
        translate([-3.1,-2.6]) koru(1.5);
        translate([ 0.1,-3.0]) koru(1.8);
        translate([ 3.2,-2.6]) koru(1.5);
    }
    // tree: trunk + two branch generations + node dots
    twig(4.5, 1.5, 3);
}

// ---------- 2D outline of the whole outer profile (box + channel) ----------
// Box: all four corners rounded r=2. Channel: far-end corners rounded r=1.5,
// square where it meets the box (the join stays a clean right angle; the
// box corner radii at x<2 / x>outer_w-2 are clear of the channel walls).
corner_r     = 2;    // box plan-corner radius
chan_end_r   = 1.5;  // channel far-end corner radius

// rounded rect, all corners
module rrect(w,l,r){ offset(r=r) offset(delta=-r) square([w,l]); }

// rect rounded only at the -Y (front) corners; back edge square so the
// equal-width channel strip continues it seamlessly
module rrect_front(w,l,r){
    hull(){
        translate([r,   r]) circle(r);
        translate([w-r, r]) circle(r);
        translate([0, l-0.001]) square([w, 0.001]);
    }
}

module outline(){
    union(){
        rrect_front(outer_w, outer_l, corner_r);
        // strip start buried 3mm into the box so the end-rounding offset
        // (which also nibbles the start corners) stays hidden inside
        translate([outer_w/2, outer_l])
            ch_strip(chan_ow, -3, ant_channel_len, 0, chan_end_r);
    }
}

// outer solid with a smooth rounded-over top rim. The top band follows a
// quarter-circle profile (radius = top_round), built from many thin slices
// so it renders/prints as a smooth curve rather than visible steps.
top_round = 0.6;   // top rim roundover radius
module body_solid(){
    r = top_round; n = 12;             // slices across the roundover
    linear_extrude(outer_h - r) outline();
    for(i=[0:n-1]){
        u0 = r*i/n;                    // height into the band
        inset = r - sqrt(max(0, r*r - u0*u0));  // circular profile
        translate([0,0,outer_h - r + u0])
            linear_extrude(r/n + 0.001) offset(delta=-inset) outline();
    }
}

// =====================================================================
// CASE BODY
// =====================================================================
module case_body(){
    difference(){
        // outer solid: full compound outline, rounded plan corners,
        // stepped chamfer on the top rim
        body_solid();

        // main cavity (board sits on the floor; extra `skirt` height above)
        translate([wall, wall, floor])
            cube([inner_w, inner_l, inner_h + 1]);

        // USB-C window in -Y wall: stadium shape (full-radius rounded ends)
        // matching the plug's own cross-section, snug around the overmold;
        // the visible face AND the rim both stay unbroken
        translate([outer_w/2, wall + 1, usb_z0 + usb_h/2])
            rotate([90,0,0])
                linear_extrude(wall + 2)
                    hull()
                        for(s=[-1,1])
                            translate([s*(usb_w - usb_h)/2, 0])
                                circle(d=usb_h);

        // ---- BRANDING, debossed into the floor's outer (print-bed) face,
        // which is the VISIBLE top face when the case is mounted inverted.
        // Asymmetric glyphs are pre-MIRRORED so they read correctly after
        // the case is flipped over for installation. ----

        // river waves flowing along the meander's underside (widened for
        // the full-width channel)
        for(w = [[-3.2, 0], [3.2, 180]])
            translate([outer_w/2, outer_l, -0.01])
                linear_extrude(deboss + 0.01)
                    wave_band(w[0], w[1], 4, ant_channel_len - wall - 16);

        // Mariko tree mark on the box underside — auto-traced from the
        // actual logo (mariko_logo_traced.scad), mirrored to read correctly
        // when the case is flipped over for installation
        translate([outer_w/2, 11.5, -0.01])
            linear_extrude(deboss + 0.01)
                mirror([1,0])
                    mariko_logo2d(w=18);

        // Reality2 hexagon hallmark near the meander's end (R2 mirrored)
        at_path(ant_channel_len - wall - 6)
            translate([0,0,-0.01])
                linear_extrude(deboss + 0.01)
                    mirror([1,0]) hex_mark2d();

        // antenna channel cavity: full-interior-width curved trough
        // following the meander, leaving the far end wall
        translate([outer_w/2, outer_l, floor])
            linear_extrude(chan_ih + 1)
                ch_strip(chan_iw, -0.02, ant_channel_len - wall);

        // pass-through: the shared wall is opened across the FULL channel
        // interior width and height, so antennas exit freely and the wide
        // lid ribbon passes over. The divider (added below) restores the
        // central board back-stop.
        translate([wall, wall + inner_l - 0.01, floor])
            cube([chan_iw, wall + 0.02, chan_ih + 1]);

        // Recess z-band: aligned with the bump band of the SEATED lid.
        // Lid underside sits at lid_z0; bumps run z lid_z0+snap_z0 for snap_h.
        // Recesses are cut INTO the wall material from the inner face.
        rz = lid_z0 + snap_z0;

        // --- box recesses: into the two long (X) walls ---
        for(sx = [-1,1])
            translate([sx<0 ? wall - snap_depth : wall + inner_w - 0.01,
                       (outer_l - snap_len)/2, rz])
                cube([snap_depth + 0.01, snap_len, snap_h]);

        // --- channel recesses: into the two channel side walls, placed in
        // the local path frame so they follow the meander ---
        for(s = [-1,1], tt = [10, ant_channel_len - 18])
            at_path(tt)
                translate([s<0 ? -chan_iw/2 - snap_depth
                               :  chan_iw/2 - 0.01,
                           -snap_len/2, rz])
                    cube([snap_depth + 0.01, snap_len, snap_h]);

        // --- pry notch: small half-round scoop in the channel's far-end
        // rim, exposing the lid ribbon's tip so a fingernail can lift it
        // (peel the lid from the thin end). Located here to keep the front
        // wall solid around the USB window. The meander is centred and
        // straight at its end, so this sits axis-aligned.
        translate([outer_w/2, outer_l + ant_channel_len - wall/2, outer_h])
            rotate([90,0,0])
                cylinder(r=2.4, h=wall+2, center=true);
    }

    // ---- central divider: splits the channel into two antenna lanes,
    // following the meander. Runs from the box cavity's back plane (where
    // it doubles as the board's central back-stop, since the shared wall
    // is now fully open) to the channel's end wall. Its top stops 0.2mm
    // below the seated lid so the lid ribbon passes freely over it.
    translate([outer_w/2, outer_l, floor - 0.01])
        linear_extrude(lid_z0 - 0.2 - floor + 0.01)
            ch_strip(divider_w, -(wall + 0.01), ant_channel_len - wall + 0.01);
}

// =====================================================================
// CLICK-IN LID  (flat plain plate; faces the phone when installed, so it
// carries no branding). Modelled with its UNDERSIDE at z=0; seated
// position: translate([0,0,lid_z0]).
// =====================================================================
module lid(){
    // box plate: fills the cavity opening, inset by tol
    translate([wall + tol, wall + tol, 0])
        cube([inner_w - 2*tol, inner_l - 2*tol, lid_h]);

    // channel ribbon: full-interior-width curved plate following the
    // meander, through the opened shared wall to the trough's far end,
    // inset by tol; it rides 0.2mm above the central divider
    translate([outer_w/2, outer_l, 0])
        linear_extrude(lid_h)
            ch_strip(chan_iw - 2*tol,
                     -(wall + 0.5), ant_channel_len - wall - tol);

    // snap bump: ramped underside (press-in lead-in), square top (catch).
    // Local profile (XZ): protrudes +X, centred on Y. Extruded snap_len.
    module bump(){
        translate([0, snap_len/2, 0]) rotate([90,0,0])
            linear_extrude(snap_len)
                polygon([[0,0],[snap_depth, snap_h*0.4],
                         [snap_depth, snap_h],[0, snap_h]]);
    }

    // box bumps: on the two long (X) edges of the plate
    for(sx = [-1,1])
        translate([sx<0 ? wall + tol : wall + inner_w - tol,
                   outer_l/2, snap_z0])
            mirror([sx<0 ? 1 : 0, 0, 0]) bump();

    // channel bumps: on the curved ribbon edges, in the local path frame,
    // aligned with the case recesses
    for(s = [-1,1], tt = [10, ant_channel_len - 18])
        at_path(tt)
            translate([s<0 ? -(chan_iw/2 - tol)
                           :   chan_iw/2 - tol,
                       0, snap_z0])
                mirror([s<0 ? 1 : 0, 0, 0]) bump();
}

// =====================================================================
// LAYOUT
// =====================================================================
if(part=="case" || part=="both") case_body();

if(part=="lid" || part=="both")
    translate(part=="both" ? [outer_w + 8, 0, 0] : [0,0,lid_z0]) lid();
