// MyWhoosh BLE shifter enclosure
// ESP32-C3 SuperMini + two 12 x 12 mm tactile switches
// Units: millimetres. Change `part` to export one component.

part = "both";  // "bottom", "lid", or "both"
$fn = 64;

// Printer fit tuning
fit_clearance = 0.25;
wall = 2.0;
roof = 2.4;

// Case
case_length = 64;
case_width = 38;
corner_radius = 5;
bottom_height = 15;

// Common ESP32-C3 SuperMini maximum envelope. Measure clones before printing.
board_length = 23.5;
board_width = 18.5;
board_height = 5.5;
board_clearance = 0.5;
usb_width = 9.5;
usb_height = 4.5;

// 12 x 12 x 7.3 mm tactile switches with coloured caps
switch_body = 12.0;
switch_clearance = 0.3;
cap_hole = 10.2;
button_spacing = 27;
button_positions = [-button_spacing / 2, button_spacing / 2];
button_labels = ["-", "+"];

// Mounting
zip_tie_width = 5.0;
zip_tie_thickness = 2.0;
strap_spacing = 34;
handlebar_diameter = 31.8;
mount_depth = 4.0;

module rounded_prism(length, width, radius, height) {
    linear_extrude(height = height)
        offset(r = radius)
            square([length - 2 * radius, width - 2 * radius], center = true);
}

module handlebar_feet() {
    difference() {
        for (x = [-strap_spacing / 2, strap_spacing / 2])
            translate([x, 0, -mount_depth / 2])
                cube([zip_tie_width + 3.0, case_width - 4, mount_depth], center = true);

        // A shallow 31.8 mm handlebar saddle prevents the case rocking.
        translate([0, 0, -handlebar_diameter / 2])
            rotate([0, 90, 0])
                cylinder(d = handlebar_diameter, h = case_length + 2, center = true);
    }
}

module board_guides() {
    board_x = case_length / 2 - wall - board_length / 2 - 0.4;
    guide_z = wall + 0.8;

    // Low rails locate the board while leaving its castellated pads accessible.
    for (y = [-1, 1])
        translate([board_x, y * (board_width / 2 + board_clearance + 0.55), guide_z])
            cube([board_length, 1.1, 1.6], center = true);

    translate([board_x - board_length / 2 - board_clearance - 0.55, 0, guide_z])
        cube([1.1, board_width + 2.2, 1.6], center = true);
}

module bottom() {
    union() {
        difference() {
            union() {
                rounded_prism(case_length, case_width, corner_radius, bottom_height);
                handlebar_feet();
            }

            // Main electronics and wiring cavity.
            translate([0, 0, wall])
                rounded_prism(
                    case_length - 2 * wall,
                    case_width - 2 * wall,
                    corner_radius - wall / 2,
                    bottom_height + 1
                );

            // USB-C opening, aligned to the connector on the SuperMini's short end.
            usb_z = wall + 2.7;
            translate([case_length / 2, 0, usb_z])
                cube([2 * wall + 2, usb_width, usb_height], center = true);

            // Two zip ties each pass through a pair of floor slots and around the bar.
            for (x = [-strap_spacing / 2, strap_spacing / 2],
                 y = [-(case_width / 2 - wall - 2), case_width / 2 - wall - 2])
                translate([x, y, (wall - mount_depth) / 2])
                    cube([
                        zip_tie_width + 0.6,
                        zip_tie_thickness + 0.8,
                        wall + mount_depth + 2
                    ], center = true);

            // Internal snap detents for the lid; they do not perforate the outer wall.
            for (x = [-20, 20], y = [-1, 1])
                translate([x, y * (case_width / 2 - wall + 0.35), bottom_height - 4.2])
                    cube([4.0, 1.0, 1.4], center = true);
        }

        board_guides();
    }
}

module switch_guide(x) {
    guide_inner = switch_body + switch_clearance;
    guide_wall = 1.2;
    guide_height = 3.2;

    for (y = [-1, 1])
        translate([x, y * (guide_inner / 2 + guide_wall / 2), roof + guide_height / 2])
            cube([guide_inner + 2 * guide_wall, guide_wall, guide_height], center = true);

    for (side = [-1, 1])
        translate([x + side * (guide_inner / 2 + guide_wall / 2), 0, roof + guide_height / 2])
            cube([guide_wall, guide_inner, guide_height], center = true);
}

module lid() {
    skirt_outer_length = case_length - 2 * wall - 2 * fit_clearance;
    skirt_outer_width = case_width - 2 * wall - 2 * fit_clearance;
    skirt_wall = 1.4;
    skirt_height = 3.2;

    difference() {
        union() {
            rounded_prism(case_length, case_width, corner_radius, roof);

            // Locating skirt. The lid prints with its flat outside face on the bed.
            translate([0, (skirt_outer_width - skirt_wall) / 2, roof + skirt_height / 2])
                cube([skirt_outer_length - 6, skirt_wall, skirt_height], center = true);
            translate([0, -(skirt_outer_width - skirt_wall) / 2, roof + skirt_height / 2])
                cube([skirt_outer_length - 6, skirt_wall, skirt_height], center = true);
            for (x = [-1, 1])
                translate([x * (skirt_outer_length - skirt_wall) / 2, 0, roof + skirt_height / 2])
                    cube([skirt_wall, skirt_outer_width - 6, skirt_height], center = true);

            for (x = button_positions)
                switch_guide(x);

            // Small bumps engage the bottom's internal detents.
            for (x = [-20, 20], y = [-1, 1])
                translate([x, y * skirt_outer_width / 2, roof + 1.8])
                    cube([3.6, 0.7, 1.0], center = true);
        }

        for (x = button_positions)
            translate([x, 0, -0.1])
                cylinder(d = cap_hole, h = roof + 0.2);

        // Engraved outside-face labels match the documented button order.
        for (i = [0 : len(button_positions) - 1])
            translate([button_positions[i], -12, -0.1])
                linear_extrude(height = 0.8)
                    text(
                        button_labels[i],
                        size = 4,
                        halign = "center",
                        valign = "center",
                        font = "Liberation Sans:style=Bold"
                    );
    }
}

if (part == "bottom") {
    bottom();
} else if (part == "lid") {
    lid();
} else {
    bottom();
    translate([0, case_width + 12, 0]) lid();
}
