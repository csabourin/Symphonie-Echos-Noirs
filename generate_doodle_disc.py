import sys
import re
import math
import xml.etree.ElementTree as ET
import random
import argparse
import json

# ==========================================
# SVG Path Tokenizer & Parser
# ==========================================

def tokenize_path(d):
    # Regex to capture commands and floats (including scientific notation and signs)
    token_re = re.compile(r'([a-zA-Z])|([+-]?(?:\d*\.\d+|\d+\.?)(?:[eE][+-]?\d+)?)')
    tokens = []
    for match in token_re.finditer(d):
        cmd, num = match.groups()
        if cmd is not None:
            tokens.append(cmd)
        elif num is not None:
            tokens.append(float(num))
    return tokens

def interpolate_cubic_bezier(x0, y0, x1, y1, x2, y2, x3, y3, steps=10):
    points = []
    for s in range(steps + 1):
        t = s / steps
        u = 1 - t
        x = u**3 * x0 + 3 * u**2 * t * x1 + 3 * u * t**2 * x2 + t**3 * x3
        y = u**3 * y0 + 3 * u**2 * t * y1 + 3 * u * t**2 * y2 + t**3 * y3
        points.append((x, y))
    return points

def interpolate_quadratic_bezier(x0, y0, x1, y1, x2, y2, steps=10):
    points = []
    for s in range(steps + 1):
        t = s / steps
        u = 1 - t
        x = u**2 * x0 + 2 * u * t * x1 + t**2 * x2
        y = u**2 * y0 + 2 * u * t * y1 + t**2 * y2
        points.append((x, y))
    return points

def parse_tokens(tokens):
    paths = []
    current_path = []
    
    cx, cy = 0.0, 0.0
    start_x, start_y = 0.0, 0.0
    
    # Last control points for smooth curves
    last_cx, last_cy = 0.0, 0.0
    
    i = 0
    cmd = None
    while i < len(tokens):
        token = tokens[i]
        if isinstance(token, str):
            cmd = token
            i += 1
        else:
            # Repeat command rule
            if cmd == 'M': cmd = 'L'
            elif cmd == 'm': cmd = 'l'
        
        if cmd == 'M':
            cx = tokens[i]
            cy = tokens[i+1]
            start_x, start_y = cx, cy
            if current_path:
                paths.append(current_path)
            current_path = [(cx, cy)]
            i += 2
        elif cmd == 'm':
            cx += tokens[i]
            cy += tokens[i+1]
            start_x, start_y = cx, cy
            if current_path:
                paths.append(current_path)
            current_path = [(cx, cy)]
            i += 2
        elif cmd == 'L':
            cx = tokens[i]
            cy = tokens[i+1]
            current_path.append((cx, cy))
            i += 2
        elif cmd == 'l':
            cx += tokens[i]
            cy += tokens[i+1]
            current_path.append((cx, cy))
            i += 2
        elif cmd == 'H':
            cx = tokens[i]
            current_path.append((cx, cy))
            i += 1
        elif cmd == 'h':
            cx += tokens[i]
            current_path.append((cx, cy))
            i += 1
        elif cmd == 'V':
            cy = tokens[i]
            current_path.append((cx, cy))
            i += 1
        elif cmd == 'v':
            cy += tokens[i]
            current_path.append((cx, cy))
            i += 1
        elif cmd in ('C', 'c'):
            if cmd == 'C':
                x1, y1 = tokens[i], tokens[i+1]
                x2, y2 = tokens[i+2], tokens[i+3]
                x, y = tokens[i+4], tokens[i+5]
            else:
                x1, y1 = cx + tokens[i], cy + tokens[i+1]
                x2, y2 = cx + tokens[i+2], cy + tokens[i+3]
                x, y = cx + tokens[i+4], cy + tokens[i+5]
            points = interpolate_cubic_bezier(cx, cy, x1, y1, x2, y2, x, y)
            current_path.extend(points[1:])
            last_cx, last_cy = x2, y2
            cx, cy = x, y
            i += 6
        elif cmd in ('S', 's'):
            if cmd == 'S':
                x2, y2 = tokens[i], tokens[i+1]
                x, y = tokens[i+2], tokens[i+3]
            else:
                x2, y2 = cx + tokens[i], cy + tokens[i+1]
                x, y = cx + tokens[i+2], cy + tokens[i+3]
            x1 = 2 * cx - last_cx
            y1 = 2 * cy - last_cy
            points = interpolate_cubic_bezier(cx, cy, x1, y1, x2, y2, x, y)
            current_path.extend(points[1:])
            last_cx, last_cy = x2, y2
            cx, cy = x, y
            i += 4
        elif cmd in ('Q', 'q'):
            if cmd == 'Q':
                x1, y1 = tokens[i], tokens[i+1]
                x, y = tokens[i+2], tokens[i+3]
            else:
                x1, y1 = cx + tokens[i], cy + tokens[i+1]
                x, y = cx + tokens[i+2], cy + tokens[i+3]
            points = interpolate_quadratic_bezier(cx, cy, x1, y1, x, y)
            current_path.extend(points[1:])
            last_cx, last_cy = x1, y1
            cx, cy = x, y
            i += 4
        elif cmd in ('T', 't'):
            if cmd == 'T':
                x, y = tokens[i], tokens[i+1]
            else:
                x, y = cx + tokens[i], cy + tokens[i+1]
            x1 = 2 * cx - last_cx
            y1 = 2 * cy - last_cy
            points = interpolate_quadratic_bezier(cx, cy, x1, y1, x, y)
            current_path.extend(points[1:])
            last_cx, last_cy = x1, y1
            cx, cy = x, y
            i += 2
        elif cmd in ('A', 'a'):
            # Arc command fallback
            if cmd == 'A':
                x, y = tokens[i+5], tokens[i+6]
            else:
                x, y = cx + tokens[i+5], cy + tokens[i+6]
            current_path.append((x, y))
            cx, cy = x, y
            i += 7
        elif cmd in ('Z', 'z'):
            cx, cy = start_x, start_y
            current_path.append((cx, cy))
            if current_path:
                paths.append(current_path)
            current_path = []
            i += 1
        else:
            i += 1
            
    if current_path:
        paths.append(current_path)
    return paths

# ==========================================
# SVG Transform Parser
# ==========================================

def parse_transform(transform_str):
    a, b, c, d, e, f = 1.0, 0.0, 0.0, 1.0, 0.0, 0.0
    funcs = re.findall(r'(\w+)\s*\(([^)]*)\)', transform_str)
    for name, args_str in funcs:
        args = [float(x) for x in re.split(r'[\s,]+', args_str.strip()) if x]
        ma, mb, mc, md, me, mf = 1.0, 0.0, 0.0, 1.0, 0.0, 0.0
        
        if name == 'translate':
            me = args[0]
            mf = args[1] if len(args) > 1 else 0.0
        elif name == 'scale':
            ma = args[0]
            md = args[1] if len(args) > 1 else args[0]
        elif name == 'rotate':
            angle_rad = math.radians(args[0])
            cos_a = math.cos(angle_rad)
            sin_a = math.sin(angle_rad)
            if len(args) >= 3:
                cx, cy = args[1], args[2]
                ma = cos_a
                mb = sin_a
                mc = -sin_a
                md = cos_a
                me = cx - cx * cos_a + cy * sin_a
                mf = cy - cx * sin_a - cy * cos_a
            else:
                ma = cos_a
                mb = sin_a
                mc = -sin_a
                md = cos_a
        elif name == 'matrix':
            if len(args) == 6:
                ma, mb, mc, md, me, mf = args
                
        # Composition matrix math
        a_n = a * ma + c * mb
        b_n = b * ma + d * mb
        c_n = a * mc + c * md
        d_n = b * mc + d * md
        e_n = a * me + c * mf + e
        f_n = b * me + d * mf + f
        a, b, c, d, e, f = a_n, b_n, c_n, d_n, e_n, f_n
        
    return lambda x, y: (a * x + c * y + e, b * x + d * y + f)

