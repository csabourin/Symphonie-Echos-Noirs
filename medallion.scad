/**
 * Parametric Layered Medallion with Electronics Cavity
 * Designed for Laser-Cut Wood and Translucent Acrylic
 *
 * Flat profile design with a raised central tube.
 *
 * Dimensions:
 * - Cavity diameter: 52 mm (holds 16-LED NeoPixel ring, microcontroller, LiPo battery)
 * - Cavity thickness: 16-17 mm (automatically calculated using stacked wood layers)
 *
 * Authors: Antigravity & Christian Sabourin
 * Date: June 2026
 */

/* [Display Settings] */
// Mode: "assembled" for 3D preview, "exploded" for exploded assembly, "flatpack" for 2D laser-cut nesting layout
mode = "exploded"; // ["assembled", "exploded", "flatpack"]

// Separation distance in the exploded view (mm)
exploded_offset = 18.0; // [0.0:100.0]

// Show visual reference of the translucent diffuser lens in 3D preview
show_lens = true;

// Show internal electronics separator shelf in 3D preview
show_separator = true;

// Enable engravings in the 2D flatpack layout (set to false to output shapes only for cutting)
enable_flatpack_engraving = false;

/* [Material & Fabrication Parameters] */
// Wood sheet thickness (mm)
wood_thickness = 2.8; // [1.0:10.0]

// Translucent acrylic lens thickness (mm)
lens_thickness = 2.0; // [1.0:6.0]

// Laser beam width compensation (mm). Slots are reduced by this amount for a tight press-fit.
laser_kerf = 0.15; // [0.0:0.5]

/* [Medallion Dimensions] */
// Outer diameter of the flat medallion outer ring (mm)
outer_diameter = 100.0; // [80.0:150.0]

// Outer diameter of the raised central tube (mm)
center_tube_diameter = 58.0; // [45.0:80.0]

// Inner diameter of the cavity (mm)
cavity_diameter = 52.0; // [40.0:80.0]

// Target depth of the internal electronics cavity (mm)
cavity_depth = 16.5; // [10.0:30.0]

// Front plate opening diameter for the lens (mm)
lens_cutout_dia = 40.0; // [30.0:50.0]

/* [Hanging Loop Settings] */
// Outer diameter of the hanging loop (mm)
loop_outer_dia = 14.0; // [8.0:25.0]

// Inner diameter of the loop hole (mm)
loop_inner_dia = 6.0; // [4.0:15.0]

// Overlap of the loop with the medallion outer circle (mm)
loop_overlap = 2.5; // [1.0:5.0]

/* [Alignment Pins] */
// Enable alignment holes for assembly registration (only on the wide outer ring)
use_alignment_holes = true;

// Diameter of alignment pins/screws (mm)
alignment_pin_dia = 3.0; // [1.5:6.0]

// Distance of alignment pins from center (mm) - set to 0 for automatic centering in the outer ring wall
alignment_pin_dist_override = 0.0; 

/* [Side Port Openings] */
// Enable USB charging port cutout on the bottom side of the spacer layers
enable_usb_port = true;

// Width of the USB plug cutout (mm)
usb_width = 11.5; // [8.0:15.0]

// Height of the USB plug cutout (mm)
usb_height = 5.5; // [4.0:10.0]

// Distance of USB port center from the back cover (mm)
usb_z_offset = 8.0; // [2.0:15.0]

// Enable slide switch cutout on the left side of the spacer layers
enable_switch = true;

// Width of the switch cutout (mm)
switch_width = 9.5; // [6.0:15.0]

// Height of the switch cutout (mm)
switch_height = 4.5; // [3.0:8.0]

// Distance of switch center from the back cover (mm)
switch_z_offset = 8.0; // [2.0:15.0]

/* [Internal Separator Plate] */
// Spacer layer index (from back) where the separator plate sits (e.g., 2 means above spacer 2)
separator_layer_index = 2; // [1:6]

