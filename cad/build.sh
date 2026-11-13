#!/bin/sh
# Export print-ready STLs and Bambu Studio 3MFs (already in print orientation) and preview renders.
set -e
cd "$(dirname "$0")"
SCAD=beat_buddy.scad
OS="openscad --backend=manifold"
OUT=../print
mkdir -p "$OUT" ../renders

rm -f "$OUT"/beat_buddy_*.stl
for p in head_front head_back button headphones body backpack; do
  $OS -D "part=\"$p\"" --export-format binstl -o "$OUT/beat_buddy_$p.stl" "$SCAD"
done

# one 3MF per filament colour, plus everything on one plate
$OS --enable=lazy-union -D 'part="plate_white"' -o "$OUT/beat_buddy_WHITE_plate.3mf" "$SCAD"
python3 name_3mf.py "$OUT/beat_buddy_WHITE_plate.3mf" "Head front (white)" "Head back (white)" "Button PWR (white)" "Button BOOT (white)"
$OS --enable=lazy-union -D 'part="plate_black"' -o "$OUT/beat_buddy_BLACK_plate.3mf" "$SCAD"
python3 name_3mf.py "$OUT/beat_buddy_BLACK_plate.3mf" "Headphones (black)" "Backpack (black)"
$OS -D 'part="plate_red"' -o "$OUT/beat_buddy_RED_plate.3mf" "$SCAD"
python3 name_3mf.py "$OUT/beat_buddy_RED_plate.3mf" "Body (hoodie colour)"
$OS --enable=lazy-union -D 'part="plate_all"' -o "$OUT/beat_buddy_ALL_PARTS.3mf" "$SCAD"
python3 name_3mf.py "$OUT/beat_buddy_ALL_PARTS.3mf" "Head front (white)" "Head back (white)" "Button PWR (white)" "Button BOOT (white)" \
  "Body (hoodie colour)" "Headphones (black)" "Backpack (black)"

# small test pieces: every kind of clip, to try before the long prints
$OS -D 'part="plate_test"' --export-format binstl -o "$OUT/beat_buddy_CLIP_TEST.stl" "$SCAD"
$OS --enable=lazy-union -D 'part="plate_test"' -o "$OUT/beat_buddy_CLIP_TEST.3mf" "$SCAD"
python3 name_3mf.py "$OUT/beat_buddy_CLIP_TEST.3mf" "Test: head front corner" "Test: head back strip" "Test: ear cup" "Test: body peg"

render() { $OS -D "part=\"$2\"" --render --imgsize=1400,1400 --colorscheme=Tomorrow --camera="$3" --projection=perspective -o "../renders/$1.png" "$SCAD"; }
render beat_buddy_angle preview 0,0,55,72,0,-35,380
render beat_buddy_front preview 0,0,58,88,0,0,330
render beat_buddy_side preview 0,0,58,90,0,90,330
render beat_buddy_back preview 0,0,58,75,0,150,340
render beat_buddy_print_plate plate_all 0,0,10,40,0,15,520
render beat_buddy_exploded exploded 0,-5,70,72,0,58,500
render beat_buddy_head_inside head_inside 0,25,0,70,0,25,170
render beat_buddy_clip_test plate_test -1,12,6,52,0,205,185

# cut-through pictures of the clips
clip() { $OS -D "view=\"$2\"" --render --imgsize=$3 --colorscheme=Tomorrow --camera="$4" $5 --projection=$6 -o "../renders/$1.png" clip_views.scad; }
clip beat_buddy_clip_head hook 1500,700 0,10.75,30,90,0,-90,24 "" ortho
clip beat_buddy_clip_pockets pockets 1400,1200 0,16,0,62,0,28,165 "" perspective
clip beat_buddy_clip_body body 1100,1100 12.5,-12,47,90,0,90,46 "" ortho
clip beat_buddy_clip_headphones headphones 1300,900 34,24.5,0,90,0,180,46 "" ortho
$OS -D 'part="cutaway"' --render --imgsize=1400,1400 --colorscheme=Tomorrow --camera=0,0,60,80,0,70,330 --projection=perspective -o ../renders/beat_buddy_cutaway.png "$SCAD"
python3 volume.py "$OUT"/*.stl
