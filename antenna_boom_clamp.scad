// Antenna Boom / Wire Clamp - v5
// Clamp body for wire boom spikes, with optional pivots for
// print-in-place assembly in all_in_one.scad
// EA4IPW - Parametric design

// ============================================================
// FREE PARAMETERS (for standalone Customizer use)
// When called from all_in_one.scad, these are overridden
// by the module arguments.
// ============================================================

/* [Type] */
near_boom_version = true; // Near-boom version adds pivots for all_in_one assembly

/* [Boom] */
boom_spikes_dia = 8.10;   // Wire boom / spike diameter

/* [Design Constants] */
clamp_wall = 3;            // Wall thickness around boom
clamp_width_extra = 0.35;  // Extra wall per side on width (M3 clearance)
fillet_r = 2;              // Edge rounding radius
ear_drop = 3;              // Clamping ear extension below body
ear_length = 10;           // Y extent of clamping ear
body_length = 25;          // Y axis (front to rear)

/* [Hardware] */
slot_width = 1;            // Fixation slot width
pivot_d = 3.6;             // Pivot cylinder diameter
pivot_l = 5;               // Pivot cylinder length
pivot_angle_cut = 90;
m3nut = 6.2;
m3head = 5.5;
m3screw = 3.5;

/* [Quality] */
$fn = 80;

// ============================================================
// DERIVED (from boom_spikes_dia + constants)
// ============================================================
body_height = boom_spikes_dia + 2 * clamp_wall;
body_width  = boom_spikes_dia + 2 * (clamp_wall + clamp_width_extra);

// ============================================================
// MODULES
// ============================================================

module _clamp_body(body_width, body_length, body_height, fillet_r, ear_drop, ear_length) {
    union() {
        cube([
            body_width  - 2*fillet_r,
            body_length - 2*fillet_r,
            body_height - 2*fillet_r
        ]);
        // the "ear", later slotted for fixation
        translate([0, body_length - ear_length, 0])
            cube([body_width - 2*fillet_r, ear_length - fillet_r*2, body_height - 2*fillet_r + ear_drop]);
    }
}

module clamp_body(body_width, body_length, body_height, fillet_r, ear_drop, ear_length) {
    translate([-body_width/2 + fillet_r, fillet_r, fillet_r])
        minkowski() {
            _clamp_body(body_width, body_length, body_height, fillet_r, ear_drop, ear_length);
            sphere(r = fillet_r);
        }
}

module clamp_boom_hole(body_height, body_length, boom_dia, ear_drop, fillet_r) {
    // Horizontal hole for wire boom, through the body center
    translate([0, 5, body_height/2])
        rotate([90, 0, 180])
        cylinder(d=boom_dia, h=body_height + ear_drop + 40);
}

module clamp_boom_hole_insert(body_length, body_height, boom_dia) {
    // Chamfered entry for boom insertion
    translate([0, body_length, body_height/2])
        rotate([90, 0, 0])
        cylinder(d1=boom_dia+1, d2=boom_dia, h=1);
}

module fixation_slot(slot_width, body_length, body_height) {
    translate([-slot_width/2, 0, body_height/2])
        cube([slot_width, body_length, 20]);
}

module nut_hole(body_width, body_length, body_height) {
    translate([-10, body_length-5, body_height+1])
        rotate([0, 90, 0])
        union() {
            cylinder(d=m3nut, h=5, $fn=6);
            cylinder(d=m3screw, h=body_width*2);
            translate([0, 0, body_width])
                cylinder(d=m3head, h=5);
        }
}

module pivot(fillet_r) {
    difference() {
        translate([-fillet_r, pivot_d/2, pivot_d/2])
            rotate([0, 90, 0])
            cylinder(d=pivot_d, h=pivot_l+fillet_r);
        translate([pivot_l*0.8, pivot_d/2, pivot_d])
            rotate([0, pivot_angle_cut])
            cube([20, pivot_d, pivot_d], center=true);
    }
}

module back_bend_insert(slot_width, body_length) {
    translate([-slot_width/2, 0, 0])
        cube([slot_width, body_length/3, 20]);
}

// ============================================================
// MAIN MODULE
// All parameters have defaults matching the file-level derived
// values. When called from all_in_one.scad, pass overrides.
// ============================================================
module antenna_boom_clamp(
    near_boom_version = true,
    body_width = undef,
    body_length = 25,
    body_height = undef,
    fillet_r = 2,
    boom_dia = 8.10,
    ear_drop = 3,
    ear_length = 10
) {
    // Use file-level derived values when called standalone (undef)
    _bw = (body_width == undef)  ? boom_dia + 2*(clamp_wall + clamp_width_extra) : body_width;
    _bh = (body_height == undef) ? boom_dia + 2*clamp_wall : body_height;

    difference() {
        union() {
            clamp_body(_bw, body_length, _bh, fillet_r, ear_drop, ear_length);
            // Near-boom version adds pivots for all_in_one assembly
            if (near_boom_version) {
                translate([_bw/2, 0, 0]) pivot(fillet_r);
                translate([0, pivot_d, 0])
                    rotate([0, 0, 180])
                    translate([_bw/2, 0, 0]) pivot(fillet_r);
            }
        }
        clamp_boom_hole(_bh, body_length, boom_dia, ear_drop, fillet_r);
        clamp_boom_hole_insert(body_length, _bh, boom_dia);
        if (near_boom_version) {
            back_bend_insert(slot_width, body_length);
        }
        fixation_slot(slot_width, body_length, _bh);
        nut_hole(_bw, body_length, _bh);
    }
}

// ============================================================
// STANDALONE RENDER (for Customizer / direct rendering)
// ============================================================
antenna_boom_clamp(near_boom_version=near_boom_version);
