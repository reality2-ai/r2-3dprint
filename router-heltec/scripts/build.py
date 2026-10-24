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
    assert len(front) == 2 and len(side) == 1, "Expected power, HDMI and one joined Ethernet/USB opening"
    power, hdmi = front
    combined = side[0]
    assert abs(power[2][0]-hdmi[2][0]) < 0.001, "Power/HDMI bottoms differ"
    # The side opening must be continuous after removing the divider, and
    # extend 2 mm towards the corner without changing the aligned heights.
    for name, b, axis, span, old_z in [
        ("power", power, 0, [13.6,27.6], [7.4,17.4]),
        ("hdmi", hdmi, 0, [30.6,53.4], [8,20]),
        ("ethernet-usb", combined, 1, [6.25,42.25], [6.4,28.4]),
    ]:
        assert all(abs(a-c) < 0.001 for a,c in zip(b[axis], span)), f"{name}: shifted horizontally"
        assert b[2][0] <= old_z[0]+0.001 and b[2][1] >= old_z[1]-0.001, f"{name}: lost clearance"
    front_web=hdmi[0][0]-power[0][1]
    assert front_web>=2.999, 'Power/HDMI web must be at least 3 mm wide'
    for name,b,axis,plug_span in [('HDMI',hdmi,0,[31,53]),
                                  ('Ethernet',combined,1,[6.5,24.5]),
                                  ('USB',combined,1,[26,42])]:
        assert min(plug_span[0]-b[axis][0],b[axis][1]-plug_span[1])>=0.249, f'{name}: insufficient plug clearance'
    return dict(power_z_mm=power[2], hdmi_z_mm=hdmi[2],
                ethernet_z_mm=combined[2], usb_z_mm=combined[2],
                power_hdmi_web_mm=round(front_web,3),ethernet_usb_web_mm=0,
                hdmi_width_mm=round(hdmi[0][1]-hdmi[0][0],3),
                combined_ethernet_usb_y_mm=combined[1],
                combined_ethernet_usb_width_mm=round(combined[1][1]-combined[1][0],3),
                checked_usb_plug_width_mm=16,user_measured_usb_plug_width_mm=15,
                checked_usb_corner_clearance_mm=round(combined[1][1]-42,3))


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


def check_cradle_overhangs(path):
    # Inspect actual downward-facing mesh surfaces above the bed. The old
    # flat hook undersides and rear-post caps would both fail this check.
    angles=[]
    for a,b,c in triangles(path):
        if min(a[2],b[2],c[2]) < 0.001:
            continue
        u=[b[i]-a[i] for i in range(3)]
        v=[c[i]-a[i] for i in range(3)]
        n=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
        if n[2] < -0.00001:
            angle=math.degrees(math.atan2(math.hypot(n[0],n[1]),-n[2]))
            assert angle>=44.9, f'Cradle underside too shallow: {angle:.3f} degrees'
            angles.append(angle)
    assert angles, 'Expected sloping hook undersides'
    return dict(minimum_underside_angle_degrees=round(min(angles),3),
                downward_faces_above_bed=len(angles))


def connected_contact_volumes(faces):
    by_vertex=collections.defaultdict(set)
    for i,face in enumerate(faces):
        for p in face:
            by_vertex[tuple(round(n,5) for n in p)].add(i)
    pending=set(range(len(faces)))
    volumes=[]
    while pending:
        component={pending.pop()}
        stack=list(component)
        while stack:
            for p in faces[stack.pop()]:
                for neighbour in by_vertex[tuple(round(n,5) for n in p)] & pending:
                    pending.remove(neighbour)
                    component.add(neighbour)
                    stack.append(neighbour)
        volumes.append(round(volume([faces[i] for i in component]),6))
    return sorted(volumes)


