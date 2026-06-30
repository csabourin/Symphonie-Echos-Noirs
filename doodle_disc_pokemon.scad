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
slot_width = 2.0;
clearance = 0.3; // Radial gap between disc and frame pocket

// --- Advanced Parameters ---
N = 20; // Number of rotational steps
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
    [[[14.0561, 1.3459], [12.4140, -0.5009], [11.2244, -3.0024], [10.7948, -5.3040], [10.9190, -7.4157], [9.8852, -11.7023], [8.9727, -11.1683]]],
    [[[5.0823, -13.3944], [4.8270, -13.1075], [4.2137, -12.8833], [3.0537, -13.1921], [2.5742, -13.6714], [2.9150, -17.5943], [4.2741, -20.9613], [3.0095, -25.4679]]],
    [[[-23.2914, -10.7322], [-24.4329, -10.7786], [-25.5591, -11.3162], [-26.2353, -12.2847], [-27.7960, -11.1382], [-28.3762, -11.4746], [-27.3936, -13.7337], [-26.0221, -15.3074], [-25.4019, -17.1275], [-24.9313, -19.3826], [-24.9819, -19.5849]]],
    [[[-26.3461, 17.7072], [-28.2711, 17.5747], [-30.5902, 16.5885], [-30.1492, 15.9790], [-28.1720, 15.8547], [-28.1588, 14.1615], [-26.4229, 12.4086], [-26.8931, 10.9980], [-26.4112, 10.2644], [-27.5983, 9.4200]]],
    [[[9.4200, 27.5983], [8.9667, 28.2357], [7.7595, 28.2619], [6.9716, 27.6746], [6.7128, 27.8765], [3.0539, 27.4672], [2.6482, 27.9838], [1.2676, 25.8369], [0.5191, 22.8887], [0.6193, 20.9600]]],
    [[[-20.1255, -5.8880], [-19.0123, -5.4612], [-16.7330, -4.9825], [-14.2645, -3.1563], [-13.6754, -5.2581], [-12.6801, -7.2874], [-11.2856, -9.1868], [-10.8522, -9.5094], [-10.5805, -9.3508]], [[-10.6059, -9.3749], [-10.8609, -9.5440], [-11.1844, -9.0234]]],
    [[[-9.0234, 11.1844], [-8.9683, 11.2186], [-6.4039, 12.3730], [-4.7165, 12.7356], [-3.8155, 12.3608], [-5.5924, 13.7786], [-6.8150, 15.8166], [-7.0747, 18.2398], [-7.2951, 18.0374], [-7.6055, 18.6589], [-8.0511, 20.0965]]],
    [[[-13.8672, 16.6249], [-14.4880, 17.5044], [-15.4666, 20.5346], [-14.3012, 20.2921], [-12.7238, 19.1895], [-11.9711, 17.1381], [-12.3710, 15.5758], [-12.0555, 16.6911], [-10.5763, 18.9850], [-10.4992, 18.9171]]],
    [[[-19.6132, 9.1330], [-18.4275, 9.0215], [-17.6404, 10.2292], [-18.0561, 11.2214], [-19.1389, 11.4576], [-17.1489, 12.8271], [-18.2666, 12.3634], [-19.5848, 11.2358], [-21.7920, 11.7997], [-23.9742, 12.8719], [-23.8491, 13.1204]]],
    [[[11.5823, -24.6328], [11.5598, -24.6444], [11.7829, -25.0491], [11.5548, -25.4314], [10.6611, -26.0257], [7.3224, -24.4950], [7.6741, -23.2154], [6.9941, -24.9550], [6.3112, -29.1006], [5.6735, -29.7714], [4.5654, -30.1283]]],
    [[[30.0645, -4.9682], [30.0642, -5.1058], [31.3566, -4.3646], [32.6485, -4.3986], [31.6492, -4.7515], [32.4828, -4.6442], [30.8995, -5.8552], [29.1369, -6.6465], [29.6793, -5.7331], [27.3074, -8.3987], [26.2308, -9.8275]]],
    [[[-26.9976, -7.4675], [-26.9767, -6.2697], [-27.2333, -7.0189], [-27.8824, -5.2901], [-28.1831, -3.2342], [-27.6528, -4.0519], [-28.1311, -3.0044], [-27.3848, -4.0220], [-27.9117, -2.8954], [-27.1271, -3.7824], [-26.6701, -4.6094], [-26.7436, -5.2004], [-25.8923, -4.0252], [-25.4647, -3.9102]]],
    [[[-25.4267, 4.1502], [-24.4783, 4.1015], [-19.6100, 0.8463], [-19.7246, 0.6430], [-16.1023, 1.0690], [-12.0757, 0.1967], [-11.9754, -0.1472]]],
    [[[-3.5607, -11.4348], [-2.8942, -11.4551], [-2.1026, -12.1769], [-2.1073, -15.0086], [-2.7926, -17.9751], [-2.1071, -16.0371], [-1.1268, -15.8504], [-0.5152, -15.1735], [-0.4889, -14.2570], [-1.0526, -13.6274], [0.5552, -12.7685]]],
    [[[11.9720, 4.4737], [11.1440, 5.2702], [10.5675, 6.9329], [10.5129, 6.1651], [8.7571, 7.3168], [7.2614, 8.9519], [6.8880, 10.5056], [7.1731, 12.1627]], [[7.1905, 12.1900], [7.7027, 12.5679], [8.4088, 12.5556], [9.2734, 11.5280], [8.0940, 11.2791]]],
    [[[-0.0815, 13.8825], [-0.6479, 13.2553], [-1.3459, 14.0561]], [[-1.3141, 14.0962], [-0.1087, 16.1460], [0.5783, 14.0496], [-1.5031, 13.8402], [-1.3459, 14.0561]], [[-1.3485, 14.1162], [-0.9999, 14.8799], [-0.2294, 15.0536], [0.6826, 14.6358], [0.9085, 13.8205], [0.5448, 13.2005], [-0.2269, 12.9796], [-0.9665, 13.3031], [-1.1946, 13.7559]]],
    [[[-13.4518, 3.1146], [-13.7841, 3.0636]], [[-13.8402, 3.1014], [-15.7886, 4.0044], [-13.9729, 7.2090], [-13.4152, 7.0728], [-12.0956, 5.6698], [-10.1240, 4.3610], [-10.8917, 2.9483], [-13.4132, 3.0488]]],
    [[[3.0488, 13.4132], [3.0636, 13.7841]], [[3.0954, 13.8781], [3.3355, 14.9493], [3.9295, 14.9575], [4.9465, 13.8596], [3.0636, 13.7841]], [[12.3450, 8.4960], [12.7124, 7.9021], [13.3421, 7.7279], [13.8776, 7.9939], [14.1123, 8.5854], [13.8117, 9.2465], [13.1574, 9.4920], [12.5157, 9.1643], [12.3450, 8.4960]], [[12.3511, 8.5152], [12.8653, 8.7236], [13.0472, 8.2186], [12.5769, 8.0073], [12.3450, 8.4960]], [[14.2166, 13.7982], [14.6033, 13.2390], [15.2819, 13.1043], [15.8355, 13.4604], [15.8637, 13.5785]]],
    [[[20.3096, -4.8528], [20.7901, -4.6531], [21.0342, -4.0109], [20.7521, -3.3835], [20.1589, -3.1311], [19.5193, -3.3911]], [[19.5525, -3.3803], [20.0527, -3.6432], [19.8502, -4.1541], [19.3169, -3.9364], [19.5193, -3.3911]], [[17.2645, -5.1554], [17.5284, -5.3482], [17.7232, -5.1209], [17.2645, -5.1554]], [[16.1685, -6.6333], [18.0142, -9.0449], [18.5977, -9.2819], [19.0977, -9.0146], [19.3510, -5.5811], [18.6644, -6.0899], [18.6196, -6.0858]]],
    [[[-6.0858, -18.6196], [-6.0046, -17.7227], [-6.6427, -16.9199], [-6.6333, -16.1685]], [[-6.6226, -16.2218], [-5.9693, -17.1590], [-5.9607, -18.4010], [-6.5227, -18.4832], [-6.5174, -17.2838], [-7.1916, -16.4106], [-6.6333, -16.1685]], [[-6.5941, -16.2458], [-6.6031, -17.5931], [-7.9728, -17.6353], [-8.6634, -17.2613], [-8.5382, -16.5945], [-7.2901, -15.6175], [-6.6333, -16.1685]]],
];

// X, Y coordinate for each slot number text label on the disc face
label_positions = [
    [15.9626, -1.7021],
    [5.4229, -9.6520],
    [-30.7784, -14.6014],
    [-33.0306, 14.0759],
    [8.8128, 31.6898],
    [-17.4912, -8.6670],
    [-6.6895, 8.4610],
    [-18.6830, 19.2680],
    [-18.9296, 5.6035],
    [13.3999, -28.3476],
    [33.5892, -8.1414],
    [-31.3261, -5.5842],
    [-25.5045, 0.6375],
    [-0.3152, -9.1378],
    [7.4698, 4.0353],
    [1.4027, 9.8575],
    [-7.6171, 1.7487],
    [3.8411, 18.4066],
    [14.3399, -9.9206],
    [-12.0380, -16.5385],
];

// Which drawing step number (1 to N) is assigned to each notch index (0 to N-1)
rim_numbers = [12, 3, 20, 14, 10, 2, 1, 19, 11, 15, 18, 16, 5, 7, 8, 17, 9, 4, 6, 13];

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
