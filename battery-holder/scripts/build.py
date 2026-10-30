#!/usr/bin/env python3
"""Build both holders and check printable solids, fit and geometric retention.

Python standard library only. Requires OpenSCAD; override with OPENSCAD.
Checks geometry, not spring mechanics, electrical contact or printer accuracy.
"""
import collections
import json
import math
import os
from pathlib import Path
import struct
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
SCAD = os.environ.get("OPENSCAD", "openscad")


def triangles(path):
    data = path.read_bytes()
    if len(data) >= 84 and len(data) == 84+50*struct.unpack_from("<I", data, 80)[0]:
        return [tuple(tuple(struct.unpack_from("<3f", data, i+12+j*12))
                      for j in range(3)) for i in range(84, len(data), 50)]
    vs = [tuple(map(float, line.split()[1:])) for line in data.decode().splitlines()
          if line.strip().startswith("vertex ")]
    return [tuple(vs[i:i+3]) for i in range(0, len(vs), 3)]


def volume(faces):
    return abs(sum(a[0]*(b[1]*c[2]-b[2]*c[1]) + a[1]*(b[2]*c[0]-b[0]*c[2])
                   + a[2]*(b[0]*c[1]-b[1]*c[0]) for a,b,c in faces)/6)


def inspect(path, expected):
    faces = triangles(path)
    assert faces, f"Empty mesh: {path}"
    edges = collections.Counter()
    directed = collections.Counter()
    neighbours = collections.defaultdict(set)
    points = set()
    for face in faces:
        vs = [tuple(round(v, 5) for v in p) for p in face]
        assert all(math.isfinite(v) for p in vs for v in p)
        assert len(set(vs)) == 3, "Degenerate triangle"
        a,b,c = vs
        u,v = [b[i]-a[i] for i in range(3)], [c[i]-a[i] for i in range(3)]
        assert sum(x*x for x in (u[1]*v[2]-u[2]*v[1], u[2]*v[0]-u[0]*v[2],
                                 u[0]*v[1]-u[1]*v[0])) > 1e-12
        points.update(vs)
        for a,b in zip(vs, vs[1:]+vs[:1]):
            edges[tuple(sorted((a,b)))] += 1
            directed[(a,b)] += 1
            neighbours[a].add(b)
            neighbours[b].add(a)
    assert all(n == 2 for n in edges.values()), f"Non-manifold: {path}"
    assert all(directed[(b,a)] == n for (a,b),n in directed.items()), "Winding"
    pending = set(points)
    count = 0
    while pending:
        count += 1
        stack = [pending.pop()]
        while stack:
            for p in neighbours[stack.pop()]:
                if p in pending:
                    pending.remove(p)
                    stack.append(p)
    assert count == 1, f"Disconnected solids: {path}"
    bounds = [[min(p[i] for p in points), max(p[i] for p in points)] for i in range(3)]
    size = [round(b-a, 4) for a,b in bounds]
    assert abs(bounds[2][0]) < 1e-4, "Part must start on print bed"
    assert all(abs(a-b) < 0.002 for a,b in zip(size, expected)), (size,expected)
    return dict(triangles=len(faces), connected_solids=count, watertight=True,
                consistent_winding=True, size_mm=size, volume_mm3=round(volume(faces),3))


def render(path, part, cells, extra=(), allow_contact_surface=False):
    result = subprocess.run([SCAD,"-o",str(path),"-D",f'part="{part}"',
                             "-D",f"cells={cells}",*extra,
                             str(ROOT / "src/battery_holder.scad")],
                            capture_output=True,text=True)
    log = result.stdout+result.stderr
    empty = "Current top level object is empty" in log
    checked_log = log
    if allow_contact_surface:
        # Tangency of a cylindrical cell with its flat floor can produce a
        # zero-volume edge in CGAL. Accept only these specific probe warnings;
        # exported printable meshes always receive the strict manifold check.
        for warning in ("WARNING: Object may not be a valid 2-manifold and may need repair!",
                        "EXPORT-WARNING: Exported object may not be a valid 2-manifold and may need repair"):
            checked_log = checked_log.replace(warning, "")
    if "ERROR:" in checked_log or "WARNING:" in checked_log or (result.returncode and not empty):
        raise RuntimeError(log)
    return log


