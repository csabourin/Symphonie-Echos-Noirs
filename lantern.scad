// =========================================================================
// Parameterized Hexagonal Musical Lantern
// Designed for Laser Cutting (flat-pack) and 3D Printing
// =========================================================================

/* [General Dimensions] */
// Total height of the lantern body (excluding feet and lid)
lantern_height = 160; // [100:300]
// Outer radius of the hexagon (distance from center to corner vertex)
outer_radius = 80; // [50:150]
// Material thickness (e.g. 3.0mm or 1/8" plywood/MDF)
thickness = 2.8; // [1.0:10.0]
// Assembly tolerance / clearance for interlocking slots (in mm)
tolerance = 0.15; // [0.0:0.5]

/* [Panel & Border Styling] */
// Width of the frame borders for side panels
border_width = 8; // [5:20]
// Margin/Overhang of the base and lid beyond the side panels
lip_margin = 4.0; // [1.0:10.0]

/* [Musical Staff & Notes] */
// Number of wavy staff lines groups per panel
num_staves = 3; // [1:5]
// Vertical spacing between individual staff lines
staff_spacing = 4.5; // [3.0:10.0]
// Thickness of the staff lines
staff_line_thickness = 1.2; // [0.5:3.0]
// Wave height (amplitude) of the staff curves
wave_amplitude = 6.0; // [0.0:20.0]
// Frequency (number of wave cycles across the panel width)
wave_frequency = 1.0; // [0.5:3.0]
// Base scale size of the musical notes
note_size = 4.5; // [2.0:10.0]

/* [Base Feet Options] */
// Height of the bottom feet skirt panels
feet_height = 20; // [10:50]
// Vertical compression factor of the arch cutout (smaller = flatter arch)
feet_arch_scale_y = 0.55; // [0.1:1.0]

/* [Interlocking Tab Configuration] */
// Width of the interlocking tabs (tenons)
tab_width = 12.0; // [5.0:30.0]
// Side panel tab offset from center (fraction of panel width)
side_tab_pos_factor = 0.32; // [0.2:0.4]
// Feet panel tab offset from center (fraction of panel width)
foot_tab_pos_factor = 0.12; // [0.05:0.25]

/* [Display Configuration] */
// Visualization mode
mode = "flatpack"; // [assembled, exploded, flatpack]
// Separation distance in the exploded view
exploded_offset = 35; // [0:100]
// Toggle rendering of the inner paper diffuser screen
show_diffuser = true;

// =========================================================================
// Calculated Geometry Constants
// =========================================================================
// Panel width is sized to meet perfectly at the 120-degree inner corners
panel_width = outer_radius - 2 * thickness * tan(30);

// Distance from the center of the hexagon to the center of the panel thickness
r_slot_center = outer_radius * cos(30) - thickness / 2;

// Horizontal position of tabs
side_tab_x = side_tab_pos_factor * panel_width;
foot_tab_x = foot_tab_pos_factor * panel_width;

// Define note coordinates for the three alternating staff patterns:
// Format: [x_ratio, staff_line_offset, note_type (0=quarter, 1=half), stem_dir (1=up, -1=down)]
notes_staff1 = [
    [-0.140, -2.0, 0,  1], // E4 (quarter, stem up)
    [-0.035, -1.0, 0,  1], // G4 (quarter, stem up)
    [ 0.070,  0.0, 0,  1], // B4 (quarter, stem up)
    [ 0.175,  1.0, 0, -1], // D5 (quarter, stem down)
    [ 0.280,  2.0, 1, -1]  // F5 (half, stem down)
];

notes_staff2 = [
    [-0.140,  0.5, 0, -1], // C5 (quarter, stem down)
    [-0.040, -0.5, 0,  1], // A4 (quarter, stem up)
    [ 0.060,  1.5, 0, -1], // E5 (quarter, stem down)
    [ 0.160,  0.0, 1,  1], // B4 (half, stem up)
    [ 0.280, -1.0, 0,  1]  // G4 (quarter, stem up)
];

notes_staff3 = [
    [-0.120, -1.5, 0,  1], // F4 (quarter, stem up)
    [-0.010, -0.5, 0,  1], // A4 (quarter, stem up)
    [ 0.130, -1.0, 0,  1], // G4 (quarter, stem up)
    [ 0.280, -2.0, 1,  1]  // E4 (half, stem up)
];

// =========================================================================
// Mathematical Wave Helper Functions
// =========================================================================
function wave_y(x, w, phase) = wave_amplitude * sin(360 * wave_frequency * x / w + phase);

