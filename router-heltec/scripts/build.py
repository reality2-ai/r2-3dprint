#!/usr/bin/env python3
"""Export printable parts, validate their meshes and check envelope collisions.

Requires OpenSCAD on PATH, or OPENSCAD=/path/to/openscad.
Uses Python's standard library. All outputs are relative to this project.
"""
import collections
from concurrent.futures import ThreadPoolExecutor
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
    if len(data) >= 84 and len(data) == 84 + 50 * struct.unpack_from("<I", data, 80)[0]:
        return [tuple(tuple(struct.unpack_from("<3f", data, i + 12 + j * 12))
                      for j in range(3)) for i in range(84, len(data), 50)]
    vertices = [tuple(map(float, line.split()[1:]))
                for line in data.decode().splitlines() if line.strip().startswith("vertex ")]
    return [tuple(vertices[i:i+3]) for i in range(0, len(vertices), 3)]


def volume(faces):
    return abs(sum(a[0]*(b[1]*c[2]-b[2]*c[1]) + a[1]*(b[2]*c[0]-b[0]*c[2])
                   + a[2]*(b[0]*c[1]-b[1]*c[0]) for a,b,c in faces) / 6)


def inspect(path):
    faces = triangles(path)
    assert faces, f"Empty mesh: {path}"
    edges = collections.Counter()
    neighbours = collections.defaultdict(set)
    points = set()
    for face in faces:
        vs = [tuple(round(n, 4) for n in p) for p in face]
        assert len(set(vs)) == 3, f"Degenerate triangle: {path}"
        points.update(vs)
        for a,b in zip(vs, vs[1:]+vs[:1]):
            edges[tuple(sorted((a,b)))] += 1
            neighbours[a].add(b)
            neighbours[b].add(a)
    assert all(n == 2 for n in edges.values()), f"Non-manifold mesh: {path}"
    pending = set(points)
    components = 0
    while pending:
        components += 1
        stack = [pending.pop()]
        while stack:
            for p in neighbours[stack.pop()]:
                if p in pending:
                    pending.remove(p)
                    stack.append(p)
    assert components == 1, f"Disconnected solids in {path}: {components}"
    bounds = [[min(p[i] for p in points), max(p[i] for p in points)] for i in range(3)]
    assert abs(bounds[2][0]) < 0.001, "Part must sit flat on Z=0"
    return dict(triangles=len(faces), components=components, manifold=True,
                bounds_mm=bounds, volume_mm3=round(volume(faces), 2))


def render(output, part, export_format=None):
    options = ["--export-format",export_format] if export_format else []
    result = subprocess.run([SCAD, *options, "-o", str(output), "-D", f'part="{part}"',
                             str(ROOT / "src/router_heltec_case.scad")], capture_output=True, text=True)
    log = result.stdout + result.stderr
    if "ERROR:" in log or (result.returncode and "Current top level object is empty" not in log):
        raise RuntimeError(log)
    return log