def check_contact_spacing(path, cells):
    """Measure end-wall crossings in the exported mesh at each terminal centre."""
    gaps = []
    for i in range(cells):
        y, z = 9.95 + i*19.1, 10.0
        crossings = set()
        for a,b,c in triangles(path):
            by,bz,cy,cz = b[1]-a[1],b[2]-a[2],c[1]-a[1],c[2]-a[2]
            det = by*cz-cy*bz
            if abs(det) < 1e-9:
                continue
            u = ((y-a[1])*cz-(z-a[2])*cy)/det
            v = (by*(z-a[2])-bz*(y-a[1]))/det
            if u >= -1e-7 and v >= -1e-7 and u+v <= 1+1e-7:
                crossings.add(round(a[0]+u*(b[0]-a[0])+v*(c[0]-a[0]),5))
        xs = sorted(crossings)
        assert len(xs) == 4, (i,xs)
        gap = round(xs[2]-xs[1],5)
        assert abs(gap-64.8) < 0.002, (i,gap)
        gaps.append({"plastic_gap_mm":gap,"with_0.1_mm_tape_each_end_mm":round(gap-0.2,5)})
    return gaps


def main():
    (ROOT/"stl").mkdir(exist_ok=True)
    (ROOT/"test").mkdir(exist_ok=True)
    report = {"status":"digital prototype; physical fit and contact force unverified",
              "cell_mm":[64,18],"hard_length_limit_mm":67,
              "nominal_length_mm":66.8,"assumed_tape_plus_adhesive_mm":0.1,
              "length_fit_allowance_mm":1.0,"fit_envelope_length_mm":65,
              "relaxed_taped_gap_mm":64.6,
              "physical_feedback":"65.8 mm first print about 1 mm tight; end walls splay",
              "parts":{},"checks":{},"loaded_with_bands_mm":{}}
    for n in (2,3):
        width = 39+(n-2)*19.1
        for part,size in (("tray",[66.8,width,12]),("band",[21,width+2,5])):
            path = ROOT/f"stl/battery-{n}-{part}.stl"
            render(path,part,n)
            report["parts"][path.name] = inspect(path,size)
            print(f"{path.name}: single watertight solid; {size} mm",flush=True)
        report["loaded_with_bands_mm"][str(n)] = [66.8,width+2,21]
        checks = {"measured_contact_spacing":check_contact_spacing(ROOT/f"stl/battery-{n}-tray.stl",n)}
        with tempfile.TemporaryDirectory() as temp:
            for scene,positive in (("seated-interference",False),
                                   ("nominal-cell-interference",False),
                                   ("unexpected-interference",False),
                                   ("preload-interference",True),
                                   ("tape-land-missing",False),
                                   ("end-relief-interference",False),
                                   ("band-interference",False),
                                   ("band-retention",True),
                                   ("cell-retention",True)):
                path = Path(temp)/f"{scene}.stl"
                render(path,scene,n,allow_contact_surface=True)
                vol = volume(triangles(path)) if path.exists() else 0
                assert (vol > 0.01 if positive else vol < 0.001), (n,scene,vol)
                checks[scene+"_mm3"] = round(vol,6)
                print(f"{n} cells: {scene} passed ({vol:.6f} mm3)",flush=True)
            # Reject a longer cell or excessive tape instead of silently enlarging.
            for setting in ("cell_l=65","tape_t=0.2","outside_l=67.1","outside_l=65.8"):
                try:
                    render(Path(temp)/"invalid.stl","tray",n,["-D",setting])
                except RuntimeError as error:
                    assert "Assertion" in str(error), str(error)
                else:
                    raise AssertionError(f"Invalid geometry accepted: {setting}")
            checks["length_budget_rejections"] = "passed"
        report["checks"][str(n)] = checks
    path = ROOT/"stl/battery-contact-fit.stl"
    render(path,"contact-fit",2)
    report["parts"][path.name] = inspect(path,[66.8,19.9,12])
    (ROOT/"test/verification.json").write_text(json.dumps(report,indent=2)+"\n")
    print("Fit piece passed. Report: test/verification.json")


if __name__ == "__main__":
    main()