def compose_transforms(tf1, tf2):
    return lambda x, y: tf1(*tf2(x, y))

def extract_polylines_from_svg(svg_path):
    try:
        tree = ET.parse(svg_path)
        root = tree.getroot()
    except Exception as e:
        print(f"Error parsing XML file {svg_path}: {e}")
        return []
        
    polylines = []
    
    def traverse(elem, current_tf):
        tag = elem.tag.split('}')[-1] if '}' in elem.tag else elem.tag
        local_tf_str = elem.attrib.get('transform', '')
        
        if local_tf_str:
            local_tf = parse_transform(local_tf_str)
            tf = compose_transforms(current_tf, local_tf)
        else:
            tf = current_tf
            
        if tag == 'path':
            d = elem.attrib.get('d', '')
            if d:
                tokens = tokenize_path(d)
                subpaths = parse_tokens(tokens)
                for path in subpaths:
                    transformed_path = [tf(x, y) for x, y in path]
                    polylines.append(transformed_path)
        elif tag == 'line':
            x1 = float(elem.attrib.get('x1', 0.0))
            y1 = float(elem.attrib.get('y1', 0.0))
            x2 = float(elem.attrib.get('x2', 0.0))
            y2 = float(elem.attrib.get('y2', 0.0))
            polylines.append([tf(x1, y1), tf(x2, y2)])
        elif tag in ('polyline', 'polygon'):
            points_str = elem.attrib.get('points', '')
            if points_str:
                coords = [float(x) for x in re.split(r'[\s,]+', points_str.strip()) if x]
                path = []
                for idx in range(0, len(coords) - 1, 2):
                    path.append(tf(coords[idx], coords[idx+1]))
                if tag == 'polygon' and path:
                    path.append(path[0])
                if path:
                    polylines.append(path)
        elif tag == 'rect':
            x = float(elem.attrib.get('x', 0.0))
            y = float(elem.attrib.get('y', 0.0))
            w = float(elem.attrib.get('width', 0.0))
            h = float(elem.attrib.get('height', 0.0))
            path = [tf(x, y), tf(x+w, y), tf(x+w, y+h), tf(x, y+h), tf(x, y)]
            polylines.append(path)
        elif tag in ('circle', 'ellipse'):
            cx = float(elem.attrib.get('cx', 0.0))
            cy = float(elem.attrib.get('cy', 0.0))
            if tag == 'circle':
                rx = ry = float(elem.attrib.get('r', 0.0))
            else:
                rx = float(elem.attrib.get('rx', 0.0))
                ry = float(elem.attrib.get('ry', 0.0))
            path = []
            for s in range(33):
                angle = s * (2.0 * math.pi / 32.0)
                path.append(tf(cx + rx * math.cos(angle), cy + ry * math.sin(angle)))
            polylines.append(path)
            
        for child in elem:
            traverse(child, tf)
            
    traverse(root, lambda x, y: (x, y))
    return polylines

def _resolve_style(elem, fill, stroke):
    """Effective fill/stroke for an element, honoring presentation attrs + style=."""
    props = {}
    for decl in elem.attrib.get('style', '').split(';'):
        if ':' in decl:
            k, v = decl.split(':', 1)
            props[k.strip().lower()] = v.strip().lower()
    fill = elem.attrib.get('fill', props.get('fill', fill)).strip().lower()
    stroke = elem.attrib.get('stroke', props.get('stroke', stroke)).strip().lower()
    return fill, stroke

def classify_svg_paths(svg_path):
    """Count drawable elements that are filled-only vs stroked.

    SVG defaults a shape to fill:black, stroke:none, so filled artwork (where each
    line is a thin filled region) is common. The generator traces path *outlines*,
    which turns every such line into a doubled, offset pair of strokes -- the cure
    is centerline/stroked source art, so we surface this up front.
    """
    try:
        root = ET.parse(svg_path).getroot()
    except Exception:
        return 0, 0

    counts = {"total": 0, "filled": 0}
    drawable = ('path', 'polygon', 'rect', 'circle', 'ellipse', 'polyline', 'line')

    def walk(elem, fill, stroke):
        fill, stroke = _resolve_style(elem, fill, stroke)
        tag = elem.tag.split('}')[-1] if '}' in elem.tag else elem.tag
        if tag in drawable:
            counts["total"] += 1
            has_fill = fill not in ('none', '')
            has_stroke = stroke not in ('none', '')
            if has_fill and not has_stroke:
                counts["filled"] += 1
        for child in elem:
            walk(child, fill, stroke)

    walk(root, 'black', 'none')  # SVG initial values
    return counts["filled"], counts["total"]

# ==========================================
# Polyline Splitting
# ==========================================

def split_polylines(polylines, num_segments):
    total_len = 0.0
    for poly in polylines:
        for i in range(len(poly) - 1):
            dx = poly[i+1][0] - poly[i][0]
            dy = poly[i+1][1] - poly[i][1]
            total_len += (dx*dx + dy*dy)**0.5
            
    if total_len == 0.0:
        return []
        
    target_len = total_len / num_segments
    new_segments = []
    current_slot = []
    current_subpath = []
    accum_len = 0.0
    
    for poly in polylines:
        if not poly:
            continue
        pt = poly[0]
        if current_subpath:
            current_slot.append(current_subpath)
        current_subpath = [pt]
            
        for i in range(len(poly) - 1):
            p1 = poly[i]
            p2 = poly[i+1]
            dx = p2[0] - p1[0]
            dy = p2[1] - p1[1]
            segment_len = (dx*dx + dy*dy)**0.5
            
            if segment_len == 0:
                continue
                
            t = 0.0
            while t < 1.0:
                len_needed = target_len - accum_len
                len_available = segment_len * (1.0 - t)
                
                if len_needed <= len_available:
                    dt = len_needed / segment_len
                    t += dt
                    px = p1[0] + t * dx
                    py = p1[1] + t * dy
                    current_subpath.append((px, py))
                    if len(current_subpath) > 1:
                        current_slot.append(current_subpath)
                    new_segments.append(current_slot)
                    current_slot = []
                    current_subpath = [(px, py)]
                    accum_len = 0.0
                else:
                    current_subpath.append(p2)
                    accum_len += len_available
                    break

        if len(current_subpath) > 1:
            current_slot.append(current_subpath)
        current_subpath = []
                    
    if current_slot:
        new_segments.append(current_slot)
        
    # Trim or extend to exactly num_segments to maintain 1-to-1 mapping
    while len(new_segments) > num_segments:
        # Merge the last two slots without drawing a connector between their subpaths.
        last2 = new_segments.pop()
        new_segments[-1].extend(last2)
    while len(new_segments) < num_segments and len(new_segments) > 0:
        # Split the longest segment
        lengths = [slot_length(slot) for slot in new_segments]
        longest_idx = lengths.index(max(lengths))
        slot_a, slot_b = split_slot_at_half(new_segments[longest_idx])
        new_segments[longest_idx] = slot_a
        new_segments.insert(longest_idx + 1, slot_b)
        
    return new_segments

def polyline_length(poly):
    return sum(
        ((poly[idx+1][0] - poly[idx][0])**2 + (poly[idx+1][1] - poly[idx][1])**2)**0.5
        for idx in range(len(poly) - 1)
    )

def total_polyline_length(polylines):
    return sum(polyline_length(poly) for poly in polylines)

def slot_subpaths(slot):
    if not slot:
        return []
    first = slot[0]
    if first and isinstance(first[0], (int, float)):
        return [slot]
    return slot

def slot_length(slot):
    return sum(polyline_length(poly) for poly in slot_subpaths(slot))

