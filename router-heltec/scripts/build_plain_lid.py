#!/usr/bin/env python3
"""Export the optional plain lid using the shared design's existing logo switch."""
import json
import subprocess

from build import ROOT, SCAD, inspect


def main():
    output = ROOT / 'stl/router-heltec-lid-plain.stl'
    result = subprocess.run([SCAD, '-o', str(output),
                             str(ROOT / 'src/plain_lid.scad')],
                            capture_output=True, text=True)
    log = result.stdout + result.stderr
    if result.returncode or 'ERROR:' in log:
        raise RuntimeError(log)
    plain = inspect(output)
    branded = inspect(ROOT / 'stl/router-heltec-lid.stl')
    assert plain['bounds_mm'] == branded['bounds_mm'], 'Plain lid dimensions differ'
    assert plain['volume_mm3'] > branded['volume_mm3'], 'Logo recess was not filled'
    report = {'status': 'digital geometry checked; physical fit requires a print trial',
              'parts': {'lid-plain': plain},
              'same_bounds_as_logo_lid': True,
              'added_material_mm3': round(plain['volume_mm3']-branded['volume_mm3'], 2),
              'design': 'Shared lid with lid_logo=false; same screen aperture, screw holes and USB-C relief'}
    (ROOT / 'test/plain-lid-validation.json').write_text(json.dumps(report, indent=2)+'\n')
    print('Plain lid: watertight, one connected solid, matching lid dimensions', flush=True)


if __name__ == '__main__':
    main()
