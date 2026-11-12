// Beat Buddy — seated desk robot with a round AMOLED face, headphones and a hoodie
//
// The head holds a Waveshare ESP32-S3-Touch-AMOLED-1.75 behind a white bezel,
// with a 1000 mAh LiPo and a small speaker inside. The head splits in two just
// behind the board and is held shut by four 6 × 2 mm magnets. It rests in the
// hood collar of the body on two pegs. A right-angle USB-C cable plugs into the
// board from below and runs down a slot in the back into the backpack.
//
// Every part prints in one colour without supports:
//   white: head_front, head_back, speaker_holder    black: band, cup_r, cup_l, backpack    red: body
//
// Units: millimetres. Body frame: z up, the robot faces −y.

/* [Render] */
part = "preview"; // [preview, exploded, cutaway, head_front, head_back, speaker_holder, band, cup_r, cup_l, body, backpack, plate_white, plate_black, plate_red, plate_all]
white = "#f4f3ef";
black = "#2b2b2d";
hoodie = "#e2402c";
eye = "#ffd23a";

/* [Display board — measure yours] */
board_d = 48.96;      // Waveshare ESP32-S3-Touch-AMOLED-1.75 outline
board_t = 10.4;       // total thickness, glass to back
window_d = 46;        // visible opening in the bezel (screen is 44.5 mm)
usb_depth = 7.5;      // USB-C centre, measured back from the glass face
usb_w = 13;           // slot for the right-angle plug body
usb_t = 7.5;
button_angle = 30;    // PWR/BOOT side buttons, degrees up from the robot's left side (+x)

/* [Head] */
head_r = 33;          // head radius (66 mm across)
head_side = 18;       // straight part of the side before the back dome
head_dome = 26;       // depth of the back dome
face_fillet = 6;      // roundness of the front edge
wall = 2;
lip_t = 1.6;          // bezel thickness in front of the glass

/* [Magnets] */
magnet_d = 6.3;       // 6 × 2 mm neodymium magnets, 4 pairs
magnet_h = 2.2;
magnet_angles = [0, 70, 110, 180];

/* [Speaker — Waveshare 2030 box speaker included with the board] */
spk = [30, 20, 5.5];  // length (left–right), height, thickness
spk_fit = 0.3;
spk_front = 36.5;     // cone face, measured back from the glass face
clip_w = 10;
clip_l = 7.5;
clip_t = 1.0;
clip_lip = 0.7;

/* [Fit] */
fit = 0.4;

/* [Hidden] */
$fn = 72;
eps = 0.01;
board_r = board_d / 2 + 0.2;
split_s = lip_t + board_t + 0.4;   // head splits here, right behind the board
ring_t = 2;                        // back half's front ring that presses on the board edge
magnet_r = (board_r + head_r) / 2;
usb_s = lip_t + usb_depth;
cup_s = 17;                        // headphone position, back from the face
cup_r = 13;
cup_out = head_r + 9;
band_in = head_r + 0.4;
band_w = 8;
band_h = 4;

head_y = -18;                      // face plane in the body frame
head_z = 79;                       // head axis height
collar_c = [0, 4, 45];
peg_x = 12;
peg_s = 8;
usb_y = head_y + usb_s;
base_z = 2;                        // body is cut flat here, so the rounded bottoms start at a printable angle

// ============================================================ head (head frame)
// Head frame: the face is the plane y = 0, the head axis runs along +y (backwards).

function head_profile() = concat(
  [[0, 0]],
  [for (a = [-90:5:0]) [head_r - face_fillet + face_fillet * cos(a), face_fillet + face_fillet * sin(a)]],
  [for (t = [0:3:90]) [head_r * cos(t), head_side + head_dome * sin(t)]]
);

module along_y() rotate([-90, 0, 0]) children();

module revolve(grow = 0) along_y() rotate_extrude($fn = 160) intersection() {
  offset(r = grow) polygon(head_profile());
  translate([0, -50]) square([100, 200]);
}

module head_outer(grow = 0) revolve(grow);

module head_cavity(inset = 0) along_y() rotate_extrude($fn = 160) intersection() {
  offset(r = -wall - inset) union() { polygon(head_profile()); mirror([1, 0]) polygon(head_profile()); }
  translate([0, -50]) square([100, 200]);
}

module polar(angle, r) rotate([0, -angle, 0]) translate([r, 0, 0]) children();

function hex_grid(pitch, rmax) = [for (i = [-6:6], j = [-6:6]) let(p = [pitch * (i + j / 2), pitch * j * sqrt(3) / 2])
  if (norm(p) <= rmax) p];