def main():
    (ROOT / "stl").mkdir(exist_ok=True)
    report = {"status": "digital prototype; physical fit not verified", "parts": {}}
    for part in ["base", "lid", "hdmi-cover", "sd-cover", "usb-cover", "heltec-cradle", "gps-holder", "gps-keeper", "screen-fit"]:
        output = ROOT / f"stl/router-heltec-{part}.stl"
        render(output, part)
        report["parts"][part] = inspect(output)
        if part == 'heltec-cradle':
            report['cradle_print_overhangs'] = check_cradle_overhangs(output)
        print(f"{part}: watertight, one connected solid", flush=True)
    scenes = [("interference", "hardware_envelope_overlap_mm3"),
                       ("holder-interference", "holder_overlap_mm3"),
                       ("antenna-clearance-interference", "antenna_bulkhead_overlap_mm3"),
                       ("screen-clearance-interference", "screen_clearance_overlap_mm3"),
                       ("logo-layout-interference", "logo_layout_margin_overlap_mm3"),
                       ("cover-interference", "installed_cover_overlap_mm3"),
                       ("usb-cover-corner-interference", "usb_cover_root_gap_overlap_mm3"),
                       ("usb-cover-open-side-interference", "usb_cover_open_edge_overlap_mm3"),
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
                if cover == 'usb' and check == 'retention':
                    # Each of the three hooks must engage independently.
                    contacts = {'top': [], 'bottom': [], 'corner': []}
                    for face in triangles(output):
                        y,z = [sum(p[i] for p in face)/3 for i in (1,2)]
                        if z >= 28.399: contacts['top'].append(face)
                        elif z <= 6.401: contacts['bottom'].append(face)
                        else:
                            assert y > 42.25, 'USB hook contact on the removed divider'
                            contacts['corner'].append(face)
                    volumes = {edge: round(volume(faces),6) for edge,faces in contacts.items()}
                    assert all(v > 0.001 for v in volumes.values()), f'Missing USB hook engagement: {volumes}'
                    report['usb_cover_individual_hook_retention_mm3'] = volumes
                report[f"{cover}_cover_{metric}_mm3"] = round(overlap, 6)
                print(f"{scene}: passed", flush=True)
    for scene,key in [('cradle-spring-contact','cradle_seated_preload_per_clip_mm3'),
                      ('cradle-retention-early','cradle_retention_at_0_2_mm_lift_per_clip_mm3')]:
        with tempfile.TemporaryDirectory() as temp:
            output=Path(temp)/'contact.stl'
            render(output,scene)
            contacts=connected_contact_volumes(triangles(output)) if output.exists() else []
            assert len(contacts)==4 and all(v>0.01 for v in contacts), f'{scene}: all four clips must engage: {contacts}'
            if scene=='cradle-spring-contact':
                assert all(v<1 for v in contacts), f'Excessive PCB-edge preload: {contacts}'
            report[key]=contacts
            print(f'{scene}: all four clips engage',flush=True)
    for part in ("cradle", "gps"):
        with tempfile.TemporaryDirectory() as temp:
            output = Path(temp) / "retention.stl"
            render(output, f"{part}-retention")
            overlap = volume(triangles(output)) if output.exists() else 0
            assert overlap > 0.01, f"{part}: module is not retained when lifted"
            if part=='cradle':
                contacts=connected_contact_volumes(triangles(output))
                assert len(contacts)==4 and all(v>0.1 for v in contacts), f'Every cradle hook must retain the lifted PCB: {contacts}'
                report['cradle_retention_at_0_6_mm_lift_per_clip_mm3']=contacts
            report[f"{part}_retention_mm3"] = round(overlap, 6)
            print(f"{part} retention: passed", flush=True)
    report["port_alignment"] = check_port_alignment()
    print("Port edges align; 3 mm front web, joined side opening and 16 mm USB clearance: passed", flush=True)
    report["antenna_bores"]=check_antenna_bores()
    print("Both antenna bores are circular with fine facets: passed", flush=True)
    # Preserve the SD cover, mounts and individual finger profile. The USB
    # opening and three-sided cover intentionally differ from the original.
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
    for name in ("outline", "installed_covers", "cover_finger", "service_cover"):
        current=module_text(source,name)
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
                        "User measured USB-C thickness about 6.5 mm; plug length/width and centring remain provisional; deeper lid pocket leaves 1.05 mm roof and 0.3 mm plug clearance",
                        "GPS antenna points upward; internal component stack is a simplified maximum envelope",
                        "Holder seating and retention are geometric checks, not a prediction of spring force",
                        "PETG cradle has 0.2 mm nominal PCB-edge preload per side, 2.0 mm arms and 45-degree hook undersides; physical grip requires a new trial",
                        "Cradle retention tests shift each spring outward by its nominal preload before lifting the PCB; this is a tip-position proxy, not elastic simulation",
                        "Cover spring force, fatigue and insertion fit require a physical PETG test",
                        "Previous PLA clips broke at the face; wider filleted roots and reduced hooks are geometry changes, not a validated strength or fatigue result",
                        "Retention volumes count only hook engagement beyond the spring-preload allowance, individually for HDMI, SD and USB covers",
                        "Relaxed springs overlap their wall contact zones by up to 0.15 mm: four for HDMI/SD and three for USB; deflection is not simulated",
                        "User measured a 15 mm-wide USB plug; both exposed sockets checked with larger 32 x 16 x 8 mm housings and straight insertion paths, lid fitted and USB cover removed",
                        "USB cover fills the former divider gap; three hooks grip top, bottom and corner while Ethernet remains accessible",
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