def check_port_alignment():
    with tempfile.TemporaryDirectory() as temp:
        output = Path(temp) / "openings.stl"
        render(output, "port-alignment")
        neighbours = collections.defaultdict(set)
        for face in triangles(output):
            vertices = [tuple(round(n, 4) for n in p) for p in face]
            for p in vertices:
                neighbours[p].update(vertices)
        pending = set(neighbours)
        bounds = []
        while pending:
            points = set()
            stack = [pending.pop()]
            while stack:
                p = stack.pop()
                points.add(p)
                for q in neighbours[p]:
                    if q in pending:
                        pending.remove(q)
                        stack.append(q)
            bounds.append([[min(p[i] for p in points), max(p[i] for p in points)]
                           for i in range(3)])
    front = sorted((b for b in bounds if b[0][1] < 60), key=lambda b: b[0][0])
    side = sorted((b for b in bounds if b[0][0] > 100), key=lambda b: b[1][0])
    assert len(front) == len(side) == 2, "Expected four separate port openings"
    power, hdmi = front
    ethernet, usb = side
    assert abs(power[2][0]-hdmi[2][0]) < 0.001, "Power/HDMI bottoms differ"
    assert all(abs(a-b) < 0.001 for a,b in zip(ethernet[2], usb[2])), "Ethernet/USB edges differ"
    # Keep the socket centres and aligned heights. Reduce excess opening width
    # to obtain printable webs while retaining clearance around the plug models.
    for name, b, axis, span, old_z in [
        ("power", power, 0, [13.6,27.6], [7.4,17.4]),
        ("hdmi", hdmi, 0, [30.6,53.4], [8,20]),
        ("ethernet", ethernet, 1, [6.25,24.75], [6.4,28.4]),
        ("usb", usb, 1, [27.75,40.25], [8,28]),
    ]:
        assert all(abs(a-c) < 0.001 for a,c in zip(b[axis], span)), f"{name}: shifted horizontally"
        assert b[2][0] <= old_z[0]+0.001 and b[2][1] >= old_z[1]-0.001, f"{name}: lost clearance"
    front_web=hdmi[0][0]-power[0][1]
    side_web=usb[1][0]-ethernet[1][1]
    assert min(front_web,side_web)>=2.999, 'Port webs must be at least 3 mm wide'
    for name,b,axis,plug_span in [('HDMI',hdmi,0,[31,53]),
                                  ('Ethernet',ethernet,1,[6.5,24.5]),
                                  ('USB',usb,1,[28,40])]:
        assert min(plug_span[0]-b[axis][0],b[axis][1]-plug_span[1])>=0.249, f'{name}: insufficient plug clearance'
    return dict(power_z_mm=power[2], hdmi_z_mm=hdmi[2],
                ethernet_z_mm=ethernet[2], usb_z_mm=usb[2],
                power_hdmi_web_mm=round(front_web,3),ethernet_usb_web_mm=round(side_web,3),
                hdmi_width_mm=round(hdmi[0][1]-hdmi[0][0],3),
                ethernet_width_mm=round(ethernet[1][1]-ethernet[1][0],3),
                usb_width_mm=round(usb[1][1]-usb[1][0],3))


def check_antenna_bores():
    with tempfile.TemporaryDirectory() as temp:
        path=Path(temp)/'bores.stl'
        # ASCII STL rounds coordinates near X=112 to 0.001 mm, obscuring the
        # sub-micron facet error. Binary STL retains sufficient precision.
        render(path,'antenna-bore-check',export_format='binstl')
        points={p for f in triangles(path) for p in f}
    report=[]
    for centre_x in (28,112):
        section={(p[0],p[2]) for p in points if abs(p[0]-centre_x)<4}
        assert section, 'Missing antenna bore'
        radii=[math.hypot(x-centre_x,z-20) for x,z in section]
        assert max(abs(r-3.25) for r in radii)<0.0002, 'Antenna bore is not circular or has shifted'
        ring=sorted(section,key=lambda p:math.atan2(p[1]-20,p[0]-centre_x))
        assert len(ring)>=128, 'Antenna bore has coarse facets'
        mid_radii=[math.hypot((a[0]+b[0])/2-centre_x,(a[1]+b[1])/2-20)
                   for a,b in zip(ring,ring[1:]+ring[:1])]
        deviation=max(3.25-r for r in mid_radii)
        assert deviation<0.0012, 'Antenna facets deviate too far from a circle'
        report.append(dict(centre_x_mm=centre_x,centre_z_mm=20,diameter_mm=6.5,
                           segments=len(ring),maximum_radial_facet_error_mm=round(deviation,6)))
    return report