// =========================================================================
// Main Execution / Selector
// =========================================================================
$fn = 120; // Circle smoothness override

if (mode == "flatpack") {
    flatpack_layout();
} else if (mode == "exploded") {
    assembly(exploded_offset);
} else {
    assembly(0);
}

// =========================================================================
// 3D Assembly Module
// =========================================================================
module assembly(offset) {
    // 1. Base Plate (horizontal, translated down by offset)
    translate([0, 0, -thickness - offset]) {
        color("BurlyWood")
            linear_extrude(height=thickness)
                base_plate_2d();
    }
    
    // 2. Bottom Feet Skirt (vertical panels under the base plate)
    for (i = [0 : 5]) {
        rotate(i * 60) {
            // Translate radially and vertically
            translate([0, r_slot_center + offset * sqrt(3)/2, -thickness - offset * 1.5]) {
                rotate([90, 0, 0]) {
                    color("Sienna")
                        linear_extrude(height=thickness)
                            foot_panel_2d();
                }
            }
        }
    }
    
    // 3. Side Panels (vertical, translated radially by offset)
    for (i = [0 : 5]) {
        rotate(i * 60) {
            translate([0, r_slot_center + offset * sqrt(3)/2, 0]) {
                rotate([90, 0, 0]) {
                    color("NavajoWhite")
                        linear_extrude(height=thickness)
                            side_panel_2d(i);
                }
            }
        }
    }
    
    // 4. Double-Layer Lid (horizontal, translated up by offset)
    // Lid Layer 1 (Bottom, with slots to receive side panel tabs)
    translate([0, 0, lantern_height + offset]) {
        color("BurlyWood")
            linear_extrude(height=thickness)
                lid_bottom_2d();
    }
    // Lid Layer 2 (Top, solid cover to hide tabs and add stepped aesthetic)
    translate([0, 0, lantern_height + thickness + offset * 1.2]) {
        color("Sienna")
            linear_extrude(height=thickness)
                lid_top_2d();
    }
    
    // 5. Diffuser Screen (inner translucent cylinder)
    if (show_diffuser) {
        // Positioned inside the side panels
        diffuser_r = r_slot_center - thickness/2 - 0.5;
        diffuser_h = lantern_height - 2;
        translate([0, 0, 1]) {
            color([1.0, 0.9, 0.6, 0.75]) { // Translucent warm glow
                linear_extrude(height=diffuser_h) {
                    difference() {
                        hexagon(diffuser_r);
                        hexagon(diffuser_r - 0.6); // 0.6mm wall thickness
                    }
                }
            }
        }
        // Warm LED Light Source visualization
        color([1.0, 0.7, 0.2, 0.4]) {
            translate([0, 0, lantern_height / 4])
                cylinder(r=15, h=lantern_height/2, center=true, $fn=24);
        }
    }
}

// =========================================================================
// 2D Flat-Pack Layout Module (for DXF/SVG Laser Cut Export)
// =========================================================================
module flatpack_layout() {
    spacing = (outer_radius + lip_margin) * 2.3;
    
    // Row 0: Horizontal Plates (Base, Bottom Lid, Top Lid)
    translate([0, 0, 0])
        base_plate_2d();
        
    translate([spacing, 0, 0])
        lid_bottom_2d();
        
    translate([spacing * 2, 0, 0])
        lid_top_2d();
        
    // Row 1 & 2: 6 Side Panels (alternating melody patterns)
    for (i = [0 : 5]) {
        row = floor(i / 3);
        col = i % 3;
        translate([col * spacing, (row + 1) * (lantern_height + 40), 0])
            side_panel_2d(i);
    }
    
    // Row 3: 6 Feet Panels (spaced horizontally in a single separate row)
    for (i = [0 : 5]) {
        translate([i * (spacing * 0.5), 3 * (lantern_height + 40) + 20, 0])
            foot_panel_2d();
    }
}

// =========================================================================
// 2D Component Modules
// =========================================================================

// Regular Hexagon Helper
module hexagon(r) {
    circle(r=r, $fn=6);
}

// --- BASE PLATE ---
module base_plate_2d() {
    difference() {
        hexagon(outer_radius + lip_margin);
        // Slots for the 6 side panels (outer tabs)
        slots_pattern(side_tab_x, r_slot_center, tab_width + tolerance, thickness + tolerance);
        // Slots for the 6 feet panels (inner tabs, offset to avoid collisions)
        slots_pattern(foot_tab_x, r_slot_center, tab_width + tolerance, thickness + tolerance);
    }
}

