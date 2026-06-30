/**
 * Parametric Hexagonal Beacons with Music Note Cutouts and Ground Stakes
 * Designed for Laser-Cut Wood
 *
 * Authors: Antigravity & Christian Sabourin
 * Date: May 2026
 *
 * This file contains a parametric design for 4 separate hexagonal beacons:
 * - N (Nord)
 * - S (Sud)
 * - E (Est)
 * - O (Ouest)
 *
 * Features:
 * - 3D Assembled Mode and 2D Flatpack Mode for laser cutting.
 * - Stencil-friendly lettering (N, S, E, O) and direction arrows.
 * - Stencil-friendly music staff lines (dashed to avoid splitting wood).
 * - Decorative music notes (note heads and stems) aligned across all panels.
 * - Cross-shaped ground stake (interlocking triangular pieces) for rigidity in soil.
 * - Tab-and-slot assembly with adjustable laser kerf correction.
 */

/* [Display Settings] */
// Mode: "assembled" for 3D preview, "flatpack" for 2D laser-cut nesting layout
mode = "assembled"; // ["assembled", "flatpack"]

// Select which beacon to display
beacon_select = "all"; // ["all", "N", "S", "E", "O"]

/* [Material & Fabrication Parameters] */
// Wood sheet thickness (mm)
wood_thickness = 2.8;

// Laser beam width compensation (mm). Slots are reduced by this amount for a tight press-fit.
laser_kerf = 0.15;

// Additional extension of tabs beyond slots for sanding flush (mm)
tab_extension = 0.5;

/* [Beacon Dimensions] */
// Mount type: "stake" for wood ground stake, "skeleton" to sleeve over the 3D-printed cage/skeleton
mount_type = "skeleton"; // ["stake", "skeleton"]

// Height of the beacon wooden body (mm) - adjusted to match ~150mm PLA insert (plus 10.25mm taller to clear the top flange beautifully)
beacon_height_param = 150.0;
beacon_height = (mount_type == "skeleton") ? (beacon_height_param + 10.25) : beacon_height_param;

// Distance from the center of the hexagon to its inner corners (mm) - circumradius. Set to 20.0 to clear a 32mm core, or 30.5 to clear the 60mm 3D-printed skeleton.
inner_radius_param = 20.0;

// Auto-adjust inner radius if using skeleton, unless overridden
inner_radius = (mount_type == "skeleton" && inner_radius_param == 20.0) ? 31.5 : inner_radius_param;

// Length of the ground stake (mm) - Ignored if mount_type is "skeleton"
stake_length = 80.0;

// Width of the ground stake at the top (mm)
stake_width = 30.0;

// Width of the ground stake tip (mm)
stake_tip_width = 6.0;

/* [Tabs & Slots Parameters] */
// Width of the tabs for side panels (mm)
tab_width = 10.0;

// Width of the tabs for the ground stake (mm)
stake_tab_w = 8.0;

// Offset of the ground stake tabs from the center (mm)
stake_tab_offset = 8.0;

/* [Decorative Cutouts Parameters] */
// Font name for the cardinal direction letters
font_name = "Liberation Sans:style=Bold";

// Height of the letter (mm) - scaled for 20mm panel width
font_size = 11.0;

// Thickness of the music staff lines (mm) - increased to prevent wood fragility with laser kerf
staff_line_thickness = 1.3;

// Spacing between the music staff lines (mm) - widened to give sturdy wood ridges between cuts
staff_line_spacing = 2.4;

// Size of the music note heads (mm) - scaled with line spacing
note_size = 2.4;

// Width of stencil bridges for letters and staves (mm)
bridge_w = 1.2;

// Additional horizontal margin/border for top and bottom plates (mm) to prevent splitting wood
cap_margin = 3.5;

// Radius of the top cap ventilation/light hole (0 for solid cap)
cap_hole_radius = 12.0;


// --- GEOMETRIC INTERNALS (Do not modify) ---
$fn = 60;

// Long panel width (front/back)
panel_w_long = (mount_type == "skeleton") ? 47.0 : inner_radius;

// Y-distance from center to front/back panels
r_in_long = (mount_type == "skeleton") ? 27.5 : (inner_radius * cos(30));

// X-distance from center to middle side corners
r_in_short = (mount_type == "skeleton") ? 35.5 : inner_radius;

