// Beat Buddy — seated desk robot with a round AMOLED face, headphones and a hoodie
//
// The head holds a Waveshare ESP32-S3-Touch-AMOLED-1.75 behind a white bezel.
// Everything snaps together, no glue or magnets:
//   - the head back clicks onto four snap hooks on the head front; each hook
//     drops into its own pocket inside the head back's rim
//   - three pads in the head back press on the board's brass posts
//   - two printed push-buttons reach the board's PWR and BOOT buttons
//   - the speaker and a 752035 LiPo clip into a frame inside the head back
//   - the one-piece headphones snap a split clip into each side of the head
//   - the head snaps onto two split, barbed pegs standing in the collar
//   - the backpack snaps onto the body on two split, barbed pegs
// A straight USB-C cable comes in through the backpack, runs up a channel in
// the body and plugs into the board from below.
//
// Board positions come from Waveshare's dimension drawing: PWR and BOOT sit on
// the back of the circuit board, at its edge, 34° either side of the point
// opposite the USB-C port. The three M2 brass posts end 10.4 mm behind the
// glass; the SPK/BAT sockets and the pin header stand a little taller.
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
pcb_back = 6.9;       // glass to the back face of the circuit board
usb_depth = 8.6;      // USB-C centre, back from the glass (the port sits on the back of the circuit board)
btn_angle = 34;       // PWR left, BOOT right, degrees either side of the top
posts = [[-20.5, 0], [14.7, 13.75], [14.7, -13.75]];  // brass posts (x, z), USB-C pointing down

/* [Push-buttons] */
btn_t = 2.4;          // thickness; the buttons print lying flat
btn_w = 3;            // stem width
btn_head = [6, 1.2];  // wide inner end: width, length
btn_len = 11.6;

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
hook_root = 7.5;      // how far the hooks reach down into the head front, for a long, easy bend
hook_t = 1.4;
hook_bump = 0.7;

/* [Clips: body to head, headphones to head] */
clip_d = 4;           // body peg shaft
clip_barb = 0.5;      // how far each barb sticks out
clip_slot = 1.2;      // split down the middle of the peg
clip_pit = 8;         // the pegs stand in pits this deep, so they are long enough to bend
hp_clip_t = 3;        // headphone clip thickness (it prints flat on the bed)
hp_clip_x = 29;       // face inside the head that the headphone clip catches on

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
btn_s = lip_t + pcb_back + 0.4 + btn_t / 2;  // the buttons pass just behind the circuit board, onto its switches
cup_s = 17;                        // headphone pegs, back from the face
cup_r = 13;
cup_out = head_r + 9;
cup_cut = cup_s + 9;               // flat back of the headphones, the print face
band_w = 8;
band_t = 4;
band_angle = 78;
col_x = [12.5, 15.5];              // frame columns for the speaker and battery
col_xl = [-14, -11];               // the left pair sit further in, clear of the SPK and BAT sockets
col_z = 10.35;
col_t = 2.5;
bat_back = spk_front - spk[2];     // battery rests against the back of the speaker
bat_front = bat_back - bat[2] - 0.2;

head_y = -18;                      // face plane in the body frame
head_z = 79;                       // head axis height
collar_c = [0, 4, 45];
peg_x = 12.5;
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

// body-to-head clip, heights in the head frame at the peg centre
sock_z0 = -sqrt(head_r * head_r - peg_x * peg_x);                    // head surface
sock_neck = sock_z0 + 2.3;                                           // end of the neck
sock_end = sock_z0 + 6.5;                                            // end of the room
seat_z = -sqrt((head_r + fit) * (head_r + fit) - peg_x * peg_x);     // collar surface
// the head settles about 0.35 mm into the collar's clearance; the barbs meet the neck there
clip_catch = sock_neck - 0.12 - 0.35;

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
    // push-button channels, with a recess for each button's wide end
    for (a = [-btn_angle, btn_angle]) at_angle(a, btn_s) {
      translate([0, 0, 23.5 + 6]) cube([btn_w + 0.4, btn_t + 0.4, 12], center = true);
      translate([0, 0, 23.5 + 1.15]) cube([btn_head[0] + 0.6, btn_t + 0.4, 2.3], center = true);
    }
    // room for the snap hooks to flex
    for (a = hook_angles) sector(a, hook_half + 2)
      translate([hook_ri - 0.75, split_s - hook_root]) square([hook_t + 0.75 + 0.3, hook_root + 1]);
    // sockets for the body's clip pegs: a neck, then a wider room the barbs open into
    for (sx = [-1, 1]) translate([sx * peg_x, peg_s, 0]) {
      translate([0, 0, -head_r - 1]) linear_extrude(sock_neck + head_r + 1) teardrop(clip_d + 0.4);
      hull() {
        translate([0, 0, sock_neck - eps]) linear_extrude(eps) teardrop(clip_d + 0.4);
        translate([0, 0, sock_neck + 0.36]) linear_extrude(eps) teardrop(clip_d + 1.6, 3.2);
      }
      translate([0, 0, sock_neck + 0.36]) linear_extrude(sock_end - sock_neck - 0.36) teardrop(clip_d + 1.6, 3.2);
    }
  }
  for (a = hook_angles) sector(a, hook_half) hook_profile();
}