def split_slot_at_half(slot):
    subpaths = slot_subpaths(slot)
    total_len = slot_length(subpaths)
    if total_len == 0.0:
        return subpaths, []

    split_len = total_len / 2.0
    slot_a = []
    slot_b = []
    accum_len = 0.0
    split_done = False

    for poly in subpaths:
        if split_done:
            slot_b.append(poly)
            continue

        current = [poly[0]]
        for idx in range(len(poly) - 1):
            p1 = poly[idx]
            p2 = poly[idx+1]
            dx = p2[0] - p1[0]
            dy = p2[1] - p1[1]
            seg_len = (dx*dx + dy*dy)**0.5

            if seg_len == 0.0:
                continue

            if accum_len + seg_len >= split_len:
                t = (split_len - accum_len) / seg_len
                split_pt = (p1[0] + t * dx, p1[1] + t * dy)
                current.append(split_pt)
                if len(current) > 1:
                    slot_a.append(current)

                remainder = [split_pt, p2]
                remainder.extend(poly[idx+2:])
                if len(remainder) > 1:
                    slot_b.append(remainder)
                split_done = True
                break

            current.append(p2)
            accum_len += seg_len

        if not split_done and len(current) > 1:
            slot_a.append(current)

    if not slot_b:
        slot_b = [slot_a.pop()] if slot_a else []
    return slot_a, slot_b

def simplify_polyline(poly, tolerance):
    if tolerance <= 0.0 or len(poly) <= 2:
        return poly

    closed = len(poly) > 2 and poly[0] == poly[-1]
    work = poly[:-1] if closed else poly

    if len(work) <= 2:
        return poly

    def rdp(points):
        if len(points) <= 2:
            return points

        x1, y1 = points[0]
        x2, y2 = points[-1]
        max_dist = -1.0
        max_idx = 0

        for idx in range(1, len(points) - 1):
            px, py = points[idx]
            d = point_to_segment_distance(px, py, x1, y1, x2, y2)
            if d > max_dist:
                max_dist = d
                max_idx = idx

        if max_dist <= tolerance:
            return [points[0], points[-1]]

        left = rdp(points[:max_idx + 1])
        right = rdp(points[max_idx:])
        return left[:-1] + right

    simplified = rdp(work)
    if closed and simplified[0] != simplified[-1]:
        simplified.append(simplified[0])
    return simplified

def simplify_polylines(polylines, tolerance):
    simplified = []
    for poly in polylines:
        new_poly = simplify_polyline(poly, tolerance)
        if len(new_poly) >= 2 and polyline_length(new_poly) > 0.01:
            simplified.append(new_poly)
    return simplified

# ==========================================
# Distance & Collision Utilities
# ==========================================

def point_to_segment_distance(px, py, x1, y1, x2, y2):
    dx = x2 - x1
    dy = y2 - y1
    if dx == 0 and dy == 0:
        return ((px - x1)**2 + (py - y1)**2)**0.5
    t = ((px - x1) * dx + (py - y1) * dy) / (dx*dx + dy*dy)
    t = max(0.0, min(1.0, t))
    proj_x = x1 + t * dx
    proj_y = y1 + t * dy
    return ((px - proj_x)**2 + (py - proj_y)**2)**0.5

def line_intersection(x1, y1, x2, y2, x3, y3, x4, y4):
    def ccw(ax, ay, bx, by, cx, cy):
        return (cy - ay) * (bx - ax) > (by - ay) * (cx - ax)
    return ccw(x1, y1, x3, y3, x4, y4) != ccw(x2, y2, x3, y3, x4, y4) and \
           ccw(x1, y1, x2, y2, x3, y3) != ccw(x1, y1, x2, y2, x4, y4)

def segment_to_segment_distance(x1, y1, x2, y2, x3, y3, x4, y4):
    if line_intersection(x1, y1, x2, y2, x3, y3, x4, y4):
        return 0.0
    d1 = point_to_segment_distance(x1, y1, x3, y3, x4, y4)
    d2 = point_to_segment_distance(x2, y2, x3, y3, x4, y4)
    d3 = point_to_segment_distance(x3, y3, x1, y1, x2, y2)
    d4 = point_to_segment_distance(x4, y4, x1, y1, x2, y2)
    return min(d1, d2, d3, d4)

def polyline_bbox(poly):
    xs = [pt[0] for pt in poly]
    ys = [pt[1] for pt in poly]
    return min(xs), min(ys), max(xs), max(ys)

def slot_bbox(slot):
    boxes = [polyline_bbox(poly) for poly in slot_subpaths(slot) if len(poly) >= 2]
    if not boxes:
        return 0.0, 0.0, 0.0, 0.0
    return (
        min(box[0] for box in boxes),
        min(box[1] for box in boxes),
        max(box[2] for box in boxes),
        max(box[3] for box in boxes),
    )

def bbox_distance(b1, b2):
    min_x1, min_y1, max_x1, max_y1 = b1
    min_x2, min_y2, max_x2, max_y2 = b2
    dx = max(min_x1 - max_x2, min_x2 - max_x1, 0.0)
    dy = max(min_y1 - max_y2, min_y2 - max_y1, 0.0)
    return (dx*dx + dy*dy)**0.5

def polyline_segments_with_bboxes(poly):
    segments = []
    for i in range(len(poly) - 1):
        x1, y1 = poly[i]
        x2, y2 = poly[i+1]
        bbox = (min(x1, x2), min(y1, y2), max(x1, x2), max(y1, y2))
        segments.append((x1, y1, x2, y2, bbox))
    return segments

def polyline_to_polyline_distance(poly1, poly2, cutoff=None):
    if cutoff is not None:
        box_dist = bbox_distance(polyline_bbox(poly1), polyline_bbox(poly2))
        if box_dist >= cutoff:
            return box_dist

    min_dist = cutoff if cutoff is not None else float('inf')
    segments1 = polyline_segments_with_bboxes(poly1)
    segments2 = polyline_segments_with_bboxes(poly2)

    for x1, y1, x2, y2, bbox1 in segments1:
        for x3, y3, x4, y4, bbox2 in segments2:
            if bbox_distance(bbox1, bbox2) >= min_dist:
                continue
            d = segment_to_segment_distance(x1, y1, x2, y2, x3, y3, x4, y4)
            if d < min_dist:
                min_dist = d
            if min_dist == 0.0:
                return 0.0
    return min_dist

def slot_to_slot_distance(slot1, slot2, cutoff=None):
    subpaths1 = [poly for poly in slot_subpaths(slot1) if len(poly) >= 2]
    subpaths2 = [poly for poly in slot_subpaths(slot2) if len(poly) >= 2]

    if not subpaths1 or not subpaths2:
        return float('inf')

    if cutoff is not None:
        box_dist = bbox_distance(slot_bbox(subpaths1), slot_bbox(subpaths2))
        if box_dist >= cutoff:
            return box_dist

    min_dist = cutoff if cutoff is not None else float('inf')
    for poly1 in subpaths1:
        for poly2 in subpaths2:
            if bbox_distance(polyline_bbox(poly1), polyline_bbox(poly2)) >= min_dist:
                continue
            d = polyline_to_polyline_distance(poly1, poly2, cutoff=min_dist)
            if d < min_dist:
                min_dist = d
            if min_dist == 0.0:
                return 0.0
    return min_dist

# ==========================================
# Simulated Annealing Angle Optimizer
# ==========================================

COLLISION_PENALTY = 1_000_000.0

def rotate_segment(seg, angle):
    cos_a = math.cos(angle)
    sin_a = math.sin(angle)
    return [
        [(x * cos_a - y * sin_a, x * sin_a + y * cos_a) for x, y in poly]
        for poly in slot_subpaths(seg)
    ]

def rotated_slots_for_assignment(segments, assignment):
    N = len(segments)
    slots = []
    for i in range(N):
        angle = assignment[i] * (2 * math.pi / N)
        slots.append(rotate_segment(segments[i], angle))
    return slots

def slot_pair_cost(d, d_min):
    if d < d_min:
        # Make collisions dominate the objective; spacing only matters after that.
        return COLLISION_PENALTY + (d_min - d)**2 * 100_000.0
    elif d > 0.0:
        # Gentle push to maximize spacing
        return 1.0 / (d * d)
    else:
        return COLLISION_PENALTY


