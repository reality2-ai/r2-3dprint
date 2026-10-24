#!/usr/bin/env python3
"""Export/check the optional logo inlay against its matching lid.

Uses OpenSCAD and the standard-library mesh checks from build.py.
"""
import ast
from concurrent.futures import ThreadPoolExecutor
import json
import re
from pathlib import Path
import subprocess
import tempfile
from build import ROOT, SCAD, inspect, triangles, volume


def render(output, part):
    result = subprocess.run([SCAD, '-o', str(output), '-D', f'part="{part}"',
                             str(ROOT/'src/logo_inlay.scad')], capture_output=True, text=True)
    log = result.stdout+result.stderr
    if 'ERROR:' in log or (result.returncode and 'Current top level object is empty' not in log):
        raise RuntimeError(log)
    return log


def main():
    report = {'status': 'digital fit checked; physical grip requires a print trial', 'parts': {}}
    with tempfile.TemporaryDirectory() as temp:
        log = render(Path(temp)/'parameters.csg','parameters')
        spec, clearance, grip, lead, centres, radius, proud = ast.literal_eval(
            re.search(r'INLAY_PARAMETERS = (.+)',log)[1])
    width, depth, xy, _, _ = spec
    radius *= width/40
    for part, name in [('inlay','logo-inlay'), ('root-fit','logo-root-fit')]:
        path = ROOT/f'stl/router-heltec-{name}.stl'
        render(path, part)
        report['parts'][name] = inspect(path)
        height = report['parts'][name]['bounds_mm'][2][1]
        assert abs(height-(depth+proud))<0.001, 'Inlay must match seating depth plus raised height'
        print(f'{name}: watertight, single connected solid, {height} mm thick', flush=True)
    def check_contact(part):
        result={}
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp)/'contact.stl'
            render(path, part)
            faces = triangles(path) if path.exists() else []
            contact = volume(faces)
            if part=='grip-contact':
                # Separate each distant contact region, so a missing grip spot
                # cannot be hidden by the other five. Placement and fit settings
                # are read from the CAD, including after printer-specific tuning.
                groups = [[] for _ in centres]
                for face in faces:
                    x=sum(p[0] for p in face)/3-xy[0]
                    y=sum(p[1] for p in face)/3-xy[1]
                    i=min(range(6),key=lambda n:(x-centres[n][0])**2+(y-centres[n][1])**2)
                    assert (x-centres[i][0])**2+(y-centres[i][1])**2<(radius+0.01)**2, 'Contact outside grip spots'
                    groups[i].append(face)
                volumes = [volume(group) for group in groups]
                if grip>0:
                    assert all(0.0001<v<6*radius*grip*(depth-lead) for v in volumes), f'Check each grip spot: {volumes}'
                else:
                    assert contact<0.001, 'Zero-grip inlay must have no interference'
                result['individual_grip_contact_mm3'] = [round(v,6) for v in volumes]
            else:
                assert contact<0.001, f'{part}: unexpected overlap {contact:.5f} mm3'
            result[part.replace('-','_')+'_mm3'] = round(contact,6)
            print(f'{part}: passed ({contact:.6f} mm3)', flush=True)
            return result
    with ThreadPoolExecutor(max_workers=3) as executor:
        for result in executor.map(check_contact,['core-contact','unexpected-contact','grip-contact']):
            report.update(result)
    report['fit'] = {'edge_clearance_mm':clearance,'local_edge_grip_mm':grip,
                     'lead_in_mm':lead,'seat_depth_mm':depth,'proud_height_mm':proud,
                     'thickness_mm':depth+proud,'logo_width_mm':width,
                     'lid_material_below_recess_mm':spec[3]-depth}
    report['limits'] = [
        'Shared original SVG tree profile and dimensions come directly from the matching lid source',
        'Contact volumes show geometric interference, not measured friction or retention force',
        'Print at 0.2 mm layer height including the first layer: four seated layers and two raised layers',
        'The root trial uses the actual recess and three root grip spots; the full tree adds three more contacts',
        'Fit depends on printer/material and first-layer expansion; tune edge_grip before forcing thin branches',
        'A tiny spot of glue can retain the inlay if needed; fit of the enlarged design requires a print trial',
        'Requires the matching 80 mm logo lid with 0.8 mm recess; incompatible with the old 40 mm recess',
        'No undercut or snap catch is added; the grip patches end at the lid surface',
    ]
    (ROOT/'test/inlay-validation.json').write_text(json.dumps(report,indent=2)+'\n')


if __name__=='__main__':
    main()
