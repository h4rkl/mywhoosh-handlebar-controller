// ============================================================
// MyWhoosh Handlebar Shifter - Improved Housing
// For ESP32-C3 SuperMini + 12x12x7.3mm Tactile Switches
// (AliExpress 12*12*7.3MM with coloured knobs)
// ============================================================

$fn = 80;

// ---------- Main Dimensions ----------
wall          = 1.8;
length        = 56;
width         = 36;
base_height   = 14;          // bottom part height
lid_height    = 6.5;         // lid height

// Button parameters (for 12x12x7.3mm + knob)
btn_body      = 12.3;        // slightly oversized for easy fit
btn_depth     = 7.5;         // how deep the switch body sits
btn_spacing   = 24;          // centre-to-centre (comfortable)
knob_hole     = 10.2;        // hole for the coloured knob to pass through

// SuperMini
board_l       = 23.5;
board_w       = 18.8;
board_h       = 5.8;

// USB-C
usb_w         = 9.4;
usb_h         = 3.9;

// Zip-tie
ziptie_w      = 5.8;
ziptie_h      = 2.4;


// ============================================================
// BOTTOM PART
// ============================================================
module bottom() {
    difference() {
        // Outer shape
        hull() {
            for(x=[-1,1], y=[-1,1])
                translate([x*(length/2-4), y*(width/2-4), 0])
                    cylinder(r=4, h=base_height);
        }
        
        // Main internal cavity
        translate([0, 0, wall])
            hull() {
                for(x=[-1,1], y=[-1,1])
                    translate([x*(length/2-4-wall), y*(width/2-4-wall), 0])
                        cylinder(r=3, h=base_height);
            }
        
        // SuperMini pocket
        translate([0, -2.5, base_height - board_h - 0.8])
            cube([board_l + 0.4, board_w + 0.4, board_h + 1], center=true);
        
        // USB-C cutout
        translate([length/2 - 0.5, 0, 4.2])
            cube([8, usb_w, usb_h], center=true);
        
        // Zip-tie slots
        for(y = [-10.5, 10.5])
            translate([0, y, -0.1])
                cube([length - 14, ziptie_w, ziptie_h], center=true);
    }
    
    // Board support rails
    translate([0, -2.5, base_height - board_h - 0.8]) {
        for(x = [-1, 1])
            translate([x * (board_l/2 + 0.9), 0, 0])
                cube([1.6, board_w - 2, 2.5], center=true);
    }
}


// ============================================================
// LID (with button mounts)
// ============================================================
module lid() {
    difference() {
        // Outer lid shape
        hull() {
            for(x=[-1,1], y=[-1,1])
                translate([x*(length/2-4), y*(width/2-4), 0])
                    cylinder(r=4, h=lid_height);
        }
        
        // Main recess inside lid
        translate([0, 0, -0.1])
            hull() {
                for(x=[-1,1], y=[-1,1])
                    translate([x*(length/2-4-wall), y*(width/2-4-wall), 0])
                        cylinder(r=2.8, h=lid_height - wall + 0.2);
            }
        
        // Button body pockets (from the inside)
        for(x = [-btn_spacing/2, btn_spacing/2]) {
            translate([x, 0, lid_height - btn_depth - 0.3])
                cube([btn_body, btn_body, btn_depth + 1], center=true);
            
            // Knob exit hole
            translate([x, 0, lid_height - 1.5])
                cylinder(d=knob_hole, h=3, center=true);
        }
    }
    
    // Snap-fit lips that go inside the bottom
    for(x = [-1, 1])
        translate([x * (length/2 - wall - 1.0), 0, -2.8])
            cube([1.4, width - 14, 3.0], center=true);
    
    // Extra retention tabs for the switches (helps hold them in place)
    for(x = [-btn_spacing/2, btn_spacing/2]) {
        for(y = [-1, 1])
            translate([x, y * (btn_body/2 + 0.7), lid_height - btn_depth + 1.2])
                cube([6, 1.3, 2.2], center=true);
    }
}


// ============================================================
// RENDER
// ============================================================

// Print these separately
bottom();

translate([0, 55, 0])
    lid();