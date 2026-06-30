/**
 * Standalone curved rectangular-octagon mirror lens
 * OpenSCAD
 */

/* [Lens Dimensions] */
lens_width = 121.85;
lens_height = 176.85;
lens_edge_thickness = 2.0;
lens_center_thickness = 9.0;

/* [Lens Shape] */
octagon_facets_factor = 0.45;
lens_corner_roundness = 18.0;

/* [Curve Quality] */
lens_slices = 180;
$fn = 60;


/* Render */
curved_rect_octagon_lens();


module curved_rect_octagon_lens() {
    lens_dome_rise = lens_center_thickness - lens_edge_thickness;

    color("LightCyan", 0.45)
    union() {
        // Flat minimum-thickness lens body: 3mm at the thinnest point.
        linear_extrude(height = lens_edge_thickness)
            lens_2d_profile();

        // Convex lens dome.
        // This approximates a smooth curved top by stacking many shrinking slices.
        for (i = [0 : lens_slices - 1]) {
            t0 = i / lens_slices;
            t1 = (i + 1) / lens_slices;

            z0 = lens_edge_thickness + lens_dome_rise * sin(t0 * 90);
            z1 = lens_edge_thickness + lens_dome_rise * sin(t1 * 90);

            s0 = lens_scale_at_height(t0);
            s1 = lens_scale_at_height(t1);

            translate([0, 0, z0])
                linear_extrude(height = z1 - z0, scale = s1 / s0)
                    scale([s0, s0, 1])
                        lens_2d_profile();
        }
    }
}


function lens_scale_at_height(t) =
    1 - 0.045 * pow(t, 1.8);


module lens_2d_profile() {
    rounded_octagon(
        w = lens_width,
        h = lens_height,
        factor = octagon_facets_factor,
        r_val = lens_corner_roundness
    );
}


module rounded_octagon(w, h, factor, r_val) {
    offset(r = r_val) {
        offset(r = -r_val) {
            polygon(points = [
                [ w * (1 - factor) / 2,  h / 2],
                [ w / 2,                  h * (1 - factor) / 2],
                [ w / 2,                 -h * (1 - factor) / 2],
                [ w * (1 - factor) / 2, -h / 2],
                [-w * (1 - factor) / 2, -h / 2],
                [-w / 2,                 -h * (1 - factor) / 2],
                [-w / 2,                  h * (1 - factor) / 2],
                [-w * (1 - factor) / 2,  h / 2]
            ]);
        }
    }
}

/* [Curve Quality] */
sphere_quality = 60;


/* Render */
curved_rect_octagon_lens();


module curved_rect_octagon_lens() {
    lens_dome_rise = lens_center_thickness - lens_edge_thickness;

    // Stretch the sphere in Y so its footprint better matches the lens shape.
    y_scale = lens_height / lens_width;

    // Use the half-width as the reference cap radius.
    // After scaling in Y, the cap also reaches approximately half-height.
    aperture_radius = lens_width / 2;

    sphere_radius = spherical_cap_radius(aperture_radius, lens_dome_rise);

    // Top of ellipsoid lands at lens_center_thickness.
    sphere_center_z = lens_center_thickness - sphere_radius;

    color("LightCyan", 1)
    union() {
        // Flat minimum-thickness body.
        linear_extrude(height = lens_edge_thickness)
            lens_2d_profile();

        // Ellipsoidal dome clipped to the octagonal lens outline.
        intersection() {
            // Vertical clipping volume.
            translate([0, 0, lens_edge_thickness])
                linear_extrude(height = lens_dome_rise + 0.02)
                    lens_2d_profile();

            // Scaled sphere = ellipsoid.
            translate([0, 0, sphere_center_z])
                scale([1, y_scale, 1])
                    sphere(r = sphere_radius, $fn = sphere_quality);
        }
    }
}


function spherical_cap_radius(aperture_radius, rise) =
    (pow(aperture_radius, 2) + pow(rise, 2)) / (2 * rise);