class AngularCostCache:
    """Memoizes pairwise slot costs keyed by their relative angular offset.

    The disc rotates rigidly about its center (the origin), so the distance
    between segment ``i`` at notch ``p`` and segment ``j`` at notch ``q`` depends
    only on the offset ``(p - q) mod N`` -- rotating both by the same amount is a
    rigid motion that preserves distance. That collapses the O(N^3) family of
    (i, j, p, q) geometries down to at most O(N^3 / 2) distinct (i, j, offset)
    values, each computed lazily and once. Annealing steps and restarts then
    reuse the cache, turning each move into cheap dictionary lookups instead of
    repeated slot-to-slot geometry.
    """

    def __init__(self, segments, N, d_min):
        self.segments = segments
        self.N = N
        self.d_min = d_min
        self.delta = 2.0 * math.pi / N
        self._rotated = {}      # (i, k) -> segment i rotated by k * delta
        self._cost = {}         # (i, j, offset) with i < j -> pair cost

    def rotated(self, i, k):
        k %= self.N
        if k == 0:
            return self.segments[i]
        key = (i, k)
        slot = self._rotated.get(key)
        if slot is None:
            slot = rotate_segment(self.segments[i], k * self.delta)
            self._rotated[key] = slot
        return slot

    def pair_cost(self, i, j, notch_i, notch_j):
        if i == j:
            return 0.0
        if i > j:
            i, j = j, i
            notch_i, notch_j = notch_j, notch_i
        offset = (notch_i - notch_j) % self.N
        key = (i, j, offset)
        cost = self._cost.get(key)
        if cost is None:
            # seg i at `offset`, seg j at 0  ==  seg i at notch_i, seg j at notch_j.
            d = slot_to_slot_distance(self.rotated(i, offset), self.segments[j], cutoff=self.d_min)
            cost = slot_pair_cost(d, self.d_min)
            self._cost[key] = cost
        return cost

    def assignment_cost(self, m):
        total = 0.0
        for i in range(self.N):
            mi = m[i]
            for j in range(i + 1, self.N):
                total += self.pair_cost(i, j, mi, m[j])
        return total

    def count_collisions(self, m):
        """Number of colliding pairs, read from the (cheap) cached costs."""
        collisions = 0
        for i in range(self.N):
            mi = m[i]
            for j in range(i + 1, self.N):
                if self.pair_cost(i, j, mi, m[j]) >= COLLISION_PENALTY:
                    collisions += 1
        return collisions


def evaluate_assignment_exact(cache, m, d_min, verbose=False):
    """Exact collision count / minimum spacing for a finished assignment."""
    N = cache.N
    collisions = 0
    min_dist = float('inf')
    for i in range(N):
        slot_i = cache.rotated(i, m[i])
        for j in range(i + 1, N):
            d = slot_to_slot_distance(slot_i, cache.rotated(j, m[j]))
            if d < min_dist:
                min_dist = d
            if d < d_min:
                collisions += 1
                if verbose:
                    print(f"  Collision between slot {i+1} and slot {j+1}: distance {d:.3f}mm")
    if min_dist == float('inf'):
        min_dist = 0.0
    return collisions, min_dist, cache.assignment_cost(m)

def greedy_initial_assignment(cache):
    N = cache.N
    order = sorted(range(N), key=lambda idx: slot_length(cache.segments[idx]), reverse=True)
    available = set(range(N))
    assignment = [None] * N
    placed = []  # (segment_index, notch)

    for seg_idx in order:
        best_notch = None
        best_score = None
        for notch in available:
            collisions = 0
            cost = 0.0
            for pseg, pnotch in placed:
                c = cache.pair_cost(seg_idx, pseg, notch, pnotch)
                if c >= COLLISION_PENALTY:
                    collisions += 1
                cost += c
            score = (collisions, cost, random.random())
            if best_score is None or score < best_score:
                best_score = score
                best_notch = notch

        assignment[seg_idx] = best_notch
        available.remove(best_notch)
        placed.append((seg_idx, best_notch))

    return assignment

def optimize_single_permutation_run(cache, max_iters, initial_assignment=None):
    N = cache.N
    d_min = cache.d_min
    if initial_assignment is None:
        m = list(range(N))
        random.shuffle(m)
    else:
        m = list(initial_assignment)

    total_cost = cache.assignment_cost(m)

    best_m = list(m)
    best_cost = total_cost
    best_collisions = cache.count_collisions(m)

    # Geometric cooling that actually reaches a cold state by the final step,
    # regardless of how many iterations were requested.
    T = max(100.0, total_cost * 0.01)
    T_end = max(1.0, T * 1e-3)
    cooling_rate = (T_end / T) ** (1.0 / max(1, max_iters))

    print(f"    Initial cost = {total_cost:.2f}, collisions = {best_collisions}")

    for step in range(max_iters):
        if best_collisions == 0:
            print(f"    Resolved all collisions at step {step}. Cost: {best_cost:.2f}")
            break

        a, b = random.sample(range(N), 2)

        # Cost of every pair touching a or b under the current assignment...
        old = cache.pair_cost(a, b, m[a], m[b])
        for k in range(N):
            if k != a and k != b:
                old += cache.pair_cost(a, k, m[a], m[k])
                old += cache.pair_cost(b, k, m[b], m[k])

        # ...and after swapping the two notches.
        na, nb = m[b], m[a]
        new = cache.pair_cost(a, b, na, nb)
        for k in range(N):
            if k != a and k != b:
                new += cache.pair_cost(a, k, na, m[k])
                new += cache.pair_cost(b, k, nb, m[k])

        delta = new - old
        if delta <= 0 or random.random() < math.exp(-delta / T):
            m[a], m[b] = na, nb
            total_cost += delta
            if total_cost < best_cost - 1e-9:
                best_cost = total_cost
                best_m = list(m)
                best_collisions = cache.count_collisions(m)

        T *= cooling_rate
        if step % 2000 == 0:
            print(
                f"    Step {step:5d} | Temp: {T:9.2f} | Current Cost: {total_cost:12.2f} | "
                f"Best Cost: {best_cost:12.2f} | Best Collisions: {best_collisions}"
            )

    collisions, min_dist, cost = evaluate_assignment_exact(cache, best_m, d_min)
    return best_m, collisions, min_dist, cost

def optimize_permutation(segments, N, d_min, max_iters=1000, restarts=2):
    cache = AngularCostCache(segments, N, d_min)

    best_m = None
    best_collisions = None
    best_min_dist = 0.0
    best_cost = float('inf')

    print(f"  Optimizing notch assignments for {N} steps ({restarts} restart(s), {max_iters} iteration(s) each)...")
    for restart in range(restarts):
        print(f"  Restart {restart + 1}/{restarts}")
        if restart == 0:
            print("    Using greedy initializer")
            initial_assignment = greedy_initial_assignment(cache)
        else:
            initial_assignment = None
        m, collisions, min_dist, cost = optimize_single_permutation_run(
            cache,
            max_iters,
            initial_assignment=initial_assignment,
        )
        print(f"    Result: collisions = {collisions}, min distance = {min_dist:.3f}mm, cost = {cost:.2f}")

        if (
            best_m is None
            or collisions < best_collisions
            or (collisions == best_collisions and min_dist > best_min_dist)
            or (collisions == best_collisions and min_dist == best_min_dist and cost < best_cost)
        ):
            best_m = m
            best_collisions = collisions
            best_min_dist = min_dist
            best_cost = cost

        if best_collisions == 0:
            break

    final_collisions, final_min_dist, final_cost = evaluate_assignment_exact(cache, best_m, d_min)
    if final_collisions > 0:
        evaluate_assignment_exact(cache, best_m, d_min, verbose=True)
    print(
        f"  Optimization finished. Collisions remaining: {final_collisions}, "
        f"minimum distance: {final_min_dist:.3f}mm"
    )
    return best_m, final_collisions, final_min_dist, final_cost

