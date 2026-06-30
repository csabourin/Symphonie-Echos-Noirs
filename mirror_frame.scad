/**
 * Parametric Mirror Frame for 3.5mm Plexiglass
 * Designed for Laser-Cut Layers or 3D Printing
 *
 * Inspired by the "Symphonie Echos Noirs" hardware suite.
 * This mirror frame coordinates in height, style, and fabrication
 * technique with the hexagonal beacons and municipal lantern.
 *
 * It is designed symmetrically and incorporates a solid backplate,
 * spacer layers accommodating a 3.5mm plexiglass mirror, a display bezel,
 * and a modular interlocking desk base stand.
 *
 * Author: GitHub Copilot
 * Date: May 2026
 */

/* [Display Settings] */
// Mode: "assembled" for 3D preview, "flatpack" for 2D laser-cut nesting layout
mode = "flatpack"; // ["assembled", "flatpack"]

// Toggle rendering of the plexiglass mirror itself in 3D preview
show_mirror = true;

// Exploded view (assembled mode only): separation gap (mm) inserted between each
// layer along the stack axis, in true assembly order. 0 = fully assembled;
// try 15-25 to see how the layers stack for glue-up. Has no effect in flatpack.
explode = 0; // [0:1:60]

/* [Material & Fabrication Parameters] */
// Wood sheet thickness (mm) - matching the beacons/lantern sheets
wood_thickness = 2.8; 

// Laser beam width compensation (mm). Slots are reduced by this amount for a tight press-fit.
laser_kerf = 0.15;

// Tolerance/clearance for sliding parts and plexiglass socket (mm)
tolerance = 0.15;

/* [Mirror Dimensions] */
// Total height of the mirror outer frame (mm) - scaled relative to the 160mm lantern
frame_height = 215.0;

// Total width of the mirror outer frame (mm)
frame_width = 160.0;

// Visible mirror opening width at the front bezel (mm)
inner_width = 110.0;

// Visible mirror opening height at the front bezel (mm)
inner_height = 165.0;

// Plexiglass mirror plate thickness (mm)
plexiglass_thickness = 3.5;

// Pocket seat overlap/bezel margin supporting the plexiglass (mm)
pocket_overlap = 6.0;

/* [Frame Aesthetics & Styling] */
// Outer corner rounding radius (mm) - gives the organic/rounded-octagon look
outer_roundness = 25.0;

// Inner opening corner rounding radius (mm)
inner_roundness = 15.0;

// octagon flat-to-diagonal flattening ratio (0 = rounded rectangle, 1 = regular octagon)
octagon_facets_factor = 0.45;

/* [Alignment & Assembly Features] */
// Toggle alignment pin/screw holes to register layers during glue-up
use_alignment_holes = true;

// Diameter of registration pins/screws (mm) e.g., 3mm for M3 bolts or dowels
alignment_hole_dia = 3.0;

// Edge margin for placing registration holes (mm)
alignment_hole_margin = 11.0;

/* [UV LED Parameters] */
// Pass-through hole diameter for front bezel and standard spacers (LED lens + shaft)
led_front_dia = 5.2;

// Seating cavity diameter in the electronics spacer (clears LED collar/flange)
led_seat_dia = 6.5;

// Wire channel width in the electronics spacer (mm)
led_wire_w = 2.0;

/* [Front Decorative Overlay / Texture Layer] */
// Add a smaller top-most bezel layer that covers the alignment holes and adds texture
include_decor_overlay = true;

// Material thickness for the decorative overlay (mm). Usually same as wood_thickness.
decor_thickness = 2.8;

// Inset from outer frame edge (mm) - makes this layer smaller than outer frame
decor_outer_inset = 6.0;

// Outset from inner opening edge (mm) - makes its inner opening larger than inner opening
decor_inner_outset = 6.0;

/* [Stand / Base Parameters] */
// Whether to include a slide-in desk stand/base in 3D assembly and flatpack
include_stand = true;

// Angle at which the mirror tilts backward when resting in the base (degrees) - e.g. 10 or 15 degrees for comfortable desktop viewing on a table
tilt_angle = -12; // [5:25]

/* [Battery Cover] */
// Render the battery cover in the 3D assembled preview
show_battery_cover = true;

// Depth of the cover box — how far it protrudes from the back plate (mm)
batt_cover_depth = 21.0;

// Finger tabs across the 100 mm width edges
batt_tab_nw = 5;