// Vertices of the inner hexagon (where the inner faces of panels meet)
v0 = [panel_w_long / 2, r_in_long];
v1 = [r_in_short, 0];
v2 = [panel_w_long / 2, -r_in_long];
v3 = [-panel_w_long / 2, -r_in_long];
v4 = [-r_in_short, 0];
v5 = [-panel_w_long / 2, r_in_long];

// Helper functions/arrays for placing the 6 panels
function get_panel_vertices(i) = [
    [v5, v0], // Panel 0 (Front)
    [v0, v1], // Panel 1
    [v1, v2], // Panel 2
    [v2, v3], // Panel 3 (Back)
    [v3, v4], // Panel 4
    [v4, v5]  // Panel 5
][i];

function get_panel_width(i) = norm(get_panel_vertices(i)[1] - get_panel_vertices(i)[0]);

function get_panel_midpoint(i) = (get_panel_vertices(i)[0] + get_panel_vertices(i)[1]) / 2;

function get_panel_angle(i) = 
    let(v_start = get_panel_vertices(i)[0],
        v_end = get_panel_vertices(i)[1],
        d = v_end - v_start)
    atan2(d[1], d[0]) + 90;

// Define default fallback references
panel_w = inner_radius; 
r_in = r_in_long;
r_cap = (r_in_long + wood_thickness + cap_margin); // Scale reference for cap

// Generates the 2D elongated hexagon for the plates
module cap_polygon(margin = 0) {
    scale_factor = (inner_radius + wood_thickness + margin) / inner_radius;
    polygon(points = [
        v0 * scale_factor,
        v1 * scale_factor,
        v2 * scale_factor,
        v3 * scale_factor,
        v4 * scale_factor,
        v5 * scale_factor
    ]);
}

// Melody representation: [x_fraction, pitch, stem_dir]
// x_fraction: -0.4 to 0.4 (fraction of staff width)
// pitch: -4 to 4 (position on staff, 0 is center line, 1 is space above, etc.)
// stem_dir: 1 (up), -1 (down), 0 (none)
function get_melody(beacon_letter, panel_idx, staff_position) =
    panel_idx == 0 ? (
        // Front panel melodies (only top=2 and bottom=0 staves, middle is letter)
        staff_position == 2 ? (
            beacon_letter == "N" ? [[-0.3, 0, 1], [0.0, 2, 1], [0.3, 3, -1]] :
            beacon_letter == "S" ? [[-0.3, 4, -1], [0.0, 2, 1], [0.3, 1, 1]] :
            beacon_letter == "E" ? [[-0.3, -2, 1], [0.0, 0, 1], [0.3, 4, -1]] :
            // "O"
            [[-0.3, 2, -1], [0.0, 1, 1], [0.3, 0, 1]]
        ) : (
            beacon_letter == "N" ? [[-0.3, -2, 1], [0.0, 0, 1], [0.3, 2, -1]] :
            beacon_letter == "S" ? [[-0.3, 2, -1], [0.0, 0, 1], [0.3, -2, 1]] :
            beacon_letter == "E" ? [[-0.3, 1, 1], [0.0, 3, -1], [0.3, 2, -1]] :
            // "O"
            [[-0.3, -1, 1], [0.0, 1, 1], [0.3, 0, 1]]
        )
    ) : (
        // Side panel melodies (panels 1 to 5)
        panel_idx == 1 ? (
            staff_position == 2 ? [[-0.3, 0, 1], [0.0, 1, 1], [0.3, 3, -1]] :
            staff_position == 1 ? [[-0.3, 3, -1], [0.0, 2, -1], [0.3, 0, 1]] :
            [[-0.3, -2, 1], [0.0, 0, 1], [0.3, 0, 1]]
        ) :
        panel_idx == 2 ? (
            staff_position == 2 ? [[-0.3, 2, -1], [0.0, 4, -1], [0.3, 2, -1]] :
            staff_position == 1 ? [[-0.3, -1, 1], [0.0, 1, 1], [0.3, 1, 1]] :
            [[-0.3, 1, 1], [0.0, 0, 1], [0.3, -2, 1]]
        ) :
        panel_idx == 3 ? (
            staff_position == 2 ? [[-0.3, -3, 1], [0.0, -1, 1], [0.3, 3, -1]] :
            staff_position == 1 ? [[-0.3, 4, -1], [0.0, 0, 1], [0.3, -2, 1]] :
            [[-0.3, 0, 1], [0.0, 1, 1], [0.3, 3, -1]]
        ) :
        panel_idx == 4 ? (
            staff_position == 2 ? [[-0.3, 1, 1], [0.0, 2, -1], [0.3, 4, -1]] :
            staff_position == 1 ? [[-0.3, -2, 1], [0.0, -1, 1], [0.3, 1, 1]] :
            [[-0.3, 3, -1], [0.0, 1, 1], [0.3, 0, 1]]
        ) : (
            // panel_idx == 5
            staff_position == 2 ? [[-0.3, 3, -1], [0.0, 0, 1], [0.3, -1, 1]] :
            staff_position == 1 ? [[-0.3, 0, 1], [0.0, 1, -1], [0.3, 3, -1]] :
            [[-0.3, 2, -1], [0.0, 0, 1], [0.3, 1, 1]]
        )
    );