// Thickness of the separator plate (mm)
separator_thickness = 2.8; 

// Wire pass-through slot width (mm)
separator_slot_w = 12.0;

// Wire pass-through slot height (mm)
separator_slot_h = 4.0;


// --- GEOMETRIC INTERNALS & CALCULATIONS ---
$fn = 60; // Standard resolution rendering

// Calculate the number of spacer layers needed to meet or exceed cavity_depth + lens_thickness
num_spacers = ceil((cavity_depth + lens_thickness) / wood_thickness);

// Actual internal depth of the cavity (before lens is subtracted)
total_spacer_depth = num_spacers * wood_thickness;

// Center-to-center radius of the wall (where alignment pins are placed in the outer ring)
alignment_pin_dist = (alignment_pin_dist_override > 0) ? 
    alignment_pin_dist_override : 
    (center_tube_diameter / 2 + outer_diameter / 2) / 2;

// Offset of the loop center along the Y axis
loop_y_center = outer_diameter / 2 + loop_outer_dia / 2 - loop_overlap;

// Engraving depth in 3D preview (mm)
engraving_3d_depth = 0.4;


// =========================================================================
// Main Execution
// =========================================================================

if (mode == "assembled") {
    assembled_view(exploded = false);
} else if (mode == "exploded") {
    assembled_view(exploded = true);
} else if (mode == "flatpack") {
    // If in F5 preview mode, extrude by a tiny amount to bypass 2D CSG tree normalization limits
    if ($preview) {
        linear_extrude(height = 0.1)
            flatpack_layout();
    } else {
        flatpack_layout();
    }
}


// =========================================================================
// 3D Assembly & Exploded Layout
// =========================================================================
module assembled_view(exploded = false) {
    // Helper to calculate Z translation depending on mode
    function get_z(layer_idx, current_z) = 
        exploded ? (layer_idx * exploded_offset) : current_z;

    // 1. Back Plate (Layer 0, OD = outer_diameter)
    translate([0, 0, get_z(0, 0)]) {
        back_plate_3d();
    }
    
    // 2. Outer Bezel Ring (Layer 1, OD = outer_diameter, ID = center_tube_diameter)
    translate([0, 0, get_z(1, wood_thickness)]) {
        outer_bezel_3d();
    }
    
    // 3. Spacer Layers (Layers 1 to num_spacers)
    // Sits in the center (OD = center_tube_diameter, ID = cavity_diameter)
    for (i = [1 : num_spacers]) {
        z_pos = wood_thickness + (i - 1) * wood_thickness;
        translate([0, 0, get_z(i + 1, z_pos)]) {
            spacer_layer_3d(i);
        }
    }
    
    // 4. Optional Separator Shelf (sits inside cavity, usually between spacer 2 and 3)
    if (show_separator) {
        z_pos_sep = wood_thickness + separator_layer_index * wood_thickness;
        z_pos_exp = (separator_layer_index + 1.5) * exploded_offset;
        translate([0, 0, exploded ? z_pos_exp : z_pos_sep]) {
            separator_plate_3d();
        }
    }
    
    // 5. Translucent Lens (sits recessed inside the top of the spacer cavity)
    if (show_lens) {
        z_pos_lens = wood_thickness + total_spacer_depth - lens_thickness;
        z_pos_exp = (num_spacers + 1.5) * exploded_offset;
        translate([0, 0, exploded ? z_pos_exp : z_pos_lens]) {
            lens_3d();
        }
    }
    
    // 6. Front Cap of the tube (OD = center_tube_diameter, ID = lens_cutout_dia)
    z_pos_front = wood_thickness + total_spacer_depth;
    translate([0, 0, get_z(num_spacers + 2, z_pos_front)]) {
        front_cap_3d();
    }
}


// =========================================================================
// 3D Part Wrappers (adding thickness and realistic rendering colors)
// =========================================================================

