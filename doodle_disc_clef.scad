// ==========================================================
// Twist Art / Rotadraw / Doodle Disc Parametric Model
// Generated programmatically from vector paths.
// ==========================================================

// --- Customizer Parameters ---
// "disc"    = disc body with the numbers raised on top (single STL; do a filament
//             swap at the layer where the numbers start to colour them)
// "numbers" = ONLY the raised numbers, for a separate second-material STL
// "frame"   = holder frame    "both" = assembly preview
part = "both"; // ["disc", "numbers", "frame", "both"]
disc_radius = 50.8;
disc_thickness = 2.0;
slot_width = 1.5;
clearance = 0.3; // Radial gap between disc and frame pocket

// --- Advanced Parameters ---
N = 19; // Number of rotational steps
notch_size = 1.0; // Radius of alignment notches on rim
rim_margin = 13.0; // Radial width of the numbers rim area
engrave_depth = 0.8;
number_height = 0.6; // Height the numbers stand proud of the disc face (for a colour swap)
font_name = "Liberation Sans:style=Bold";
font_size_rim = 4.5;
font_size_slot = 3.0;
theta_index = 90; // Index pointer angle (12 o'clock = 90 deg)

// Holder frame parameters
frame_thickness = disc_thickness + 1.6;
frame_width = (disc_radius + 8.0) * 2;
frame_height = (disc_radius + 8.0) * 2;
paper_width = (disc_radius + 4.0) * 2;
paper_height = (disc_radius + 4.0) * 2;

// --- Geometric Data ---

// Each slot is a list of drawable subpaths, pre-rotated by their notch angle
slots = [
    [[[5.5998, -14.3446], [0.9715, -9.6424], [-1.6021, -11.0174], [-3.5199, -11.3842], [-5.4711, -11.3022], [-5.7907, -11.2104]]],
    [[[-12.5522, -1.2837], [-13.0288, 0.2622], [-13.1506, 2.0923], [-12.3245, 5.4034], [-10.8541, 7.4966], [-9.0376, 8.8358], [-7.0881, 9.5452]]],
    [[[7.5131, 9.2144], [7.5707, 9.1296], [8.5452, 6.3227], [13.6478, 6.2712], [16.3778, 5.1031], [17.7072, 3.6720], [18.0038, 3.0886]]],
    [[[16.1046, -8.6208], [15.9823, -9.2537], [14.6378, -11.3831], [12.6536, -12.6731], [10.3425, -13.1125], [8.5343, -12.6191], [7.0694, -11.0777], [6.8394, -9.8409], [7.0257, -9.2569]]],
    [[[-11.2994, -2.7155], [-10.8717, -3.0922], [-10.3577, -4.1739], [-10.2797, -5.3601], [-10.9956, -6.7983], [-12.3457, -7.6927], [-13.9408, -7.8009], [-15.2424, -7.2607], [-14.7684, -8.8811], [-13.7724, -9.9509], [-12.4857, -10.5357]]],
    [[[10.5813, 12.4471], [10.5368, 12.4590], [8.6011, 12.1180], [6.8767, 11.1524], [3.8595, 8.6938], [5.1933, 6.5455], [6.3787, 3.4174]]],
    [[[0.5673, -7.2142], [0.1129, -7.1910], [-2.2391, -6.5968], [-4.4163, -5.5231], [-6.2603, -3.9605], [-7.5489, -2.1102], [-8.3350, -0.1024], [-8.5973, 1.4936]]],
    [[[-5.8671, 6.4592], [-5.2593, 7.5758], [-2.2809, 10.8406], [0.9096, 12.7209], [4.9575, 13.7437], [5.1423, 13.7463]]],
    [[[0.4002, 14.6712], [5.3222, 16.4392], [5.7674, 23.3456], [6.0880, 24.9165]]],
    [[[20.3723, -15.5840], [21.2625, -16.2125], [22.0788, -17.4405], [22.4571, -18.8466], [22.2292, -20.3625], [21.6580, -21.3100], [19.8341, -22.5482], [18.1838, -22.7313], [16.3201, -22.3249], [15.1961, -21.6294]]],
    [[[-3.0701, 26.2550], [-2.4634, 25.1971], [-2.0174, 23.3386], [-1.9383, 20.8156], [-2.2567, 18.3134], [-3.1623, 15.0707], [-3.1623, 15.0707]], [[-3.4684, 14.9295], [-4.2744, 13.9238], [-4.3328, 13.0049]]],
    [[[13.6500, -1.2562], [13.3009, -1.0759], [10.5451, -1.1660], [6.6886, -1.9125], [7.0569, -2.6880], [8.4259, -4.0345], [11.2193, -5.2933], [12.0493, -5.2243]]],
    [[[-2.1065, -12.9631], [-1.5031, -14.7200], [-0.4016, -15.4155], [0.6387, -15.3857]], [[1.0862, -16.3521], [5.1000, -25.0208]]],
    [[[-18.1572, -17.9546], [-18.1745, -17.9824], [-16.5188, -18.4961], [-14.7915, -18.3187], [-13.2196, -17.5586], [-11.6019, -15.9562], [-11.3263, -17.7427], [-11.9655, -19.3585], [-13.7579, -20.9367], [-14.0331, -21.0420]]],
    [[[17.3052, 18.4453], [18.9250, 18.7738], [20.8740, 18.6187], [23.4820, 17.7491], [27.1242, 21.8018], [25.1955, 22.0739]]],
    [[[-32.6648, -7.4217], [-28.6905, -10.3574], [-24.6784, -12.5712], [-22.6745, -12.9965], [-20.5145, -12.6875]]],
    [[[-23.9817, 2.5880], [-23.5123, 2.3197], [-20.2991, 2.0165], [-18.5652, 2.4546], [-16.9692, 3.2698], [-13.9413, 6.1011], [-12.8242, 8.0654]]],
    [[[13.9768, -5.8446], [13.2297, -7.8805]], [[12.2024, -7.7405], [2.9571, -6.4804], [3.2361, -8.6341], [3.2783, -8.7052]]],
    [[[-7.6340, -5.3150], [-9.1165, -6.7938], [-9.9977, -8.7889], [-10.0902, -10.6771], [-9.6036, -12.1512], [-8.5057, -13.3909], [-6.7876, -14.2881], [-4.3917, -14.7594]]],
];