def format_scad_slot(slot):
    subpaths = []
    for poly in slot_subpaths(slot):
        pts = ", ".join(f"[{pt[0]:.4f}, {pt[1]:.4f}]" for pt in poly)
        subpaths.append(f"[{pts}]")
    return "[" + ", ".join(subpaths) + "]"

def solve_layout_for_steps(polylines, N, d_min, max_iters, restarts):
    print(f"Splitting drawing paths into {N} equal-length segment(s)...")
    segments = split_polylines(polylines, N)
    print(f"Produced {len(segments)} segment(s).")

    if len(segments) != N:
        raise ValueError(f"Splitting failed to produce exactly {N} segments (produced {len(segments)}).")

    best_m, collisions, min_dist, cost = optimize_permutation(
        segments,
        N,
        d_min,
        max_iters=max_iters,
        restarts=restarts,
    )
    return {
        "N": N,
        "segments": segments,
        "assignment": best_m,
        "collisions": collisions,
        "min_dist": min_dist,
        "cost": cost,
    }

def find_minimal_step_layout(polylines, min_steps, max_steps, d_min, max_iters, restarts):
    if min_steps < 2:
        raise ValueError("Minimum steps must be at least 2.")
    if max_steps < min_steps:
        raise ValueError("Maximum steps must be greater than or equal to minimum steps.")

    best_failed_layout = None
    total_len = total_polyline_length(polylines)

    print(f"Searching for the smallest collision-free step count from {min_steps} to {max_steps}...")
    for N in range(min_steps, max_steps + 1):
        avg_len = total_len / N
        print(f"\nTrying {N} step(s): average stroke length {avg_len:.2f}mm")
        layout = solve_layout_for_steps(polylines, N, d_min, max_iters, restarts)

        if (
            best_failed_layout is None
            or layout["collisions"] < best_failed_layout["collisions"]
            or (layout["collisions"] == best_failed_layout["collisions"] and layout["min_dist"] > best_failed_layout["min_dist"])
        ):
            best_failed_layout = layout

        if layout["collisions"] == 0:
            print(f"\nSelected {N} step(s): smallest collision-free layout found.")
            return layout

    print(
        f"\nNo collision-free layout found up to {max_steps} steps. "
        f"Using best attempted layout: {best_failed_layout['N']} step(s), "
        f"{best_failed_layout['collisions']} collision(s), min distance {best_failed_layout['min_dist']:.3f}mm."
    )
    return best_failed_layout

# ==========================================
# Rotation Center Selection
# ==========================================

def point_clearance(px, py, polylines):
    """Distance from (px, py) to the nearest stroke (any polyline segment)."""
    best = float('inf')
    for poly in polylines:
        for idx in range(len(poly) - 1):
            x1, y1 = poly[idx]
            x2, y2 = poly[idx + 1]
            d = point_to_segment_distance(px, py, x1, y1, x2, y2)
            if d < best:
                best = d
    return best

def enclosing_radius(px, py, polylines):
    """Largest distance from (px, py) to any drawn point -> the disc radius needed."""
    best = 0.0
    for poly in polylines:
        for x, y in poly:
            r = ((x - px) ** 2 + (y - py) ** 2) ** 0.5
            if r > best:
                best = r
    return best

def choose_rotation_center(polylines, samples=24, refine_iters=4):
    """Pick the rotation origin that puts the largest empty zone at the disc center.

    A stroke running through (or near) the rotation center collides with itself at
    every rotational offset, which no notch permutation can fix. So instead of the
    bounding-box center we search for the point that maximizes ``clearance / radius``:
    the nearest-stroke distance divided by the enclosing radius. That ratio is
    scale-invariant and, because the drawing is later scaled so its enclosing radius
    fills the disc, maximizing it maximizes the empty central zone *in final mm* while
    keeping the drawing as large as possible.
    """
    min_x = min(pt[0] for poly in polylines for pt in poly)
    max_x = max(pt[0] for poly in polylines for pt in poly)
    min_y = min(pt[1] for poly in polylines for pt in poly)
    max_y = max(pt[1] for poly in polylines for pt in poly)

    bx0, by0, bx1, by1 = min_x, min_y, max_x, max_y
    best = None  # (score, px, py, clearance, radius)

    for _ in range(refine_iters):
        step_x = (bx1 - bx0) / samples if bx1 > bx0 else 0.0
        step_y = (by1 - by0) / samples if by1 > by0 else 0.0
        for gx in range(samples + 1):
            for gy in range(samples + 1):
                px = bx0 + gx * step_x
                py = by0 + gy * step_y
                radius = enclosing_radius(px, py, polylines)
                if radius <= 0.0:
                    continue
                clearance = point_clearance(px, py, polylines)
                score = clearance / radius
                if best is None or score > best[0]:
                    best = (score, px, py, clearance, radius)

        # Zoom the search window in around the current best for the next pass.
        _, bpx, bpy, _, _ = best
        win_x = (bx1 - bx0) * 2.0 / samples
        win_y = (by1 - by0) * 2.0 / samples
        bx0, bx1 = bpx - win_x, bpx + win_x
        by0, by1 = bpy - win_y, bpy + win_y

    return best  # (score, px, py, clearance, radius)

# ==========================================
# Label Placement
# ==========================================

def get_label_position(slot, offset=4.0):
    subpaths = [poly for poly in slot_subpaths(slot) if len(poly) >= 2]
    if not subpaths:
        return (0.0, 0.0)

    lens = [0.0]
    total_len = 0.0
    pieces = []
    for poly in subpaths:
        for idx in range(len(poly) - 1):
            p1 = poly[idx]
            p2 = poly[idx+1]
            dx = p2[0] - p1[0]
            dy = p2[1] - p1[1]
            total_len += (dx*dx + dy*dy)**0.5
            lens.append(total_len)
            pieces.append((p1, p2))

    if not pieces:
        return subpaths[0][0]
        
    mid_len = total_len / 2.0
    for idx, (p1, p2) in enumerate(pieces):
        if lens[idx] <= mid_len <= lens[idx+1]:
            seg_len = lens[idx+1] - lens[idx]
            t = (mid_len - lens[idx]) / seg_len if seg_len > 0 else 0.0
            mx = p1[0] + t * (p2[0] - p1[0])
            my = p1[1] + t * (p2[1] - p1[1])
            
            dx = p2[0] - p1[0]
            dy = p2[1] - p1[1]
            dl = (dx*dx + dy*dy)**0.5
            if dl > 0:
                nx = -dy / dl
                ny = dx / dl
            else:
                nx, ny = 0.0, 1.0
                
            lx = mx + nx * offset
            ly = my + ny * offset
            return lx, ly

    return pieces[0][0]

def slot_label_anchor(slot):
    """Arc-length midpoint of a slot. Labels start here, then move off to clear traces."""
    subpaths = [poly for poly in slot_subpaths(slot) if len(poly) >= 2]
    if not subpaths:
        return (0.0, 0.0)
    lens = [0.0]
    total = 0.0
    pieces = []
    for poly in subpaths:
        for idx in range(len(poly) - 1):
            p1, p2 = poly[idx], poly[idx + 1]
            total += ((p2[0]-p1[0])**2 + (p2[1]-p1[1])**2) ** 0.5
            lens.append(total)
            pieces.append((p1, p2))
    if not pieces:
        return subpaths[0][0]
    mid = total / 2.0
    for idx, (p1, p2) in enumerate(pieces):
        if lens[idx] <= mid <= lens[idx + 1]:
            seg = lens[idx + 1] - lens[idx]
            t = (mid - lens[idx]) / seg if seg > 0 else 0.0
            return (p1[0] + t * (p2[0] - p1[0]), p1[1] + t * (p2[1] - p1[1]))
    return pieces[0][0]

def point_to_slots_distance(px, py, slots):
    """Nearest distance from a point to any slot centerline (across all slots)."""
    best = float('inf')
    for slot in slots:
        for poly in slot_subpaths(slot):
            for i in range(len(poly) - 1):
                x1, y1 = poly[i]
                x2, y2 = poly[i + 1]
                d = point_to_segment_distance(px, py, x1, y1, x2, y2)
                if d < best:
                    best = d
    return best

