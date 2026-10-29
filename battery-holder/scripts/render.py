#!/usr/bin/env python3
"""Render the CAD using an existing X display (e.g. the user's XRDP session).

Set DISPLAY and, if needed, XAUTHORITY. Override executable with OPENSCAD.
This does not start a display or open a window in the user's desktop.
"""
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
SCAD = os.environ.get("OPENSCAD", "openscad")
(ROOT/"images").mkdir(exist_ok=True)
for cells,word in ((2,"two"),(3,"three")):
    for part in ("tray","assembly","tape-preview"):
        output = ROOT/f"images/{word}-cell-{part}.png"
        subprocess.run([SCAD,"-o",str(output),"--imgsize=1200,850","--viewall",
                        "--autocenter","--projection=o",
                        "--camera=0,0,0,65,0,35,180",
                        "--colorscheme=Tomorrow","-D",f"cells={cells}",
                        "-D",f'part="{part}"',str(ROOT/"src/battery_holder.scad")],
                       check=True)
        print(output,flush=True)