module back_plate_3d() {
    difference() {
        color("BurlyWood")
            linear_extrude(height = wood_thickness)
                back_plate_2d(only_cut = true);
        
        // Subtract engraving on the bottom face (visible when rotating model)
        translate([0, 0, -0.05]) {
            color("SaddleBrown")
                linear_extrude(height = engraving_3d_depth + 0.05)
                    back_plate_engraving_2d();
        }
    }
}

module outer_bezel_3d() {
    difference() {
        color("BurlyWood")
            linear_extrude(height = wood_thickness)
                outer_bezel_2d(only_cut = true);
        
        // Subtract engraving on the top face
        translate([0, 0, wood_thickness - engraving_3d_depth]) {
            color("SaddleBrown")
                linear_extrude(height = engraving_3d_depth + 0.05)
                    outer_bezel_engraving_2d();
        }
    }
}

module spacer_layer_3d(layer_idx) {
    color("SandyBrown")
        linear_extrude(height = wood_thickness)
            spacer_layer_2d(layer_idx);
}

module separator_plate_3d() {
    color("Sienna")
        linear_extrude(height = separator_thickness)
            separator_plate_2d();
}

module lens_3d() {
    color("GhostWhite", 0.7) // Semi-transparent white
        linear_extrude(height = lens_thickness)
            lens_2d();
}

module front_cap_3d() {
    color("BurlyWood")
        linear_extrude(height = wood_thickness)
            front_cap_2d();
}


// =========================================================================
// 2D Shapes (Used for both 3D extrusion and 2D flatpack export)
// =========================================================================

// Main profile shape sharing a clean union of circle + top loop
module outer_profile_2d(layer_od, has_loop = true) {
    r_out = layer_od / 2;
    union() {
        circle(r = r_out);
        if (has_loop) {
            translate([0, loop_y_center]) {
                circle(d = loop_outer_dia, $fn = 60);
            }
        }
    }
}

// Inner hanging hole in the loop
module loop_hole_2d() {
    translate([0, loop_y_center]) {
        circle(d = loop_inner_dia - laser_kerf, $fn = 40);
    }
}

// Alignment registration holes (positioned to avoid the 6 front glyphs)
module alignment_holes_2d() {
    r_pin = (alignment_pin_dia - laser_kerf) / 2;
    // Align at 45, 135, 225, 315 degrees to sit perfectly between glyphs
    for (a = [45, 135, 225, 315]) {
        rotate(a) translate([alignment_pin_dist, 0]) {
            circle(r = r_pin, $fn = 30);
        }
    }
}

// Back Plate (solid circular backing of full diameter)
module back_plate_2d(only_cut = false) {
    difference() {
        outer_profile_2d(outer_diameter, has_loop = true);
        loop_hole_2d();
        if (use_alignment_holes) {
            alignment_holes_2d();
        }
        if (!only_cut) {
            back_plate_engraving_2d();
        }
    }
}

// Mystical engraving pattern for the back plate
module back_plate_engraving_2d() {
    scale_factor = outer_diameter / 70.0;
    scale(scale_factor) {
        // 1. Concentric circles (optimized segments)
        difference() {
            circle(r = 24.0, $fn = 40);
            circle(r = 23.4, $fn = 40);
        }
        difference() {
            circle(r = 14.0, $fn = 40);
            circle(r = 13.4, $fn = 40);
        }
        
        // 2. Astronomical cross lines
        square([0.6, 48.0], center = true);
        square([48.0, 0.6], center = true);
        
        // 3. Diagonal markers and nodes
        for (a = [45, 135, 225, 315]) {
            rotate(a) {
                translate([19.0, 0]) square([6.0, 0.6], center = true);
                translate([10.0, 0]) circle(r = 0.8, $fn = 12);
            }
        }
        
        // 4. Center emblem glyph
        scale(1.2) {
            draw_glyph(4);
        }
    }
}