// PWR/BOOT push-button, lying flat as printed, pointing along +y. The wide end rests on
// the board's switch; being flat, it reaches behind the circuit board without touching its edge.
module button() linear_extrude(btn_t) {
  translate([-btn_head[0] / 2, 0]) square(btn_head);
  translate([-btn_w / 2, 0]) square([btn_w, btn_len - btn_w / 2]);
  translate([0, btn_len - btn_w / 2]) circle(d = btn_w, $fn = 32);
}

// speaker and battery frame, four columns hanging from the dome
module frame() {
  for (cx = [col_x, col_xl], sz = [-1, 1]) mirror([0, 0, sz < 0 ? 1 : 0]) {
    w = cx[1] - cx[0];
    translate([cx[0], split_s, col_z]) cube([w, 40, col_t]);
    // stops for the speaker's cone face
    translate([cx[0], spk_front, col_z - 1.5]) cube([w, 10, 1.5 + eps]);
    // battery catch: ramp from the open end, flat face against the battery
    hull() {
      translate([cx[0], bat_front - 1, col_z - eps]) cube([w, eps, eps]);
      translate([cx[0], bat_front - eps, col_z - 0.9]) cube([w, eps, 0.9 + eps]);
    }
  }
}

module pads() {
  difference() {
    union() {
      for (p = posts) translate([p[0], split_s, p[1]]) along_y() cylinder(d = p[0] < 0 ? 4 : 5, h = 3, $fn = 32);
      // the two right pads hang off the frame columns, the left one off the wall
      for (sz = [-1, 1]) hull() {
        translate([col_x[0], split_s, sz > 0 ? col_z : -col_z - col_t]) cube([col_x[1] - col_x[0], 3, col_t]);
        translate([posts[1][0], split_s, sz * posts[1][1]]) along_y() cylinder(d = 4, h = 3, $fn = 24);
      }
      translate([-head_r, split_s, -1]) cube([head_r + posts[0][0], 3, 2]);
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
        union() { frame(); pads(); hp_bosses(); }
      }
    }
    // a pocket for each snap hook's bump; they also stop the head back turning
    for (a = hook_angles) sector(a, hook_half + 1) intersection() {
      translate([0, -0.2]) offset(delta = 0.2) hook_profile();
      translate([hook_ri + hook_t + 0.05, split_s]) square([5, 100]);
    }
    // windows for the headphone clips
    for (sx = [-1, 1]) translate([sx * 31, cup_cut - hp_clip_t / 2, 0]) cube([10, hp_clip_t + 0.5, 4.3], center = true);
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
    hp_well();
    translate([cup_out - 0.8, cup_s, 0]) rotate([0, 90, 0]) difference() {
      cylinder(r = 9.6, h = 2, $fn = 96);
      translate([0, 0, -1]) cylinder(r = 8.4, h = 4, $fn = 96);
    }
  }
  // locating pin into the head wall; it stops the headphones rocking
  translate([head_r + 0.35, cup_s, 0]) rotate([0, -90, 0]) linear_extrude(2.15) teardrop(3);
}

hp_root = hp_clip_x + 8.5;   // where the clip's two prongs join the cup