module head_full() {
  difference() {
    union() {
      head_outer();
      // magnet bosses behind the ring
      intersection() {
        head_outer();
        for (a = magnet_angles) polar(a, magnet_r) translate([0, split_s, 0]) along_y() cylinder(d = magnet_d + 3, h = ring_t + 1.2 + magnet_h);
      }
    }
    // hollow back, starting behind the ring that clamps the board
    difference() {
      intersection() { head_cavity(); translate([-50, split_s + ring_t, -50]) cube(100); }
      for (a = magnet_angles) polar(a, magnet_r) translate([0, split_s, 0]) along_y() cylinder(d = magnet_d + 3, h = ring_t + 1.2 + magnet_h);
    }
    // board pocket and the ring opening behind it
    translate([0, lip_t, 0]) along_y() cylinder(r = board_r, h = split_s - lip_t + eps, $fn = 160);
    translate([0, split_s - eps, 0]) along_y() cylinder(r = board_r - 1.7, h = ring_t + 1, $fn = 160);
    // screen window with a chamfer
    translate([0, -eps, 0]) along_y() cylinder(h = lip_t + 2 * eps, r1 = window_d / 2 + 1.2, r2 = window_d / 2, $fn = 160);
    // magnet pockets on both sides of the split
    for (a = magnet_angles) polar(a, magnet_r) translate([0, split_s - magnet_h, 0]) along_y() cylinder(d = magnet_d, h = 2 * magnet_h);
    // USB-C plug from below
    translate([-usb_w / 2, usb_s - usb_t / 2, -head_r - 5]) cube([usb_w, usb_t, head_r + 5 - board_r + 1.5]);
    // side-button access
    polar(button_angle, board_r - 2) translate([0, lip_t + 1.5, -5]) cube([head_r, board_t - 3, 10]);
    // speaker grille
    for (p = hex_grid(4, 10)) translate([p[0], head_side, p[1]]) along_y() cylinder(d = 2.4, h = head_dome + 5, $fn = 16);
    // headphone pegs
    for (sx = [-1, 1]) translate([sx * (head_r - 5), cup_s, 0]) rotate([0, 90, 0]) cylinder(d = 3.3, h = 10, center = true, $fn = 24);
    // locating holes for the body pegs
    for (sx = [-1, 1]) translate([sx * peg_x, peg_s, -head_r - 1]) cylinder(d = 4.4, h = head_r + 1 - sqrt(head_r * head_r - peg_x * peg_x) + 3.8, $fn = 24);
  }
}

// Separate holder glued into the dome behind the grille. The speaker clips in
// cone first; the top follows the inside of the dome so it only seats centred.
module speaker_holder() {
  px = spk[0] + 2 * spk_fit;
  pz = spk[1] + 2 * spk_fit;
  sw = 1.6;
  lip_y = spk_front - spk[2] - 0.2;
  y0 = lip_y - 1.2;
  difference() {
    intersection() {
      union() {
        translate([-px / 2 - sw, y0, -pz / 2 - sw]) cube([px + 2 * sw, 30, pz + 2 * sw]);
      }
      head_cavity(0.15);
    }
    translate([-px / 2, y0 - 1, -pz / 2]) cube([px, 40, pz]);
    for (m = [0, 1]) mirror([0, 0, m]) {
      // flexing clip tab, freed by two slots and thinned from outside
      for (sx = [-1, 1]) translate([sx * (clip_w / 2 + 0.3) - 0.3, y0 - 1, pz / 2 - 0.1]) cube([0.6, clip_l + 1, sw + 0.2]);
      translate([-clip_w / 2, y0 - 1, pz / 2 + clip_t]) cube([clip_w, clip_l + 1, sw]);
    }
    // wire exits on both ends
    for (sx = [-1, 1]) translate([sx * (px / 2 + sw / 2), y0 + 2, 0]) cube([sw + 1, 6, 6], center = true);
  }
  intersection() {
    union() {
      for (m = [0, 1]) mirror([0, 0, m]) hull() {
        translate([-clip_w / 2 + 0.5, y0, pz / 2 - eps]) cube([clip_w - 1, eps, eps]);
        translate([-clip_w / 2 + 0.5, lip_y - eps, pz / 2 - clip_lip]) cube([clip_w - 1, eps, clip_lip + eps]);
      }
      // corner stops the cone face rests on
      for (sx = [-1, 1], sz = [-1, 1]) hull()
        for (c = [[0, 0], [-3.5, 0], [0, -3.5]]) translate([sx * (px / 2 + c[0]), spk_front, sz * (pz / 2 + c[1])]) cube([eps, 30, eps]);
    }
    translate([-px / 2 - eps, y0, -pz / 2 - eps]) cube([px + 2 * eps, 30, pz + 2 * eps]);
    head_cavity(0.15);
  }
}