// Outer Bezel Ring (Layer 1, wide flat ring containing the main engraving)
module outer_bezel_2d(only_cut = false) {
    difference() {
        outer_profile_2d(outer_diameter, has_loop = true);
        
        // Inner cutout for the central tube to pass through
        circle(d = center_tube_diameter, $fn = 120);
        
        loop_hole_2d();
        if (use_alignment_holes) {
            alignment_holes_2d();
        }
        if (!only_cut) {
            outer_bezel_engraving_2d();
        }
    }
}

// Engraving for the wide outer ring bezel
module outer_bezel_engraving_2d() {
    bezel_inner_r = center_tube_diameter / 2;
    bezel_outer_r = outer_diameter / 2;
    bezel_width = bezel_outer_r - bezel_inner_r;
    
    // Scale factor based on the wide bezel width (normalized to original 15mm width)
    scale_factor = bezel_width / 15.0;
    
    // 1. Concentric grooves around the bezel
    r_start = bezel_inner_r + 3.0 * scale_factor;
    r_step = 1.2 * scale_factor;
    for (i = [0 : 3]) {
        difference() {
            circle(r = r_start + i * r_step + 0.25, $fn = 60);
            circle(r = r_start + i * r_step - 0.25, $fn = 60);
        }
    }
    
    // 2. Six outer circular node frames housing unique glyphs
    // Placed at 60-degree increments starting from 90 (top)
    node_dist = bezel_inner_r + bezel_width * 0.55;
    node_r = 5.2 * scale_factor;
    
    for (i = [0 : 5]) {
        angle = i * 60 + 90;
        rotate(angle) {
            translate([node_dist, 0]) {
                // Circle border
                difference() {
                    circle(r = node_r, $fn = 24);
                    circle(r = node_r - 0.45 * scale_factor, $fn = 24);
                }
                
                // Geometric Glyph
                scale(node_r * 0.16) {
                    draw_glyph(i);
                }
            }
        }
    }
}

// Spacer Rings (Z-stacked, OD = center_tube_diameter, ID = cavity_diameter)
module spacer_layer_2d(layer_idx) {
    difference() {
        outer_profile_2d(center_tube_diameter, has_loop = false);
        
        // Inner electronics cavity (plus kerf correction)
        circle(d = cavity_diameter, $fn = 120);
        
        // Port cutouts (applied to specific layers based on Z-height)
        z_start = (layer_idx - 1) * wood_thickness;
        z_end = layer_idx * wood_thickness;
        
        // USB port cutout (placed at the bottom: Y = -center_tube_diameter/2)
        if (enable_usb_port && (z_start < usb_z_offset + usb_height / 2) && (z_end > usb_z_offset - usb_height / 2)) {
            translate([-usb_width / 2, -center_tube_diameter / 2 - 2]) {
                square([usb_width, center_tube_diameter / 2 - cavity_diameter / 2 + 4]);
            }
        }
        
        // Slide switch cutout (placed at the left: X = -center_tube_diameter/2)
        if (enable_switch && (z_start < switch_z_offset + switch_height / 2) && (z_end > switch_z_offset - switch_height / 2)) {
            translate([-center_tube_diameter / 2 - 2, -switch_width / 2]) {
                square([center_tube_diameter / 2 - cavity_diameter / 2 + 4, switch_width]);
            }
        }
    }
}

// Internal Separator Plate (optional shelf to hold PCBs above LiPo battery)
module separator_plate_2d() {
    difference() {
        // Sized slightly smaller than cavity diameter for sliding fit
        circle(d = cavity_diameter - 0.4, $fn = 120);
        
        // Wire pass-through slot 1 (Top)
        translate([0, cavity_diameter / 2 - 8.0]) {
            square([separator_slot_w, separator_slot_h], center = true);
        }
        
        // Wire pass-through slot 2 (Bottom)
        translate([0, -cavity_diameter / 2 + 8.0]) {
            square([separator_slot_w, separator_slot_h], center = true);
        }
        
        // Central hole to clear bottom-side components of a microcontroller
        circle(d = 16.0, $fn = 40);
    }
}