def slot_sample_points(slot, n=14):
    """Evenly spaced points along a slot centerline with their outward normals."""
    pieces = []
    for poly in slot_subpaths(slot):
        for idx in range(len(poly) - 1):
            p1, p2 = poly[idx], poly[idx + 1]
            seg = ((p2[0]-p1[0])**2 + (p2[1]-p1[1])**2) ** 0.5
            if seg > 0:
                pieces.append((p1, p2, seg))
    total = sum(seg for _, _, seg in pieces)
    if total == 0.0:
        mx, my = slot_label_anchor(slot)
        return [(mx, my, 0.0, 1.0)]

    pts = []
    for s in range(1, n + 1):
        target = total * s / (n + 1)
        acc = 0.0
        for p1, p2, seg in pieces:
            if acc + seg >= target:
                t = (target - acc) / seg
                mx = p1[0] + t * (p2[0] - p1[0])
                my = p1[1] + t * (p2[1] - p1[1])
                nx, ny = -(p2[1] - p1[1]) / seg, (p2[0] - p1[0]) / seg
                pts.append((mx, my, nx, ny))
                break
            acc += seg
    return pts

def place_slot_label(own_slot, all_slots, placed_labels, slot_width, font_size, margin=0.5):
    """Place a raised slot number hugging its OWN slot, clear of traces and other labels.

    The number must read as belonging to its line, so we offset it the *minimum*
    amount off a point on its own centerline -- just enough to clear the trace -- and
    only push further if that spot still hits another trace or an already-placed
    label. Among valid spots we keep the one closest to the slot (smallest offset),
    preferring the more open side. This keeps each number next to its own stroke
    while guaranteeing it never sits on a trace or on another number.
    """
    glyph = font_size * 0.65                 # half-extent of a 1-2 digit glyph
    samples = slot_sample_points(own_slot)
    trace_clear = slot_width / 2.0 + glyph   # number body vs any trace edge
    label_clear = 2.0 * glyph + 0.4          # number body vs another number
    base = slot_width / 2.0 + glyph + margin

    best = None
    for extra in (0.0, 1.0, 2.0, 3.0, 4.5, 6.0, 8.0):
        off = base + extra
        for mx, my, nx, ny in samples:
            for sign in (1.0, -1.0):
                px = mx + sign * nx * off
                py = my + sign * ny * off
                d_trace = point_to_slots_distance(px, py, all_slots)
                if d_trace < trace_clear:
                    continue
                d_label = min((((px-lx)**2 + (py-ly)**2) ** 0.5) for lx, ly in placed_labels) if placed_labels else float('inf')
                if d_label < label_clear:
                    continue
                # Valid spot: prefer small offset, then the more open side.
                score = (-off, d_trace + min(d_label, 8.0))
                if best is None or score > best[0]:
                    best = (score, px, py)
        if best is not None:
            return (best[1], best[2])

    # Nothing fully cleared: fall back to the least-bad spot found anywhere.
    fb = None
    for mx, my, nx, ny in samples:
        for sign in (1.0, -1.0):
            px = mx + sign * nx * base
            py = my + sign * ny * base
            d_trace = point_to_slots_distance(px, py, all_slots)
            if fb is None or d_trace > fb[0]:
                fb = (d_trace, px, py)
    if fb is not None:
        return (fb[1], fb[2])
    mx, my = slot_label_anchor(own_slot)
    return (mx, my)

# ==========================================
# OpenSCAD Writer
# ==========================================

SCAD_TEMPLATE = """// ==========================================================
// Twist Art / Rotadraw / Doodle Disc Parametric Model
// Generated programmatically from vector paths.
// ==========================================================

// --- Customizer Parameters ---
// "disc"    = disc body with the numbers raised on top (single STL; do a filament
//             swap at the layer where the numbers start to colour them)
// "numbers" = ONLY the raised numbers, for a separate second-material STL
// "frame"   = holder frame    "both" = assembly preview
part = "both"; // ["disc", "numbers", "frame", "both"]
disc_radius = {disc_radius:.1f};
disc_thickness = {disc_thickness:.1f};
slot_width = {slot_width:.1f};
clearance = 0.3; // Radial gap between disc and frame pocket

// --- Advanced Parameters ---
N = {N}; // Number of rotational steps
notch_size = 1.0; // Radius of alignment notches on rim
rim_margin = 13.0; // Radial width of the numbers rim area
engrave_depth = 0.8;
number_height = 0.6; // Height the numbers stand proud of the disc face (for a colour swap)
font_name = "Liberation Sans:style=Bold";
font_size_rim = 4.5;
font_size_slot = 3.0;
theta_index = {theta_index}; // Index pointer angle (12 o'clock = 90 deg)

// Holder frame parameters
frame_thickness = disc_thickness + 1.6;
frame_width = (disc_radius + 8.0) * 2;
frame_height = (disc_radius + 8.0) * 2;
paper_width = (disc_radius + 4.0) * 2;
paper_height = (disc_radius + 4.0) * 2;

// --- Geometric Data ---

// Each slot is a list of drawable subpaths, pre-rotated by their notch angle
slots = {slots_data};

// X, Y coordinate for each slot number text label on the disc face
label_positions = {labels_data};

// Which drawing step number (1 to N) is assigned to each notch index (0 to N-1)
rim_numbers = {rim_numbers_data};

// --- Assembly Render ---
if (part == "disc") {{
    stencil_disc();
}} else if (part == "numbers") {{
    disc_numbers();
}} else if (part == "frame") {{
    holder_frame();
}} else {{
    // Render assembly: transparent disc sitting inside the frame
    color("LightBlue", 0.7) stencil_disc();
    color("Plum", 1.0) holder_frame();
}}

// --- Modules ---

module draw_subpath(points, w) {{
    if (len(points) >= 2) {{
        for (i = [0 : len(points) - 2]) {{
            hull() {{
                translate(points[i]) circle(d = w, $fn = 12);
                translate(points[i+1]) circle(d = w, $fn = 12);
            }}
        }}
    }}
}}

module draw_slot(subpaths, w) {{
    for (j = [0 : len(subpaths) - 1]) {{
        draw_subpath(subpaths[j], w);
    }}
}}

// Raised numbers that stand proud of the disc face. Kept as its own module so it
// can also be exported on its own (part = "numbers") for a second-material print.
module disc_numbers() {{
    // Rim step-numbers (1..N) around the outer ring
    for (m = [0 : N - 1]) {{
        if (rim_numbers[m] > 0) {{
            rotate([0, 0, m * 360 / N])
                translate([disc_radius - rim_margin + 5.0, 0, disc_thickness])
                    rotate([0, 0, -90]) // radial orientation
                        linear_extrude(height = number_height)
                            text(text = str(rim_numbers[m]), font = font_name, size = font_size_rim, halign = "center", valign = "center");
        }}
    }}

    // Per-slot labels on the disc face
    for (i = [0 : len(label_positions) - 1]) {{
        translate([label_positions[i][0], label_positions[i][1], disc_thickness])
            linear_extrude(height = number_height)
                text(text = str(i + 1), font = font_name, size = font_size_slot, halign = "center", valign = "center");
    }}
}}

module stencil_disc() {{
    union() {{
        difference() {{
            // Base disc
            cylinder(r = disc_radius, h = disc_thickness, $fn = 150);

            // Subtract notches around the rim (triangles)
            for (m = [0 : N - 1]) {{
                rotate([0, 0, m * 360 / N])
                    translate([disc_radius, 0, -1])
                        cylinder(r = notch_size, h = disc_thickness + 2, $fn = 3);
            }}

            // Subtract tracing slots
            for (i = [0 : len(slots) - 1]) {{
                translate([0, 0, -1])
                    linear_extrude(height = disc_thickness + 2)
                        draw_slot(slots[i], slot_width);
            }}
        }}

        // Numbers raised on the top face (coloured separately at print time)
        color("Black") disc_numbers();
    }}
}}

module holder_frame() {{
    difference() {{
        // Outer square frame with index tab
        union() {{
            translate([-frame_width/2, -frame_height/2, 0])
                cube([frame_width, frame_height, frame_thickness]);
            
            // tab for index pointer
            rotate([0, 0, theta_index])
                translate([disc_radius + clearance, -10.0, 0])
                    cube([12.0, 20.0, frame_thickness]);
        }}
        
        // Circular recess pocket for the disc
        translate([0, 0, frame_thickness - disc_thickness])
            cylinder(r = disc_radius + clearance, h = disc_thickness + 1.0, $fn = 150);
        
        // Center drawing window opening
        translate([0, 0, -1])
            cylinder(r = disc_radius - rim_margin + 2.0, h = frame_thickness + 2.0, $fn = 150);
            
        // Paper alignment recess on underside
        translate([-paper_width/2, -paper_height/2, -0.1])
            cube([paper_width, paper_height, 0.7]);
            
        // Index arrow on the tab
        rotate([0, 0, theta_index])
            translate([disc_radius + clearance + 3.0, 0, frame_thickness - engrave_depth])
                linear_extrude(height = engrave_depth + 0.1)
                    polygon(points = [[-4.0, -2.5], [0.0, 0.0], [-4.0, 2.5]]);
    }}
}}
"""