// Finger tabs across the 21 mm depth edges
batt_tab_nd = 3;

// Finger tabs across the 21.7 mm height edges
batt_tab_nh = 2;

// USB Micro port slot width in the depth direction (mm)
usb_w = 12.0;

// USB Micro port slot height in the panel-height direction (mm)
usb_h = 7.0;

/* [Calculated Constants] */
$fn = 60;

// Battery pocket global dimensions (shared with battery_cover_3d)
batt_pocket_w = 100.00;
batt_pocket_h = 21.7;
batt_pocket_y = -frame_height/2 + 57;

// Width of the plexiglass mirror plate (with tolerance)
plex_w_slot = inner_width + 2 * pocket_overlap + tolerance;
plex_h_slot = inner_height + 2 * pocket_overlap + tolerance;

// Spacer layers seating the plexiglass mirror.
// Each wood sheet is wood_thickness (e.g. 2.8mm). We use FLOOR so the spacer
// pocket is thinner than the plate, leaving the mirror proud of the wood:
//   floor(3.5 / 2.8) = 1 spacer (2.8mm pocket) -> plate stands 0.7mm proud.
// max(1, ...) guards against a 0-spacer pocket for very thin plates.
num_spacer_layers = max(1, floor(plexiglass_thickness / wood_thickness));

// How far the plate protrudes past the front face of the spacer stack (mm).
plexiglass_proud = plexiglass_thickness - num_spacer_layers * wood_thickness;

// Total thickness of the mirror assembly frame.
// Because the plate is proud, the mirror (not the spacer ring) drives the height
// of the middle region, so the front bezel rests on the plate:
//   back + plate + front + optional decor overlay.
total_frame_thickness = 2 * wood_thickness + plexiglass_thickness + (include_decor_overlay ? decor_thickness : 0);

// Stand dimensions
stand_width = 140.0;
stand_depth = 80.0;
stand_bracket_h = 50.0;
stand_bracket_w = 70.0;
stand_tab_w = 30.0;
bracket_spacing = frame_width * 0.55; // adaptive bracket spacing

// Places children at each of the three UV LED positions (top, left, right).
// LEDs are positioned 4mm past the plexiglass pocket edge, within the solid frame rails.
module at_led_positions() {
    translate([0,                  plex_h_slot/2 + 4]) children(); // top
    translate([-(plex_w_slot/2 + 4), 0            ]) children(); // left
    translate([ plex_w_slot/2 + 4,  0            ]) children(); // right
}

// 6.5mm seating cavity: seats LED collar in the electronics spacer
module led_seat_holes() { at_led_positions() circle(d = led_seat_dia); }

// 5.2mm pass-through: LED shaft through standard spacers, lens through front bezel
module led_front_holes() { at_led_positions() circle(d = led_front_dia); }

// Electronics spacer layer: LED seating cavities only.
// Wire routing is handled by the back plate (no octagon-corner conflicts there).
module electronics_spacer_layer_2d() {
    difference() {
        outer_oct_profile();
        plex_pocket_profile();
        if (use_alignment_holes) alignment_holes();
        led_seat_holes();
    }
}

// Small pass-through holes in the back plate for LED leads (one per LED)
module led_wire_holes() {
    at_led_positions() circle(d = 3.0);
}

// Wire channels cut through the back plate.
// The back plate has no plexiglass pocket, so channels can cross the centre freely.
// Layout: two horizontal branches from the side LEDs meet the top LED's vertical
// trunk at x=0 / y=0, then the trunk continues down to the battery pocket.
module back_plate_wire_channels() {
    cw     = led_wire_w;
    lx     = -(plex_w_slot/2 + 4);
    rx     =   plex_w_slot/2 + 4;
    ty     =   plex_h_slot/2 + 4;
    batt_y = -frame_height/2 + 57;

    // Vertical trunk: top LED → battery pocket (x=0, safe on solid back plate)
    translate([0, (ty + batt_y) / 2])
        square([cw, ty - batt_y], center = true);
    // Left LED → trunk junction at x=0, y=0
    translate([lx / 2, 0])
        square([abs(lx), cw], center = true);
    // Right LED → trunk junction at x=0, y=0
    translate([rx / 2, 0])
        square([rx, cw], center = true);
}

// Back plate with optional battery pocket, LED wire holes and routing channels
module back_plate_2d(battery = false) {
    difference() {
        outer_oct_profile();
        if (use_alignment_holes) alignment_holes();
        if (battery) battery_pocket();
        if (battery) led_wire_holes();
        if (battery) back_plate_wire_channels();
    }
}

