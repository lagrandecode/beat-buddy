#!/bin/sh
# Export print-ready STLs and Bambu Studio 3MFs (already in print orientation) and preview renders.
set -e
cd "$(dirname "$0")"
SCAD=beat_buddy.scad
OS="openscad --backend=manifold"
OUT=../print
mkdir -p "$OUT" ../renders

for p in head_front head_back band cup_r cup_l body backpack; do
  $OS -D "part=\"$p\"" --export-format binstl -o "$OUT/beat_buddy_$p.stl" "$SCAD"
done

# one 3MF per filament colour, plus everything on one plate
$OS --enable=lazy-union -D 'part="plate_white"' -o "$OUT/beat_buddy_WHITE_plate.3mf" "$SCAD"
python3 name_3mf.py "$OUT/beat_buddy_WHITE_plate.3mf" "Head front (white)" "Head back (white)"
$OS --enable=lazy-union -D 'part="plate_black"' -o "$OUT/beat_buddy_BLACK_plate.3mf" "$SCAD"
python3 name_3mf.py "$OUT/beat_buddy_BLACK_plate.3mf" "Headphone band (black)" "Ear cup right (black)" "Ear cup left (black)" "Backpack (black)"
$OS -D 'part="plate_red"' -o "$OUT/beat_buddy_RED_plate.3mf" "$SCAD"
python3 name_3mf.py "$OUT/beat_buddy_RED_plate.3mf" "Body (hoodie colour)"
$OS --enable=lazy-union -D 'part="plate_all"' -o "$OUT/beat_buddy_ALL_PARTS.3mf" "$SCAD"
python3 name_3mf.py "$OUT/beat_buddy_ALL_PARTS.3mf" "Head front (white)" "Head back (white)" "Body (hoodie colour)" \
  "Headphone band (black)" "Ear cup right (black)" "Ear cup left (black)" "Backpack (black)"

render() { $OS -D "part=\"$2\"" --render --imgsize=1400,1400 --colorscheme=Tomorrow --camera="$3" --projection=perspective -o "../renders/$1.png" "$SCAD"; }
render beat_buddy_angle preview 0,0,55,72,0,-35,380
render beat_buddy_front preview 0,0,58,88,0,0,330
render beat_buddy_side preview 0,0,58,90,0,90,330
render beat_buddy_back preview 0,0,58,75,0,150,340
render beat_buddy_print_plate plate_all 0,0,10,40,0,15,520
render beat_buddy_exploded exploded 0,-5,70,72,0,58,500
$OS -D 'part="cutaway"' --render --imgsize=1400,1400 --colorscheme=Tomorrow --camera=0,0,60,80,0,70,330 --projection=perspective -o ../renders/beat_buddy_cutaway.png "$SCAD"
python3 volume.py "$OUT"/*.stl