// --- 2D UTILITY MODULES ---

// Generates a regular polygon of size radius and n sides
module regular_polygon(r, n) {
    circle(r = r, $fn = n);
}

// Generates a single dashed line for stencils
module dashed_line(w, thickness, num_dashes, bridge_w) {
    seg_w = (w - (num_dashes - 1) * bridge_w) / num_dashes;
    for (i = [0 : num_dashes - 1]) {
        translate([-w/2 + seg_w/2 + i * (seg_w + bridge_w), 0])
            square([seg_w, thickness], center = true);
    }
}

// Generates a music staff of 5 dashed lines
module music_staff(w, line_spacing, line_thickness, num_dashes, bridge_w) {
    for (i = [-2 : 2]) {
        translate([0, i * line_spacing])
            dashed_line(w, line_thickness, num_dashes, bridge_w);
    }
}

// Generates a single music note (head + optional stem)
module music_note(x, pitch, line_spacing, note_size, stem_dir) {
    y = pitch * (line_spacing / 2);
    translate([x, y]) {
        // Rotate note head slightly like a real note
        rotate(15) scale([1.3, 1]) circle(d = note_size);
        
        // Add stem
        if (stem_dir != 0) {
            stem_len = line_spacing * 3.5;
            stem_offset_x = (stem_dir > 0) ? (note_size * 0.5) : (-note_size * 0.5);
            stem_y_start = 0;
            stem_y_end = stem_dir * stem_len;
            
            // Generate stem as a small polygon
            translate([stem_offset_x, 0]) {
                if (stem_dir > 0) {
                    translate([0, stem_len/2])
                        square([0.8, stem_len], center = true);
                } else {
                    translate([0, -stem_len/2])
                        square([0.8, stem_len], center = true);
                }
            }
        }
    }
}

// Combines staff lines and notes
module music_staff_with_notes(w, line_spacing, line_thickness, num_dashes, bridge_w, note_size, notes) {
    difference() {
        // We cut out the staff lines and the notes
        union() {
            music_staff(w, line_spacing, line_thickness, num_dashes, bridge_w);
            for (note = notes) {
                music_note(note[0] * w, note[1], line_spacing, note_size, note[2]);
            }
        }
    }
}

// Generates stencil letter with direction arrows
module panel_stencil_letter(letter, size, font_name, bridge_w) {
    // Arrow pointing UP
    translate([0, size * 0.85])
        polygon(points = [[-size * 0.25, 0], [0, size * 0.25], [size * 0.25, 0]]);
        
    // Arrow pointing DOWN
    translate([0, -size * 0.85])
        polygon(points = [[-size * 0.25, 0], [0, -size * 0.25], [size * 0.25, 0]]);
    
    // Main Letter
    difference() {
        text(letter, size = size, font = font_name, halign = "center", valign = "center");
        
        // Add stencil bridge for Ouest "O" to keep the center loop attached
        if (letter == "O") {
            square([bridge_w, size * 1.5], center = true);
        }
    }
}

// Generates a 2D side panel (with tabs and cutouts)
module side_panel_2d(beacon_letter, panel_idx) {
    w = get_panel_width(panel_idx);
    h = beacon_height;
    t = wood_thickness;
    ext = tab_extension;
    
    // Define positions of the staves
    staff_z = [h * 0.22, h * 0.5, h * 0.78];
    staff_w = w - 4; // leaving 2mm border on each side for wider staves and beautifully spaced notes
    