// Battery pocket for 3xAAA holder.
// Raised 42mm above the frame bottom so the bracket slot zone (bottom 30mm)
// and a 12mm safety margin stay as solid wood.
module battery_pocket() {
    translate([0, batt_pocket_y])
        square([batt_pocket_w, batt_pocket_h], center=true);
}

// ---- Battery Cover: laser-cut finger-joint box (5 panels) ----
// Coordinate convention for 2D panel modules:
//   batt_cover_back_2d      — origin at bottom-left of base rect; tabs protrude outward
//   batt_cover_top_bottom_2d — origin at front-left (Y=0 = open face, Y=D = back)
//   batt_cover_side_2d      — origin at bottom-front (X=0 = bottom, Y=0 = open face)

// Back (closed-end) panel: W × H with finger tabs on all 4 edges.
module batt_cover_back_2d() {
    W = batt_pocket_w; H = batt_pocket_h; t = wood_thickness;
    nw = batt_tab_nw; nh = batt_tab_nh;
    sw = W / (2*nw - 1); sh = H / (2*nh - 1);
    union() {
        square([W, H]);
        for (i = [0:nw-1]) {
            translate([i*2*sw, H])  square([sw, t]);  // top tabs
            translate([i*2*sw, -t]) square([sw, t]);  // bottom tabs
        }
        for (i = [0:nh-1]) {
            translate([W,  i*2*sh]) square([t, sh]);  // right tabs
            translate([-t, i*2*sh]) square([t, sh]);  // left tabs
        }
    }
}

// Top or bottom panel: W × D with short-edge tabs (L/R) and back-edge slots.
module batt_cover_top_bottom_2d() {
    W = batt_pocket_w; D = batt_cover_depth; t = wood_thickness;
    nw = batt_tab_nw; nd = batt_tab_nd;
    sw = W / (2*nw - 1); sd = (D - t) / (2*nd - 1);
    difference() {
        union() {
            square([W, D]);
            for (i = [0:nd-2]) {
                translate([-t, (i*2 + 1)*sd]) square([t, sd]);  // left tabs
                translate([W,  (i*2 + 1)*sd]) square([t, sd]);  // right tabs
            }
        }
        // Back-edge slots receive back panel's top/bottom tabs
        for (i = [0:nw-1])
            translate([i*2*sw, D - t]) square([sw, t + 0.1]);
    }
}

// Left or right side panel: Oh × D with slots on all three joined edges.
// Oh = H + 2*t (outer height including top/bottom wall thickness).
// with_usb=true cuts the USB Micro port slot in the top-left corner of the face.
module batt_cover_side_2d(with_usb = false) {
    H = batt_pocket_h; D = batt_cover_depth; t = wood_thickness;
    nd = batt_tab_nd; nh = batt_tab_nh;
    sd = (D - t) / (2*nd - 1); sh = H / (2*nh - 1);
    Oh = H + 2*t;
    difference() {
        square([Oh, D]);
        // Top-shoulder slots for top panel's short-edge tabs
        for (i = [0:nd-2])
            translate([Oh - t, (i*2 + 1)*sd]) square([t + 0.1, sd]);
        // Bottom-shoulder slots for bottom panel's short-edge tabs
        for (i = [0:nd-2])
            translate([-0.1, (i*2 + 1)*sd]) square([t + 0.1, sd]);
        // Back-edge slots for back panel's left/right tabs
        for (i = [0:nh-1])
            translate([t + i*2*sh, D - t]) square([sh, t + 0.1]);
        // USB Micro port slot: top-left corner of face (near top, near open face)
        if (with_usb)
            translate([Oh - t - usb_h - 2, 2]) square([usb_h, usb_w]);
    }
}

// Simplified 3D preview assembled from the 5 laser-cut panels.
// Open face at Z=0 (flush with back plate); box extends to Z = -batt_cover_depth.
module battery_cover_3d() {
    W = batt_pocket_w; H = batt_pocket_h; D = batt_cover_depth; t = wood_thickness;
    Oh = H + 2*t;
    translate([-W/2, -H/2, 0]) {
        // Back wall
        translate([0, 0, -D])           linear_extrude(t) square([W, H]);
        // Top wall
        translate([0, H, -D])           rotate([-90, 0, 0]) linear_extrude(t) square([W, D]);
        // Bottom wall
        translate([0, -t, -D])          rotate([-90, 0, 0]) linear_extrude(t) square([W, D]);
        // Left wall (with USB-C slot in 3D preview)
        translate([-t, -t, -D])         rotate([0, 90, 0])  linear_extrude(t) square([D, Oh]);
        // Right wall
        translate([W, -t, -D])          rotate([0, 90, 0])  linear_extrude(t) square([D, Oh]);
    }
}

