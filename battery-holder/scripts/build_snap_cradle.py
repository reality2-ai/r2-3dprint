#!/usr/bin/env python3
"""Export the current curved cradle as explicitly labelled fit-test STLs.

These retain the old 66.8 mm envelope, not the new protected-cell dimensions.
Checks mesh integrity and dimensions, not physical grip or electrical contact.
"""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

from build import inspect, triangles, volume

ROOT = Path(__file__).resolve().parents[1]
SCAD = os.environ.get("OPENSCAD", "openscad")


def main():
    env = os.environ.copy()
    env.setdefault("QT_QPA_PLATFORM", "offscreen")
    outputs = []
    with tempfile.TemporaryDirectory(prefix="snap-cradle-") as temp:
        for cells, width in ((1, 21.3), (2, 43.4)):
            name = f"battery-{cells}-snap-fit-test.stl"
            staged = Path(temp) / name
            result = subprocess.run(
                [SCAD, "-o", str(staged), "-D", 'part="tray"',
                 "-D", f"cells={cells}", str(ROOT / "concepts/snap-cradle.scad")],
                env=env, capture_output=True, text=True)
            log = result.stdout + result.stderr
            if result.returncode or "ERROR:" in log or "WARNING:" in log:
                raise RuntimeError(log)
            report = inspect(staged, [66.8, width, 14.8])
            for probe in ("interference", "retention"):
                path = Path(temp) / f"{cells}-{probe}.stl"
                check = subprocess.run(
                    [SCAD, "-o", str(path), "-D", f'part="{probe}"',
                     "-D", f"cells={cells}", str(ROOT / "concepts/snap-cradle.scad")],
                    env=env, capture_output=True, text=True)
                probe_log = check.stdout + check.stderr
                empty = "Current top level object is empty" in probe_log
                # A cell tangent to its flat floor can leave zero-volume faces.
                if probe == "interference":
                    for warning in (
                        "WARNING: Object may not be a valid 2-manifold and may need repair!",
                        "EXPORT-WARNING: Exported object may not be a valid 2-manifold and may need repair"):
                        probe_log = probe_log.replace(warning, "")
                if "ERROR:" in probe_log or "WARNING:" in probe_log or (check.returncode and not empty):
                    raise RuntimeError(probe_log)
                measured = volume(triangles(path)) if path.exists() else 0
                if probe == "interference":
                    assert measured < 0.001, (cells, probe, measured)
                else:
                    assert measured > 1.0*cells, (cells, probe, measured)
                report[probe + "_mm3"] = round(measured, 6)
            print(name, report, flush=True)
            outputs.append((staged, ROOT / "stl" / name))
        # Publish only after both variants pass the mesh checks.
        for source, target in outputs:
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, target)


if __name__ == "__main__":
    main()
