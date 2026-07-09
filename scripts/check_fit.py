#!/usr/bin/env python3
"""Verify the lid snap-fit via boolean interference.

Renders two intersections with OpenSCAD:
  closed : lid seated at lid_z0        -> volume must be ~0 (lid seats)
  lifted : lid raised 0.8mm            -> volume must be >0 (clips catch)

Run from the repo root:  python3 scripts/check_fit.py
Requires: openscad on PATH.

If you change any geometry (wall, lid_h, seat, snap_*, tol, the meander,
or heights), re-run this before printing. If lid_z0 changes (it is
outer_h - seat - lid_h), update LID_Z0 below to match.
"""
import subprocess, sys, os, tempfile

LID_Z0 = 11.4   # keep in sync with lid_z0 in xiao_case.scad

def stl_volume(path):
    tris, cur = [], []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if line.startswith("vertex"):
                cur.append(tuple(float(x) for x in line.split()[1:4]))
                if len(cur) == 3:
                    tris.append(cur); cur = []
    v = sum((a[0]*(b[1]*c[2]-b[2]*c[1])
           - a[1]*(b[0]*c[2]-b[2]*c[0])
           + a[2]*(b[0]*c[1]-b[1]*c[0]))/6 for a, b, c in tris)
    return abs(v)

def run(lift, out):
    scad = f"""use <xiao_case.scad>
intersection(){{ case_body(); translate([0,0,{LID_Z0}+{lift}]) lid(); }}
"""
    with tempfile.NamedTemporaryFile("w", suffix=".scad", dir=".",
                                     delete=False) as f:
        f.write(scad); tmp = f.name
    try:
        subprocess.run(["openscad", "-o", out, tmp],
                       check=True, capture_output=True)
    finally:
        os.unlink(tmp)
    return stl_volume(out)

if __name__ == "__main__":
    closed = run(0.0, "/tmp/fit_closed.stl")
    lifted = run(0.8, "/tmp/fit_lifted.stl")
    print(f"closed-position interference: {closed:.3f} mm^3 (want ~0)")
    print(f"lifted 0.8mm engagement:      {lifted:.3f} mm^3 (want >0)")
    ok = closed < 0.5 and lifted > 2.0
    print("PASS" if ok else "FAIL")
    sys.exit(0 if ok else 1)