    difference() {
        // Main panel body
        union() {
            square([w, h]);
            // Top tab - generated to lock into the collar ring
            translate([w/2 - tab_width/2, h])
                square([tab_width, t + ext]);
            // Bottom tab
            translate([w/2 - tab_width/2, -(t + ext)])
                square([tab_width, t + ext]);
        }
        
        // Subtract decorative cutouts
        if (panel_idx == 0) {
            // Front panel: Top staff, Bottom staff, and Middle letter
            translate([w/2, staff_z[2]])
                music_staff_with_notes(staff_w, staff_line_spacing, staff_line_thickness, 3, bridge_w, note_size, get_melody(beacon_letter, panel_idx, 2));
                
            translate([w/2, staff_z[0]])
                music_staff_with_notes(staff_w, staff_line_spacing, staff_line_thickness, 3, bridge_w, note_size, get_melody(beacon_letter, panel_idx, 0));
                
            translate([w/2, staff_z[1]])
                panel_stencil_letter(beacon_letter, font_size, font_name, bridge_w);
        } else {
            // Side panels: Top, Middle, and Bottom staves
            for (s = [0 : 2]) {
                translate([w/2, staff_z[s]])
                    music_staff_with_notes(staff_w, staff_line_spacing, staff_line_thickness, 3, bridge_w, note_size, get_melody(beacon_letter, panel_idx, s));
            }
        }
    }
}


// --- 3D PART GENERATORS ---

// Extruded side panel
module side_panel_3d(beacon_letter, panel_idx) {
    color("BurlyWood")
        linear_extrude(height = wood_thickness, center = false)
            side_panel_2d(beacon_letter, panel_idx);
}

// Top Cap (Hexagon with slots and circular hole)
module top_cap_2d() {
    t = wood_thickness;
    k = laser_kerf;
    
    difference() {
        cap_polygon(cap_margin);
        
        // Slots for the 6 side panels (tabs must be tight fit)
        for (i = [0 : 5]) {
            mid_i = get_panel_midpoint(i);
            ang_i = get_panel_angle(i);
            translate([mid_i[0], mid_i[1]])
                rotate(ang_i - 90)
                    square([tab_width - k, t - k], center = true);
        }
        
        // Central hole for light / aesthetics / letting the skeleton top (55.66mm diameter) out
        // 55.66mm diameter has radius of 27.83mm
        circle(r = 27.83);
    }
}

module top_cap_3d() {
    color("Peru")
        linear_extrude(height = wood_thickness)
            top_cap_2d();
}

// Bottom Base Plate (Hexagon with slots for side panels and cross-shaped stake slots)
module bottom_plate_2d() {
    t = wood_thickness;
    k = laser_kerf;
    
    difference() {
        cap_polygon(cap_margin);
        
        // Slots for the 6 side panels (tabs must be tight fit)
        for (i = [0 : 5]) {
            mid_i = get_panel_midpoint(i);
            ang_i = get_panel_angle(i);
            translate([mid_i[0], mid_i[1]])
                rotate(ang_i - 90)
                    square([tab_width - k, t - k], center = true);
        }
        
        // Slots for Stake A (along X-axis)
        translate([-stake_tab_offset, 0])
            square([stake_tab_w - k, t - k], center = true);
        translate([stake_tab_offset, 0])
            square([stake_tab_w - k, t - k], center = true);
            
        // Slots for Stake B (along Y-axis)
        translate([0, -stake_tab_offset])
            square([t - k, stake_tab_w - k], center = true);
        translate([0, stake_tab_offset])
            square([t - k, stake_tab_w - k], center = true);
    }
}

module bottom_plate_3d() {
    color("Peru")
        linear_extrude(height = wood_thickness)
            bottom_plate_2d();
}

// Ground Stake Piece (2D)
// slot_from_top = true for Stake A, false for Stake B
module stake_piece_2d(slot_from_top) {
    w = stake_width;
    h = stake_length;
    t = wood_thickness;
    ext = tab_extension;
    k = laser_kerf;
    
    difference() {
        // Main Stake shape + tabs
        union() {
            // Tapered body
            polygon(points = [
                [-w/2, 0],
                [-stake_tip_width/2, -h],
                [stake_tip_width/2, -h],
                [w/2, 0]
            ]);
            
            // Tabs extending into bottom plate (exactly flush, no extension, to avoid touching PLA core)
            translate([-stake_tab_offset - stake_tab_w/2, 0])
                square([stake_tab_w, t]);
            translate([stake_tab_offset - stake_tab_w/2, 0])
                square([stake_tab_w, t]);
        }
        
        // Interlocking slot (width matches wood thickness, height is half stake length)
        // We include kerf correction to make the slot slide together tightly
        slot_w = t - k;
        slot_h = h/2 + 0.5; // slight tolerance at bottom of slot for full insertion
        
        if (slot_from_top) {
            // Slot cut from top down
            translate([-slot_w/2, -slot_h])
                square([slot_w, slot_h + 1]); // extend slightly past Z=0 to clear tab area
        } else {
            // Slot cut from bottom up
            translate([-slot_w/2, -h - 1])
                square([slot_w, slot_h + 1]);
        }
    }
}

