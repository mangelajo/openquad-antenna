// All-in-One Antenna Hub - v4
// 4x antenna boom clamps arranged around a central boom collar
// Print-in-place assembly with configurable gaps
// EA4IPW - Parametric design

/* [Boom] */
boom_is_round = true;
boom_dia=15.9;   // Boom tube diameter
boom_side=15.1;  // Boom tube side (not round)
boom_spikes_dia = 8.10;  // Boom spikes (wood support for wire) diameter
boom_around = 3;
boom_around_h = 18;
boom_spike_hole = 5;
boom_spike_hole_h = 12.8;
boom_spike_hole_dist = 9.5;

/* [Main Body] */
body_side = 50;
body_height = 2.3;
fillet_r = 0.5;  // Edge rounding radius

/* [Boom Spike holders] */
bs_holder_width = 15;
bs_holder_height = 18;
bs_holder_thickness = 1.5;

/* [Print-in-Place] */
print_gap = 0.20;          // Separation between parts for print-in-place (Z axis critical)
clamp_collar_gap = 0.85;   // Radial gap between collar and clamp front (>print_gap, prints well)

/* [Clamp Overrides] */
clamp_body_height = 14;    // Must match antenna_boom_clamp default or override
clamp_fillet_r = 2;        // Must match antenna_boom_clamp default or override
clamp_ear_drop = 3;        // Must match antenna_boom_clamp default or override
clamp_boom_dia = 8.10;     // Wire boom diameter (= boom_spikes_dia)

/* [Quality] */
$fn = 80;

// --- Derived ---
// Clamp placement offsets (see plan for geometry derivation)
// Z: base_plate_top + print_gap + clamp_body_height
//    where base_plate_top = body_height + fillet_r (after minkowski)
clamp_z_offset = body_height + fillet_r + print_gap + clamp_body_height;
// Y: collar outer radius + radial gap
clamp_y_offset = (boom_dia_eff() + boom_around) / 2 + clamp_collar_gap;

function boom_dia_eff() =
    boom_is_round ? boom_dia : boom_side * sqrt(2);

module _body() {
    
    
    union() {
     cylinder( d=body_side  - 2*fillet_r, h=body_height-fillet_r);
     cylinder( d=boom_dia_eff()+boom_around - 2*fillet_r, h=body_height+boom_around_h-fillet_r*2);

     }
}

module body() {
    translate([0,0,fillet_r])
        minkowski() {
            _body();

            sphere(r = fillet_r);
        }
}



/*
module boom_hole() {
    // Vertical hole for boom
    translate([0,5, (body_height)/2])
        rotate([90,0,180])
        cylinder(d=boom_dia, h=body_height+ear_height+dome_extra_h+20);
}

module boom_hole_insert() {
      //translate([0,0, (body_height)/2])
      //  rotate([90,0,180])
      //  cylinder(d1=boom_dia+1,d2=boom_dia, h=1);
        
       translate([0,body_length, (body_height)/2])
        rotate([90,0,0])
        cylinder(d1=boom_dia+1,d2=boom_dia, h=1);
}
*/

module boom_hole() {
   if (boom_is_round) {
      cylinder(h=boom_around_h+body_height+fillet_r, d=boom_dia);
   } else {
      h = boom_around + body_height;
      translate([0,0,h/2])
      cube([boom_side,boom_side, h*10], center=true); // TODO: why *10 to make it cut?
   }
}

module bs_holder() {
  translate([-bs_holder_thickness/2,boom_dia_eff()/6,body_height]) // TODO: the /6 is an approx
  difference() {
      union(){
          eff_width = bs_holder_width+fillet_r*2;
          eff_depth = (body_side - boom_dia_eff()+boom_around*2)/2;
          translate([-eff_width/2-bs_holder_thickness/2,0,0])
          cube([bs_holder_thickness,eff_depth,bs_holder_height-fillet_r]);
          translate([+eff_width/2+bs_holder_thickness/2,0,0])
          cube([bs_holder_thickness,eff_depth,bs_holder_height-fillet_r]);

         }
       
       // the hole for the spike holder  
       translate([-bs_holder_width/2 - bs_holder_thickness/2-fillet_r*2,boom_spike_hole_dist, boom_spike_hole_h])
          rotate([0,90,0])
          cylinder(d=boom_spike_hole,h=bs_holder_width+bs_holder_thickness+fillet_r*8);
  }
}

use <antenna_boom_clamp.scad>

// === Assembly ===
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
                        boom_dia = clamp_boom_dia,
                        body_height = clamp_body_height,
                        fillet_r = clamp_fillet_r,
                        ear_drop = clamp_ear_drop
                    );
                 }
                
        }
    }
    boom_hole();
   
}