// Handle Double-Tube Clamp - v1
// Two-half clamp that grips two parallel round tubes and exposes a
// solid square male plug (7.99 mm sq, 17.6 mm long) that inserts into
// the mast/handle boom_segment's female socket (see non_foldable_quad.scad).
// EA4IPW - Parametric design
//
// Hardware: 2x M3x10 screws + hex nuts. Heads recess into the bottom
// half (from the outer -Z face), nuts sit in pockets on the top half
// (from the outer +Z face, alongside the plug). Screws sit in the
// midline between the two tubes, flanking the plug. 5mm-deep recesses
// on each side leave 10mm of material between them to match the M3x10
// shaft length.

// ============================================================
// FREE PARAMETERS
// ============================================================

/* [Render] */
render_part    = "both";   // "top", "bottom", or "both" (print plate)

/* [Tubes] */
tube_dia       = 13.4;     // Clamped tube outer diameter
tube_spacing   = 40.0;     // Center-to-center between the two tubes
tube_clearance = 0.10;     // Added to bore diameter; M3s close the rest

/* [Body] */
clamp_length   = 28.0;     // Along tube axis (Y)
wall           = 5.0;      // Material around each tube bore
end_margin     = 5.0;      // Material from tube outer surface to body X-end

// ============================================================
// DESIGN CONSTANTS (hardware / printability)
// ============================================================

/* [Hidden] */
boom_dia          = 8.0;   // Mirrors non_foldable_quad.scad
print_gap         = 0.01;  // Press-fit clearance (same convention)
hub_wall          = 3;     // Wall around the socket (matches boom_segment)
socket_depth      = 14;    // Depth of the blind square socket
fillet_r          = 2;     // Minkowski sphere radius for rounded body
m3screw           = 3.5;   // M3 clearance hole
m3head            = 5.7;   // M3 socket-head cap diameter
m3nut             = 6.4;   // M3 hex nut across-corners (pocket dia)
// M3x10 screw budget: head (~3mm) + 10mm under-head length.
// Recesses sized so head-bottom and nut-top leave exactly 10mm of
// material between them, matching the screw's under-head length:
//   body_height (20) - head_recess (5) - nut_pocket (5) = 10 mm.
nut_pocket_depth  = 8.0;
head_recess_depth = 8.0;
screw_edge        = 5.0;   // Y distance from body end to screw center
eps               = 0.01;  // Overcut for clean boolean cuts

/* [Hidden] */
$fn = 80;

// ============================================================
// DERIVED
// ============================================================

bore_dia    = tube_dia + tube_clearance;
body_height = tube_dia + 2 * wall;
body_width  = tube_spacing + tube_dia + 2 * end_margin;
half_h      = body_height / 2;

// Solid male plug that slots into the handle boom_segment's female
// socket. Matches the plug geometry from non_foldable_quad.scad.
plug_side   = boom_dia - print_gap;          // 7.99 mm
plug_len    = 17.6;                          // Matches non_foldable_quad.scad

// Screws sit in the midline between the tubes (Y=0), flanking the
// handle socket that comes out of the +Y face at X=0. Offset along X
// must clear both the socket (soc/2 + head radius) and the tube bores.
screw_x_offset = 8.0;
screw_xs       = [-screw_x_offset, +screw_x_offset];
screw_ys       = [0];

// ============================================================
// MODULES
// ============================================================

// Rounded rectangular body, centered at origin, spanning
// [-body_width/2, +body_width/2] x [-clamp_length/2, +clamp_length/2] x
// [-body_height/2, +body_height/2]. Minkowski keeps outer dims exact.
module _rounded_body() {
    inner_x = body_width   - 2 * fillet_r;
    inner_y = clamp_length - 2 * fillet_r;
    inner_z = body_height  - 2 * fillet_r;
    minkowski() {
        cube([inner_x, inner_y, inner_z], center = true);
        sphere(r = fillet_r);
    }
}

// Solid square plug on +Z, centered at X=Y=0 between the two screw
// holes. Axis along Z. Base sinks into the top half's body for a
// clean union; tip extends past the body's top face.
// plug_embed: how much of the plug lies inside the body (gives it a
// structural root into the top half). plug_len total, so the part
// sticking out past the +Z face = plug_len - plug_embed.
module _tip_plug() {
    plug_embed = 1;  // Stays within top half, leaves 1 mm floor
    z_base = half_h - plug_embed;
    translate([-plug_side/2, -plug_side/2, z_base])
        cube([plug_side, plug_side, plug_len]);
}

