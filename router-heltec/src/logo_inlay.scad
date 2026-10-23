// Optional contrasting-colour inlay for the existing recessed Mariko tree.
// Millimetres. Print fit must be calibrated; a tiny glue spot is an option.
use <router_heltec_case.scad>

part = "preview"; // [preview, inlay, root-fit, grip-contact, unexpected-contact]
edge_clearance = 0.05; // per side, away from the six grip spots
edge_grip = 0.04; // local interference per side; tune after a print trial
lead_in = 0.1; // first layer has clearance; upper three layers provide grip
contact_radius = 0.7; // width of each local grip patch along the edge
$fn = 48;

spec = lid_logo_spec();
inlay_height = spec[1]; // 0.4 mm, flush with the existing lid
logo_scale = spec[0]/40;
// Points on the existing traced outline at 40 mm width: top leaf, outer side
// leaves, and three sturdy root edges. All dimensions scale with the logo.
contact_points = [for(p=[[-0.105,22.159],[-20.079,1.5],[19.921,1.5],
    [-12.382,-17.382],[12.264,-17.231],[0.051,-22.025]]) p*logo_scale];

module contact_areas() {
    for(p=contact_points) translate(p) circle(r=contact_radius*logo_scale);
}
module inlay_outline() {
    offset(delta=-edge_clearance) lid_logo_profile();
}
module logo_inlay() {
    linear_extrude(inlay_height) inlay_outline();
    translate([0,0,lead_in]) linear_extrude(inlay_height-lead_in)
        intersection() {
            offset(delta=edge_grip) lid_logo_profile();
            contact_areas();
        }
}
module root_fit() {
    // Single connected root section for an inexpensive initial fit trial in
    // the actual lid. Three root grip spots match the full inlay exactly.
    intersection() {
        logo_inlay();
        translate([-22*logo_scale,-23*logo_scale,-0.1])
            cube([44*logo_scale,16*logo_scale,inlay_height+0.2]);
    }
}
module seated() {
    translate([spec[2][0],spec[2][1],spec[3]-spec[1]]) children();
}
module grip_contact() {
    intersection() { seated() logo_inlay(); lid(); }
}
module grip_allowance() {
    seated() translate([0,0,lead_in-0.001])
        linear_extrude(inlay_height-lead_in+0.002) contact_areas();
}
module inlay_preview() {
    color("#d8ddd9") base();
    color("#aebdb4") installed_covers();
    hardware();
    installed_holders();
    cable_envelopes();
    translate([0,0,spec[4]]) {
        color("#39434c") lid();
        color("#e3ad48") seated() logo_inlay();
    }
}
assert(edge_clearance>=0 && edge_clearance<=0.15,"Keep the thin branches connected");
assert(edge_grip>=0 && edge_grip<=0.12,"Use a small local interference; do not force the logo");
assert(lead_in>0 && lead_in<inlay_height,"Lead-in must leave a gripping band");
if(part=="parameters") echo(INLAY_PARAMETERS=[spec,edge_clearance,edge_grip,lead_in,contact_points,contact_radius]);
else if(part=="inlay") logo_inlay();
else if(part=="root-fit") root_fit();
else if(part=="grip-contact") grip_contact();
else if(part=="unexpected-contact") difference() { grip_contact(); grip_allowance(); }
else if(part=="core-contact") intersection() {
    lid(); seated() linear_extrude(inlay_height) inlay_outline();
}
else inlay_preview();