def main():
    (ROOT / "stl").mkdir(exist_ok=True)
    report = {"status": "digital prototype; physical fit not verified", "parts": {}}
    for part in ["base", "lid", "hdmi-cover", "sd-cover", "usb-cover", "heltec-cradle", "gps-holder", "gps-keeper", "screen-fit"]:
        output = ROOT / f"stl/router-heltec-{part}.stl"
        render(output, part)
        report["parts"][part] = inspect(output)
        print(f"{part}: watertight, one connected solid", flush=True)
    scenes = [("interference", "hardware_envelope_overlap_mm3"),
                       ("holder-interference", "holder_overlap_mm3"),
                       ("antenna-clearance-interference", "antenna_bulkhead_overlap_mm3"),
                       ("screen-clearance-interference", "screen_clearance_overlap_mm3"),
                       ("logo-layout-interference", "logo_layout_margin_overlap_mm3"),
                       ("cover-interference", "installed_cover_overlap_mm3"),
                       ("usb-cover-corner-interference", "usb_cover_root_gap_overlap_mm3"),
                       ("port-interference", "service_port_overlap_mm3"),
                       ("keyboard-interference", "keyboard_access_overlap_mm3"),
                       ("usb-access-interference", "external_usb_insertion_overlap_mm3"),
                       ("internal-usb-interference", "internal_usb_overlap_mm3"),
                       ("ethernet-access-interference", "ethernet_access_overlap_mm3")]
    def check_clearance(item):
        scene,key=item
        with tempfile.TemporaryDirectory() as temp:
            output = Path(temp) / "interference.stl"
            render(output, scene)
            overlap = volume(triangles(output)) if output.exists() else 0
            # Board/standoff seating faces intentionally touch; zero-volume faces
            # can produce a non-manifold intermediate mesh from CGAL.
            assert overlap < 0.01, f"{scene}: collision {overlap:.4f} mm³"
            print(f"{scene}: passed", flush=True)
            return key,round(overlap,6)
    # Independent OpenSCAD processes, each with its own temporary output.
    # Preserve every assertion and deterministic report order while avoiding
    # serial waits for the detailed vector-logo Boolean operations.
    with ThreadPoolExecutor(max_workers=3) as executor:
        report.update(executor.map(check_clearance,scenes))
    with tempfile.TemporaryDirectory() as temp:
        output = Path(temp) / "spring-contact.stl"
        render(output, "cover-spring-contact")
        overlap = volume(triangles(output)) if output.exists() else 0
        assert overlap > 0.001, "Cover springs must preload the original openings"
        report["cover_relaxed_spring_contact_mm3"] = round(overlap, 6)
        print("Cover spring contact confined to intended wall regions: passed", flush=True)
    with tempfile.TemporaryDirectory() as temp:
        output = Path(temp) / "retention.stl"
        render(output, "cover-retention")
        overlap = volume(triangles(output)) if output.exists() else 0
        assert overlap > 0.001, "Cover detents do not engage the wall when pulled"
        report["cover_retention_engagement_mm3"] = round(overlap, 6)
        print("Cover detents engage when pulled: passed", flush=True)
    # Every cover must engage independently: a passing cap cannot mask another
    # cap's missing hook or spring that does not reach its wall.
    for cover in ("hdmi", "sd", "usb"):
        for check, metric in [("spring-contact", "relaxed_spring_contact"),
                              ("retention", "retention_engagement")]:
            scene = f"{cover}-cover-{check}"
            with tempfile.TemporaryDirectory() as temp:
                output = Path(temp) / "cover.stl"
                render(output, scene)
                overlap = volume(triangles(output)) if output.exists() else 0
                assert overlap > 0.001, f"{scene}: cover does not engage"
                report[f"{cover}_cover_{metric}_mm3"] = round(overlap, 6)
                print(f"{scene}: passed", flush=True)
    for part in ("cradle", "gps"):
        with tempfile.TemporaryDirectory() as temp:
            output = Path(temp) / "retention.stl"
            render(output, f"{part}-retention")
            overlap = volume(triangles(output)) if output.exists() else 0
            assert overlap > 0.01, f"{part}: module is not retained when lifted"
            report[f"{part}_retention_mm3"] = round(overlap, 6)
            print(f"{part} retention: passed", flush=True)
    report["port_alignment"] = check_port_alignment()
    print("Port edges align; 3 mm webs and plug clearances: passed", flush=True)
    report["antenna_bores"]=check_antenna_bores()
    print("Both antenna bores are circular with fine facets: passed", flush=True)
    # Preserve the SD cover and unchanged mounting/access definitions. HDMI
    # and USB covers fit the aligned openings with reinforced port webs.
    original = ROOT.parent / "router"
    def canonical(path):
        return sorted(tuple(sorted(tuple(round(n, 4) for n in p) for p in f))
                      for f in triangles(path))
    for part in ("sd-cover",):
        assert canonical(ROOT / f"stl/router-heltec-{part}.stl") == canonical(original / f"stl/router-{part}.stl"), f"Changed inherited {part}"
    source = (ROOT / "src/router_heltec_case.scad").read_text()
    old_source = (original / "src/router_case.scad").read_text()
    def module_text(text, name):
        start = text.index(f"module {name}(")
        return text[start:text.index("\n}", start)+2]
    for name in ("outline", "external_usb_plugs", "installed_covers", "cover_finger", "service_cover"):
        current=module_text(source,name)
        if name=="service_cover":
            # The narrower USB cover uses 6.5 mm end fingers to leave 0.9 mm
            # corner gaps. All other finger geometry stays identical.
            current=current.replace('min(8,size[0]-6)','8').replace(
                '    // Shorter end fingers keep 0.9 mm corner gaps on the narrowed USB cover.\n','')
        assert current == module_text(old_source, name), f"Changed Pi interface: {name}"
    for name in ("wall", "floor_h", "base_h", "lid_h", "main_w", "cable_bay",
                 "outer_w", "outer_d", "ethernet_step_y", "corner_r", "pcb_z",
                 "pcb_t", "pi_xy", "pi_holes", "sd_xy", "sd_size", "lid_screws"):
        definition = lambda text: next(line.split(";", 1)[0] for line in text.splitlines()
                                       if line.startswith(name+" ="))
        assert definition(source) == definition(old_source), f"Changed Pi geometry parameter: {name}"
    report["inherited_pi_mounts_sd_cover_and_clip_design"] = "identical"
    report["resized_covers"] = ["hdmi-cover", "usb-cover"]
    report["limits"] = ["Simplified board/component envelopes, not exact manufacturer solids",
                        "User confirmed screen cover 33 x 18.6 mm and PCB underside-to-top height 7.1 mm",
                        "User measured GPS PCB 18 x 16 mm, total stack 7 mm and 38 mm extension from Heltec end",
                        "Screen position on PCB, support-pad clearance, cable bend and SMA thread fit require physical checks",
                        "8 mm USB-C plug thickness is provisional; lid relief and board height adapt to this parameter",
                        "GPS antenna points upward; internal component stack is a simplified maximum envelope",
                        "Holder seating and retention are geometric checks, not a prediction of spring force",
                        "Cover spring force, fatigue and insertion fit require a physical PETG test",
                        "Previous PLA clips broke at the face; wider filleted roots and reduced hooks are geometry changes, not a validated strength or fatigue result",
                        "Retention volumes count only hook engagement beyond the spring-preload allowance, individually for HDMI, SD and USB covers",
                        "Relaxed cover springs intentionally overlap four wall contact zones per cover by up to 0.15 mm; deflection is not simulated",
                        "Both exposed USB sockets checked simultaneously with 32 x 12 x 8 mm housings and straight insertion paths, lid fitted and USB cover removed",
                        "Internal nano Wi-Fi dongle allowance is a 6 x 16 x 8 mm body protruding from the USB socket; actual dongle fit requires checking",
                        "Heltec upper internal USB cable and lower internal Wi-Fi dongle checked together against the closed shell and installed covers",
                        "Ethernet access checked with an 18 x 20 mm boot/latch envelope through the narrowed opening",
                        "User reports previous case fits Pi 2B and Pi 3; this revision preserves board mounts but new recess and cover are not physically tested"]
    (ROOT / "test/validation.json").write_text(json.dumps(report, indent=2) + "\n")
    print("Hardware envelope check passed; see test/validation.json")
    from build_inlay import main as build_inlay
    build_inlay()
    from build_plain_lid import main as build_plain_lid
    build_plain_lid()


if __name__ == "__main__":
    main()
