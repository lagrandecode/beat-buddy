// Beat Buddy — seated desk robot with a round AMOLED face, headphones and a hoodie
//
// The head holds a Waveshare ESP32-S3-Touch-AMOLED-1.75 behind a white bezel.
// Everything snaps together, no glue or magnets:
//   - the head back clicks onto four snap hooks on the head front
//   - three pads in the head back press on the board's brass posts
//   - two printed push-buttons reach the board's PWR and BOOT buttons
//   - the speaker and a 752035 LiPo clip into a frame inside the head back
//   - the one-piece headphones snap their pegs into holes in the head
//   - the backpack snaps onto the body on two barbed pegs
// A straight USB-C cable comes in through the backpack, runs up a channel in
// the body and plugs into the board from below.
//
// Board positions come from Waveshare's dimension drawing: PWR and BOOT sit on
// the board edge 34° either side of the point opposite the USB-C port, and the
// three M2 brass posts are the rearmost parts, 10.4 mm behind the glass.
//
// Print colours: white head_front, head_back, button ×2 · black headphones,
// backpack · red body. Head front prints screen side down.
//
// Units: millimetres. Body frame: z up, the robot faces −y.

/* [Render] */
part = "preview"; // [preview, exploded, cutaway, head_inside, head_front, head_back, button, headphones, body, backpack, plate_white, plate_black, plate_red, plate_all]
white = "#f4f3ef";
black = "#2b2b2d";
hoodie = "#e2402c";
eye = "#ffd23a";

/* [Display board] */
board_d = 48.96;      // glass outline
board_t = 10.4;       // glass to the tops of the brass posts
window_d = 46;        // visible opening in the bezel (screen is 43.8 mm)
usb_depth = 7.5;      // USB-C centre, back from the glass
btn_depth = 7.5;      // PWR/BOOT button centre, back from the glass
btn_angle = 34;       // PWR left, BOOT right, degrees either side of the top
posts = [[-20.5, 0], [18.68, 13.75], [18.68, -13.75]];  // brass posts (x, z), USB-C pointing down

/* [Head] */
head_r = 33;
head_side = 18;       // straight part of the side before the back dome
head_dome = 26;
wall = 2;
lip_t = 1.6;          // bezel in front of the glass

/* [Snap hooks between the head halves] */
hook_angles = [-120, -62, 62, 120];
hook_w = 8;
hook_len = 5;         // how far the hooks reach into the head back
hook_root = 4;        // how far the hooks are rooted into the head front
hook_t = 1.4;
hook_bump = 0.7;

/* [Speaker and battery] */
spk = [30, 20, 5.5];  // Waveshare 2030 box speaker: length, height, thickness
bat = [35, 20, 7.5];  // 752035 LiPo: length, height, thickness
spk_front = 36.6;     // cone face, back from the glass face

/* [USB-C cable] */
plug_w = 14;          // straight plug body, with clearance
plug_t = 9;

/* [Fit] */
fit = 0.4;

/* [Hidden] */
$fn = 72;
eps = 0.01;
board_r = board_d / 2 + 0.2;
split_s = lip_t + board_t + 0.15;  // head splits just behind the brass posts
usb_s = lip_t + usb_depth;
btn_s = lip_t + btn_depth;
cup_s = 17;                        // headphone pegs, back from the face
cup_r = 13;
cup_out = head_r + 9;
cup_cut = cup_s + 9;               // flat back of the headphones, the print face
band_w = 8;
band_t = 4;
band_angle = 78;
col_x = [12.5, 15.5];              // frame columns for the speaker and battery
col_z = 10.35;
col_t = 2.5;
bat_back = spk_front - spk[2];     // battery rests against the back of the speaker
bat_front = bat_back - bat[2] - 0.2;

head_y = -18;                      // face plane in the body frame
head_z = 79;                       // head axis height
collar_c = [0, 4, 45];
peg_x = 12;
peg_s = 8;
usb_y = head_y + usb_s;
base_z = 2;
chan_z = [21, 31];                 // cable tunnel through the body and backpack
bp_peg_z = 15;

// ============================================================ head (head frame)
// The face is the plane y = 0 and the head axis runs along +y (backwards).
// Angles around the axis are measured from the top, positive towards +x.

// front edge: 45° chamfer blending into a 6 mm round, so it prints face down
function head_profile() = concat(
  [[0, 0], [head_r - 3.51, 0]],
  [for (a = [-45:5:0]) [head_r - 6 + 6 * cos(a), 6 + 6 * sin(a)]],
  [for (t = [0:3:90]) [head_r * cos(t), head_side + head_dome * sin(t)]]
);