module _body_solid() {
    union() {
        _rounded_body();
        _tip_plug();
    }
}

// Two tube bores along Y through the body. Cut is slightly longer than
// the clamp so the faces stay clean after Minkowski.
module _tube_bores() {
    for (sx = [-1, +1])
        translate([sx * tube_spacing/2, 0, 0])
            rotate([90, 0, 0])
                cylinder(
                    d = bore_dia,
                    h = clamp_length + 2 * fillet_r + 2 * eps,
                    center = true
                );
}

// Vertical through-clearance for each M3 screw.
module _screw_clearance() {
    for (x = screw_xs, y = screw_ys)
        translate([x, y, 0])
            cylinder(
                d = m3screw,
                h = body_height + 2 * fillet_r + 2 * eps,
                center = true
            );
}

// Hex nut pockets, sunk from the +Z face of the top half. The plug
// sticks out of the same face but is offset in X, so no collision.
// $fn=6 -> hexagonal cross section. Diameter is across-corners.
module _nut_pockets() {
    for (x = screw_xs, y = screw_ys)
        translate([x, y, body_height/2 - nut_pocket_depth])
            cylinder(d = m3nut, h = nut_pocket_depth + eps, $fn = 6);
}

// Cylindrical head recesses, sunk from the -Z face of the bottom half.
module _head_recesses() {
    for (x = screw_xs, y = screw_ys)
        translate([x, y, -body_height/2 - eps])
            cylinder(d = m3head, h = head_recess_depth + eps);
}

// Full undivided part with all cuts applied except the half-space split.
// "which" = "top" or "bottom" so we only add that half's hardware pocket.
module _clamp_with_cuts(which) {
    difference() {
        _body_solid();
        _tube_bores();
        _screw_clearance();
        if (which == "bottom") _head_recesses();
        if (which == "top")    _nut_pockets();
    }
}

// One half, split at Z=0 through the tube centers. Top = Z>=0, bottom = Z<=0.
module half(which) {
    assert(which == "top" || which == "bottom",
        str("half() which must be \"top\" or \"bottom\", got: ", which));
    // Use a large cutter box aligned on the split plane.
    box = max(body_width, clamp_length + plug_len, body_height) * 2;
    intersection() {
        _clamp_with_cuts(which);
        if (which == "top")
            translate([0, 0, box/2]) cube(box, center = true);
        else
            translate([0, 0, -box/2]) cube(box, center = true);
    }
}

// Lay each half flat on Z=0 for printing.
// Top half: carries the handle plug emerging from its outer (+Z) face.
//   Print with the SPLIT face on the bed so the plug points upward.
//   Tube grooves open downward - printer bridges the semicircle ceiling
//   (~14 mm span, prints cleanly with layer cooling). Head recesses also
//   open downward and need a small bridge over the screw clearance hole.
// Bottom half: no plug. Print with the outer (-Z) face on the bed so
//   tube grooves and nut pockets open upward, everything self-supporting.
module lay_flat(which) {
    if (which == "top") {
        // Native top half: split face at Z=0, body at Z=0..half_h, plug
        // extending up past +Z. Already laid flat correctly: split face on
        // the bed, plug pointing up.
        half("top");
    } else {
        // Native bottom half: split face at Z=0, body at -half_h..0.
        // Lift so the outer (-Z) face sits on the bed.
        translate([0, 0, body_height/2])
            half("bottom");
    }
}

// ============================================================
// DISPATCH
// ============================================================

echo(str("body: ", body_width, " x ", clamp_length, " x ", body_height, " mm"));
echo(str("bore_dia=", bore_dia, " mm  tube_spacing=", tube_spacing, " mm"));
echo(str("plug: ", plug_side, " x ", plug_side, " x ", plug_len, " mm"));
echo(str("screws at X=+/-", screw_x_offset, " (between tubes), Y=0"));

if (render_part == "top") {
    lay_flat("top");
} else if (render_part == "bottom") {
    lay_flat("bottom");
} else if (render_part == "both") {
    gap = 6;
    translate([-(body_width/2 + gap/2), 0, 0])
        lay_flat("bottom");
    translate([+(body_width/2 + gap/2), 0, 0])
        lay_flat("top");
} else {
    assert(false,
        str("render_part must be \"top\", \"bottom\", or \"both\", got: ",
            render_part));
}
