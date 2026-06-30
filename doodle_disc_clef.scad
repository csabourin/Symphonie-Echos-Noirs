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
disc_radius = 67.5;
disc_thickness = 2.0;
slot_width = 2.0;
clearance = 0.3; // Radial gap between disc and frame pocket

// --- Advanced Parameters ---
N = 22; // Number of rotational steps
notch_size = 1.0; // Radius of alignment notches on rim
rim_margin = 13.0; // Radial width of the numbers rim area
engrave_depth = 0.8;
number_height = 0.6; // Height the numbers stand proud of the disc face (for a colour swap)
font_name = "Liberation Sans:style=Bold";
font_size_rim = 4.5;
font_size_slot = 3.5;
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
    [[[-5.0146, 22.2300], [0.7154, 14.3240], [4.7858, 15.7656], [7.6733, 15.8773], [8.2917, 15.7569]]],
    [[[15.4942, 8.7727], [17.1269, 7.2100], [18.6834, 4.7795], [19.5809, 2.2179], [19.9074, -0.2986], [19.7125, -2.8306], [18.4437, -6.3972], [17.9014, -7.0889]]],
    [[[0.9882, -19.2285], [-1.4042, -18.6518], [-4.1956, -17.0430], [-6.8894, -14.0587], [-7.3038, -13.9328], [-14.0558, -17.1186]]],
    [[[21.0795, 6.8019], [21.1647, 6.7908], [22.9158, 6.1122], [24.9683, 4.5899], [26.6672, 2.2513], [27.3267, 0.4455], [27.5296, -1.4619], [27.2446, -3.2805], [25.7111, -6.4292], [24.9590, -7.1010]]],
    [[[-25.9485, -0.2184], [-24.6429, 1.8818], [-22.2935, 3.3560], [-20.3937, 3.6275], [-19.1469, 3.4062], [-17.5698, 2.4169], [-16.7031, 0.8959], [-16.5034, -0.8652], [-16.9641, -2.5629], [-18.4070, -3.9854]]],
    [[[4.0213, 18.3992], [3.9009, 18.7293], [4.3158, 21.0897], [5.8243, 22.9125], [7.7302, 23.7596], [5.5076, 24.9012], [3.3446, 24.9216], [1.3431, 24.1102], [-0.6398, 21.9821], [-0.9102, 21.3667]]],
    [[[-6.8930, 20.2447], [-7.1814, 18.0107], [-6.9229, 12.2566], [-3.1936, 11.9456], [2.2163, 10.4098], [2.4155, 10.3079]]],
    [[[9.3720, 4.9248], [10.1757, 1.6558], [10.2848, -1.9350], [9.5235, -5.4300], [8.0006, -8.3991], [5.9228, -10.8209], [5.4946, -11.1474]]],
    [[[11.8159, 3.8523], [13.6354, 0.5889], [14.8825, -3.0107], [15.3645, -5.7185], [15.1938, -11.1964], [14.6262, -12.9312]]],
    [[[-17.6769, 8.2867], [-17.5438, 12.6380], [-16.8595, 16.0080], [-15.4534, 20.3736], [-19.5374, 23.6302]]],
    [[[-25.4034, 17.1687], [-30.0497, 19.0653], [-33.4991, 21.0610], [-34.8659, 22.7622], [-35.6108, 24.7842], [-35.4771, 27.0488], [-34.7614, 28.5215], [-34.5198, 28.7822]]],
    [[[40.5212, 19.4438], [41.0167, 18.2554], [41.2174, 16.6176], [40.6627, 14.2238], [39.1803, 11.8216], [36.2523, 9.4611], [33.6399, 8.3770], [30.8947, 7.8514]]],
    [[[27.4313, 16.2375], [26.5948, 15.8075], [23.0478, 14.6444], [18.1380, 13.7961], [18.1380, 13.7961]], [[17.7550, 14.1156], [15.8988, 14.5545], [14.0934, 13.8334], [11.5235, 10.6639], [11.5164, 10.6515]]],
    [[[-11.5164, -10.6515], [-8.6210, -5.6272], [-9.8453, -5.2876], [-12.6780, -5.5139], [-15.2615, -6.4269], [-16.7929, -7.4181], [-18.0726, -8.7015], [-18.7095, -9.8511]]],
    [[[16.7331, -12.9264], [17.6238, -12.9956], [19.3391, -12.1157], [20.0842, -10.7678]], [[21.6525, -10.9251], [34.8270, -12.2468]]],
    [[[17.0786, 32.7296], [17.3057, 33.6468], [14.7405, 33.6088], [12.3921, 32.5656], [10.5301, 30.7743], [8.9905, 27.7769], [8.4005, 28.3989], [7.7820, 30.1634], [7.9388, 32.7300], [8.0501, 32.9759]]],
    [[[-11.0559, 32.0933], [-11.2995, 33.7480], [-11.1509, 35.3580], [-10.2485, 38.0953], [-8.6195, 40.4866], [-5.8641, 42.6522], [-5.5887, 43.2008], [-6.9791, 47.3949]]],
    [[[31.4948, -36.0979], [34.3304, -38.3884], [35.2218, -28.2329], [35.0547, -24.4743]]],
    [[[16.2581, -39.5411], [17.7759, -36.9314], [18.4719, -33.9808], [17.9914, -29.9802], [17.1795, -28.1247], [15.5164, -25.8953], [13.4658, -24.2221], [13.4042, -24.1916]]],
    [[[-22.0377, -16.7106], [-21.2326, -14.2559], [-20.9055, -11.4098], [-21.0038, -8.1254], [-21.6154, -4.8960], [-22.7174, -1.7999]], [[-21.3571, -1.0903], [-19.3225, -0.0289]]],
    [[[-18.5480, 5.4161], [-7.2530, 7.6497], [-8.6783, 10.5301], [-10.8696, 12.3906]]],
    [[[2.4452, -16.3002], [2.5462, -16.6318], [4.5412, -19.1690], [6.9445, -20.6014], [9.2088, -20.9893], [11.5913, -20.4157], [13.9571, -18.7936], [16.2370, -15.9900]]],
];

// X, Y coordinate for each slot number text label on the disc face
label_positions = [
    [6.6995, 11.3226],
    [24.9832, 10.4325],
    [-2.3337, -12.4470],
    [31.7070, 0.9446],
    [-22.2405, 9.1099],
    [12.3682, 24.4912],
    [-2.7308, 6.2913],
    [5.9415, -1.4538],
    [5.6243, -1.7068],
    [-11.9877, 16.9683],
    [-30.0975, 24.1857],
    [35.4999, 14.6816],
    [18.9804, 18.5042],
    [-10.3905, -1.0184],
    [24.8891, -15.7753],
    [13.6936, 27.4262],
    [-11.0494, 44.2196],
    [39.3437, -33.2523],
    [22.7065, -31.2500],
    [-25.5788, -8.0596],
    [-9.9141, 2.5609],
    [9.3368, -16.3960],
];

// Which drawing step number (1 to N) is assigned to each notch index (0 to N-1)
rim_numbers = [5, 3, 12, 13, 16, 2, 17, 1, 10, 11, 4, 21, 20, 8, 14, 6, 7, 19, 9, 18, 22, 15];

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
