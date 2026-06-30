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
N = 8; // Number of rotational steps
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
    [[[-24.1767, 24.0326], [-23.5237, 23.1514], [-22.5348, 22.8613], [-21.8232, 21.5970], [-20.2730, 21.4143], [-19.3469, 22.3674], [-19.6121, 24.0873], [-16.9174, 27.0036], [-16.7193, 23.7288], [-15.8849, 23.3502], [-15.3273, 23.8985], [-15.2719, 27.0482], [-12.3958, 28.0450], [-10.2640, 30.0092], [-6.9584, 26.4199], [-7.3523, 25.2968], [-6.9976, 24.2396], [-5.9786, 23.6690], [-4.6259, 24.0565], [-4.0465, 25.1340], [-2.6831, 25.9053], [-2.4523, 27.3375], [-3.4462, 28.3977], [-5.0098, 28.1921], [-6.3616, 29.6754], [-4.5391, 29.9764], [-3.0074, 31.1191], [-2.4001, 32.5727], [-2.3136, 35.0825], [-2.6700, 36.5049], [-2.7056, 36.5580]]],
    [[[23.9373, 27.7635], [24.1655, 28.9209], [23.8965, 30.1222], [22.8361, 31.7399], [24.7634, 31.8328], [25.3119, 30.8835], [26.4546, 30.4357], [27.5316, 30.8997], [28.0322, 31.8716], [27.5741, 33.3199], [27.9301, 34.2033], [27.8324, 35.0179], [26.6200, 36.0181], [25.2418, 35.6347], [24.6550, 34.4800], [19.7594, 34.2671], [19.5581, 37.5335], [18.3158, 39.9136], [20.3755, 42.0146], [20.5876, 42.7271], [20.2460, 43.1973], [19.5993, 43.2702], [17.2206, 41.0475], [17.3380, 45.1180], [18.4424, 45.6678], [18.8900, 46.8071], [18.3949, 47.9434], [17.3034, 48.4206], [16.1679, 48.0137], [14.6716, 48.5005], [13.4588, 47.6333], [13.4596, 46.1549], [14.6818, 45.2349], [14.6427, 44.2962]]],
    [[[20.9682, -41.6761], [19.6559, -40.2494], [21.3596, -38.8721], [22.5621, -36.9762], [23.1024, -34.9512], [23.0525, -32.8825], [21.8612, -30.0176], [19.6504, -27.9677], [21.5595, -25.9024], [22.7657, -26.0961], [23.5889, -25.8120], [24.1312, -25.1066], [24.1767, -24.0326]], [[24.1645, -24.0707], [23.0910, -24.9370], [21.8944, -24.5306], [19.6723, -26.9333], [17.6746, -26.2109], [20.3773, -23.2133], [19.8979, -21.8414], [20.7066, -20.8556], [21.7795, -20.8910], [22.4356, -21.5841], [22.5074, -22.3632], [23.8245, -22.6728], [24.1934, -23.2886], [24.1767, -24.0326]], [[24.1335, -24.1281], [23.4066, -24.7989], [22.5074, -24.8371], [22.4351, -25.6412], [21.8826, -26.2667], [20.6879, -26.3324], [19.9285, -25.3893], [20.3948, -23.9888], [18.1710, -21.5612]]],
    [[[28.0949, -2.3973], [27.3203, -2.3633], [28.2723, -0.4128], [31.5272, -0.5631], [31.9320, 0.4621], [32.7156, 0.8436], [33.5269, 0.7074], [34.0891, 0.1019]], [[34.1998, -0.0667], [35.1726, -2.7600], [35.2049, -4.4401], [34.8360, -5.9857], [26.1864, 2.7026], [28.2193, 3.0694], [30.6520, 2.7250], [32.5042, 1.7743], [34.0891, 0.1019]], [[34.1738, -0.0043], [34.2106, -0.5189], [33.6518, -0.7069], [22.0343, 10.9105]]],
    [[[-7.8657, -23.2955], [-3.9243, -23.2955], [-3.6622, -23.7286], [-3.8563, -24.1126], [-4.3566, -24.1822], [-24.0326, -24.1767]], [[-24.0268, -24.1112], [-23.2925, -21.8509], [-22.0727, -20.2032], [-19.5223, -18.6091], [-17.5303, -18.2307], [-15.2844, -18.5345], [-13.0825, -19.7085], [-11.4318, -21.6240], [-10.5686, -24.1767], [-20.7264, -24.1767]]],
    [[[-31.7513, -2.4398], [-34.0891, -0.1019]], [[-33.8612, -0.0209], [-31.6238, 1.5429], [-29.0464, 1.4500], [-28.7290, 2.3749], [-27.9688, 2.8308], [-27.0339, 2.6729], [-26.4097, 1.8123], [-26.5317, 0.9477], [-27.0958, 0.3586], [-26.5804, -0.3156], [-26.5458, -1.1392], [-27.4187, -2.0139], [-28.7677, -1.6848], [-29.1122, -0.5663], [-34.4344, -0.2709], [-34.0891, -0.1019]], [[-34.1073, 0.3092], [-34.3058, 4.4029], [-35.5679, 4.9248], [-35.7148, 6.2462], [-34.8150, 6.9996], [-34.1078, 6.9583], [-33.3886, 6.4347], [-32.7059, 7.0325], [-31.6790, 7.0321], [-30.9708, 6.3106], [-30.9836, 5.3304], [-31.4271, 4.7453], [-32.2934, 4.4570], [-32.1811, 1.9454], [-33.2933, 0.5836], [-34.0098, -0.9057], [-34.0891, -0.1019]], [[-34.1071, -0.0534], [-34.5303, 0.9585], [-33.4544, 1.7867], [-32.8979, 0.0961], [-33.9632, -0.3928], [-34.0891, -0.1019]], [[-34.0212, 0.0809], [-33.6721, 0.5234], [-32.5901, 0.1531]]],
    [[[-0.1531, -32.5901], [0.0295, -32.0564], [1.0965, -32.8855], [0.5586, -34.2284], [0.1019, -34.0891]], [[0.0454, -34.1267], [-0.8733, -34.8399], [-1.7789, -33.9343], [-0.3896, -32.7849], [0.4207, -33.8269], [0.1019, -34.0891]], [[0.0170, -34.0267], [-0.8153, -33.3499], [0.3148, -31.9489], [1.2359, -32.8700], [0.1019, -34.0891]], [[0.0459, -34.1094], [-0.8098, -34.4631], [-1.7093, -33.3538], [0.2064, -32.8623], [1.0153, -33.8646], [0.1019, -34.0891]], [[0.0146, -34.0119], [-0.2622, -33.4887], [0.2327, -31.9180], [1.3302, -32.7902], [0.7327, -34.5496], [0.1019, -34.0891]], [[0.0160, -34.0189], [-0.4874, -33.5142], [0.7095, -32.0031], [1.8048, -33.0983], [0.6360, -34.4916], [0.1019, -34.0891]], [[0.0481, -34.1313], [-0.7805, -34.8708], [-1.8641, -33.7872], [-0.2928, -32.5952], [0.5386, -33.6023], [0.1019, -34.0891]], [[-0.1558, -34.1873], [-1.8078, -35.2199], [-3.3053, -36.6850], [-4.3908, -38.3216], [-4.8015, -39.7433], [-5.8699, -38.3401], [-6.2601, -37.1526], [-6.0550, -35.7297], [-5.5354, -34.9056]]],
    [[[28.5961, 20.7679], [28.0296, 20.6395], [25.7506, 20.7784], [24.3062, 21.4784], [23.4712, 22.8105], [23.1623, 24.7404], [24.0326, 24.1767]], [[30.5456, 20.9421], [29.5440, 19.8474], [29.5331, 19.4260], [31.1983, 21.0618], [30.9889, 21.2376], [30.5456, 20.9421]], [[37.9179, 20.7669], [38.7819, 19.3706], [39.1696, 19.2588], [38.9149, 20.0117], [37.9179, 20.7669]], [[31.2407, 20.4221], [30.6397, 19.2425], [31.8517, 20.5890], [31.5989, 20.7330], [31.2407, 20.4221]], [[36.6372, 20.4604], [37.2072, 19.3699], [37.6317, 19.2885], [37.1672, 20.2303], [36.6372, 20.4604]], [[32.2094, 20.0773], [31.8308, 19.2069], [32.7300, 20.0226], [32.2094, 20.0773]], [[31.0327, 14.8724], [29.8450, 13.8544], [29.7747, 12.4348], [30.8404, 11.3395], [32.2641, 11.3258], [33.2221, 12.2443], [33.2903, 13.7327], [32.3697, 14.7194], [31.0327, 14.8724]], [[36.4949, 14.8559], [35.2908, 13.8489], [35.2433, 12.4123], [36.2154, 11.3637], [37.6333, 11.3039], [38.6457, 12.1731], [38.7967, 13.5803], [37.7943, 14.7482], [36.4949, 14.8559]], [[33.8787, 11.0029], [33.4043, 10.7367], [33.5456, 10.2455], [34.2380, 10.0768], [34.7976, 10.3677], [34.6402, 10.8941], [33.8787, 11.0029]]],
];

// X, Y coordinate for each slot number text label on the disc face
label_positions = [
    [-20.2971, 28.4296],
    [20.3349, 29.2625],
    [27.6309, -23.8841],
    [37.8203, 0.0652],
    [-6.2631, -27.6316],
    [-37.4371, 9.3038],
    [4.3776, -35.3994],
    [42.1493, 12.4880],
];

// Which drawing step number (1 to N) is assigned to each notch index (0 to N-1)
rim_numbers = [3, 4, 8, 2, 1, 6, 5, 7];

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