// =========================================================================
// Main Execution / Selector
// =========================================================================
if (mode == "flatpack") {
    flatpack_layout();
} else {
    assembly_3d();
}

// =========================================================================
// 3D Assembly Module
// =========================================================================
module assembly_3d() {
    // We position the bottom of the mirror stand at Z = 0
    if (include_stand) {
        // Base plate on the table
        color("Sienna") 
            linear_extrude(height = wood_thickness) 
                stand_base_2d();
        
        // Two vertical bracket supports
        for (i = [-1, 1]) {
            translate([i * bracket_spacing / 2, 0, wood_thickness]) {
                // Flip the bracket 180 degrees around Z to match the mirror's tilt
                rotate([90, 0, 270]) {
                    color("BurlyWood")
                        linear_extrude(height = wood_thickness, center = true)
                            stand_bracket_2d();
                }
            }
        }
    }
    
    // Position of mirror frame relative to the stand slots
    // The slot entry bottom is at stand_bracket_h - 22 above the base card
    slot_bottom_z = wood_thickness + stand_bracket_h - 22;
    
    // Estimate center of gravity offset: move mirror forward so its center is above the base
    cg_offset = -frame_height/2 * sin(tilt_angle * PI/180) * 0.7; // 0.7 fudge factor for wood/plexi density
    translate([cg_offset, 0, slot_bottom_z]) {
        // Rotate 90 degrees around X to stand upright, then add the tilt angle
        rotate([90 + tilt_angle, 0, 0]) {
            // Translate the frame so its bottom edge (local Y = -frame_height/2)
            // rests exactly at the bottom of the bracket slots (Z = slot_bottom_z)
            translate([0, frame_height / 2, -total_frame_thickness / 2]) {
                
                // --- Mirror Stack Assembly (relative to frame center) ---
                // In exploded view each layer is shifted along +Z by `explode` times
                // its position in the stacking order, so the glue-up sequence reads
                // back -> spacers -> mirror -> bezel -> overlay. With explode = 0 the
                // offsets collapse to the original assembled positions.

                // 1. Back Plate (Z = 0 of the frame stack)
                color("Sienna")
                    linear_extrude(height = wood_thickness)
                        back_plate_2d(true);

                // Battery cover (3D printed, protrudes from the back plate outward).
                // Explode pushes it further out the back (away from the stack).
                if (show_battery_cover) {
                    translate([0, batt_pocket_y, -explode * 1.5])
                        color("DimGray", 0.9)
                        battery_cover_3d();
                }

                // 2. Electronics spacer (first spacer, on top of back plate)
                translate([0, 0, wood_thickness + explode * 1]) {
                    color("SlateGray")
                        linear_extrude(height = wood_thickness)
                        electronics_spacer_layer_2d();
                }

                // 3. Remaining standard spacers (only when more than one spacer layer)
                if (num_spacer_layers >= 2) {
                    for (l = [2 : num_spacer_layers]) {
                        translate([0, 0, l * wood_thickness + explode * l]) {
                            color("Chocolate")
                                linear_extrude(height = wood_thickness)
                                spacer_layer_2d();
                        }
                    }
                }

                // 4. Plexiglass Mirror (semi-transparent light-blue preview).
                // Lifted just above the spacer stack when exploded so it reads as
                // dropping into the pocket.
                if (show_mirror) {
                    translate([0, 0, wood_thickness + explode * (num_spacer_layers + 0.7)]) {
                        color("LightCyan", 0.6)
                            linear_extrude(height = plexiglass_thickness)
                            plexiglass_2d();
                    }
                }

                // 5. Front Bezel / Frame
                // Rests on the proud plate (top of mirror), not the spacer ring.
                translate([0, 0, wood_thickness + plexiglass_thickness + explode * (num_spacer_layers + 1.5)]) {
                    color("BurlyWood")
                        linear_extrude(height = wood_thickness)
                            front_plate_2d();
                }

                // 6. Front Decorative Overlay / Texture Layer (covers alignment holes)
                if (include_decor_overlay) {
                    translate([0, 0, wood_thickness + plexiglass_thickness + wood_thickness + explode * (num_spacer_layers + 2.5)]) {
                        color("SandyBrown")
                            linear_extrude(height = decor_thickness)
                            decor_plate_2d();
                    }
                }
            }
        }
    }
}

