// =========================================================================
// Parametric Wooden Tuning Fork ("Diapason en bois")
// Designed for Laser Cutting (flat-pack) and 3D Assembly
// ===============================================================================

/* [Display Configuration] */
// Mode: "assembled" for 3D preview, "exploded" for exploded assembly, "flatpack" for 2D laser-cut nesting layout
mode = "assembled"; // ["assembled", "exploded", "flatpack"]

// Separation distance in the exploded view (mm)
exploded_offset = 20; // [0:100]

/* [Material & Fabrication Parameters] */
// Wood sheet thickness (mm)
thickness = 2.8; // [1.0:10.0]

// Laser beam width compensation / tolerance (mm). Slots are reduced by this amount for a tight press-fit.
tolerance = 0.15; // [0.0:0.5]

// Additional extension of tabs beyond slots for sanding flush (mm)
tab_extension = 0.5; // [0.0:2.0]

/* [Tuning Fork Dimensions] */
// Total thickness (height) of the tuning fork assembly (mm)
fork_height = 25.0; // [15.0:50.0]

// Length of the parallel prongs (tines) (mm)
prong_length = 120.0; // [50.0:200.0]

// Width of each prong (mm)
prong_width = 18.0; // [10.0:30.0]

// Distance between the prongs (mm)
prong_gap = 24.0; // [10.0:50.0]

// Length of the handle (mm) - sized to fit 2 AA batteries end-to-end
handle_length = 115.0; // [100.0:200.0]

// Width of the handle (mm) - sized to fit AA battery diameter
handle_width = 22.0; // [18.0:40.0]

// Radius of the pommel (circular end of handle) (mm)
pommel_radius = 16.0; // [12.0:30.0]

// Radius of the outer curve transitioning from handle to prongs (mm)
transition_radius = 25.0; // [15.0:50.0]

/* [Tab & Slot Parameters] */
// Length of each tab/slot (along the edge) (mm) - smaller tabs preferred
tab_length = 6.0; // [3.0:12.0]

// Number of tabs along each prong - more tabs for stability
num_tabs_prong = 5; // [3:10]

// Number of tabs along the handle straight section
num_tabs_handle = 4; // [2:8]

// Pommel type: "decorative" for circular stacked plates with flat closed handle end, "flat" for simple square handle end
pommel_type = "decorative"; // ["decorative", "flat"]

// Number of stacked horizontal spacers in the decorative pommel
num_spacers = 3; // [1:5]

// Spacing of the living hinge cuts (mm)
hinge_spacing = 2.2; // [1.0:5.0]

// --- GEOMETRIC INTERNALS & CALCULATIONS (Do not modify) ---
$fn = 60;

// Inner wall height (height of side panels)
inside_height = fork_height - 2 * thickness;

// Derived geometry constants
W_handle = handle_width / 2;
W_outer = prong_gap / 2 + prong_width;
W_cap = prong_width - 2 * thickness;
W_end_cap = handle_width - 2 * thickness;

// Calculate transition curve dy and alpha
dx = W_outer - W_handle;
dy = sqrt(dx * (4 * transition_radius - dx));
y2 = handle_length + dy;
cos_alpha = 1 - dx / (2 * transition_radius);
alpha = acos(cos_alpha);

// Calculate pommel arc angle theta_p
theta_p = acos(W_handle / pommel_radius);
y_intersect = pommel_radius - sqrt(pommel_radius * pommel_radius - W_handle * W_handle);

// Calculate flat wall lengths
L_prong = prong_length;
L_trans_up = transition_radius * alpha * PI / 180;
L_trans_low = transition_radius * alpha * PI / 180;
L_handle = handle_length - pommel_radius;

L_outer = L_prong + L_trans_up + L_trans_low + L_handle;

R_inner = prong_gap / 2;
L_yoke_inner = R_inner * PI;
L_inner = prong_length + L_yoke_inner + prong_length;

// Tab widths along the edge
tab_width = tab_length;

// Slot dimensions (with tolerance compensation)
slot_w = thickness - tolerance;
slot_l = tab_length - tolerance;

// --- UTILITIES ---

// Helper to generate a 2D arc of radius r, thickness t, from angle a1 to a2
module arc_2d(r, t, a1, a2) {
    steps = 30;
    pts_outer = [ for (i = [0:steps]) let(a = a1 + (i/steps)*(a2 - a1)) [ (r + t/2) * cos(a), (r + t/2) * sin(a) ] ];
    pts_inner = [ for (i = [0:steps]) let(a = a2 - (i/steps)*(a2 - a1)) [ (r - t/2) * cos(a), (r - t/2) * sin(a) ] ];
    polygon(concat(pts_outer, pts_inner));
}