def prepare_polylines(args):
    """Extract and normalize an SVG into centered, scaled, simplified polylines.

    Returns ``(scaled_polylines, meta)``. The polylines are already in disc/CAD
    millimetres: y-up, centered on the chosen rotation origin, and scaled to fill
    the drawing area. ``meta`` carries the disc geometry needed to interpret them
    (so the interactive editor and the --segments path stay self-describing).
    """
    print(f"Reading SVG file: {args.svg_file}")
    raw_polylines = extract_polylines_from_svg(args.svg_file)
    print(f"Extracted {len(raw_polylines)} paths from SVG.")

    filled, total = classify_svg_paths(args.svg_file)
    if total and filled / total >= 0.5:
        print(
            f"Note: {filled}/{total} shapes are filled (fill set, stroke=none). This generator "
            f"traces the CONTOUR (outline) of filled art, so thin filled lines appear as doubled, "
            f"offset strokes -- expected, and fine if you want the contour. For single-stroke output "
            f"instead, use centerline/stroked art (fill:none with strokes)."
        )

    # Filter out empty/0-length/single-point paths
    filtered_polylines = []
    for poly in raw_polylines:
        if len(poly) < 2:
            continue
        plen = sum(((poly[idx+1][0] - poly[idx][0])**2 + (poly[idx+1][1] - poly[idx][1])**2)**0.5 for idx in range(len(poly)-1))
        if plen > 0.01:
            filtered_polylines.append(poly)

    print(f"Filtered out {len(raw_polylines) - len(filtered_polylines)} zero-length or single-point paths.")
    raw_polylines = filtered_polylines

    if not raw_polylines:
        print("Error: No valid paths found in SVG file after filtering.")
        sys.exit(1)

    # Flip Y axis (SVG goes down, CAD goes up)
    polylines = []
    for poly in raw_polylines:
        flipped = [(pt[0], -pt[1]) for pt in poly]
        polylines.append(flipped)

    # Find bounding box
    min_x = min(pt[0] for poly in polylines for pt in poly)
    max_x = max(pt[0] for poly in polylines for pt in poly)
    min_y = min(pt[1] for poly in polylines for pt in poly)
    max_y = max(pt[1] for poly in polylines for pt in poly)

    # Choose the rotation origin. The bounding-box center often sits on a stroke,
    # which causes collisions no notch permutation can resolve; the "clearance"
    # mode instead drops the origin into the largest empty zone of the artwork.
    if args.center_mode == "bbox":
        cx = (min_x + max_x) / 2.0
        cy = (min_y + max_y) / 2.0
        center_clearance = point_clearance(cx, cy, polylines)
    else:
        _, cx, cy, center_clearance, _ = choose_rotation_center(polylines)

    # Center polylines
    centered_polylines = []
    for poly in polylines:
        centered_polylines.append([(pt[0] - cx, pt[1] - cy) for pt in poly])

    # Find maximum radius
    max_r = max(math.sqrt(pt[0]**2 + pt[1]**2) for poly in centered_polylines for pt in poly)
    if max_r == 0:
        print("Error: The drawing has zero size.")
        sys.exit(1)

    # Scale to fit inside the annulus. Outer numbers rim starts at
    # disc_radius - rim_margin; keep a 3mm buffer inside that.
    rim_margin = 13.0
    r_max_drawing = args.radius - rim_margin - 3.0

    print(f"Drawing bounds: X[{min_x:.1f}, {max_x:.1f}], Y[{min_y:.1f}, {max_y:.1f}]")
    print(f"Rotation origin ({args.center_mode}): ({cx:.1f}, {cy:.1f}), max radius {max_r:.1f}mm")

    scale_factor = r_max_drawing / max_r
    center_clearance_mm = center_clearance * scale_factor
    print(f"Empty zone around rotation center: {center_clearance_mm:.2f}mm radius")
    if center_clearance_mm < args.dmin:
        print(
            f"Warning: strokes pass within {center_clearance_mm:.2f}mm of the rotation center "
            f"(< d_min {args.dmin:.2f}mm). Some collisions may be unavoidable; try --center-mode "
            f"clearance, a larger --radius, or artwork with a clearer empty center."
        )
    scaled_polylines = []
    for poly in centered_polylines:
        scaled_polylines.append([(pt[0] * scale_factor, pt[1] * scale_factor) for pt in poly])

    print(f"Scaled drawing to fit inside max radius of {r_max_drawing:.1f}mm (scale factor: {scale_factor:.4f})")

    points_before = sum(len(poly) for poly in scaled_polylines)
    scaled_polylines = simplify_polylines(scaled_polylines, args.simplify_tolerance)
    points_after = sum(len(poly) for poly in scaled_polylines)
    if args.simplify_tolerance > 0.0:
        print(
            f"Simplified paths with {args.simplify_tolerance:.3f}mm tolerance: "
            f"{points_before} -> {points_after} point(s)."
        )
    if not scaled_polylines:
        print("Error: No valid paths remain after simplification.")
        sys.exit(1)

    meta = {
        "units": "mm",
        "disc_radius": args.radius,
        "slot_width": args.width,
        "dmin": args.dmin,
        "rim_margin": rim_margin,
        "r_max_drawing": r_max_drawing,
        "scale_factor": scale_factor,
        "center_clearance_mm": center_clearance_mm,
        "suggested_steps": 16,
    }
    return scaled_polylines, meta


def write_export_json(scaled_polylines, meta, path):
    """Dump the prepared drawing for the HTML segment editor to consume."""
    subpaths = [[[round(x, 4), round(y, 4)] for (x, y) in poly] for poly in scaled_polylines]
    data = {"version": 1, "meta": meta, "subpaths": subpaths}
    try:
        with open(path, "w") as f:
            json.dump(data, f)
    except Exception as e:
        print(f"Error writing export file {path}: {e}")
        sys.exit(1)
    print(f"Wrote interactive editor data: {path}")
    print(f"  {len(subpaths)} subpath(s). Open segment_editor.html and load this file.")