module along_y() rotate([-90, 0, 0]) children();

module head_outer(grow = 0) along_y() rotate_extrude($fn = 160) intersection() {
  offset(r = grow) polygon(head_profile());
  translate([0, -50]) square([100, 200]);
}

module head_cavity() along_y() rotate_extrude($fn = 160) intersection() {
  offset(r = -wall) union() { polygon(head_profile()); mirror([1, 0]) polygon(head_profile()); }
  translate([0, -50]) square([100, 200]);
}

// sector of a profile (r, y) revolved around the head axis
module sector(angle, half) along_y() rotate([0, 0, angle - 90 - half]) rotate_extrude(angle = 2 * half, $fn = 160) children();

module at_angle(angle, y) translate([0, y, 0]) rotate([0, angle, 0]) children();

function hex_grid(pitch, rmax) = [for (i = [-6:6], j = [-6:6]) let(p = [pitch * (i + j / 2), pitch * j * sqrt(3) / 2])
  if (norm(p) <= rmax) p];

hook_ri = head_r - wall - 0.25 - hook_t;
hook_half = hook_w / (2 * PI * (hook_ri + hook_t)) * 180;
hook_tip = split_s + hook_len;

module hook_profile() polygon([
  [hook_ri, split_s - hook_root - 0.5], [hook_ri + hook_t, split_s - hook_root - 0.5],
  [hook_ri + hook_t, hook_tip - 1.8], [hook_ri + hook_t + hook_bump, hook_tip - 1.1],
  [hook_ri + hook_t + hook_bump, hook_tip - 0.7], [hook_ri + hook_t, hook_tip], [hook_ri, hook_tip]
]);

module usb_slot() translate([-plug_w / 2, usb_s - plug_t / 2, -head_r - 5]) cube([plug_w, plug_t, head_r + 5 - 23]);

module head_front() {
  difference() {
    intersection() { head_outer(); translate([-50, -1, -50]) cube([100, split_s + 1, 100]); }
    translate([0, lip_t, 0]) along_y() cylinder(r = board_r, h = split_s, $fn = 160);
    translate([0, -eps, 0]) along_y() cylinder(h = lip_t + 2 * eps, r1 = window_d / 2 + 1.2, r2 = window_d / 2, $fn = 160);
    usb_slot();
    // push-button holes, with a recess for each button's collar
    for (a = [-btn_angle, btn_angle]) at_angle(a, btn_s) {
      translate([0, 0, 23.5]) cylinder(d = 3.4, h = 12, $fn = 32);
      translate([0, 0, 23.5]) cylinder(d = 5.9, h = 2.45, $fn = 40);
    }
    // room for the snap hooks to flex
    for (a = hook_angles) sector(a, hook_half + 2)
      translate([hook_ri - 0.75, split_s - hook_root]) square([hook_t + hook_bump + 1.0, hook_root + 1]);
    // locating holes for the body pegs
    for (sx = [-1, 1]) translate([sx * peg_x, peg_s, -head_r - 1]) cylinder(d = 4.4, h = head_r + 1 - sqrt(head_r * head_r - peg_x * peg_x) + 3.8, $fn = 24);
  }
  for (a = hook_angles) sector(a, hook_half) hook_profile();
}

// PWR/BOOT push-button, modelled pointing outwards along +z, collar on the bed
module button() {
  cylinder(d = 5.4, h = 1, $fn = 40);
  cylinder(d = 3, h = 9.3, $fn = 32);
  translate([0, 0, 9.3]) sphere(d = 3, $fn = 32);
}

// speaker and battery frame, four columns hanging from the dome
module frame() {
  for (sx = [-1, 1], sz = [-1, 1]) mirror([sx < 0 ? 1 : 0, 0, 0]) mirror([0, 0, sz < 0 ? 1 : 0]) {
    translate([col_x[0], split_s, col_z]) cube([col_x[1] - col_x[0], 40, col_t]);
    // stops for the speaker's cone face
    translate([col_x[0], spk_front, col_z - 1.5]) cube([col_x[1] - col_x[0], 10, 1.5 + eps]);
    // battery catch: ramp from the open end, flat face against the battery
    hull() {
      translate([col_x[0], bat_front - 1, col_z - eps]) cube([col_x[1] - col_x[0], eps, eps]);
      translate([col_x[0], bat_front - eps, col_z - 0.9]) cube([col_x[1] - col_x[0], eps, 0.9 + eps]);
    }
  }
}