// Staggered living hinge cut generator (subtracted from panels)
module living_hinge_cuts(L_hinge, H, spacing=2.0, bridge=3.0) {
    num_cols = floor(L_hinge / spacing);
    col_w = spacing;
    cut_w = 0.01; // Hairline cut (<0.025mm) so the laser software collapses it to a single pass
    overlap = 1.0; // Overlap to cleanly break the top/bottom panel boundaries
    
    for (c = [0 : num_cols - 1]) {
        let(x = c * col_w + col_w / 2) {
            if (c % 2 == 0) {
                // Pattern A: Two cuts with a central bridge, breaking bottom and top edges
                // Bottom cut: starts at -overlap, goes up to H/2 - bridge/2
                translate([x - cut_w/2, -overlap])
                square([cut_w, H/2 - bridge/2 + overlap]);
                
                // Top cut: starts at H/2 + bridge/2, goes up to H + overlap
                translate([x - cut_w/2, H/2 + bridge/2])
                square([cut_w, H/2 - bridge/2 + overlap]);
            } else {
                // Pattern B: One central cut, stopping before top/bottom edges
                translate([x - cut_w/2, bridge])
                square([cut_w, H - 2*bridge]);
            }
        }
    }
}

// --- 2D PROFILE GENERATION ---

// Generates the points for the right half of the tuning fork profile
function get_right_half_points(steps = 15) =
  let(
    // 1. Pommel boundary (flat end or circular flare)
    pommel_pts = (pommel_type == "flat") ? 
      [ [W_handle, pommel_radius], [0, pommel_radius] ] : 
      [ for (i = [0:steps]) let(t = -90 + (i/steps)*(90 - theta_p)) 
        [ pommel_radius * cos(t), pommel_radius + pommel_radius * sin(t) ] ],
      
    // 2. Handle straight: from pommel_radius to handle_length
    handle_pts = [ [W_handle, handle_length] ],
    
    // 3. Transition S-curve
    lower_trans = [ for (i = [0:steps]) let(t = 180 - (i/steps)*alpha) 
      [ W_handle + transition_radius + transition_radius * cos(t), handle_length + transition_radius * sin(t) ] ],
    upper_trans = [ for (i = [1:steps]) let(t = -alpha + (i/steps)*alpha) 
      [ W_outer - transition_radius + transition_radius * cos(t), y2 + transition_radius * sin(t) ] ],
      
    // 4. Prong outer straight
    prong_top_y = y2 + prong_length,
    prong_outer = [ [W_outer, prong_top_y] ],
    
    // 5. Prong top straight
    prong_top = [ [R_inner, prong_top_y] ],
    
    // 6. Prong inner straight
    prong_inner = [ [R_inner, y2] ],
    
    // 7. Inner yoke curve: semicircle of radius R_inner from theta = 0 to -90
    inner_yoke = [ for (i = [1:steps]) let(t = -(i/steps)*90)
      [ R_inner * cos(t), y2 + R_inner * sin(t) ] ]
  )
  concat(pommel_pts, handle_pts, lower_trans, upper_trans, prong_outer, prong_top, prong_inner, inner_yoke);

// Creates the full 2D silhouette of the tuning fork
module fork_2d_shape() {
    right_points = get_right_half_points(15);
    left_points = [ for (i = [1 : len(right_points)-2]) 
        let(p = right_points[len(right_points) - 1 - i]) [-p[0], p[1]] 
    ];
    polygon(concat(right_points, left_points));
}

// Places slot cutouts on the right half (curved/hinged sections are kept tab-free)
module right_half_slots() {
    // 1. Handle slots (straight section, from pommel_radius to handle_length)
    for (i = [0 : num_tabs_handle - 1]) {
        let(y = pommel_radius + (i + 0.5) * L_handle / num_tabs_handle)
        translate([W_handle - thickness/2, y])
        square([slot_w, slot_l], center=true);
    }
    
    // 2. Prong outer slots (straight section)
    for (i = [0 : num_tabs_prong - 1]) {
        let(y = y2 + (i + 0.5) * prong_length / num_tabs_prong)
        translate([W_outer - thickness/2, y])
        square([slot_w, slot_l], center=true);
    }
    
    // 3. Prong top slot (straight section)
    translate([R_inner + prong_width/2, y2 + prong_length - thickness/2])
    square([slot_l, slot_w], center=true);
    
    // 4. Prong inner slots (straight section)
    for (i = [0 : num_tabs_prong - 1]) {
        let(y = y2 + (i + 0.5) * prong_length / num_tabs_prong)
        translate([R_inner + thickness/2, y])
        square([slot_w, slot_l], center=true);
    }
}

