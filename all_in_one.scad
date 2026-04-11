// Antenna Boom / Wire Clamp - v3
// Matches reference: dome at front, boom hole in middle,
// clamp slot + ears at rear hanging below
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

//[Boom Spike holders]
bs_holder_width = 15;
bs_holder_height = 18;
bs_holder_thickness = 1.5;

/* [Quality] */
$fn = 80;


// calculated

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
                    translate([0,10.3,17])
                    rotate([0,180,0])
                    antena_boom_clamp();
                 }
                
        }
    }
    boom_hole();
   
}