module pads() {
  difference() {
    union() {
      for (p = posts) translate([p[0], split_s, p[1]]) along_y() cylinder(d = 5, h = 3, $fn = 32);
      // the two right pads hang off the frame columns, the left one off the wall
      for (sz = [-1, 1]) hull() {
        translate([col_x[0], split_s, sz > 0 ? col_z : -col_z - col_t]) cube([col_x[1] - col_x[0], 3, col_t]);
        translate([posts[1][0], split_s, sz * posts[1][1]]) along_y() cylinder(d = 4, h = 3, $fn = 24);
      }
      translate([-head_r, split_s, -1.5]) cube([head_r + posts[0][0], 3, 3]);
    }
    // pin header on the back of the board
    translate([16.6, split_s - 1, -10.8]) cube([3.6, 5, 21.6]);
  }
}

module head_back() {
  difference() {
    union() {
      difference() {
        intersection() { head_outer(); translate([-50, split_s, -50]) cube([100, 100, 100]); }
        head_cavity();
      }
      intersection() {
        head_outer();
        union() { frame(); pads(); }
      }
    }
    // groove the snap hooks click into
    along_y() rotate_extrude($fn = 160) intersection() {
      offset(delta = 0.2) hook_profile();
      translate([hook_ri + hook_t + 0.05, 0]) square([5, 100]);
    }
    usb_slot();
    for (p = hex_grid(4, 10)) translate([p[0], head_side, p[1]]) along_y() cylinder(d = 2.4, h = head_dome + 5, $fn = 16);
    for (sx = [-1, 1]) translate([sx * (head_r - 5), cup_s, 0]) rotate([0, 90, 0]) linear_extrude(10, center = true) teardrop(3.3);
  }
}

// ---------------------------------------------------------------- headphones

module cup_shape() translate([head_r - 6, cup_s, 0]) rotate([0, 90, 0]) rotate_extrude($fn = 120)
  hull() {
    square([cup_r, eps]);
    translate([cup_r - 4, cup_out - head_r + 6 - 4]) circle(r = 4, $fn = 40);
    square([eps, cup_out - head_r + 6]);
  }

module cup_r() {
  difference() {
    cup_shape();
    head_outer(0.3);
    translate([cup_out - 0.8, cup_s, 0]) rotate([0, 90, 0]) difference() {
      cylinder(r = 9.6, h = 2, $fn = 96);
      translate([0, 0, -1]) cylinder(r = 8.4, h = 4, $fn = 96);
    }
  }
  // snap peg: through the head wall, with a barb that catches on the inside
  peg_in = head_r - wall - 0.1;
  translate([head_r + 0.35, cup_s, 0]) rotate([0, -90, 0]) {
    linear_extrude(head_r + 0.35 - peg_in) teardrop(3);
    translate([0, 0, head_r + 0.35 - peg_in]) linear_extrude(1, scale = 2.4 / 3.6) hull() { teardrop(3); circle(d = 3.6, $fn = 24); }
  }
}

// round with a 45° point towards +y, so it prints without support either way up
module teardrop(d) hull() {
  circle(d = d, $fn = 24);
  translate([0, d / sqrt(2)]) square(0.01, center = true);
}

module band() sector(0, band_angle) intersection() {
  difference() { offset(r = 0.4 + band_t) polygon(head_profile()); offset(r = 0.4) polygon(head_profile()); }
  translate([0, cup_cut - band_w]) square([60, band_w]);
}

module headphones() intersection() {
  union() { band(); cup_r(); mirror([1, 0, 0]) cup_r(); }
  translate([-60, 6, -60]) cube([120, cup_cut - 6, 120]);
}

// ============================================================ body (body frame)

module head_place() translate([0, head_y, head_z]) children();

module limb(a, ra, b, rb) hull() { translate(a) sphere(ra); translate(b) sphere(rb); }

collar_ring = 15;
collar_tube = 9;

module collar_roll() rotate_extrude($fn = 120) translate([collar_ring, 0]) circle(collar_tube, $fn = 48);

// thick rolled hood, a little lower at the front
module collar() translate(collar_c) rotate([10, 0, 0]) {
  collar_roll();
  intersection() {
    hull() {
      collar_roll();
      translate([0, 0, -16]) cylinder(r = 13, h = 0.1, $fn = 96);
    }
    translate([-40, -40, -20]) cube([80, 80, 20]);
  }
}