// --- LID LAYER 1 (BOTTOM) ---
module lid_bottom_2d() {
    difference() {
        hexagon(outer_radius + lip_margin);
        // Slots for the 6 side panels
        slots_pattern(side_tab_x, r_slot_center, tab_width + tolerance, thickness + tolerance);
        // Decorative venting fretwork (scaled to fit inside frame bounds)
        lid_fretwork(outer_radius - border_width - 4);
    }
}

// --- LID LAYER 2 (TOP) ---
module lid_top_2d() {
    difference() {
        // Slightly larger than bottom layer for a beautiful stepped lip
        hexagon(outer_radius + lip_margin + 2.0);
        // NO slots! This layer covers the tabs.
        // Same central venting fretwork
        lid_fretwork(outer_radius - border_width - 4);
    }
}

// --- SIDE PANEL ---
module side_panel_2d(index) {
    w_inner = panel_width - 2 * border_width;
    h_inner = lantern_height - 2 * border_width;
    
    union() {
        // The outer frame with tabs
        difference() {
            union() {
                // Main rectangle (centered horizontally on X, starts at Y=0)
                translate([-panel_width/2, 0])
                    square([panel_width, lantern_height]);
                
                // Bottom Tabs (fit into base plate)
                translate([-side_tab_x - tab_width/2, -thickness])
                    square([tab_width, thickness]);
                translate([side_tab_x - tab_width/2, -thickness])
                    square([tab_width, thickness]);
                
                // Top Tabs (fit into lid bottom layer)
                translate([-side_tab_x - tab_width/2, lantern_height])
                    square([tab_width, thickness]);
                translate([side_tab_x - tab_width/2, lantern_height])
                    square([tab_width, thickness]);
            }
            // Cut out the inner frame opening
            translate([-w_inner/2, border_width])
                square([w_inner, h_inner]);
        }
        
        // Fretwork content inside the opening
        translate([0, border_width])
            panel_fretwork(w_inner, h_inner, index);
    }
}

// --- FOOT SKIRT PANEL ---
module foot_panel_2d() {
    w = panel_width;
    h = feet_height;
    
    difference() {
        union() {
            // Main rectangular body of foot panel (below reference Y=0 line)
            translate([-w/2, -h])
                square([w, h]);
            
            // Top Tabs (protrude UP into base plate slots)
            translate([-foot_tab_x - tab_width/2, 0])
                square([tab_width, thickness]);
            translate([foot_tab_x - tab_width/2, 0])
                square([tab_width, thickness]);
        }
        
        // Arch Cutout at bottom
        // Sized to leave solid columns at the corners for load-bearing
        translate([0, -h])
            scale([1.0, feet_arch_scale_y])
                circle(d=w - border_width * 1.5, $fn=40);
    }
}

// =========================================================================
// Interlocking Slot Patterns
// =========================================================================
module slots_pattern(tx, ty, sw, st) {
    for (i = [0 : 5]) {
        rotate(i * 60) {
            // Left tab slot
            translate([-tx, ty])
                square([sw, st], center=true);
            // Right tab slot
            translate([tx, ty])
                square([sw, st], center=true);
        }
    }
}

// =========================================================================
// Decorative Fretwork Patterns
// =========================================================================

// Lid Fretwork (Radial Geometric Motif)
module lid_fretwork(max_r) {
    // Center ring cutout
    circle(r=max_r * 0.22, $fn=30);
    
    // Curved/Radial vent petals
    for (i = [0 : 5]) {
        rotate(i * 60) {
            // Main petal slots
            translate([0, max_r * 0.5])
                scale([0.65, 1.6])
                    circle(r=max_r * 0.16, $fn=16);
            
            // Minor accent spokes (helps venting and matches geometry)
            rotate(30)
                translate([0, max_r * 0.65])
                    scale([0.3, 1.2])
                        circle(r=max_r * 0.08, $fn=12);
        }
    }
}

// Side Panel Inner Fretwork (Music Theme)
module panel_fretwork(w_inner, h_inner, index) {
    staff_y_spacing = h_inner / (num_staves + 1);
    
    // Choose notes list based on panel index (alternating melody)
    notes = (index % 3 == 0) ? notes_staff1 : 
            ((index % 3 == 1) ? notes_staff2 : notes_staff3);
            