module head_front() intersection() { head_full(); translate([-50, -1, -50]) cube([100, split_s + 1, 100]); }
module head_back() intersection() { head_full(); translate([-50, split_s, -50]) cube([100, 100, 100]); }

// ---------------------------------------------------------------- headphones

module band(grow = 0) translate([0, cup_s, 0]) rotate([90, 0, 0]) rotate([0, 0, 18])
  rotate_extrude(angle = 144, $fn = 160)
    translate([band_in - grow, -band_w / 2 - grow]) offset(r = 1.2) offset(delta = -1.2) square([band_h + 2 * grow, band_w + 2 * grow]);

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
    band(0.15);
    // ring detail on the outside
    translate([cup_out - 0.8, cup_s, 0]) rotate([0, 90, 0]) difference() {
      cylinder(r = 9.6, h = 2, $fn = 96);
      translate([0, 0, -1]) cylinder(r = 8.4, h = 4, $fn = 96);
    }
  }
  translate([head_r - 3.2, cup_s, 0]) rotate([0, 90, 0]) cylinder(d = 3, h = 3.6, $fn = 24);
}

module cup_l() mirror([1, 0, 0]) cup_r();

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
  hull() for (sx = [-1, 1]) {
    translate([sx * 13, 4, 14]) sphere(16);
    translate([sx * 10, 5, 34]) sphere(13);
  }
  for (sx = [-1, 1]) {
    // thighs
    limb([sx * 12, -2, 11], 11.5, [sx * 12, -20, 12], 11);
    // boots
    hull() for (dx = [-5, 5], y = [-23, -33], z = [6, 13]) translate([sx * 12.5 + dx, y, z]) sphere(6);
    // arms, hands resting on the knees
    limb([sx * 21, 3, 32], 7.5, [sx * 17, -14, 22], 7);
    // hoodie drawstrings
    limb([sx * 5, -12, 37], 1.1, [sx * 6, -11, 27], 1.1);
    translate([sx * 6, -11.2, 26]) sphere(1.9);
  }
  collar();
}

module cable_slot() hull() {
  translate([-2.3, usb_y + 2, 36]) cube([4.6, 3, 13]);
  translate([-2.3, 34, 13]) cube([4.6, 1, 25]);
}

module backpack_pegs(d, l) for (sx = [-1, 1]) translate([sx * 8, 8, 22]) rotate([-90, 0, 0]) cylinder(d = d, h = l, $fn = 24);

