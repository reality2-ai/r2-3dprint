#!/usr/bin/env python3
"""Export the single 69 mm protected-cell holder on a flush-ended 67 mm base."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

from build import inspect, triangles, volume

ROOT = Path(__file__).resolve().parents[1]


def axial_crossings(faces, y, z):
    """Intersect the exported surface with a line through a terminal."""
    hits = []
    for a, b, c in faces:
        uy, uz = b[1]-a[1], b[2]-a[2]
        vy, vz = c[1]-a[1], c[2]-a[2]
        det = uy*vz-uz*vy
        if abs(det) < 1e-10:
            continue
        dy, dz = y-a[1], z-a[2]
        u, v = (dy*vz-dz*vy)/det, (uy*dz-uz*dy)/det
        if u >= -1e-7 and v >= -1e-7 and u+v <= 1+1e-7:
            hits.append(a[0]+u*(b[0]-a[0])+v*(c[0]-a[0]))
    distinct = []
    for x in sorted(hits):
        if not distinct or abs(x-distinct[-1]) > 1e-5:
            distinct.append(x)
    return distinct


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cells", type=int, choices=(1,), default=1)
    parser.add_argument("--lift", type=float,
                        help="Shallow step under the overhang in mm (default 2)")
    parser.add_argument("--diameter", type=float, default=18)
    args = parser.parse_args()
    lift = 2 if args.lift is None else args.lift
    if lift <= 0 or args.diameter <= 0:
        parser.error("Lift and diameter must be positive")
    width = args.cells*(args.diameter+3.3)+(args.cells-1)*0.8
    height = lift+args.diameter/2+5.8
    env = os.environ.copy()
    env.setdefault("QT_QPA_PLATFORM", "offscreen")
    with tempfile.TemporaryDirectory(prefix="protected-cradle-") as temp:
        def export(part):
            path = Path(temp) / f"{part}.stl"
            result = subprocess.run(
                [os.environ.get("OPENSCAD", "openscad"), "-o", str(path),
                 "-D", f'part="{part}"', "-D", f"cells={args.cells}",
                 "-D", f"mount_lift={lift}", "-D", f"cell_d={args.diameter}",
                 str(ROOT / "src/protected_snap_cradle.scad")],
                capture_output=True, text=True, env=env)
            log = result.stdout+result.stderr
            empty = "Current top level object is empty" in log
            if part == "interference":
                for warning in (
                    "WARNING: Object may not be a valid 2-manifold and may need repair!",
                    "EXPORT-WARNING: Exported object may not be a valid 2-manifold and may need repair"):
                    log = log.replace(warning, "")
            if "ERROR:" in log or "WARNING:" in log or (result.returncode and not empty):
                raise RuntimeError(log)
            return part, path

        parts = ["tray", "interference", "retention", "footprint", "overhang-clearance"]
        with ThreadPoolExecutor(max_workers=3) as pool:
            paths = dict(pool.map(export, parts))
        report = inspect(paths["tray"], [71.8, width, height])
        faces = triangles(paths["tray"])
        centre_y = args.diameter/2+0.05+1.6
        centre_z = lift+1.8+args.diameter/2
        for offset, inner_x in ((0, 1.5), (3, 1.0)):
            hits = axial_crossings(faces, centre_y+offset, centre_z)
            expected = [0, inner_x, 70.8, 71.8]
            assert len(hits) == 4 and all(abs(a-b)<0.005 for a,b in zip(hits, expected)), hits
            if offset == 0:
                report["plastic_contact_gap_mm"] = round(hits[2]-hits[1], 4)
        inspect(paths["footprint"], [67, width, 0.01])
        # Both start at X=0, so all 4.8 mm of extension lies at the far end.
        for part, xmax in (("footprint", 67), ("tray", 71.8)):
            xs = [p[0] for face in triangles(paths[part]) for p in face]
            assert abs(min(xs)) < 0.001 and abs(max(xs)-xmax) < 0.001
        for part in ("interference", "retention", "overhang-clearance"):
            path = paths[part]
            measured = volume(triangles(path)) if path.exists() else 0
            if part == "retention":
                assert measured > args.cells, (part, measured)
            else:
                assert measured < 0.001, (part, measured)
            report[part+"_mm3"] = round(measured, 6)
        target = ROOT / "stl" / f"battery-{args.cells}-protected-snap-tray.stl"
        shutil.copyfile(paths["tray"], target)
        print(target.name, report)
        print(f"Cell: 69 x {args.diameter:g} mm; under-overhang clearance: {lift:g} mm")


if __name__ == "__main__":
    main()