def write_disc_scad(segments, best_m, collisions, min_dist, N, radius, width, output):
    """Rotate segments into disc coords, place labels, and write the OpenSCAD file.

    Shared by the automatic layout path and the --segments (user-defined) path.
    """
    theta_index_rad = math.pi / 2.0  # index pointer at 12 o'clock
    total_len = sum(slot_length(s) for s in segments)
    avg_stroke_len = total_len / N if N else 0.0

    if collisions > 0:
        print(f"Warning: {collisions} slot overlap(s) remain in this layout.")
        print("Consider fewer/longer segments, a larger disc radius, a smaller --width, "
              "raising --max-iters/--restarts, or re-editing the segments.")
    else:
        print(
            f"Success! A collision-free slot layout was found with {N} step(s). "
            f"Average stroke length: {avg_stroke_len:.2f}mm; minimum slot spacing: {min_dist:.3f}mm."
        )

    # Final slots rotated into disc coordinates by their assigned notch.
    slots = []
    for i in range(N):
        angle = best_m[i] * (2 * math.pi / N) - theta_index_rad
        slots.append(rotate_segment(segments[i], angle))

    # Raised slot numbers hugging their own slot, clear of traces and other labels.
    font_size_slot = 3.0  # must match font_size_slot in the SCAD template
    label_positions = []
    for i in range(N):
        lx, ly = place_slot_label(slots[i], slots, label_positions, width, font_size_slot)
        label_positions.append((lx, ly))

    # Which drawing step (1..N) sits at each notch index.
    rim_numbers = [0] * N
    for i in range(N):
        rim_numbers[best_m[i]] = i + 1

    slots_data = "[\n"
    for s in slots:
        slots_data += f"    {format_scad_slot(s)},\n"
    slots_data += "]"

    labels_data = "[\n"
    for l in label_positions:
        labels_data += f"    [{l[0]:.4f}, {l[1]:.4f}],\n"
    labels_data += "]"

    rim_numbers_data = str(rim_numbers)

    scad_content = SCAD_TEMPLATE.format(
        disc_radius=radius,
        disc_thickness=2.0,  # default thickness
        slot_width=width,
        N=N,
        theta_index=90,
        slots_data=slots_data,
        labels_data=labels_data,
        rim_numbers_data=rim_numbers_data,
    )

    print(f"Writing OpenSCAD file: {output}")
    try:
        with open(output, "w") as f:
            f.write(scad_content)
        print("Generation complete!")
    except Exception as e:
        print(f"Error writing to output file: {e}")
        sys.exit(1)


def run_segments_mode(args):
    """Build the disc from user-defined segments (from the HTML editor)."""
    try:
        with open(args.segments, "r") as f:
            data = json.load(f)
    except Exception as e:
        print(f"Error reading segments file {args.segments}: {e}")
        sys.exit(1)

    raw_segments = data.get("segments", [])
    segments = []
    for seg in raw_segments:
        subpaths = []
        for sp in seg.get("subpaths", []):
            pts = [(float(p[0]), float(p[1])) for p in sp if len(p) >= 2]
            if len(pts) >= 2 and polyline_length(pts) > 1e-9:
                subpaths.append(pts)
        if subpaths:
            segments.append(subpaths)

    if not segments:
        print("Error: segments file contains no usable segments.")
        sys.exit(1)

    N = len(segments)
    meta = data.get("meta", {})
    radius = float(meta.get("disc_radius", args.radius))
    width = float(meta.get("slot_width", args.width))
    dmin = float(meta.get("dmin", args.dmin))

    print(f"Loaded {N} user-defined segment(s) from {args.segments}.")
    print(f"Disc radius {radius:.1f}mm, slot width {width:.1f}mm, d_min {dmin:.2f}mm.")

    best_m, collisions, min_dist, _cost = optimize_permutation(
        segments, N, dmin, max_iters=args.max_iters, restarts=args.restarts
    )
    write_disc_scad(segments, best_m, collisions, min_dist, N, radius, width, args.output)


def main():
    parser = argparse.ArgumentParser(description="Twist Art / Rotadraw Doodle Disc generator")
    parser.add_argument("svg_file", nargs="?", help="Input SVG file containing vector paths (omit when using --segments)")
    parser.add_argument("--export-json", metavar="PATH", default=None,
                        help="Prepare the SVG and write drawing+disc data for the HTML segment editor, then stop")
    parser.add_argument("--segments", metavar="PATH", default=None,
                        help="Build the disc from user-defined segments (JSON exported by segment_editor.html) instead of auto-splitting")
    parser.add_argument("-n", "--steps", type=int, default=64, help="Maximum number of rotation steps to try (default: 64)")
    parser.add_argument("--min-steps", type=int, default=8, help="Fewest rotation steps to try when minimizing (default: 8)")
    parser.add_argument("--fixed-steps", action="store_true", help="Use exactly --steps instead of searching for the minimum collision-free count")
    parser.add_argument("-r", "--radius", type=float, default=67.5, help="Disc radius in mm (default: 67.5)")
    parser.add_argument("-w", "--width", type=float, default=2.0, help="Tracing slot width in mm (default: 2.0)")
    parser.add_argument("-o", "--output", default="doodle_disc.scad", help="Output OpenSCAD file name")
    parser.add_argument("-d", "--dmin", type=float, default=None, help="Minimum centerline spacing between slots in mm (default: slot width)")
    parser.add_argument("--center-mode", choices=["clearance", "bbox"], default="clearance",
                        help="Rotation origin: 'clearance' drops it into the largest empty zone of the artwork "
                             "(fewer unavoidable collisions); 'bbox' uses the bounding-box center (default: clearance)")
    parser.add_argument("--simplify-tolerance", type=float, default=0.2, help="Polyline simplification tolerance after scaling, in mm (default: 0.2)")
    parser.add_argument("--max-iters", type=int, default=8000, help="Annealing iterations per restart (default: 8000)")
    parser.add_argument("--restarts", type=int, default=3, help="Annealing restarts per tested step count (default: 3)")
    parser.add_argument("--seed", type=int, default=None, help="Random seed for repeatable optimization")
    args = parser.parse_args()

    if args.seed is not None:
        random.seed(args.seed)
    if args.radius <= 0:
        print("Error: --radius must be positive.")
        sys.exit(1)
    if args.width <= 0:
        print("Error: --width must be positive.")
        sys.exit(1)
    if args.dmin is None:
        args.dmin = args.width
    if args.dmin <= 0:
        print("Error: --dmin must be positive.")
        sys.exit(1)
    if args.max_iters < 1:
        print("Error: --max-iters must be at least 1.")
        sys.exit(1)
    if args.restarts < 1:
        print("Error: --restarts must be at least 1.")
        sys.exit(1)

    # --- Mode: build from user-defined segments (HTML editor output) ---
    if args.segments:
        run_segments_mode(args)
        return

    # --- SVG-based modes (auto layout and editor export) need a source file ---
    if not args.svg_file:
        print("Error: an SVG file is required (or use --segments PATH).")
        sys.exit(1)
    if args.simplify_tolerance < 0:
        print("Error: --simplify-tolerance must be non-negative.")
        sys.exit(1)
    if args.steps < 2:
        print("Error: --steps must be at least 2.")
        sys.exit(1)
    if args.min_steps < 2:
        print("Error: --min-steps must be at least 2.")
        sys.exit(1)
    if args.min_steps > args.steps:
        print("Error: --min-steps must be less than or equal to --steps.")
        sys.exit(1)

    scaled_polylines, meta = prepare_polylines(args)

    # --- Mode: export prepared drawing for the interactive segment editor ---
    if args.export_json:
        write_export_json(scaled_polylines, meta, args.export_json)
        return

    # --- Mode: automatic equal-length splitting + layout ---
    try:
        if args.fixed_steps:
            layout = solve_layout_for_steps(
                scaled_polylines,
                args.steps,
                args.dmin,
                max_iters=args.max_iters,
                restarts=args.restarts,
            )
        else:
            layout = find_minimal_step_layout(
                scaled_polylines,
                args.min_steps,
                args.steps,
                args.dmin,
                max_iters=args.max_iters,
                restarts=args.restarts,
            )
    except ValueError as e:
        print(f"Error: {e}")
        sys.exit(1)

    write_disc_scad(
        layout["segments"],
        layout["assignment"],
        layout["collisions"],
        layout["min_dist"],
        layout["N"],
        args.radius,
        args.width,
        args.output,
    )

if __name__ == "__main__":
    main()