// X, Y coordinate for each slot number text label on the disc face
label_positions = [
    [-5.1476, -17.5213],
    [-8.9082, 4.6997],
    [10.0236, 3.1076],
    [17.5637, -12.7430],
    [-18.0622, -9.0188],
    [9.1240, 15.4594],
    [-2.3518, -2.9733],
    [-1.2802, 7.1895],
    [1.0443, 18.3028],
    [25.2174, -16.7894],
    [-7.4682, 14.1228],
    [3.9083, -3.5176],
    [6.8480, -21.1801],
    [-18.2783, -21.3007],
    [17.5676, 21.7637],
    [-30.0260, -5.3925],
    [-18.4948, 6.2243],
    [19.4813, -8.8415],
    [-6.0232, -8.2281],
];

// Which drawing step number (1 to N) is assigned to each notch index (0 to N-1)
rim_numbers = [12, 5, 15, 8, 9, 7, 11, 4, 17, 3, 16, 6, 14, 2, 19, 13, 1, 10, 18];

// --- Assembly Render ---
if (part == "disc") {
    stencil_disc();
} else if (part == "numbers") {
    disc_numbers();
} else if (part == "frame") {
    holder_frame();
} else {
    // Render assembly: transparent disc sitting inside the frame
    color("LightBlue", 0.7) stencil_disc();
    color("Plum", 1.0) holder_frame();
}

// --- Modules ---

module draw_subpath(points, w) {
    if (len(points) >= 2) {
        for (i = [0 : len(points) - 2]) {
            hull() {
                translate(points[i]) circle(d = w, $fn = 12);
                translate(points[i+1]) circle(d = w, $fn = 12);
            }
        }
    }
}

module draw_slot(subpaths, w) {
    for (j = [0 : len(subpaths) - 1]) {
        draw_subpath(subpaths[j], w);
    }
}

// Raised numbers that stand proud of the disc face. Kept as its own module so it
// can also be exported on its own (part = "numbers") for a second-material print.
module disc_numbers() {
    // Rim step-numbers (1..N) around the outer ring
    for (m = [0 : N - 1]) {
        if (rim_numbers[m] > 0) {
            rotate([0, 0, m * 360 / N])
                translate([disc_radius - rim_margin + 5.0, 0, disc_thickness])
                    rotate([0, 0, -90]) // radial orientation
                        linear_extrude(height = number_height)
                            text(text = str(rim_numbers[m]), font = font_name, size = font_size_rim, halign = "center", valign = "center");
        }
    }

    // Per-slot labels on the disc face
    for (i = [0 : len(label_positions) - 1]) {
        translate([label_positions[i][0], label_positions[i][1], disc_thickness])
            linear_extrude(height = number_height)
                text(text = str(i + 1), font = font_name, size = font_size_slot, halign = "center", valign = "center");
    }
}

module stencil_disc() {
    union() {
        difference() {
            // Base disc
            cylinder(r = disc_radius, h = disc_thickness, $fn = 150);

            // Subtract notches around the rim (triangles)
            for (m = [0 : N - 1]) {
                rotate([0, 0, m * 360 / N])
                    translate([disc_radius, 0, -1])
                        cylinder(r = notch_size, h = disc_thickness + 2, $fn = 3);
            }

            // Subtract tracing slots
            for (i = [0 : len(slots) - 1]) {
                translate([0, 0, -1])
                    linear_extrude(height = disc_thickness + 2)
                        draw_slot(slots[i], slot_width);
            }
        }

        // Numbers raised on the top face (coloured separately at print time)
        color("Black") disc_numbers();
    }
}

module holder_frame() {
    difference() {
        // Outer square frame with index tab
        union() {
            translate([-frame_width/2, -frame_height/2, 0])
                cube([frame_width, frame_height, frame_thickness]);
            
            // tab for index pointer
            rotate([0, 0, theta_index])
                translate([disc_radius + clearance, -10.0, 0])
                    cube([12.0, 20.0, frame_thickness]);
        }
        
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
    }
}