// Places slot cutouts on both halves symmetrically
module all_slots() {
    right_half_slots();
    mirror([1, 0, 0]) right_half_slots();
    
    // Vertical end cap slot closing the handle box (at y = pommel_radius)
    translate([0, pommel_radius + thickness/2])
    square([slot_l, slot_w], center=true);
}

// --- 3D PART BUILDERS ---

// Helper for straight vertical walls with tabs
module vertical_wall_y(x, y_start, length, thickness, inside_h, tab_positions, tab_w, tab_ext) {
    // Main wall body
    translate([x - thickness/2, y_start, thickness])
    cube([thickness, length, inside_h]);
    
    // Tabs (bottom and top)
    for (y_t = tab_positions) {
        translate([x - thickness/2, y_t - tab_w/2, -tab_ext])
        cube([thickness, tab_w, thickness + tab_ext]);
        
        translate([x - thickness/2, y_t - tab_w/2, fork_height - thickness])
        cube([thickness, tab_w, thickness + tab_ext]);
    }
}

// Helper for curved tabs
module curved_tab(C, R, t, tab_w, thickness, tab_ext) {
    // Bottom tab
    translate(C)
    rotate(t)
    translate([R - thickness/2, -tab_w/2, -tab_ext])
    cube([thickness, tab_w, thickness + tab_ext]);
    
    // Top tab
    translate(C)
    rotate(t)
    translate([R - thickness/2, -tab_w/2, fork_height - thickness])
    cube([thickness, tab_w, thickness + tab_ext]);
}

// Renders the 3D model of one outer wall (right side, curved/hinged sections are tab-free)
module outer_wall_3d() {
    // 1. Prong outer straight
    prong_outer_tabs = [ for (i = [0:num_tabs_prong-1]) y2 + (i + 0.5) * prong_length / num_tabs_prong ];
    vertical_wall_y(W_outer, y2, prong_length, thickness, inside_height, prong_outer_tabs, tab_width, tab_extension);
    
    // 2. Upper transition curve (tab-free)
    translate([W_outer - transition_radius, y2, thickness])
    linear_extrude(height = inside_height)
    arc_2d(transition_radius - thickness/2, thickness, -alpha, 0);
    
    // 3. Lower transition curve (tab-free)
    translate([W_handle + transition_radius, handle_length, thickness])
    linear_extrude(height = inside_height)
    arc_2d(transition_radius + thickness/2, thickness, 180, 180 - alpha);
    
    // 4. Handle straight (from pommel_radius to handle_length)
    handle_tabs = [ for (i = [0:num_tabs_handle-1]) pommel_radius + (i + 0.5) * L_handle / num_tabs_handle ];
    vertical_wall_y(W_handle, pommel_radius, L_handle, thickness, inside_height, handle_tabs, tab_width, tab_extension);
}

// Renders the 3D model of the inner wall (curved/hinged yoke is tab-free)
module inner_wall_3d() {
    prong_inner_tabs = [ for (i = [0:num_tabs_prong-1]) y2 + (i + 0.5) * prong_length / num_tabs_prong ];
    
    // Right inner straight
    vertical_wall_y(R_inner, y2, prong_length, thickness, inside_height, prong_inner_tabs, tab_width, tab_extension);
    
    // Left inner straight
    mirror([1, 0, 0])
    vertical_wall_y(R_inner, y2, prong_length, thickness, inside_height, prong_inner_tabs, tab_width, tab_extension);
    
    // Semicircular yoke curve (tab-free)
    translate([0, y2, thickness])
    linear_extrude(height = inside_height)
    arc_2d(R_inner + thickness/2, thickness, -180, 0);
}

// Renders one of the prong tip caps in 3D
module prong_cap_3d(x_center, y) {
    // Main cap plate
    translate([x_center - W_cap/2, y - thickness/2, thickness])
    cube([W_cap, thickness, inside_height]);
    
    // Bottom tab
    translate([x_center - tab_width/2, y - thickness/2, -tab_extension])
    cube([tab_width, thickness, thickness + tab_extension]);
    
    // Top tab
    translate([x_center - tab_width/2, y - thickness/2, fork_height - thickness])
    cube([tab_width, thickness, thickness + tab_extension]);
}

