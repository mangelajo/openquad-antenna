// Non-Foldable Cubical Quad - v1
// Integrated-rod X element + boom segment couplers.
// EA4IPW - Parametric design
//
// Pattern:  [boom_seg]-X-[boom_seg]-X- ... -X-[boom_seg]
// The X hub and its 4 rods are printed as a single piece (no fiberglass).
// Each boom segment carries a male plug on one end and a female socket on
// the other; the X hub has simple through-sockets on +/-Y.
//
// Parameters match the web calculator (web/calc.js): frequency (MHz),
// velocity factor, and number of directors drive the geometry, so the
// printed parts match what the calculator shows on screen.
//
// Integrated rods are limited by the print bed. Suitable for VHF/UHF.
// For HF / 6m, use the foldable design (all_in_one.scad).

// ============================================================
// FREE PARAMETERS
// ============================================================

/* [Render] */
render_part    = "x";     // "x" or "boom" - dispatcher
element_index  = 0;       // 0=reflector, 1=driven, 2..=director N (director N => index N+1)
segment_index  = 0;       // 0 = reflector<->driven gap (0.20 lambda), >=1 = 0.15 lambda gaps
driven_element = false;   // Driven X: central coax bore + 45 deg solder exits

/* [Antenna] */
freq          = 868.0;    // MHz
vf            = 0.95;     // wire velocity factor
num_directors = 5;        // total elements = 2 + num_directors

/* [Mechanical] */
boom_dia    = 8.0;        // Boom square side length; socket side = boom_dia + print_gap
rod_side    = 8.0;        // Printed rod cross section (square, filleted)
max_rod_len = 220;        // Assert guard against unprintable rods

// ============================================================
// DESIGN CONSTANTS (hardware / printability, rarely changed)
// ============================================================

/* [Hidden] */
print_gap     = 0.20;     // Press-fit clearance (matches all_in_one.scad)
hub_wall      = 3;        // Wall thickness around the boom socket
// hub_height is derived below: it must be >= rod_side so the horizontal
// rods attach to a full-height hub face (no support material needed).
socket_depth  = 14;       // Boom-socket depth into hub / segment
plug_len      = 12;       // Male plug length on boom segment
rod_fillet    = 1.2;      // Rod edge rounding
wire_tip_hole = 1.6;      // Transverse through-hole at rod tip for wire tie
feed_hole_d   = 5.0;      // Coax strain-relief bore (driven only)
solder_slot_w = 2.2;      // Solder-exit slot width (driven only)
solder_slot_h = 4.0;      // Solder-exit slot height (driven only)
tip_inset     = 3.0;      // Distance from rod tip to wire-tie hole center

/* [Hidden] */
$fn = 80;

// ============================================================
// DERIVED - calculator math, mirrors web/calc.js
// ============================================================

C_MM_MHZ = 299792.458;

lambda   = C_MM_MHZ / freq;

// Element k factors: [reflector, driven, dir1, dir2, ...]
// Directors cascade by 0.97 per step: dir_n = 1.022 * 0.97^n (n>=1).
// This matches web/calc.js elementConstant(): CONSTANTS.director=0.991
// is itself 1.022 * 0.97, then DIRECTOR_RATIO=0.97 compounds per index.
k_vec = concat(
    [1.047, 1.022],
    [for (n = [1 : num_directors]) 1.022 * pow(0.97, n)]
);

perim    = k_vec[element_index] * lambda * vf;
side_len = perim / 4;
rod_len  = side_len * sqrt(2) / 2;   // hub-center to square-loop corner

// Spacings: [refl<->driven (0.20 lambda), driven<->dir1, dirN<->dirN+1, ...] (0.15 lambda)
spacings = concat(
    [0.20 * lambda],
    [for (n = [1 : num_directors]) 0.15 * lambda]
);
seg_len = spacings[segment_index];

// Hub outer footprint. hub_wall is the wall thickness per side around the
// boom socket, so the hub_side must grow by 2*hub_wall (not 1*) to keep
// the hub walls intact after the boom through-socket is subtracted.
hub_side = boom_dia + 2 * hub_wall;

// Hub Z extent: match the rod cross-section so the rods attach to a
// full-height face and the part prints without support material.
hub_height = rod_side;

// Guard: rod must fit the print bed
assert(
    rod_len <= max_rod_len,
    str("rod_len=", rod_len, "mm exceeds max_rod_len=", max_rod_len,
        "mm - use the foldable design for this band")
);

echo(str("freq=", freq, " MHz  lambda=", lambda, " mm  vf=", vf));
echo(str("k factors: ", k_vec));
echo(str("element_index=", element_index,
         "  perim=", perim, " mm  side=", side_len,
         " mm  rod_len=", rod_len, " mm"));
echo(str("segment_index=", segment_index, "  seg_len=", seg_len, " mm"));
echo(str("all spacings (mm): ", spacings));

// ============================================================
// MODULES
// ============================================================