// =========================================================================
// Flatpack Nesting Layout (2D)
// =========================================================================
module flatpack_layout() {
    spacing_x = frame_width + 15.0;
    spacing_y = frame_height + 15.0;
    
    // Front Bezel Frame
    translate([0, 0]) {
        front_plate_2d();
    }
    
    // Electronics spacer (first)
    translate([spacing_x, 0]) {
        electronics_spacer_layer_2d();
    }
    // Remaining standard spacers (only when more than one spacer layer)
    if (num_spacer_layers >= 2) {
        for (i = [1 : num_spacer_layers - 1]) {
            translate([(i + 1) * spacing_x, 0]) {
                spacer_layer_2d();
            }
        }
    }

    // Front Decorative Overlay (nested in layout)
    if (include_decor_overlay) {
        translate([(num_spacer_layers + 1) * spacing_x, 0]) {
            decor_plate_2d();
        }
    }
    
    // Solid Back Plate with battery pocket
    translate([0, -spacing_y]) {
        back_plate_2d(true);
    }
    
    if (include_stand) {
        // Base plate
        translate([spacing_x, -spacing_y]) {
            stand_base_2d();
        }
        
        // Front & Back vertical brackets side-by-side
        translate([spacing_x * 2, -spacing_y]) {
            stand_bracket_2d();
        }
        translate([spacing_x * 2 + stand_bracket_w + 10, -spacing_y]) {
            stand_bracket_2d();
        }
    }

    // Plexiglass Mirror (nested in layout)
    translate([spacing_x * 3 + 30, -spacing_y]) {
        color("LightCyan") plexiglass_2d();
    }

    // Battery cover panels (row 3) — laser-cut finger-joint box
    // Offset each panel by wood_thickness so protruding tabs don't clip the origin
    t    = wood_thickness;
    Oh   = batt_pocket_h + 2*t;
    csp  = batt_pocket_w + 2*t + 15;  // column spacing for cover panels
    cy   = -2*spacing_y;              // row 3 Y origin

    // 1. Back panel (W × H, tabs on all sides)
    translate([t, cy + t])
        color("SandyBrown") batt_cover_back_2d();

    // 2. Top panel
    translate([csp + t, cy])
        color("BurlyWood") batt_cover_top_bottom_2d();

    // 3. Bottom panel
    translate([2*csp + t, cy])
        color("BurlyWood") batt_cover_top_bottom_2d();

    // 4. Left side panel (with USB-C slot)
    translate([3*csp, cy])
        color("Sienna") batt_cover_side_2d(true);

    // 5. Right side panel
    translate([3*csp + Oh + 15, cy])
        color("Sienna") batt_cover_side_2d(false);
}

// =========================================================================
// 2D Shape Components
// =========================================================================

// Front Frame (Bezel Layer) with visible opening cutout and LED pass-throughs
module front_plate_2d() {
    difference() {
        outer_oct_profile();
        inner_oct_profile();
        if (use_alignment_holes) alignment_holes();
        led_front_holes();
    }
}

// Front Decorative Overlay / Texture Layer (smaller, covers front holes for clean look and stepped texture)
module decor_plate_2d() {
    difference() {
        // Outer profile is inset slightly to create a stepped reveal
        rounded_octagon(
            w = frame_width - 2 * decor_outer_inset,
            h = frame_height - 2 * decor_outer_inset,
            factor = octagon_facets_factor,
            r_val = max(5, outer_roundness - decor_outer_inset)
        );
        // Inner opening is outset slightly to create an inner bevel effect
        rounded_octagon(
            w = inner_width + 2 * decor_inner_outset,
            h = inner_height + 2 * decor_inner_outset,
            factor = octagon_facets_factor,
            r_val = inner_roundness + decor_inner_outset
        );
    }
}

// Standard spacer: plexiglass pocket + 5.2mm holes for LED shaft passage
module spacer_layer_2d() {
    difference() {
        outer_oct_profile();
        plex_pocket_profile();
        if (use_alignment_holes) alignment_holes();
        led_front_holes();
    }
}