    // Draw each staff
    for (s = [1 : num_staves]) {
        y_center = s * staff_y_spacing;
        
        // Dynamic phase shift for each staff so they wave organically relative to each other
        phase = (s * 110 + index * 40) % 360;
        
        // 1. Draw the 5 wavy staff lines
        for (l = [-2 : 2]) {
            y_offset = l * staff_spacing;
            wavy_line(w_inner, y_center + y_offset, staff_line_thickness, phase);
        }
        
        // 2. Draw vertical musical bar lines for realism and structural support
        // Left starting double-bar
        bar_line(w_inner, y_center, phase, -w_inner/2 + 13.5, staff_line_thickness * 1.5);
        
        // Right ending double-bar (double lines for musical completion)
        double_bar_lines(w_inner, y_center, phase);
        
        // 3. Draw Treble Clef at the beginning of the staff (left side)
        clef_x = -w_inner/2 + 6.0;
        clef_y = y_center + wave_y(clef_x, w_inner, phase);
        treble_clef(clef_x, clef_y, 0.72);
        
        // 4. Draw the melody notes
        for (n = [0 : len(notes)-1]) {
            note = notes[n];
            n_x_ratio = note[0];
            n_line_offset = note[1];
            n_type = note[2];
            n_stem = note[3];
            
            n_x = n_x_ratio * w_inner;
            // The note Y position tracks the wave height of the staff at its X position
            n_y = y_center + wave_y(n_x, w_inner, phase) + n_line_offset * staff_spacing;
            
            draw_note(n_x, n_y, n_type, n_stem, staff_spacing);
        }
    }
}

// Wavy Line Generator (Pairwise hull circles along wave path)
module wavy_line(w, y_base, line_thick, phase) {
    steps = 28; // Balance resolution and render speed
    step_size = w / steps;
    for (i = [0 : steps-1]) {
        x1 = -w/2 + i * step_size;
        x2 = -w/2 + (i+1) * step_size;
        
        y1 = y_base + wave_y(x1, w, phase);
        y2 = y_base + wave_y(x2, w, phase);
        
        hull() {
            translate([x1, y1]) circle(d=line_thick, $fn=8);
            translate([x2, y2]) circle(d=line_thick, $fn=8);
        }
    }
}

// Single Vertical Bar Line
module bar_line(w_inner, y_center, phase, bar_x, b_width) {
    y_start = y_center - 2.1 * staff_spacing + wave_y(bar_x, w_inner, phase);
    translate([bar_x - b_width/2, y_start])
        square([b_width, 4.2 * staff_spacing]);
}

// Double Bar Line (Terminating Music)
module double_bar_lines(w_inner, y_center, phase) {
    bx1 = w_inner/2 - 10.0;
    bx2 = w_inner/2 - 7.5;
    t1 = staff_line_thickness;
    t2 = staff_line_thickness * 2.2;
    
    bar_line(w_inner, y_center, phase, bx1, t1);
    bar_line(w_inner, y_center, phase, bx2, t2);
}

// Bezier Point Helper (evaluates a cubic Bezier curve at parameter t [0,1])
function bezier_point(p0, p1, p2, p3, t) = 
    (1-t)*(1-t)*(1-t)*p0 + 
    3*(1-t)*(1-t)*t*p1 + 
    3*(1-t)*t*t*p2 + 
    t*t*t*p3;

// Bezier Stroke Helper (draws a curve segment with calligraphic variable width)
module bezier_stroke(p0, p1, p2, p3, t1, t2, steps=8) {
    for (i = [0 : steps-1]) {
        ta = i / steps;
        tb = (i + 1) / steps;
        pt_a = bezier_point(p0, p1, p2, p3, ta);
        pt_b = bezier_point(p0, p1, p2, p3, tb);
        d_a = t1 + (t2 - t1) * ta;
        d_b = t1 + (t2 - t1) * tb;
        hull() {
            translate(pt_a) circle(d=d_a, $fn=8);
            translate(pt_b) circle(d=d_b, $fn=8);
        }
    }
}

