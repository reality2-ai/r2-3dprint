// V2 TPU gasket. Wide lip down for printing, inward for assembly.
$fn=128;
difference() {
 union() {
  cylinder(d=11,h=2.2);
  cylinder(d=11.55,h=0.6);
 }
 translate([0,0,-0.1]) cylinder(d=8.4,h=2.4);
}