// split clip, the same idea as the backpack pegs but flat, so it prints lying on the bed:
// two prongs squeeze together through the window in the head, then spring apart behind it
module hp_clip() translate([0, cup_cut, 0]) rotate([90, 0, 0]) linear_extrude(hp_clip_t)
  for (m = [0, 1]) mirror([0, m]) polygon([
    [hp_root + 0.5, 0.7], [hp_root + 0.5, 2.0], [hp_clip_x, 2.0], [hp_clip_x - 0.3, 2.5], [hp_clip_x - 0.6, 2.5],
    [hp_clip_x - 2.1, 1.6], [hp_clip_x - 2.1, 0.7]]);

// room in the cup for the prongs to bend
module hp_well() translate([head_r - 8, cup_cut - hp_clip_t - 0.3, -2.7]) cube([hp_root - head_r + 8, hp_clip_t + 1.3, 5.4]);

// flat faces inside the head back for the headphone clips to catch on
module hp_bosses() for (sx = [-1, 1]) mirror([sx < 0 ? 1 : 0, 0, 0]) hull() {
  translate([hp_clip_x, cup_cut - hp_clip_t - 1.2, -4.5]) cube([4, hp_clip_t + 2.4, 9]);
  translate([head_r - wall - 0.1, cup_cut - hp_clip_t - 4, -4.5]) cube([2, 0.2, 9]);
}

// round with a 45° point towards +y, so it prints without support either way up;
// top cuts the point off flat at that height
module teardrop(d, top = 100) intersection() {
  hull() {
    circle(d = d, $fn = 32);
    translate([0, d / sqrt(2)]) square(0.01, center = true);
  }
  translate([-d, -d]) square([2 * d, d + top]);
}

module band() sector(0, band_angle) intersection() {
  difference() { offset(r = 0.4 + band_t) polygon(head_profile()); offset(r = 0.4) polygon(head_profile()); }
  translate([0, cup_cut - band_w]) square([60, band_w]);
}

module headphones() intersection() {
  union() { band(); for (m = [0, 1]) mirror([m, 0, 0]) { cup_r(); hp_clip(); } }
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

// along +z at each head peg position, starting at the bottom of its pit
module head_pegs() for (sx = [-1, 1]) translate([sx * peg_x, head_y + peg_s, head_z + seat_z - clip_pit]) children();

// split peg along +z: the two halves squeeze together to pass a neck, then the barbs spring out
module clip_peg(d, len, barb, slot) difference() {
  union() {
    cylinder(d = d, h = len, $fn = 32);
    translate([0, 0, len]) cylinder(d1 = d, d2 = d + 2 * barb, h = 0.6 * barb, $fn = 32);
    translate([0, 0, len + 0.6 * barb]) cylinder(d = d + 2 * barb, h = 0.3, $fn = 32);
    translate([0, 0, len + 0.6 * barb + 0.3]) cylinder(d1 = d + 2 * barb, d2 = d - 0.6, h = 1.8, $fn = 32);
  }
  translate([-slot / 2, -d, 0]) cube([slot, 2 * d, len + 5]);
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
      head_pegs() cylinder(d = clip_d + 1.6, h = 20, $fn = 32);
    }
    head_pegs() clip_peg(clip_d, clip_catch - seat_z + clip_pit, clip_barb, clip_slot);
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
    // 0.3 mm of clearance against the body
    translate([0, 0.3, 0]) body_shapes();
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
    backpack_pegs() translate([-0.45, -5, 6]) cube([0.9, 10, 10]);
  }
}

// ============================================================ output

module screen() head_place() {
  color("#050505") translate([0, lip_t + 0.2, 0]) along_y() cylinder(r = window_d / 2, h = 0.2, $fn = 120);
  color(eye) for (sx = [-1, 1]) translate([sx * 7.5, lip_t, 1]) rotate([90, 0, 0])
    linear_extrude(0.2) offset(r = 2.5) square([2.5, 9], center = true);
}

// resting on the switches, which end about 23.25 mm from the centre
module buttons_placed() for (a = [-btn_angle, btn_angle]) at_angle(a, btn_s) translate([0, btn_t / 2, 23.25]) rotate([90, 0, 0]) button();

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
    translate([0, lip_t, 0]) along_y() cylinder(r = board_d / 2, h = pcb_back, $fn = 120);
    for (p = posts) translate([p[0], lip_t + pcb_back, p[1]]) along_y() cylinder(d = 3.2, h = board_t - pcb_back, $fn = 24);
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
  for (sx = [-1, 1]) translate([sx * 6, 42, 0]) button();
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
