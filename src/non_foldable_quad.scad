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
render_part    = "all";     // "x" or "boom" - dispatcher
element_index  = 0;       // 0=reflector, 1=driven, 2..=director N (director N => index N+1)
segment_index  = 0;       // 0 = reflector<->driven gap (0.20 lambda), >=1 = 0.15 lambda gaps
driven_element = false;   // Driven X: central coax bore + 45 deg solder exits

/* [Antenna] */
freq          = 868.0;    // MHz
vf            = 0.95;     // wire velocity factor
num_directors = 2;        // total elements = 2 + num_directors

/* [Mechanical] */
boom_dia    = 8.0;        // Boom square side length; socket side = boom_dia + print_gap
rod_side    = 8.0;        // Printed rod cross section (square, filleted)
max_rod_len = 220;        // Assert guard against unprintable rods
handle_len    = 80;      // Extra boom segment length to use as mast/handle

// ============================================================
// DESIGN CONSTANTS (hardware / printability, rarely changed)
// ============================================================

/* [Hidden] */
print_gap     = 0.01;     // Press-fit clearance (matches all_in_one.scad)
hub_wall      = 3;        // Wall thickness around the boom socket
// hub_height is derived below: it must be >= rod_side so the horizontal
// rods attach to a full-height hub face (no support material needed).
socket_depth  = 14;       // Boom-socket depth into hub / segment
rod_fillet    = 1.2;      // Rod edge rounding
total_h = rod_side - 2 * rod_fillet;
plug_len      = 12+total_h;       // Male plug length on boom segment
wire_tip_hole = 1.6;      // Transverse through-hole at rod tip for wire tie
feed_hole_d   = 5.0;      // Coax strain-relief bore (driven only)
solder_slot_w = 2.2;      // Solder-exit slot width (driven only)
solder_slot_h = 4.0;      // Solder-exit slot height (driven only)
tip_inset     = 3.0;      // Distance from rod tip to wire-tie hole center
label_depth   = 0.6;      // How deep to emboss the element label into the hub top
label_size    = 4.0;      // Label text height (mm)
endcap_len    = 20;       // End-cap boom total length (closed tail past last X)


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

echo(str("freq=", freq, " MHz  lambda=", lambda, " mm  vf=", vf,
         "  num_directors=", num_directors));
echo(str("k factors: ", k_vec));

// Per-element dimensions (covers every X that "all" mode would print).
for (i = [0 : 1 + num_directors]) {
    _perim = k_vec[i] * lambda * vf;
    _side  = _perim / 4;
    _rod   = _side * sqrt(2) / 2;
    _role  = (i == 0) ? "reflector"
            : (i == 1) ? "driven"
            : str("director", i - 1);
    echo(str("element[", i, "] ", _role,
             "  perim=", _perim, " mm  side=", _side,
             " mm  rod_len=", _rod, " mm"));
}

// Per-segment dimensions (one per gap in "all" mode).
for (i = [0 : len(spacings) - 1]) {
    _gap = (i == 0) ? "reflector<->driven"
         : (i == 1) ? "driven<->director1"
                    : str("director", i - 1, "<->director", i);
    echo(str("segment[", i, "] ", _gap,
             "  seg_len=", spacings[i], " mm"));
}
echo(str("segment[handle] mast/handle  seg_len=", handle_len, " mm"));
echo(str("segment[endcap] front cap    cap_len=", endcap_len, " mm"));

// Dispatcher-specific values (for "x" and "boom" render modes).
echo(str("dispatcher element_index=", element_index,
         "  perim=", perim, " mm  side=", side_len,
         " mm  rod_len=", rod_len, " mm"));
echo(str("dispatcher segment_index=", segment_index,
         "  seg_len=", seg_len, " mm"));

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