// Highly Accurate Calligraphic Treble Clef Module
module treble_clef(x, y, scale_factor) {
    // Horizontally scale by 1.70 to match the aspect ratio of clef.svg (0.4642 vs 0.273)
    translate([x, y]) scale([scale_factor * 1.70, scale_factor]) {
        // Control points for the 8 Bezier segments forming the classic G-clef
        
        // 1. Spine (center slanting vertical column)
        p_spine_0 = [0.5, 14.5];
        p_spine_1 = [0.2, 6.0];
        p_spine_2 = [-0.2, -2.0];
        p_spine_3 = [-0.5, -11.0];
        bezier_stroke(p_spine_0, p_spine_1, p_spine_2, p_spine_3, 0.8, 1.4, steps=6);
        
        // 2. Bottom Hook
        p_hook_0 = [-0.5, -11.0];
        p_hook_1 = [-0.8, -14.0];
        p_hook_2 = [-3.0, -14.0];
        p_hook_3 = [-3.0, -11.5];
        bezier_stroke(p_hook_0, p_hook_1, p_hook_2, p_hook_3, 1.4, 0.8, steps=6);
        // Bottom terminal ornament dot
        translate([-3.0, -11.5]) circle(d=2.0, $fn=12);
        
        // 3. Top Loop (curves up and right, then loops down)
        p_top_0 = [0.5, 14.5];
        p_top_1 = [0.8, 17.5];
        p_top_2 = [3.2, 14.5];
        p_top_3 = [0.0, 3.5];
        bezier_stroke(p_top_0, p_top_1, p_top_2, p_top_3, 0.8, 1.2, steps=8);
        
        // 4. Crossing to Bell Bottom (curving down-left)
        p_bell_0 = [0.0, 3.5];
        p_bell_1 = [-1.5, 1.0];
        p_bell_2 = [-3.2, -3.5];
        p_bell_3 = [-1.0, -9.5];
        bezier_stroke(p_bell_0, p_bell_1, p_bell_2, p_bell_3, 1.2, 2.4, steps=8);
        
        // 5. Bell Bottom to Bell Right (the main outer loop)
        p_loop_0 = [-1.0, -9.5];
        p_loop_1 = [1.5, -11.2];
        p_loop_2 = [5.0, -7.0];
        p_loop_3 = [3.8, -2.5];
        bezier_stroke(p_loop_0, p_loop_1, p_loop_2, p_loop_3, 2.4, 1.6, steps=8);
        
        // 6. Bell Right to Spiral Start (wrapping inward)
        p_spir_0 = [3.8, -2.5];
        p_spir_1 = [2.2, 0.5];
        p_spir_2 = [-1.0, 0.5];
        p_spir_3 = [-2.8, -2.5];
        bezier_stroke(p_spir_0, p_spir_1, p_spir_2, p_spir_3, 1.6, 1.2, steps=8);
        
        // 7. Inner Spiral (around the G line)
        p_in_0 = [-2.8, -2.5];
        p_in_1 = [-2.8, -6.5];
        p_in_2 = [1.2, -6.5];
        p_in_3 = [1.2, -4.5];
        bezier_stroke(p_in_0, p_in_1, p_in_2, p_in_3, 1.2, 1.0, steps=8);
        
        // 8. Spiral Center terminal curl
        p_core_0 = [1.2, -4.5];
        p_core_1 = [1.2, -3.2];
        p_core_2 = [-0.8, -3.2];
        p_core_3 = [-0.8, -4.5];
        bezier_stroke(p_core_0, p_core_1, p_core_2, p_core_3, 1.0, 0.8, steps=8);
        // Inner terminal dot
        translate([-0.8, -4.5]) circle(d=1.3, $fn=12);
        
        // Clef background bridge (adds mechanical strength to the fine parts)
        translate([-1.5, -4.5])
            square([3.0, 1.2]);
    }
}

// Musical Note Generator
module draw_note(x, y, note_type, stem_dir, s_space) {
    translate([x, y]) {
        // 1. Draw Note Head (angled oval)
        rotate(28) {
            if (note_type == 0) {
                // Quarter Note (Solid Head)
                scale([1.25, 0.85]) 
                    circle(d=note_size, $fn=16);
            } else {
                // Half Note (Hollow Head)
                difference() {
                    scale([1.25, 0.85]) 
                        circle(d=note_size, $fn=16);
                    scale([0.7, 0.45]) 
                        circle(d=note_size, $fn=16);
                }
            }
        }
        
        // 2. Draw Stem (thin vertical rectangle)
        if (stem_dir != 0) {
            dx = 1.25 * note_size / 2;
            stem_len = s_space * 3.3;
            stem_w = staff_line_thickness * 1.15;
            
            if (stem_dir == 1) {
                // Stem UP on the right side of the head
                translate([dx - stem_w, -0.5])
                    square([stem_w, stem_len]);
            } else {
                // Stem DOWN on the left side of the head
                translate([-dx, -stem_len + 0.5])
                    square([stem_w, stem_len]);
            }
        }
    }
}