// Renders the vertical handle end cap in 3D (closing the handle box)
module handle_end_cap_3d() {
    difference() {
        union() {
            // Main vertical plate
            translate([-W_end_cap/2, pommel_radius, thickness])
            cube([W_end_cap, thickness, inside_height]);
            
            // Bottom tab
            translate([-tab_width/2, pommel_radius, -tab_extension])
            cube([tab_width, thickness, thickness + tab_extension]);
            
            // Top tab
            translate([-tab_width/2, pommel_radius, fork_height - thickness])
            cube([tab_width, thickness, thickness + tab_extension]);
        }
        
        // Horizontal slots for pommel spacers (only if decorative)
        if (pommel_type == "decorative") {
            for (i = [0 : num_spacers - 1]) {
                let(z = thickness + (i + 1) * inside_height / (num_spacers + 1) - thickness/2)
                translate([-(tab_width - tolerance)/2, pommel_radius - 1, z - (thickness - tolerance)/2])
                cube([tab_width - tolerance, thickness + 2, thickness - tolerance]);
            }
        }
    }
}

// Generates the 2D shape of the horizontal pommel spacer
module pommel_spacer_2d() {
    overlap = 0.5;
    union() {
        difference() {
            translate([0, pommel_radius])
            circle(r = pommel_radius, $fn = $fn);
            
            // Cut off at the flat cap line y = pommel_radius
            translate([-pommel_radius * 2, pommel_radius])
            square([pommel_radius * 4, pommel_radius * 2]);
        }
        
        // Tab extending into the handle end cap (slot) with overlap
        translate([-tab_width/2, pommel_radius - overlap])
        square([tab_width, thickness + overlap]);
    }
}

// --- 2D FLATPACK BUILDERS ---

// Renders the flat outer wall with tabs and living hinge slots (curves tab-free)
module flat_outer_wall() {
    overlap = 0.5;
    difference() {
        union() {
            // Base panel
            square([L_outer, inside_height]);
            
            // Tabs
            // 1. Prong outer tabs
            for (i = [0 : num_tabs_prong - 1]) {
                let(x = L_prong - (i + 0.5) * L_prong / num_tabs_prong) {
                    translate([x - tab_width/2, inside_height - overlap]) square([tab_width, thickness + tab_extension + overlap]);
                    translate([x - tab_width/2, -(thickness + tab_extension)]) square([tab_width, thickness + tab_extension + overlap]);
                }
            }
            // 2. Handle tabs
            for (i = [0 : num_tabs_handle - 1]) {
                let(y_t = pommel_radius + (i + 0.5) * L_handle / num_tabs_handle,
                    x = L_prong + L_trans_up + L_trans_low + (L_handle - (y_t - pommel_radius))) {
                    translate([x - tab_width/2, inside_height - overlap]) square([tab_width, thickness + tab_extension + overlap]);
                    translate([x - tab_width/2, -(thickness + tab_extension)]) square([tab_width, thickness + tab_extension + overlap]);
                }
            }
        }
        
        // Staggered living hinge cuts for the S-curve transition
        translate([L_prong, 0])
        living_hinge_cuts(L_trans_up + L_trans_low, inside_height, hinge_spacing);
    }
}

// Renders the flat inner wall with tabs and living hinge slots (yoke curve tab-free)
module flat_inner_wall() {
    overlap = 0.5;
    difference() {
        union() {
            // Base panel
            square([L_inner, inside_height]);
            
            // Tabs
            // 1. Left prong inner tabs
            for (i = [0 : num_tabs_prong - 1]) {
                let(x = (i + 0.5) * L_prong / num_tabs_prong) {
                    translate([x - tab_width/2, inside_height - overlap]) square([tab_width, thickness + tab_extension + overlap]);
                    translate([x - tab_width/2, -(thickness + tab_extension)]) square([tab_width, thickness + tab_extension + overlap]);
                }
            }
            // 2. Right prong inner tabs
            for (i = [0 : num_tabs_prong - 1]) {
                let(x = L_prong + L_yoke_inner + (i + 0.5) * L_prong / num_tabs_prong) {
                    translate([x - tab_width/2, inside_height - overlap]) square([tab_width, thickness + tab_extension + overlap]);
                    translate([x - tab_width/2, -(thickness + tab_extension)]) square([tab_width, thickness + tab_extension + overlap]);
                }
            }
        }
        
        // Staggered living hinge cuts in the yoke section (denser 1.2mm spacing and thinner 1.5mm bridges)
        translate([L_prong, 0])
        living_hinge_cuts(L_yoke_inner, inside_height, 1.2, 1.5);
    }
}

// Renders the flat prong cap with tabs
module flat_prong_cap() {
    overlap = 0.5;
    union() {
        square([W_cap, inside_height]);
        
        // Top tab
        translate([W_cap/2 - tab_width/2, inside_height - overlap]) 
        square([tab_width, thickness + tab_extension + overlap]);
        
