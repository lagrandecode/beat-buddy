// Cut-through pictures of the three kinds of clip, for the assembly guide.
use <beat_buddy.scad>
view = "hook"; // [hook, pockets, body, headphones]
white = "#f4f3ef";
blue = "#5aa0d0";
red = "#e2402c";
black = "#3a3a3d";
mark = "#ff8a00";

module cut_hook() intersection() { rotate([0, -62, 0]) children(); translate([0, 2, 26.5]) cube([40, 17.5, 7]); }
module cut_body() intersection() { children(); translate([-50, -20, 38.5]) cube([62.5, 16, 17]); }
module cut_hp() intersection() { children(); translate([22, 0, -8]) cube([24, 24.5, 16]); }

if (view == "hook") { color(white) cut_hook() head_front(); color(blue) cut_hook() head_back(); }
if (view == "pockets") {
  // the head back seen from its open side, with the four hook pockets marked
  color(white) head_back();
  color(mark) for (a = [-120, -62, 62, 120]) sector(a, 8.4) translate([30.6, 15.1]) square([0.45, 1.9]);
}
if (view == "body") {
  color(red) cut_body() body();
  color(white) cut_body() head_place() head_front();
  color(blue) cut_body() head_place() head_back();
}
if (view == "headphones") { color(blue) cut_hp() head_back(); color(black) cut_hp() headphones(); }