module _rod_with_tip_hole(rod_len, rod_side, fillet_r, tip_hole_d, tip_inset, driven_hole) {
    // Straight through-hole at the tip, perpendicular to the rod axis
    // and lying in the plane of the four spreaders (XZ plane for the +X
    // rod). The wire enters from the neighbor on one side, exits toward
    // the neighbor on the other side, and the bend happens outside the
    // rod - so the hole itself stays straight and easy to thread.
    difference() {
        _rod(rod_len, rod_side, fillet_r);
        translate([rod_len - tip_inset, 0, 0])
            if (driven_hole) {
                 translate([-rod_side/2,+rod_side/2,rod_side/8])
                 rotate([45,45,0])
                 cylinder(
                    d = tip_hole_d*1.5,
                    h = rod_side * 3,
                    center = true
                );
                translate([-rod_side/2,+rod_side/2,-rod_side/8])
                 rotate([45,45+90,0])
                 cylinder(
                    d = tip_hole_d*1.5,
                    h = rod_side * 3,
                    center = true
                );
            } else {
                cylinder(
                    d = tip_hole_d,
                    h = rod_side * 3,
                    center = true
                );
            }
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
//
// label: optional short string embossed on the +Z face of the hub (e.g.
// "R", "D", "1", "2") for identification. Empty string disables it.
module quad_x_element(
    rod_len, rod_side, boom_dia, hub_side, hub_height, driven, label = ""
) {
    difference() {
        union() {
            _hub_solid(hub_side, hub_height, rod_fillet);
            // 4 rods at 0/90/180/270 deg around the boom axis (Y).
            // Rotation is around +Y so rods spread in the XZ plane.
            for (a = [0, 90, 180, 270]) {
                let (driven_hole = (driven && (a == 0)))
                    rotate([0, a, 0])
                        _rod_with_tip_hole(
                            rod_len, rod_side, rod_fillet,
                            wire_tip_hole, tip_inset, driven_hole
                        );
            }
        }
        _hub_boom_socket(boom_dia, print_gap, hub_side);
    }
}

// boom_endcap - closed tail with a socket (blind hole) on the -Y side.
// Slides over the last boom segment's plug that sticks out past the
// final X hub, sealing the front of the antenna. Label embossed on the
// top (+Z) face near the socket end. The four edges around the closed
// (+Y) end are chamfered for a cleaner finish.
module boom_endcap(cap_len, boom_dia, label = "") {
    od    = boom_dia + 2 * hub_wall;
    soc   = boom_dia + print_gap;
    chamf = hub_wall * 0.6;       // 45 deg chamfer depth on the tip edges

    difference() {
        // Solid closed body spanning Y=0 .. Y=cap_len.
        translate([-od/2, 0, -od/2])
            cube([od, cap_len, od]);

        // Blind socket on the -Y end, depth = socket_depth.
        translate([-soc/2, 0, -soc/2])
            cube([soc, socket_depth, soc]);

        // 45 deg chamfer on the four edges of the closed (+Y) tip.
        // Each cutter is a small cube rotated 45 deg about the edge axis
        // and centered on the edge so half its body sticks out past the
        // end, removing a triangular prism of depth `chamf`.
        cutter = chamf * sqrt(2);

        // X-running edges: top (+Z) and bottom (-Z) of the +Y face.
        for (sz = [+1, -1]) {
            translate([0, cap_len, sz * od/2])
                rotate([45, 0, 0])
                    cube([od * 3, cutter, cutter], center = true);
        }
        // Z-running edges: left (-X) and right (+X) of the +Y face.
        for (sx = [+1, -1]) {
            translate([sx * od/2, cap_len, 0])
                rotate([0, 0, 45])
                    cube([cutter, cutter, od * 3], center = true);
        }

        if (label != "") {
            // Label on the top face, anchored right at the socket (-Y)
            // rim. valign="bottom" pins the bottom of the glyphs to the
            // socket_depth line, so the text grows outward toward the
            // closed end and stays well clear of the chamfer.
            translate([0, 1, od/2 - label_depth])
                linear_extrude(height = label_depth + 0.2)
                    text(
                        text   = label,
                        size   = label_size,
                        halign = "center",
                        valign = "bottom",
                        font   = "Liberation Sans:style=Bold"
                    );
        }
    }
}

// boom_segment - short square boom stub with a male plug on +Y and a
// female socket on -Y. Mates into the X hub's square through-socket on
// adjacent X elements. Segments never couple directly to each other.
//
// label_minus / label_plus: short tags embossed on the top (+Z) face
// near the -Y and +Y ends respectively, indicating which X element
// each end plugs into (e.g. "R" and "D"). Empty string disables.
// label_center_1 / label_center_2: optional two-line vanity text
// embossed in the middle of the top face (e.g. "EA4IPW" / "OpenQuad").
module boom_segment(
    seg_len, boom_dia,
    label_minus = "", label_plus = "",
    label_center_1 = "", label_center_2 = ""
) {
    od   = boom_dia + 2 * hub_wall;    // outer side of the segment body
    plug = boom_dia - print_gap;       // male plug side (fits into socket)
    soc  = boom_dia + print_gap;       // female socket side (accepts plug)

    // Text sits at z = od/2, extruded downward by label_depth. Place
    // each label close to its own border (just inside the rim) so the
    // two ends read clearly even on short segments.
    label_inset = label_size * 0.75;

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

        // Labels on the top face, near each end (past the socket/plug).
        if (label_minus != "") {
            translate([0, label_inset, od/2 - label_depth])
                linear_extrude(height = label_depth + 0.2)
                    text(
                        text   = label_minus,
                        size   = label_size,
                        halign = "center",
                        valign = "center",
                        font   = "Liberation Sans:style=Bold"
                    );
        }
        if (label_plus != "") {
            translate([0, seg_len - label_inset, od/2 - label_depth])
                linear_extrude(height = label_depth + 0.2)
                    text(
                        text   = label_plus,
                        size   = label_size,
                        halign = "center",
                        valign = "center",
                        font   = "Liberation Sans:style=Bold"
                    );
        }

        // Two-line vanity text centered on the body. Smaller than the
        // end tags to fit within the narrow boom width; each line reads
        // along the boom length (X-axis after lay-flat).
        if (label_center_1 != "" || label_center_2 != "") {
            center_size = label_size * 0.95;
            row_spacing = center_size * 1.2;
            center_y    = seg_len / 2;
            for (row = [[label_center_1, +row_spacing / 2],
                        [label_center_2, -row_spacing / 2]]) {
                if (row[0] != "") {
                    translate([row[1], center_y, od/2 - label_depth])
                        rotate([0, 0, 90])
                        linear_extrude(height = label_depth + 0.2)
                            text(
                                text   = row[0],
                                size   = center_size,
                                halign = "center",
                                valign = "center",
                                font   = "Liberation Sans:style=Bold"
                            );
                }
            }
        }
    }
}

// ============================================================
// ASSEMBLY (dispatch)
// ============================================================

// ---- Layout helpers for render_part="all" (full print plate) ----

// X element rotated so the rod fan lies in the XY plane (flat on the bed).
// Native X has boom axis along Y and rods in XZ; rotating -90 deg around X
// sends the boom axis to Z (boom sticks up) and the rods into XY.
module _x_lay_flat(rod_len, rod_side, boom_dia, hub_side, hub_height, driven, label = "") {
    // Lay the X flat on the bed (rods spread in XY, boom axis along Z),
    // then carve the label into the top (+Z) face of the +X rod so the
    // text is visible looking straight down at the print bed.
    difference() {
        rotate([-90, 0, 0])
            quad_x_element(
                rod_len    = rod_len,
                rod_side   = rod_side,
                boom_dia   = boom_dia,
                hub_side   = hub_side,
                hub_height = hub_height,
                driven     = driven,
                label      = ""
            );

        // Label cut on the top face of the +X rod. Top surface after
        // lay-flat sits at z = +rod_side/2; we extrude downward from
        // slightly above so a small overlap guarantees a clean cut.
        if (label != "") {
            // Place the text a bit past the hub so it clears the boom
            // socket boss. label_x = rod root + small margin.
            label_x = hub_side / 2 + label_size * 0.6;
            translate([label_x, 0, rod_side / 2 - label_depth])
                linear_extrude(height = label_depth + 0.2)
                    text(
                        text   = label,
                        size   = label_size,
                        halign = "center",
                        valign = "center",
                        font   = "Liberation Sans:style=Bold"
                    );
        }
    }
}

// Short identifier for element index i: "R" reflector, "D" driven,
// "1","2",... directors. Used to emboss each X hub.
function element_label(i) =
    (i == 0) ? "R"
  : (i == 1) ? "D"
             : str(i - 1);

// Boom segment laid flat with its long axis along +X, starting at origin.
// The native -Y end (socket) lands at +X=0; +Y end (plug) at +X=seg_len.
// label_minus -> socket end; label_plus -> plug end.
module _boom_lay_flat(
    seg_len, boom_dia,
    label_minus = "", label_plus = "",
    label_center_1 = "", label_center_2 = ""
) {
    rotate([0, 0, -90])
        boom_segment(
            seg_len        = seg_len,
            boom_dia       = boom_dia,
            label_minus    = label_minus,
            label_plus     = label_plus,
            label_center_1 = label_center_1,
            label_center_2 = label_center_2
        );
}

// End-cap boom laid flat along +X. Plug lands at +X=cap_len (plug points
// outward in +X after the -90 deg rotation around Z).
module _endcap_lay_flat(cap_len, boom_dia, label = "") {
    rotate([0, 0, -90])
        boom_endcap(cap_len = cap_len, boom_dia = boom_dia, label = label);
}

if (render_part == "x") {
    // Single X: lay flat so the label is readable on top of the +X rod.
    _x_lay_flat(
        rod_len    = rod_len,
        rod_side   = rod_side,
        boom_dia   = boom_dia,
        hub_side   = hub_side,
        hub_height = hub_height,
        driven     = driven_element,
        label      = element_label(element_index)
    );
} else if (render_part == "boom") {
    boom_segment(seg_len = seg_len, boom_dia = boom_dia);
} else if (render_part == "all") {
    // Lay every X element (one per element_index 0..total-1) and every
    // boom segment (one per unique gap) flat on the print bed, spaced
    // apart so nothing overlaps. X elements are spread along +X (row);
    // boom segments go in a second row below (negative Y).

    total_elems = 2 + num_directors;

    // Rod-length per element (max = reflector/idx 0).
    rod_len_of = function (idx)
        (k_vec[idx] * lambda * vf / 4) * sqrt(2) / 2;
    max_rod = rod_len_of(0);

    // Each laid-flat X spans 2*rod_len + hub_side along both X and Y.
    // Use the reflector's footprint for a uniform cell pitch.
    gap    = 5;
    cell   = 2 * max_rod + hub_side + gap;

    // Interlocked pack: alternate X-elements' rotation by 45 deg so
    // neighbors' rods slot into each other's empty corners. Pitch along
    // +X shrinks from (2*rod_len + hub_side) to ~(rod_len + hub_side/2),
    // roughly halving the print footprint.
    pack_pitch = max_rod + hub_side / 2 + gap;
    pack_y0    = max_rod + hub_side / 2;   // clearance from Y=0 edge
    for (i = [0 : total_elems - 1]) {
        rot = (i % 2 == 0) ? 0 : 45;
        translate([pack_pitch / 2 + i * pack_pitch, pack_y0, 0])
            rotate([0, 0, rot])
                _x_lay_flat(
                    rod_len    = rod_len_of(i),
                    rod_side   = rod_side,
                    boom_dia   = boom_dia,
                    hub_side   = hub_side,
                    hub_height = hub_height,
                    driven     = (i == 1),
                    label      = element_label(i)
                );
    }

    // Boom segments: laid flat below the interlocked row, long axis +X,
    // stacked along -Y so longer segments don't collide with shorter ones.
    // An extra segment of length handle_len is added at the end to serve
    // as a mast/handle that plugs into the reflector's back socket.
    // Labels show which X element each end plugs into.
    num_segs     = len(spacings);
    boom_pitch_y = boom_dia + 2 * hub_wall + gap;
    booms_y0     = -(boom_dia + 2 * hub_wall) / 2 - gap;
    for (i = [0 : num_segs - 1]) {
        // segment[i] connects element_label(i) (-Y end) to element_label(i+1) (+Y end).
        translate([0, booms_y0 - i * boom_pitch_y, 0])
            // Center-to-center X-hub spacing must equal spacings[i].
            // The chain is [seg body | X hub through-socket | next seg body];
            // the X hub consumes hub_height (= rod_side) between bodies,
            // so seg body length = target spacing - hub_height.
            _boom_lay_flat(
                seg_len     = spacings[i] - hub_height,
                boom_dia    = boom_dia,
                label_minus = element_label(i),
                label_plus  = element_label(i + 1)
            );
    }
    // Mast/handle segment: plug end goes into the reflector.
    // Stamped with an EA4IPW / OpenQuad attribution on the top face.
    translate([0, booms_y0 - num_segs * boom_pitch_y, 0])
        _boom_lay_flat(
            seg_len        = handle_len,
            boom_dia       = boom_dia,
            label_minus    = "H",
            label_plus     = "R",
            label_center_1 = "EA4IPW",
            label_center_2 = "OpenQuad"
        );

    // End-cap: plugs into the last director's free (+Y) socket to seal
    // the front of the boom. The plug is the +X end after lay-flat.
    translate([0, booms_y0 - (num_segs + 1) * boom_pitch_y, 0])
        _endcap_lay_flat(
            cap_len  = endcap_len,
            boom_dia = boom_dia,
            label    = str(num_directors)
        );
} else {
    assert(false,
        str("render_part must be \"x\", \"boom\", or \"all\", got: ", render_part));
}
