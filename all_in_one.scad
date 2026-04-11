// All-in-One Antenna Hub - v5
// 4x antenna boom clamps arranged around a central boom collar
// Print-in-place assembly with configurable gaps
// EA4IPW - Parametric design
//
// Change boom_spikes_dia or boom_dia and everything scales:
// clamp body, collar, pivot holes, plate spacing, base plate.

// ============================================================
// FREE PARAMETERS (the only things you should normally change)
// ============================================================

/* [Boom] */
boom_is_round = true;
boom_dia = 15.9;            // Main boom tube diameter
boom_side = 15.1;           // Main boom tube side (square boom)
boom_spikes_dia = 8.10;     // Wire boom / spike diameter

/* [Print-in-Place] */
print_gap = 0.20;           // Z-axis gap between parts (critical for print-in-place)
clamp_collar_gap = 0.85;    // Radial gap between collar and clamp front

// ============================================================
// DESIGN CONSTANTS (structural/hardware, rarely changed)
// ============================================================

/* [Clamp Constants] */
clamp_wall = 3;              // Wall thickness around boom in clamp
clamp_width_extra = 0.35;    // Extra wall per side on width (M3 hardware clearance)
clamp_fillet_r = 2;          // Clamp edge rounding
clamp_body_length = 25;      // Clamp total length (Y axis)
ear_drop = 3;                // Clamp ear extension below body (M3 hardware, fixed)
ear_length = 10;             // Clamp ear Y extent

/* [Main Body Constants] */
fillet_r = 0.5;              // Main body fillet radius
boom_around = 3;             // Collar wall thickness around main boom
body_height = 2.3;           // Base plate thickness
bs_holder_thickness = 1.5;   // Pivot frame plate thickness
collar_above_clamp = 3.3;    // Collar extends this far above clamp attachment
base_plate_margin = 2.2;     // Base plate extends beyond clamp attachment point

/* [Pivot Constants] */
pivot_d = 3.6;               // Pivot cylinder diameter (on clamp)
pivot_clearance = 0.7;       // Radial clearance around pivot in hole

/* [Quality] */
$fn = 80;

// ============================================================
// DERIVED (calculated from free params + constants)
// Never set these manually — change the inputs above instead.
// ============================================================

function boom_dia_eff() =
    boom_is_round ? boom_dia : boom_side * sqrt(2);

// --- Clamp body dimensions (scale with boom_spikes_dia) ---
clamp_body_height = boom_spikes_dia + 2 * clamp_wall;
clamp_body_width  = boom_spikes_dia + 2 * (clamp_wall + clamp_width_extra);

// --- Collar and pivot frame height ---
boom_around_h = fillet_r + print_gap + clamp_body_height + collar_above_clamp;
bs_holder_height = boom_around_h;

// --- Pivot frame plate width (maintains print_gap to clamp body) ---
bs_holder_width = clamp_body_width + 2 * print_gap;

// --- Clamp placement offsets ---
clamp_z_offset = body_height + fillet_r + print_gap + clamp_body_height;
clamp_y_offset = (boom_dia_eff() + boom_around) / 2 + clamp_collar_gap;

// --- Base plate diameter ---
body_side = 2 * (clamp_y_offset + clamp_body_length/2 + base_plate_margin);

// --- Pivot hole in pivot frame (derived from clamp placement + pivot geometry) ---
pivot_hole_dia  = pivot_d + 2 * pivot_clearance;
pivot_hole_h    = clamp_z_offset - pivot_d/2 - body_height;
pivot_hole_dist = pivot_d/2 + clamp_y_offset - boom_dia_eff()/6;

// ============================================================
// MODULES
// ============================================================

module _body() {
    union() {
        // Base plate
        cylinder(d=body_side - 2*fillet_r, h=body_height - fillet_r);
        // Collar around main boom
        cylinder(d=boom_dia_eff() + boom_around - 2*fillet_r, h=body_height + boom_around_h - fillet_r*2);
    }
}

module body() {
    translate([0, 0, fillet_r])
        minkowski() {
            _body();
            sphere(r = fillet_r);
        }
}

module boom_hole() {
    if (boom_is_round) {
        cylinder(h=boom_around_h + body_height + fillet_r, d=boom_dia);
    } else {
        // Square boom: cut tall enough to go through collar
        translate([0, 0, (boom_around_h + body_height)/2])
            cube([boom_side, boom_side, (boom_around_h + body_height) * 3], center=true);
    }
}

module bs_holder() {
    // Pivot frame: two vertical plates that straddle the clamp
    // The boom_dia_eff()/6 offset avoids generating geometry inside
    // the collar (it gets cut by boom_hole anyway)
    translate([-bs_holder_thickness/2, boom_dia_eff()/6, body_height])
    difference() {
        union() {
            eff_width = bs_holder_width + fillet_r*2;
            eff_depth = (body_side - boom_dia_eff() + boom_around*2) / 2;
            // Left plate
            translate([-eff_width/2 - bs_holder_thickness/2, 0, 0])
                cube([bs_holder_thickness, eff_depth, bs_holder_height - fillet_r]);
            // Right plate
            translate([+eff_width/2 + bs_holder_thickness/2, 0, 0])
                cube([bs_holder_thickness, eff_depth, bs_holder_height - fillet_r]);
        }
        // Pivot hole — aligns with clamp pivot cylinders
        translate([-bs_holder_width/2 - bs_holder_thickness/2 - fillet_r*2, pivot_hole_dist, pivot_hole_h])
            rotate([0, 90, 0])
            cylinder(d=pivot_hole_dia, h=bs_holder_width + bs_holder_thickness + fillet_r*8);
    }
}

// ============================================================
// ASSEMBLY
// ============================================================

use <antenna_boom_clamp.scad>

difference() {
    union() {
        body();
        for (i = [0:3]) {
            rotate([0, 0, i * 90])
                union() {
                    minkowski() {
                        bs_holder();
                        sphere(r = fillet_r);
                    }
                    translate([0, clamp_y_offset, clamp_z_offset])
                        rotate([0, 180, 0])
                        antenna_boom_clamp(
                            near_boom_version = true,
                            boom_dia      = boom_spikes_dia,
                            body_height   = clamp_body_height,
                            body_width    = clamp_body_width,
                            body_length   = clamp_body_length,
                            fillet_r      = clamp_fillet_r,
                            ear_drop      = ear_drop,
                            ear_length    = ear_length
                        );
                }
        }
    }
    boom_hole();
}