        // Bottom tab
        translate([W_cap/2 - tab_width/2, -(thickness + tab_extension)]) 
        square([tab_width, thickness + tab_extension + overlap]);
    }
}

// Renders the vertical handle end cap flat with tabs and spacer slots
module flat_handle_end_cap() {
    overlap = 0.5;
    difference() {
        union() {
            // Main body
            square([W_end_cap, inside_height]);
            
            // Top tab
            translate([W_end_cap/2 - tab_width/2, inside_height - overlap])
            square([tab_width, thickness + tab_extension + overlap]);
            
            // Bottom tab
            translate([W_end_cap/2 - tab_width/2, -(thickness + tab_extension)])
            square([tab_width, thickness + tab_extension + overlap]);
        }
        
        // Horizontal slots for pommel spacers (only if decorative)
        if (pommel_type == "decorative") {
            for (i = [0 : num_spacers - 1]) {
                let(y = (i + 1) * inside_height / (num_spacers + 1))
                translate([W_end_cap/2 - slot_l/2, y - slot_w/2])
                square([slot_l, slot_w]);
            }
        }
    }
}

// --- DISPLAY ASSEMBLY & EXPLOSION CONTROL ---

eo = (mode == "exploded") ? exploded_offset : 0;

if (mode == "assembled" || mode == "exploded") {
    // 3D Assembled / Exploded View
    
    // Bottom Plate (wood color)
    color([0.85, 0.73, 0.53])
    translate([0, 0, -eo])
    linear_extrude(height = thickness)
    difference() {
        fork_2d_shape();
        all_slots();
    }
    
    // Top Plate (wood color)
    color([0.85, 0.73, 0.53])
    translate([0, 0, fork_height - thickness + eo])
    linear_extrude(height = thickness)
    difference() {
        fork_2d_shape();
        all_slots();
    }
    
    // Side Walls (darker wood color for contrast)
    color([0.75, 0.63, 0.43]) {
        // Right Outer Wall
        translate([eo, 0, 0])
        outer_wall_3d();
        
        // Left Outer Wall
        translate([-eo, 0, 0])
        mirror([1, 0, 0])
        outer_wall_3d();
        
        // Inner Wall
        translate([0, -eo, 0])
        inner_wall_3d();
        
        // Prong Caps
        let(cap_y = y2 + prong_length - thickness/2) {
            translate([eo, eo, 0])
            prong_cap_3d(R_inner + prong_width/2, cap_y);
            
            translate([-eo, eo, 0])
            prong_cap_3d(-(R_inner + prong_width/2), cap_y);
        }
        
        // Handle End Cap (closed square in the end)
        translate([0, -eo, 0])
        handle_end_cap_3d();
        
        // Stacked horizontal pommel spacers (only if decorative)
        if (pommel_type == "decorative") {
            for (i = [0 : num_spacers - 1]) {
                let(z = thickness + (i + 1) * inside_height / (num_spacers + 1) - thickness/2)
                translate([0, -eo * 1.5, z])
                linear_extrude(height = thickness)
                pommel_spacer_2d();
            }
        }
    }
} else if (mode == "flatpack") {
    // 2D Laser-Cut Nesting Layout (drawn on Z=0 plane)
    
    // Top Plate
    translate([0, 0])
    difference() {
        fork_2d_shape();
        all_slots();
    }
    
    // Bottom Plate
    translate([W_outer * 2 + 15, 0])
    difference() {
        fork_2d_shape();
        all_slots();
    }
    
    // Left Outer Wall
    translate([0, y2 + prong_length + 10])
    flat_outer_wall();
    
    // Right Outer Wall
    translate([0, y2 + prong_length + inside_height + 20])
    flat_outer_wall();
    
    // Inner Wall
    translate([0, y2 + prong_length + 2 * inside_height + 30])
    flat_inner_wall();
    
    // Prong Caps (2)
    translate([L_inner + 10, y2 + prong_length + 10])
    flat_prong_cap();
    
    translate([L_inner + 10, y2 + prong_length + inside_height + 20])
    flat_prong_cap();
    
    // Handle End Cap
    translate([L_inner + 10 + prong_width + 10, y2 + prong_length + 10])
    flat_handle_end_cap();
    
    // Decorative Pommel Spacers (if enabled)
    if (pommel_type == "decorative") {
        for (i = [0 : num_spacers - 1]) {
            translate([L_inner + 10 + prong_width + 10 + handle_width + 10 + i * (pommel_radius * 2 + 10), y2 + prong_length + 10 + pommel_radius])
            pommel_spacer_2d();
        }
    }
}