// Translucent lens (for white acrylic or paper diffuser)
module lens_2d() {
    // Sized for a snug fit inside the 52mm cavity
    circle(d = cavity_diameter - 0.2, $fn = 120);
}

// Front Cap of the tube (OD = center_tube_diameter, ID = lens_cutout_dia)
module front_cap_2d(only_cut = false) {
    difference() {
        outer_profile_2d(center_tube_diameter, has_loop = false);
        circle(d = lens_cutout_dia, $fn = 120);
        
        if (!only_cut) {
            // Central ring of runes surrounding the lens opening
            rune_radius = (lens_cutout_dia / 2) + 2.4;
            rune_count = 18;
            for (i = [0 : rune_count - 1]) {
                angle = i * (360 / rune_count) + 10;
                rotate(angle) {
                    translate([rune_radius, 0]) {
                        rotate(-90) scale(0.42) {
                            draw_mini_rune(i % 6);
                        }
                    }
                }
            }
        }
    }
}


// =========================================================================
// Geometric Rune Generators (Vector lines built from 2D primitives)
// =========================================================================

module draw_glyph(type) {
    if (type == 0) {
        // Celestial cross and circle (Top)
        circle(r = 2.4, $fn = 12);
        difference() {
            circle(r = 2.4, $fn = 12);
            circle(r = 1.8, $fn = 12);
        }
        square([0.8, 8.0], center = true);
        square([8.0, 0.8], center = true);
        for(a = [45, 135, 225, 315]) {
            rotate(a) translate([2.4, 0]) square([2.0, 0.6], center = true);
        }
    } else if (type == 1) {
        // Rune of Will: Triangle intersected by vertical staff (Top-Right)
        difference() {
            polygon([[0, 4.0], [-3.5, -2.2], [3.5, -2.2]]);
            polygon([[0, 2.3], [-2.1, -1.5], [2.1, -1.5]]);
        }
        square([0.8, 8.0], center = true);
        translate([0, 1.0]) square([4.0, 0.6], center = true);
        translate([0, -1.0]) square([4.0, 0.6], center = true);
    } else if (type == 2) {
        // Rune of Flow: Interlocking nodes (Bottom-Right)
        for(a = [0, 120, 240]) {
            rotate(a) {
                translate([0, 1.8]) circle(r = 1.1, $fn = 10);
                translate([0.5, 0.5]) square([0.7, 2.4], center = true);
                translate([1.1, 1.8]) square([1.8, 0.7], center = true);
            }
        }
        circle(r = 0.8, $fn = 10);
    } else if (type == 3) {
        // Rune of Earth: Concentric diamonds with crossbars (Bottom)
        rotate(45) {
            difference() {
                square([5.4, 5.4], center = true);
                square([4.2, 4.2], center = true);
            }
            difference() {
                square([2.8, 2.8], center = true);
                square([1.6, 1.6], center = true);
            }
        }
        square([0.8, 7.5], center = true);
        square([7.5, 0.8], center = true);
    } else if (type == 4) {
        // Rune of Spirit: Star structure with outer orbiting nodes (Bottom-Left)
        difference() {
            union() {
                polygon([[0, 3.8], [-3.3, -1.9], [3.3, -1.9]]);
                rotate(180) polygon([[0, 3.8], [-3.3, -1.9], [3.3, -1.9]]);
            }
            circle(r = 1.8, $fn = 12);
        }
        circle(r = 1.0, $fn = 12);
        for(a = [0 : 60 : 300]) {
            rotate(a) translate([2.4, 0]) circle(r = 0.6, $fn = 8);
        }
    } else if (type == 5) {
        // Rune of Growth: Branching tree rune (Top-Left)
        square([1.0, 8.0], center = true);
        for(y = [0.5, 2.2]) {
            translate([0, y]) rotate(30) translate([2.0, 0]) square([4.0, 0.7], center = true);
            translate([0, y]) rotate(-30) translate([-2.0, 0]) square([4.0, 0.7], center = true);
        }
        translate([0, -1.5]) rotate(30) translate([2.0, 0]) square([4.0, 0.7], center = true);
        translate([0, -1.5]) rotate(-30) translate([-2.0, 0]) square([4.0, 0.7], center = true);
    }
}

