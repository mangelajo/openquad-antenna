// Antenna Boom / Wire Clamp - v4
// Matches reference: dome at front, boom hole in middle,
// clamp slot + ears at rear hanging below
// EA4IPW - Parametric design

/* [Type] */
near_boom_version = true; // the near boom version connects to the main boom instead of the wire
/* [Main Boom Connection] */

pivot_d = 3.6;
pivot_l = 5;
pivot_angle_cut = 90;

/* [Main Body] */
body_width = 14.8;       // X axis
body_length = 25;      // Y axis (front dome to rear)
body_height = 14;      // Z axis
fillet_r = 2;  // Edge rounding radius

/* [Dome (front, wire pass-through)] */
dome_dia = 10;         // Diameter of rounded top
dome_extra_h = 8;     // How much dome rises above body
wire_dia = 4;          // Wire hole diameter
wire_down = 2;        // distance pulled down from the dome to the bottom

/* [Boom hole (middle, vertical)] */
boom_dia = 8.10;         // Boom tube diameter
// Distance from front edge of body to boom center
boom_from_front = 32;

/* [Clamp section (rear)] */
slot_width = 1;      // Clamping slot width
ear_drop = 3;          // How far the clamping ear extends below the body
ear_length = 10;       // Y extent of clamping ear
bolt_dia = 4.5;        // Bolt hole through ears
m3nut=6.2;
m3head=5.5;
m3screw=3.5;

/* [Quality] */
$fn = 80;

// --- Derived ---
// Y=0 is at front of body
// Body goes from Y=0 to Y=body_length
dome_cy = dome_dia/2;  // dome center Y
boom_cy = boom_from_front; // boom center Y

module _clamp_body(body_width, body_length, body_height, fillet_r, ear_drop, ear_length) {
    union() {
     cube([
                body_width  - 2*fillet_r,
                body_length - 2*fillet_r,
                body_height - 2*fillet_r
            ]);
     // the "ear", later slotted for fixation
     translate([0,body_length-ear_length,0])
        cube([body_width-2*fillet_r, ear_length-fillet_r*2, body_height - 2*fillet_r + ear_drop]);
     }
}

module clamp_body(body_width, body_length, body_height, fillet_r, ear_drop, ear_length) {
    translate([-body_width/2 + fillet_r, fillet_r, fillet_r])
        minkowski() {
            _clamp_body(body_width, body_length, body_height, fillet_r, ear_drop, ear_length);

            sphere(r = fillet_r);
        }
}

module dome_shape(body_height, dome_dia, dome_extra_h, dome_cy) {
    // Cylinder + hemisphere on top, at front of body
    translate([0, dome_cy, 0]) {
        // Cylinder portion up to body_height is inside the body
        // Above body: cylinder + sphere cap
        translate([0, 0, body_height]) {
            // Cylindrical base of dome above body
            cylinder(d=dome_dia, h=dome_extra_h - dome_dia/2);
            // Spherical cap on top
            translate([0, 0, dome_extra_h - dome_dia/2])
                sphere(d=dome_dia);
        }
    }
}

module wire_hole(body_width, body_height, wire_dia, dome_cy) {
    // Horizontal hole through dome, along X axis
    translate([0, dome_cy, body_height/2])
        rotate([0, 90, 0])
            cylinder(d=wire_dia, h=body_width+20, center=true);
}

module clamp_boom_hole(body_height, body_length, boom_dia, ear_drop, dome_extra_h, fillet_r) {
    // Vertical hole for boom
    translate([0,5, (body_height)/2])
        rotate([90,0,180])
        cylinder(d=boom_dia, h=body_height + (body_height - 2*fillet_r + ear_drop + 2*fillet_r) + dome_extra_h + 20);
}

module clamp_boom_hole_insert(body_length, body_height, boom_dia) {
       translate([0,body_length, (body_height)/2])
        rotate([90,0,0])
        cylinder(d1=boom_dia+1,d2=boom_dia, h=1);
}

module fixation_slot(slot_width, body_length, body_height) {
    translate([-slot_width/2,0, (body_height)/2])
        cube([slot_width,body_length,20]);
}

module nut_hole(body_width, body_length, body_height) {
    translate([-10,body_length-5, body_height+1])
    rotate([0,90,0])
        union() {
            cylinder(d=m3nut,h=5,$fn=6);
            cylinder(d=m3screw,body_width*2);
            translate([0,0,body_width])
                cylinder(d=m3head,h=5);
        }
}

module pivot(fillet_r) {
    difference(){
        translate([-fillet_r,pivot_d/2,pivot_d/2])
            rotate([0,90,0])
                cylinder(d=pivot_d,h=pivot_l+fillet_r);
         translate([pivot_l*0.8,pivot_d/2,pivot_d])
         rotate([0,pivot_angle_cut]) cube([20,pivot_d,pivot_d], center=true);
         }
}

module back_bend_insert(slot_width, body_length) {
    translate([-slot_width/2,0, 0])
        cube([slot_width,body_length/3,20]);
}

module antenna_boom_clamp(
    near_boom_version = true,
    body_width = 14.8,
    body_length = 25,
    body_height = 14,
    fillet_r = 2,
    boom_dia = 8.10,
    ear_drop = 3,
    ear_length = 10
) {
// === Assembly ===
    difference() {
        union() {
            clamp_body(body_width, body_length, body_height, fillet_r, ear_drop, ear_length);
            // the near-main-boom version has two small pivots
            if (near_boom_version) {
                translate([body_width/2,0,0]) pivot(fillet_r);
                translate([0,pivot_d,0])
                rotate([0,0,180])
                translate([body_width/2,0,0]) pivot(fillet_r);
             }
        }
        //wire_hole(body_width, body_height, wire_dia, dome_cy);
        clamp_boom_hole(body_height, body_length, boom_dia, ear_drop, dome_extra_h, fillet_r);
        clamp_boom_hole_insert(body_length, body_height, boom_dia);
        if (near_boom_version) {
           back_bend_insert(slot_width, body_length);
        }
        fixation_slot(slot_width, body_length, body_height);
        nut_hole(body_width, body_length, body_height);
    }
}

antenna_boom_clamp(near_boom_version=near_boom_version);
