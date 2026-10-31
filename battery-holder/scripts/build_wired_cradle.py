#!/usr/bin/env python3
"""Export the experimental wired holder and check pockets, holes and contact targets."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import math
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

from build import inspect, triangles, volume
from build_protected_cradle import axial_crossings

ROOT = Path(__file__).resolve().parents[1]


def expect_hits(faces, y, z, expected):
    hits = axial_crossings(faces, y, z)
    assert len(hits) == len(expected) and all(abs(a-b)<0.005 for a,b in zip(hits, expected)), (hits, expected)
    return hits


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--wire-hole", type=float, default=1.2)
    args = parser.parse_args()
    if not 1 < args.wire_hole < 2.2:
        parser.error("Wire hole must pass the approximately 1 mm insulation and leave pocket backing")
    env = os.environ.copy()
    env.setdefault("QT_QPA_PLATFORM", "offscreen")
    parts = ["tray", "heads", "interference", "retention", "head-interference",
             "wire-interference", "contact-preload", "relieved-interference",
             "footprint", "overhang-clearance"]
    with tempfile.TemporaryDirectory(prefix="wired-cradle-") as temp:
        def export(part):
            path = Path(temp) / f"{part}.stl"
            result = subprocess.run(
                [os.environ.get("OPENSCAD", "openscad"), "-o", str(path),
                 "-D", f'part="{part}"', "-D", f"wire_hole_d={args.wire_hole}",
                 str(ROOT / "src/wired_snap_cradle.scad")],
                capture_output=True, text=True, env=env)
            log = result.stdout+result.stderr
            empty = "Current top level object is empty" in log
            if part in ("interference", "head-interference", "relieved-interference"):
                for warning in (
                    "WARNING: Object may not be a valid 2-manifold and may need repair!",
                    "EXPORT-WARNING: Exported object may not be a valid 2-manifold and may need repair"):
                    log = log.replace(warning, "")
            if "ERROR:" in log or "WARNING:" in log or (result.returncode and not empty):
                raise RuntimeError(log)
            return part, path

        with ThreadPoolExecutor(max_workers=3) as pool:
            paths = dict(pool.map(export, parts))
        faces = triangles(paths["tray"])
        report = inspect(paths["tray"], [72.8, 21.3, 17.2002])
        cy, cz = 10.65, 12.8
        expect_hits(faces, cy, cz, [])  # continuous bare-wire path through both ends
        expect_hits(faces, cy+0.8, cz, [0, 0.5, 71.3, 71.8])  # 0.5 mm pocket floors
        expect_hits(faces, cy+2, cz, [0, 1, 70.8, 71.8])  # full wall outside the pockets
        # Bore/pocket diameters measured across both actual exported end walls.
        swapped = [tuple((p[1],p[0],p[2]) for p in face) for face in faces]
        for x, diameter in ((0.25,args.wire_hole),(0.75,3),
                            (71.55,args.wire_hole),(71.05,3)):
            expect_hits(swapped,x,cz,[0,cy-diameter/2,cy+diameter/2,21.3])
        # Offset marks leave the wire holes unobstructed and preserve polarity.
        expect_hits(faces,cy+6,cz,[-0.5,1,70.8,72.3])
        for dz in (-2,2):
            expect_hits(faces,cy+6,cz+dz,[0,1,70.8,72.3])
        contacts = expect_hits(triangles(paths["heads"]),cy,cz,[0.5,1.6,70.2,71.3])
        report["target_contact_gap_mm"] = round(contacts[2]-contacts[1],4)
        report["target_preload_mm"] = round(69-report["target_contact_gap_mm"],4)
        inspect(paths["footprint"],[67,21.3,0.01])
        xs = [p[0] for face in triangles(paths["footprint"]) for p in face]
        assert abs(min(xs))<0.001 and abs(max(xs)-67)<0.001
        profile = [p for face in faces for p in face if abs(p[0]-26.2)<0.001 and p[2]>cz]
        opening = min(p[1] for p in profile if p[1]>cy)-max(p[1] for p in profile if p[1]<cy)
        assert abs(opening-16.5925)<0.005, opening
        report["lip_opening_mm"] = round(opening,4)
        for part in parts[2:]:
            if part == "footprint":
                continue
            path = paths[part]
            measured = volume(triangles(path)) if path.exists() else 0
            if part == "retention":
                assert measured>1, (part,measured)
            elif part == "contact-preload":
                assert 0<measured<0.4*math.pi*1.4**2, (part,measured)
            else:
                assert measured<0.001, (part,measured)
            report[part+"_mm3"] = round(measured,6)
        report["wire_hole_mm"] = args.wire_hole
        report["pocket_diameter_mm"] = 3
        report["pocket_depth_mm"] = 0.5
        target = ROOT / "stl/battery-1-protected-wired-tray.stl"
        shutil.copyfile(paths["tray"],target)
        print(target.name,report,flush=True)
        print("Only the plastic tray is exported; wire and solder heads are illustrative targets.")


if __name__ == "__main__":
    main()
