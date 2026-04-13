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
near_boom_version = false; // Near-boom version adds pivots for all_in_one assembly
driver_element = false;    // Driver element: 45° wire exit holes for soldering (no horizontal wire hole)

/* [Boom] */
boom_spikes_dia = 8.10;   // Wire boom / spike diameter

/* [Design Constants] */
clamp_wall = 3;            // Wall thickness around boom
clamp_width_extra = 0.35;  // Extra wall per side on width (M3 clearance)
fillet_r = 2;              // Edge rounding radius
ear_drop = 3;              // Clamping ear extension below body
ear_length = 10;           // Y extent of clamping ear
ear_slot_width=0.6;        // ear slot width, don't make too wide (1mm) to avoid cracks when tightening the screw
body_length = 30;          // Y axis (front to rear)

/* [Wire] */
wire_dia = 4;              // Wire pass-through hole diameter (0 to disable)
wire_from_back = 5;        // Distance from back of body to wire hole center
wire_exit_angle = 35;      // Driver: angle from vertical toward the side (degrees)
wire_spread_angle = 20;    // Driver: Y-axis spread between the two exits (degrees)

/* [Hardware] */
slot_width = 1;            // Fixation slot width
pivot_d = 3.6;             // Pivot cylinder diameter
pivot_l = 5;               // Pivot cylinder length
pivot_angle_cut = 90;
m3nut = 6.4;
m3head = 5.7;
m3screw = 3.5;

/* [Lock Detent] */
lock_bump_dia = 4.0;            // Diameter of locking bump sphere
lock_bump_protrusion = 1.5;     // How far bump extends beyond body surface
lock_radius = 6;                // Distance from pivot center to bump center
lock_angle_open = 75;           // Angle at open (print) position (degrees from pivot)

/* [Quality] */
$fn = 80;

// ============================================================
// DERIVED (from boom_spikes_dia + constants)
// ============================================================
body_height = boom_spikes_dia + 2 * clamp_wall;
body_width  = boom_spikes_dia + 2 * (clamp_wall + clamp_width_extra);

// Lock bump position in clamp local frame (YZ, relative to pivot center)
lock_y_open = pivot_d/2 + lock_radius * cos(lock_angle_open);
lock_z_open = pivot_d/2 + lock_radius * sin(lock_angle_open);

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

module wire_hole(body_width, body_length, body_height, wire_dia, wire_from_back, slot_width, driver_element) {
    if (wire_dia > 0) {
        if (driver_element) {
            // Driver element: angled holes on each side of the slot.
            // Each hole starts above boom center, angles outward (±X)
            // and downward (-Z) for pulling wires out for soldering.
            // wire_exit_angle: 0=straight down, 90=horizontal
            // wire_spread_angle: Y-axis spread between the two exits
            for (side = [1, -1]) {
                translate([0, wire_from_back * 2, -body_height*0.2])
                    rotate([0, 0, side < 0 ? 180 : 0])
                    rotate([side < 0 ? -wire_spread_angle : wire_spread_angle,
                            wire_exit_angle, 0])
                    cylinder(d=wire_dia, h=body_width * 2, center=false);
            }
        } else {
            // Regular element: horizontal wire pass-through + vertical exit holes
            translate([0, wire_from_back, body_height/2])
                rotate([0, 90, 0])
                cylinder(d=wire_dia, h=body_width + 20, center=true);
        }
    }
}

module fixation_slot(slot_width, body_length, body_height) {
    translate([-slot_width/2, 0, body_height/2])
        cube([slot_width, body_length, 20]);
}

module nut_hole(body_width, body_length, body_height) {
    translate([-10, body_length-5, body_height-0.5])
        rotate([0, 90, 0])
        union() {
            cylinder(d=m3nut, h=6, $fn=6);
            cylinder(d=m3screw, h=body_width*2);
            translate([0, 0, body_width-1])
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

module lock_bump(body_width, lock_y, lock_z, bump_dia, bump_protrusion) {
    // Spherical bumps on both sides of the body near the pivot.
    // The sphere center is shifted inside the body so only
    // bump_protrusion extends past the body surface.
    for (side = [1, -1]) {
        translate([side * (body_width/2 - bump_dia/2 + bump_protrusion), lock_y, lock_z])
            sphere(d=bump_dia);
    }
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
    ear_length = 10,
    lock_y = undef,
    lock_z = undef,
    lock_d = 4.0,
    lock_p = 1.5
) {
    // undef params fall back to file-level derived values for standalone use.
    _bw = (body_width == undef)  ? boom_dia + 2*(clamp_wall + clamp_width_extra) : body_width;
    _bh = (body_height == undef) ? boom_dia + 2*clamp_wall : body_height;
    _ly = (lock_y == undef) ? lock_y_open : lock_y;
    _lz = (lock_z == undef) ? lock_z_open : lock_z;

    difference() {
        union() {
            clamp_body(_bw, body_length, _bh, fillet_r, ear_drop, ear_length);
            // Near-boom version adds pivots + lock bumps for all_in_one assembly
            if (near_boom_version) {
                translate([_bw/2, 0, 0]) pivot(fillet_r);
                translate([0, pivot_d, 0])
                    rotate([0, 0, 180])
                    translate([_bw/2, 0, 0]) pivot(fillet_r);
                // Detent bumps on both sides for snap-fit locking
                lock_bump(_bw, _ly, _lz, lock_d, lock_p);
            }
        }
        clamp_boom_hole(_bh, body_length, boom_dia, ear_drop, fillet_r);
        clamp_boom_hole_insert(body_length, _bh, boom_dia);
       
        if (near_boom_version) {
            back_bend_insert(slot_width, body_length);
        } else {
             wire_hole(_bw, body_length, _bh, wire_dia, wire_from_back, slot_width, driver_element);
        }
        fixation_slot(slot_width, body_length-ear_length, _bh);
        translate([0,body_length-ear_length,0]) fixation_slot(ear_slot_width, ear_length, _bh);
        nut_hole(_bw, body_length, _bh);
    }
}

// ============================================================
// STANDALONE RENDER (for Customizer / direct rendering)
// ============================================tra================
antenna_boom_clamp(
    near_boom_version = near_boom_version,
    boom_dia      = boom_spikes_dia,
    body_length   = body_length,
    fillet_r      = fillet_r,
    ear_drop      = ear_drop,
    ear_length    = ear_length,
    lock_d        = lock_bump_dia,
    lock_p        = lock_bump_protrusion
);