module body() intersection() {
  union() {
    difference() {
      body_shapes();
      head_place() head_outer(fit);
      translate([-7.5, usb_y - 4.5, 34]) cube([15, 9, 20]);
      cable_slot();
      backpack_pegs(3.4, 22);
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
    intersection() { cable_slot(); translate([-50, 0, 0]) cube([100, bp_back - 4, 100]); }
    translate([0, 15, 15.5]) rotate([-90, 0, 0]) cylinder(d = 5.5, h = 20, $fn = 32);
    // flap outline on the back
    translate([0, bp_back - 1, 0]) {
      translate([-8, 0, 25]) cube([16, 2, 1.4]);
      for (sx = [-1, 1]) translate([sx * 8 - 0.7, 0, 25]) cube([1.4, 2, 14]);
    }
  }
  intersection() {
    backpack_pegs(3.0, 12);
    translate([0, 0.25, 0]) body_shapes();
  }
}

// ============================================================ output

module screen() head_place() {
  color("#050505") translate([0, lip_t + 0.2, 0]) along_y() cylinder(r = window_d / 2, h = 0.2, $fn = 120);
  color(eye) for (sx = [-1, 1]) translate([sx * 7.5, lip_t, 1]) rotate([90, 0, 0])
    linear_extrude(0.2) offset(r = 2.5) square([2.5, 9], center = true);
}

module assembled() {
  color(hoodie) body();
  color(black) backpack();
  head_place() {
    color(white) head_front();
    color(white) head_back();
    color(black) { band(); cup_r(); cup_l(); }
  }
  screen();
}

// stand-ins for the bought parts, for the guide renders (head frame)
battery_size = [40, 10, 30];       // 103040 LiPo: width, thickness, height
module components() {
  color("#1d3b2a") translate([0, lip_t, 0]) along_y() cylinder(r = board_d / 2, h = board_t, $fn = 120);
  color("#6f8fb5") translate([-battery_size[0] / 2, split_s + ring_t + 0.4, -battery_size[2] / 2]) cube(battery_size);
  color("#444") translate([-spk[0] / 2, spk_front - spk[2], -spk[1] / 2]) cube([spk[0], spk[2], spk[1]]);
  color("#c8c8cc") for (a = magnet_angles) polar(a, magnet_r) translate([0, split_s - 2, 0]) along_y() cylinder(d = 6, h = 4, $fn = 32);
  color("#8a8a8a") {
    translate([-6, usb_s - 3.25, -board_r - 12]) cube([12, 6.5, 13]);
    // cable route, down the slot and out of the backpack (body frame points)
    path = [[usb_s + 2, -board_r - 8], [40, 38 - head_z], [40, 17 - head_z], [56, 15.5 - head_z]];
    for (i = [0:len(path) - 2]) hull() for (p = [path[i], path[i + 1]]) translate([0, p[0], p[1]]) sphere(d = 3.8, $fn = 16);
  }
}

module exploded() {
  color(hoodie) body();
  color(black) translate([0, 30, 0]) backpack();
  head_place() translate([0, 0, 35]) {
    color(white) translate([0, -30, 0]) head_front();
    translate([0, -12, 0]) components();
    color("#9a9a9a") translate([0, 6, 0]) speaker_holder();
    color(white) translate([0, 18, 0]) head_back();
    color(black) {
      translate([0, 18, 22]) band();
      translate([22, 18, 0]) cup_r();
      translate([-22, 18, 0]) cup_l();
    }
  }
}

module cutaway() {
  intersection() {
    union() {
      color(hoodie) body();
      color(black) backpack();
      head_place() { color(white) head_front(); color("#dcdcd6") head_back(); color("#9a9a9a") speaker_holder(); }
    }
    translate([-100, -100, -1]) cube([100, 200, 200]);
  }
  head_place() components();
}

// print orientations
module p_head_front() translate([0, 0, split_s]) rotate([-90, 0, 0]) head_front();
module p_head_back() translate([0, 0, -split_s]) rotate([90, 0, 0]) head_back();
module p_speaker_holder() translate([0, 0, -(spk_front - spk[2] - 1.4)]) rotate([90, 0, 0]) speaker_holder();
module p_band() translate([0, 0, -(cup_s - band_w / 2)]) rotate([90, 0, 0]) band();
module p_cup_r() translate([0, 0, cup_out]) rotate([0, 90, 0]) translate([0, -cup_s, 0]) cup_r();
module p_cup_l() translate([0, 0, cup_out]) rotate([0, -90, 0]) translate([0, -cup_s, 0]) cup_l();
module p_backpack() translate([0, 0, bp_back]) rotate([-90, 0, 0]) translate([0, 0, -24]) backpack();
module p_body() translate([0, 0, -base_z]) body();

module plate_white() { translate([-40, 0, 0]) p_head_front(); translate([40, 0, 0]) p_head_back(); translate([0, 55, 0]) p_speaker_holder(); }
module plate_black() {
  translate([0, 35, 0]) p_band();
  translate([-30, -25, 0]) p_cup_r();
  translate([5, -25, 0]) p_cup_l();
  translate([40, -25, 0]) p_backpack();
}

if (part == "preview") assembled();
else if (part == "exploded") exploded();
else if (part == "cutaway") cutaway();
else if (part == "head_front") p_head_front();
else if (part == "head_back") p_head_back();
else if (part == "speaker_holder") p_speaker_holder();
else if (part == "band") p_band();
else if (part == "cup_r") p_cup_r();
else if (part == "cup_l") p_cup_l();
else if (part == "body") p_body();
else if (part == "backpack") p_backpack();
else if (part == "plate_white") plate_white();
else if (part == "plate_black") plate_black();
else if (part == "plate_red") p_body();
else if (part == "plate_all") {
  translate([-75, 70, 0]) p_head_front();
  translate([0, 70, 0]) p_head_back();
  translate([80, 20, 0]) p_body();
  translate([-50, -10, 0]) p_band();
  translate([-90, -85, 0]) p_cup_r();
  translate([-55, -85, 0]) p_cup_l();
  translate([0, -80, 0]) p_backpack();
  translate([-120, 20, 0]) p_speaker_holder();
}