module body_shapes() {
  hull() {
    for (sx = [-1, 1]) {
      translate([sx * 13, 4, 14]) sphere(16);
      translate([sx * 10, 5, 34]) sphere(13);
    }
    // hoodie front, deep enough for the cable channel
    translate([0, -5, 34]) sphere(14);
  }
  for (sx = [-1, 1]) {
    // thighs
    limb([sx * 12, -2, 11], 11.5, [sx * 12, -20, 12], 11);
    // boots
    hull() for (dx = [-5, 5], y = [-23, -33], z = [6, 13]) translate([sx * 12.5 + dx, y, z]) sphere(6);
    // arms, hands resting on the knees
    limb([sx * 21, 3, 32], 7.5, [sx * 17, -14, 22], 7);
    // hoodie drawstrings
    limb([sx * 5, -16, 37], 1.1, [sx * 6, -15.4, 27], 1.1);
    translate([sx * 6, -15.6, 26]) sphere(1.9);
  }
  collar();
}

// straight USB-C plug down from the head, then back out through the backpack
module cable_channel() {
  w = plug_w + 1;
  y0 = usb_y - plug_t / 2 - 0.5;
  y1 = usb_y + plug_t / 2 + 0.5;
  translate([-w / 2, 0, 0]) {
    translate([0, y0, chan_z[1] - 1]) cube([w, y1 - y0, 65 - chan_z[1]]);
    // wide bend, so a rigid plug about 24 mm long can turn the corner
    hull() {
      translate([0, y0, chan_z[1] - 3]) cube([w, y1 - y0, 52 - chan_z[1] + 3]);
      translate([0, usb_y + 2, chan_z[0]]) cube([w, 18 - usb_y - 2, chan_z[1] - chan_z[0]]);
    }
    translate([0, usb_y + 2, chan_z[0]]) cube([w, 60, chan_z[1] - chan_z[0]]);
  }
}

// along +y at each backpack peg position
module backpack_pegs() for (sx = [-1, 1]) translate([sx * 7, 0, bp_peg_z]) rotate([-90, 0, 0]) children();

module body() intersection() {
  union() {
    difference() {
      body_shapes();
      head_place() head_outer(fit);
      cable_channel();
      // backpack peg holes, wider at the end so the barbs click in
      backpack_pegs() {
        translate([0, 0, 6]) cylinder(d = 3.6, h = 24, $fn = 24);
        translate([0, 0, 6]) cylinder(d = 4.4, h = 3, $fn = 24);
      }
    }
    for (sx = [-1, 1]) translate([sx * peg_x, head_y + peg_s, 44]) cylinder(d = 3.8, h = 7.4, $fn = 24);
  }
  translate([-100, -100, base_z]) cube([200, 200, 200]);
}

// ---------------------------------------------------------------- backpack

bp_back = 27;
module backpack() {
  difference() {
    intersection() {
      hull() for (x = [-9, 9], z = [13, 33], y = [12, bp_back - 3]) translate([x, y, z]) sphere(4);
      translate([-50, 0, 0]) cube([100, bp_back, 100]);
    }
    translate([0, -0.25, 0]) body_shapes();
    cable_channel();
    // flap seam above the cable opening
    translate([-9, bp_back - 1, chan_z[1] + 1.6]) cube([18, 2, 1.2]);
  }
  // split pegs; the barbs squeeze through the body hole and open in the wider end
  difference() {
    backpack_pegs() {
      translate([0, 0, 8.7]) cylinder(d = 3.4, h = 14, $fn = 24);
      translate([0, 0, 8.3]) cylinder(d = 4.1, h = 0.4, $fn = 24);
      translate([0, 0, 6.5]) cylinder(d1 = 3.0, d2 = 4.1, h = 1.8, $fn = 24);
    }
    backpack_pegs() translate([-0.45, -5, 6]) cube([0.9, 10, 7]);
  }
}

// ============================================================ output

module screen() head_place() {
  color("#050505") translate([0, lip_t + 0.2, 0]) along_y() cylinder(r = window_d / 2, h = 0.2, $fn = 120);
  color(eye) for (sx = [-1, 1]) translate([sx * 7.5, lip_t, 1]) rotate([90, 0, 0])
    linear_extrude(0.2) offset(r = 2.5) square([2.5, 9], center = true);
}