module draw_mini_rune(type) {
    if (type == 0) {
        // X with vertical bar (Gibo/Hagl)
        square([0.8, 6.0], center = true);
        rotate(45) square([0.8, 5.0], center = true);
        rotate(-45) square([0.8, 5.0], center = true);
    } else if (type == 1) {
        // Arrow pointing up (Tiwaz)
        square([0.8, 6.0], center = true);
        translate([0, 1.5]) rotate(45) translate([-1.2, 0]) square([2.4, 0.8], center = true);
        translate([0, 1.5]) rotate(-45) translate([1.2, 0]) square([2.4, 0.8], center = true);
    } else if (type == 2) {
        // Dagaz (Hourglass symbol)
        difference() {
            union() {
                polygon([[-1.8, -2.5], [1.8, -2.5], [-1.8, 2.5], [1.8, 2.5]]);
                square([0.8, 5.0], center = true);
            }
            polygon([[-1.0, -1.6], [1.0, -1.6], [0, 0]]);
            polygon([[-1.0, 1.6], [1.0, 1.6], [0, 0]]);
        }
    } else if (type == 3) {
        // Ingwaz (Diamond)
        rotate(45) difference() {
            square([3.6, 3.6], center = true);
            square([2.2, 2.2], center = true);
        }
    } else if (type == 4) {
        // Algiz (Three-pronged fork)
        square([0.8, 6.0], center = true);
        translate([0, 1.0]) {
            rotate(45) translate([1.2, 0]) square([2.4, 0.8], center = true);
            rotate(-45) translate([-1.2, 0]) square([2.4, 0.8], center = true);
        }
    } else if (type == 5) {
        // Sowilo (Lightning bolt/zigzag)
        translate([-0.8, 1.8]) rotate(-45) square([2.4, 0.8], center = true);
        rotate(45) square([2.4, 0.8], center = true);
        translate([0.8, -1.8]) rotate(-45) square([2.4, 0.8], center = true);
    }
}


// =========================================================================
// 2D Flatpack Nesting Layout (Grid-based alignment of all parts)
// =========================================================================
module flatpack_layout() {
    part_spacing_x = outer_diameter + 12.0;
    part_spacing_y = outer_diameter + loop_outer_dia - loop_overlap + 12.0;
    
    only_cut = !enable_flatpack_engraving;
    
    // Row 0: Large components
    // 1. Outer Bezel Ring (with engraving)
    translate([0, 0]) {
        outer_bezel_2d(only_cut = only_cut);
    }
    
    // 2. Back Plate
    translate([part_spacing_x, 0]) {
        back_plate_2d(only_cut = only_cut);
    }
    
    // 3. Diffuser lens (Acrylic)
    translate([part_spacing_x * 2, 0]) {
        color("GhostWhite") lens_2d();
    }
    
    // 4. Separator plate (Internal shelf)
    translate([part_spacing_x * 3, 0]) {
        color("Sienna") separator_plate_2d();
    }
    
    // Row 1: Central tube components
    // 1. Front Cap Ring
    translate([0, -part_spacing_y]) {
        front_cap_2d(only_cut = only_cut);
    }
    
    // Spacer rings in a clean grid starting next to Front Cap Ring
    for (i = [1 : num_spacers]) {
        col = i % 4;
        row = ceil(i / 4);
        
        translate([col * part_spacing_x, -part_spacing_y - row * part_spacing_y * 0.7]) {
            echo(str("Spacer Layer ", i, " at grid position (col: ", col, ", row: ", row, ")"));
            spacer_layer_2d(i);
        }
    }
}