// Filleted square rod extending along +X from the hub face.
// Length is measured hub-center to tip, so the rod cube starts at X=0
// (hub center) and ends at X=rod_len.
module _rod(rod_len, rod_side, fillet_r) {
    // Rounded square prism via minkowski. Inner cube is shrunk by 2*fillet_r
    // in every dim so the final shape stays at [rod_side x rod_side x rod_len].
    inner_s = rod_side - 2 * fillet_r;
    inner_l = rod_len  - 2 * fillet_r;
    translate([fillet_r, -rod_side/2 + fillet_r, -rod_side/2 + fillet_r])
        minkowski() {
            cube([inner_l, inner_s, inner_s]);
            sphere(r = fillet_r);
        }
}

module _rod_with_tip_hole(rod_len, rod_side, fillet_r, tip_hole_d, tip_inset) {
    // Straight through-hole at the tip, perpendicular to the rod axis
    // and lying in the plane of the four spreaders (XZ plane for the +X
    // rod). The wire enters from the neighbor on one side, exits toward
    // the neighbor on the other side, and the bend happens outside the
    // rod - so the hole itself stays straight and easy to thread.
    difference() {
        _rod(rod_len, rod_side, fillet_r);
        translate([rod_len - tip_inset, 0, 0])
            cylinder(
                d = tip_hole_d,
                h = rod_side * 3,
                center = true
            );
    }
}

// Central hub: rounded square prism with boom through-socket on +/-Y.
module _hub_solid(hub_side, hub_height, fillet_r) {
    inner = hub_side - 2 * fillet_r;
    inner_h = hub_height - 2 * fillet_r;
        minkowski() {
            //cube([inner, inner_h, inner_h*4], center=true);
                    rotate([90,0,0])
         cylinder(h=inner_h, boom_dia*0.90,boom_dia*0.90, center=true);

            sphere(r = fillet_r);
        }

}

module _hub_boom_socket(boom_dia, print_gap, hub_side) {
    // Square through-hole along Y for the boom. boom_dia is the square
    // boom's side length; the cut is (boom_dia + print_gap) on a side
    // and extends well past both hub faces so it pierces cleanly.
    s = boom_dia + print_gap;
    cube([s, hub_side * 3, s], center = true);
}

module _driven_features(hub_side, hub_height, feed_hole_d, solder_w, solder_h) {
    // Vertical coax strain-relief bore through the hub.
    cylinder(d = feed_hole_d, h = hub_height * 3, center = true);

    // Two solder-exit slots on top of the hub, at +/-X, pointing outward
    // at 45 deg toward the rod bases so feedline wires can be soldered to
    // the driven loop.
    for (side = [1, -1]) {
        translate([side * hub_side / 2, 0, 0])
            rotate([0, side * 45, 0])
            translate([0, -solder_w/2, -solder_h/2])
                cube([hub_side, solder_w, solder_h]);
    }
}

// quad_x_element - central hub with 4 integrated rods at 0/90/180/270 deg
// (aligned to the boom, not diamond). The rod length is driven by the
// element_index via rod_len (computed above from the calculator math).
//
// Axes:
//   +/-Y : boom axis (through-socket here)
//   +/-X, +/-Z : four rod directions (square/aligned orientation)
module quad_x_element(
    rod_len, rod_side, boom_dia, hub_side, hub_height, driven
) {
    difference() {
        union() {
            _hub_solid(hub_side, hub_height, rod_fillet);
            // 4 rods at 0/90/180/270 deg around the boom axis (Y).
            // Rotation is around +Y so rods spread in the XZ plane.
            for (a = [0, 90, 180, 270]) {
                rotate([0, a, 0])
                    _rod_with_tip_hole(
                        rod_len, rod_side, rod_fillet,
                        wire_tip_hole, tip_inset
                    );
            }
        }
        _hub_boom_socket(boom_dia, print_gap, hub_side);

        if (driven) {
            _driven_features(
                hub_side, hub_height, feed_hole_d,
                solder_slot_w, solder_slot_h
            );
        }
    }
}

// boom_segment - short square boom stub with a male plug on +Y and a
// female socket on -Y. Mates into the X hub's square through-socket on
// adjacent X elements. Segments never couple directly to each other.
module boom_segment(seg_len, boom_dia) {
    od   = boom_dia + 2 * hub_wall;    // outer side of the segment body
    plug = boom_dia - print_gap;       // male plug side (fits into socket)
    soc  = boom_dia + print_gap;       // female socket side (accepts plug)

    difference() {
        union() {
            // Main square body spanning Y=0 .. Y=seg_len.
            translate([-od/2, 0, -od/2])
                cube([od, seg_len, od]);

            // Male plug on +Y end.
            translate([-plug/2, seg_len, -plug/2])
                cube([plug, plug_len, plug]);
        }

        // Female socket on -Y end (cut inward along +Y from the -Y face).
        translate([-soc/2, 0, -soc/2])
            cube([soc, socket_depth, soc]);
    }
}

// ============================================================
// ASSEMBLY (dispatch)
// ============================================================

if (render_part == "x") {
    quad_x_element(
        rod_len     = rod_len,
        rod_side    = rod_side,
        boom_dia    = boom_dia,
        hub_side    = hub_side,
        hub_height  = hub_height,
        driven      = driven_element
    );
} else if (render_part == "boom") {
    boom_segment(seg_len = seg_len, boom_dia = boom_dia);
} else {
    assert(false, str("render_part must be \"x\" or \"boom\", got: ", render_part));
}