// Mirror Plexiglass itself (no holes, 2D outline)
module plexiglass_2d() {
    // Formed slightly smaller than pocket slots to enable easy fit
    rounded_octagon(
        w = inner_width + 2 * pocket_overlap - tolerance,
        h = inner_height + 2 * pocket_overlap - tolerance,
        factor = octagon_facets_factor,
        r_val = inner_roundness + pocket_overlap/2
    );
}

// Desk Stand Base plate (horizontal on table)
module stand_base_2d() {
    slot_w_with_tolerance = (total_frame_thickness + tolerance);
    difference() {
        // Rounded ellipse-like base
        offset(r = 10) {
            square([stand_width - 20, stand_depth - 20], center = true);
        }
        
        // Left Bracket Slot
        translate([-bracket_spacing / 2, 0]) {
            square([wood_thickness - laser_kerf, stand_tab_w - laser_kerf], center = true);
        }
        
        // Right Bracket Slot
        translate([bracket_spacing / 2, 0]) {
            square([wood_thickness - laser_kerf, stand_tab_w - laser_kerf], center = true);
        }
    }
}

// Desk Stand Vertical Bracket (with angled slot)
module stand_bracket_2d() {
    tab_thickness = wood_thickness;
    
    union() {
        // Main Bracket Body
        difference() {
            // Elegant rounded support bracket shape
            hull() {
                translate([-stand_bracket_w/2 + 8, 0]) 
                    square([stand_bracket_w - 16, 5]);
                translate([-stand_bracket_w/4, stand_bracket_h - 15]) 
                    circle(r = 15);
                translate([stand_bracket_w/4, stand_bracket_h - 15]) 
                    circle(r = 15);
            }
            
            // Angled Slot that grabs the assembled mirror frame
            // Positioned at the top of the bracket to receive the frame securely
            translate([0, stand_bracket_h - 22]) {
                rotate([0, 0, -tilt_angle]) {
                    // We widen the entry to let the frame slide in beautifully
                    translate([-total_frame_thickness/2, 0]) {
                        square([total_frame_thickness + tolerance, 30]);
                    }
                }
            }
        }
        
        // Lower Tab that locks into the stand base plate
        translate([-stand_tab_w/2, -wood_thickness]) {
            square([stand_tab_w, wood_thickness]);
        }
    }
}

// =========================================================================
// Geometry Primitives and Helpers
// =========================================================================

// 2D Outer Frame Shape
module outer_oct_profile() {
    rounded_octagon(
        w = frame_width,
        h = frame_height,
        factor = octagon_facets_factor,
        r_val = outer_roundness
    );
}

// 2D Front Opening / Bezel Cutout Shape
module inner_oct_profile() {
    rounded_octagon(
        w = inner_width,
        h = inner_height,
        factor = octagon_facets_factor,
        r_val = inner_roundness
    );
}

// 2D Plexiglass Seating Pocket Cutout Shape
module plex_pocket_profile() {
    rounded_octagon(
        w = plex_w_slot,
        h = plex_h_slot,
        factor = octagon_facets_factor,
        r_val = inner_roundness + pocket_overlap
    );
}

// Generates an elegant rounded octagon via inset-outset offset operations.
// Keeps bounds accurate to width and height parameters.
module rounded_octagon(w, h, factor, r_val) {
    offset(r = r_val) {
        offset(r = -r_val) {
            polygon(points = [
                [w * (1 - factor)/2, h/2],
                [w/2, h * (1 - factor)/2],
                [w/2, -h * (1 - factor)/2],
                [w * (1 - factor)/2, -h/2],
                [-w * (1 - factor)/2, -h/2],
                [-w/2, -h * (1 - factor)/2],
                [-w/2, h * (1 - factor)/2],
                [-w * (1 - factor)/2, h/2]
            ]);
        }
    }
}

// Distributes registration alignment pin holes around the perimeter
module alignment_holes() {
    r_hole = alignment_hole_dia / 2;
    hw = frame_width / 2 - alignment_hole_margin;
    hh = frame_height / 2 - alignment_hole_margin;
    
    // Top and Bottom center holes
    translate([0, hh]) circle(r = r_hole);
    translate([0, -hh]) circle(r = r_hole);
    
    // 4 Corner holes
    translate([hw, hh*0.5]) circle(r = r_hole);
    translate([-hw, hh*0.5]) circle(r = r_hole);
    translate([hw, -hh*0.5]) circle(r = r_hole);
    translate([-hw, -hh*0.5]) circle(r = r_hole);
}