// Extruded Stake Piece (3D)
module stake_piece_3d(slot_from_top) {
    color("SaddleBrown")
        translate([0, 0, -wood_thickness])
            rotate([90, 0, 0])
                linear_extrude(height = wood_thickness, center = true)
                    stake_piece_2d(slot_from_top);
}


// --- skeleton 3D PREVIEW MODULE ---

// Generates a 3D preview of the 3D-printed skeleton cage
module skeleton_preview() {
    h = beacon_height;
    r_sk = inner_radius - 0.5; // Outer radius of skeleton with clearance
    r_sk_in = r_sk - 2.5;      // Inner radius of skeleton rings/pillars
    r_top_cap = r_sk + 2.0;    // Top round shoulder/lip is slightly wider than the hexagon body
    
    // Helper to generate rounded-corner elongated hexagon for rings
    module skeleton_ring_shape(scale_f, offset_r = 3.5) {
        offset(r = offset_r, $fn = 30)
            polygon(points = [
                v0 * scale_f - [offset_r, offset_r],
                v1 * scale_f - [offset_r, 0],
                v2 * scale_f - [offset_r, -offset_r],
                v3 * scale_f - [-offset_r, -offset_r],
                v4 * scale_f - [-offset_r, 0],
                v5 * scale_f - [-offset_r, offset_r]
            ]);
    }
    
    color("GhostWhite", 0.85) {  // White PLA translucent structure
        // Bottom Base plate ring (with rounded corners, scaled to match skeleton)
        linear_extrude(height = 4)
            difference() {
                skeleton_ring_shape(0.98);
                skeleton_ring_shape(0.90);
            }
            
        // Top Cap Plate (Sits ABOVE the beacon wood shell height)
        translate([0, 0, h]) {
            cylinder(r = r_top_cap, h = 18, $fn = 60); // 18mm tall top round part
            // Decorative concentric circle grooves on top cap
            translate([0, 0, 18.01]) {
                difference() {
                    cylinder(r = r_top_cap - 2, h = 0.5, $fn = 60);
                    cylinder(r = r_top_cap - 4, h = 1, $fn = 60);
                }
            }
        }
        
        // 6 Vertical Pillars at the exact elongated hexagon corners
        for (i = [0 : 5]) {
            v_i = [v0, v1, v2, v3, v4, v5][i];
            translate([v_i[0] * 0.95, v_i[1] * 0.95, 0])
                cylinder(r = 1.8, h = h, $fn = 12);
        }
        
        // Middle horizontal and diagonal brace rings (with rounded corners)
        // Place braces at h * 0.35 and h * 0.65 to mirror the printed layout
        for (z = [h * 0.35, h * 0.65]) {
            translate([0, 0, z]) {
                linear_extrude(height = 3, center = true)
                    difference() {
                        skeleton_ring_shape(0.98);
                        skeleton_ring_shape(0.90);
                    }
                // Lattice diamond supports visible on each of the 6 sides
                for (i = [0 : 5]) {
                    mid_i = get_panel_midpoint(i);
                    ang_i = get_panel_angle(i);
                    translate([mid_i[0] * 0.95, mid_i[1] * 0.95, z])
                        rotate([0, 0, ang_i - 90]) {
                            rotate([0, 45, 0])
                                cube([8, 1.2, 1.2], center = true);
                            rotate([0, -45, 0])
                                cube([8, 1.2, 1.2], center = true);
                        }
                }
            }
        }
    }
}


// --- FULL ASSEMBLIES ---

// Complete 3D assembly of a single beacon
module single_beacon_assembly(beacon_letter) {
    h = beacon_height;
    t = wood_thickness;
    
    // Bottom plate
    translate([0, 0, -t])
        bottom_plate_3d();
        
    // Top cap - generated to slot top tabs and let the top cylinder out
    translate([0, 0, h])
        top_cap_3d();
        
    // 6 Side panels (rotated to face outward and read correctly from outside, starting at Z = 0)
    for (i = [0 : 5]) {
        w_i = get_panel_width(i);
        mid_i = get_panel_midpoint(i);
        ang_i = get_panel_angle(i);
        
        translate([mid_i[0], mid_i[1], 0])
            rotate([0, 0, ang_i - 90])
                rotate([90, 0, 180])
                    translate([-w_i/2, 0, 0])
                        side_panel_3d(beacon_letter, i);
    }
    