module buttons_placed() for (a = [-btn_angle, btn_angle]) at_angle(a, btn_s) translate([0, 0, 24.9]) button();

module assembled() {
  color(hoodie) body();
  color(black) backpack();
  head_place() {
    color(white) head_front();
    color(white) head_back();
    color(white) buttons_placed();
    color(black) headphones();
  }
  screen();
}

// stand-ins for the bought parts, for the guide renders (head frame)
module components() {
  color("#1d3b2a") {
    translate([0, lip_t, 0]) along_y() cylinder(r = board_d / 2, h = 6.9, $fn = 120);
    for (p = posts) translate([p[0], lip_t + 6.9, p[1]]) along_y() cylinder(d = 3.4, h = 3.5, $fn = 24);
  }
  color("#6f8fb5") translate([-bat[0] / 2, bat_front + 0.2, -bat[1] / 2]) cube([bat[0], bat[2], bat[1]]);
  color("#444") translate([-spk[0] / 2, spk_front - spk[2], -spk[1] / 2]) cube([spk[0], spk[2], spk[1]]);
  color("#8a8a8a") {
    translate([-6, usb_s - 3.2, -23.8 - 22]) cube([12, 6.4, 22]);
    mid = (chan_z[0] + chan_z[1]) / 2 - head_z;
    path = [[usb_s, -46], [usb_s, -49], [usb_s + 6, mid], [bp_back + 12 - head_y, mid]];
    for (i = [0:len(path) - 2]) hull() for (p = [path[i], path[i + 1]]) translate([0, p[0], p[1]]) sphere(d = 3.8, $fn = 16);
  }
}

module exploded() {
  color(hoodie) body();
  color(black) translate([0, 30, 0]) backpack();
  head_place() translate([0, 0, 35]) {
    color(white) translate([0, -30, 0]) { head_front(); buttons_placed(); }
    translate([0, -12, 0]) components();
    color(white) translate([0, 18, 0]) head_back();
    color(black) translate([0, 18, 26]) headphones();
  }
}

module cutaway() {
  intersection() {
    union() {
      color(hoodie) body();
      color(black) backpack();
      head_place() { color(white) head_front(); color("#dcdcd6") head_back(); color(white) buttons_placed(); }
    }
    translate([-100, -100, -1]) cube([100, 200, 200]);
  }
  head_place() components();
}

// looking into the head back with the speaker and battery clipped in
module head_inside() {
  color(white) head_back();
  color("#6f8fb5") translate([-bat[0] / 2, bat_front + 0.2, -bat[1] / 2]) cube([bat[0], bat[2], bat[1]]);
  color("#444") translate([-spk[0] / 2, spk_front - spk[2], -spk[1] / 2]) cube([spk[0], spk[2], spk[1]]);
}

// print orientations
module p_head_front() rotate([90, 0, 0]) head_front();
module p_head_back() translate([0, 0, -split_s]) rotate([90, 0, 0]) head_back();
module p_headphones() translate([0, 0, cup_cut]) rotate([-90, 0, 0]) headphones();
module p_backpack() translate([0, 0, bp_back]) rotate([-90, 0, 0]) backpack();
module p_body() translate([0, 0, -base_z]) body();

module plate_white() {
  translate([-38, 0, 0]) p_head_front();
  translate([38, 0, 0]) p_head_back();
  for (sx = [-1, 1]) translate([sx * 6, 45, 0]) button();
}
module plate_black() {
  translate([0, 10, 0]) p_headphones();
  translate([0, -45, 0]) p_backpack();
}

if (part == "preview") assembled();
else if (part == "exploded") exploded();
else if (part == "cutaway") cutaway();
else if (part == "head_inside") head_inside();
else if (part == "head_front") p_head_front();
else if (part == "head_back") p_head_back();
else if (part == "button") button();
else if (part == "headphones") p_headphones();
else if (part == "body") p_body();
else if (part == "backpack") p_backpack();
else if (part == "plate_white") plate_white();
else if (part == "plate_black") plate_black();
else if (part == "plate_red") p_body();
else if (part == "plate_all") {
  translate([-75, 70, 0]) p_head_front();
  translate([0, 70, 0]) p_head_back();
  for (sx = [-1, 1]) translate([60 + sx * 6, 95, 0]) button();
  translate([80, 10, 0]) p_body();
  translate([-40, -30, 0]) p_headphones();
  translate([30, -80, 0]) p_backpack();
}
