// V3: thickened outer body. Minimum wall at gasket groove 1.175mm.
// RAK M8 captive-gasket cap: assembly prototype, not verified waterproof.
// Units mm. Assumed right-hand M8x1. Print closed end down.
clearance = 0.30; // DIAMETRAL allowance; try 0.20, 0.30, 0.40
pitch = 1;
height = 9;
roof = 2;
$fn = 96;
// Female thread cutter: truncated 60-degree profile swept as a mesh.
module thread_cut() {
    root = (8 - 1.082532*pitch + clearance)/2;
    crest = (8 + clearance)/2;
    steps = 96*10;
    points = [for(i=[0:steps],j=[0:3])
        let(a=i*360/96, z=-1+i*pitch/96,
            r=(j==0||j==3)?root-0.025:crest,
            dz=j==0?-0.375:j==1?-0.0625:j==2?0.0625:0.375)
        [r*cos(a),r*sin(a),z+dz]];
    faces = concat(
        [[3,2,1],[3,1,0]],
        [for(i=[0:steps-1],j=[0:3]) each
            [[4*i+j,4*i+(j+1)%4,4*(i+1)+(j+1)%4],
             [4*i+j,4*(i+1)+(j+1)%4,4*(i+1)+j]]],
        [[4*steps,4*steps+1,4*steps+2],[4*steps,4*steps+2,4*steps+3]]);
    polyhedron(points=points,faces=faces,convexity=20);
}
difference() {
    union() {
        cylinder(h=height,d=14);
        for(a=[0:30:330]) rotate([0,0,a])
            translate([6.8,0,0]) cylinder(h=height,d=1.2,$fn=16);
    }
    // 7mm depth exceeds measured 6mm projection, giving 1mm end clearance.
    translate([0,0,roof]) cylinder(h=height,d=8-1.082532+clearance);
    translate([0,0,roof]) thread_cut();
    // V2: 1.6mm deep pocket, 0.6mm retaining groove at inner end.
    translate([0,0,height-1.6]) cylinder(h=1.7,d=10.9);
    translate([0,0,height-1.6]) cylinder(h=0.6,d=11.65);
    // Entry chamfer at open end.
    translate([0,0,height-0.6]) cylinder(h=0.61,d1=7.4+clearance,d2=8.8+clearance);
}