    // Ground Stake A (slot from top)
    rotate([0, 0, 0])
        stake_piece_3d(slot_from_top = true);
        
    // Ground Stake B (slot from bottom, rotated 90 degrees)
    rotate([0, 0, 90])
        stake_piece_3d(slot_from_top = false);

    if (mount_type == "skeleton") {
        // Preview the 3D-printed cage skeleton inside (perfectly sleeved)
        translate([0, 0, 0])
            skeleton_preview();
    }
}

// Displays all selected beacons in 3D
module all_beacons_assembly() {
    spacing = inner_radius * 3.5;
    
    if (beacon_select == "all") {
        translate([-spacing * 1.5, 0, 0]) single_beacon_assembly("N");
        translate([-spacing * 0.5, 0, 0]) single_beacon_assembly("S");
        translate([spacing * 0.5, 0, 0]) single_beacon_assembly("E");
        translate([spacing * 1.5, 0, 0]) single_beacon_assembly("O");
    } else if (beacon_select == "N") {
        single_beacon_assembly("N");
    } else if (beacon_select == "S") {
        single_beacon_assembly("S");
    } else if (beacon_select == "E") {
        single_beacon_assembly("E");
    } else if (beacon_select == "O") {
        single_beacon_assembly("O");
    }
}


// --- 2D FLATPACK NESTING FOR LASER CUTTING ---

// Nesting layout for a single beacon's parts
module flatpack_single_beacon(beacon_letter) {
    h = beacon_height;
    t = wood_thickness;
    ext = tab_extension;
    
    // Side Panels laid out horizontally
    // Each panel can have a different width, so let's translate sequentially to prevent overlaps
    for (i = [0 : 5]) {
        let(offset_x = (i == 0) ? 0 : 
                       (i == 1) ? get_panel_width(0) + 12 :
                       (i == 2) ? get_panel_width(0) + get_panel_width(1) + 24 :
                       (i == 3) ? get_panel_width(0) + get_panel_width(1) + get_panel_width(2) + 36 :
                       (i == 4) ? get_panel_width(0) + get_panel_width(1) + get_panel_width(2) + get_panel_width(3) + 48 :
                                  get_panel_width(0) + get_panel_width(1) + get_panel_width(2) + get_panel_width(3) + get_panel_width(4) + 60) {
            translate([offset_x, 0])
                side_panel_2d(beacon_letter, i);
        }
    }
    
    // Spacing reference based on total side panels width
    total_panels_w = get_panel_width(0) + get_panel_width(1) + get_panel_width(2) + get_panel_width(3) + get_panel_width(4) + get_panel_width(5) + 60;
    
    // Caps & Stakes positioned safely below the panels with no overlap
    // Using absolute offsets based on cap radius r_cap ensures they never overlap regardless of panel widths
    translate([r_cap + 15, -r_cap - 25])
        top_cap_2d();
        
    translate([r_cap * 3 + 35, -r_cap - 25])
        bottom_plate_2d();
        
    // Stake A (goes downwards, Y <= 0 locally) - placed safely at the end of the sheet
    translate([r_cap * 5 + 75, -20])
        stake_piece_2d(slot_from_top = true);
        
    // Stake B (goes downwards, Y <= 0 locally) - placed safely at the end of the sheet
    translate([r_cap * 5 + 75 + stake_width + 15, -20])
        stake_piece_2d(slot_from_top = false);
}

// Displays flatpack sheets
module flatpack_layout() {
    // Generously expanded vertical sheet spacing to prevent any overlapping between sheets
    spacing_y = beacon_height + stake_length + r_cap * 2 + 80;
    
    if (beacon_select == "all") {
        translate([0, spacing_y * 0]) {
            // Label N sheet
            flatpack_single_beacon("N");
        }
        translate([0, -spacing_y * 1]) {
            // Label S sheet
            flatpack_single_beacon("S");
        }
        translate([0, -spacing_y * 2]) {
            // Label E sheet
            flatpack_single_beacon("E");
        }
        translate([0, -spacing_y * 3]) {
            // Label O sheet
            flatpack_single_beacon("O");
        }
    } else {
        flatpack_single_beacon(beacon_select);
    }
}


// --- MAIN ENTRY POINT ---

if (mode == "assembled") {
    all_beacons_assembly();
} else if (mode == "flatpack") {
    flatpack_layout();
}
