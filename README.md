# Beat Buddy

A seated desk robot with a round AMOLED face, headphones and a red hoodie. The face is a Waveshare ESP32-S3-Touch-AMOLED-1.75. A USB-C cable comes in through the backpack and runs up inside the body to the board, so it charges while it sits on your desk.

Everything snaps together. There's no glue, tape, screws or magnets.

![Beat Buddy](renders/beat_buddy_angle.png)

| Front | Side | Back |
| --- | --- | --- |
| ![Front](renders/beat_buddy_front.png) | ![Side](renders/beat_buddy_side.png) | ![Back](renders/beat_buddy_back.png) |

**Size:** 84 mm wide across the headphones, 114 mm tall. See [PLAN.md](PLAN.md) for the parts list and the firmware plan, and open [assembly_guide.html](assembly_guide.html) for the illustrated build guide.

## Files

| File | What's in it |
| --- | --- |
| `print/beat_buddy_WHITE_plate.3mf` | Head front, head back and the two push-buttons |
| `print/beat_buddy_BLACK_plate.3mf` | Headphones (one piece) and the backpack |
| `print/beat_buddy_RED_plate.3mf` | Body |
| `print/beat_buddy_ALL_PARTS.3mf` | All 7 parts on one plate, named by colour |
| `print/beat_buddy_*.stl` | Each part on its own, already in print orientation. Print `button.stl` twice. |
| `cad/beat_buddy.scad` | The editable OpenSCAD model. Board sizes are at the top. |

Every part is a single colour, so you don't need an AMS: print one plate per colour.

## Printing

| Part | Time on a Bambu A1 (0.2 mm) | Supports |
| --- | --- | --- |
| Head front | 1 h 23 m | None |
| Head back | 2 h 52 m | **Tree supports (auto)**, for the inside of the dome |
| Push-buttons ×2 | 4 m | None |
| Headphones | 54 m | None |
| Body | 4 h 18 m | None |
| Backpack | 28 m | None |

About 10 hours in total. Filament: about 30 g white (including supports), 10 g black and 35 g of hoodie colour.

- Material: PLA (matte looks best). Walls: 3. Infill: 15% gyroid.
- The orientation is already set in the files, so don't rotate them. The head front prints screen side down and the head back prints with its open side down.
- The head back's supports are all inside the dome, where nobody sees them. Pull them out through the open side.

## Parts to buy

- Waveshare ESP32-S3-Touch-AMOLED-1.75 (standard version, not "-G")
- 3.7 V 500 mAh 752035 LiPo (7.5 × 20 × 35 mm) with an MX1.25 2-pin plug
- The 8 Ω 2 W speaker that comes with the board (Waveshare 2030 box speaker, 20 × 30 × 5.5 mm)
- An ordinary **straight** USB-C cable. The stiff part of the plug must be at most 13 mm wide, 8.5 mm thick and 24 mm long, which covers almost all of them.

## Assembly

1. **Buttons:** from inside the head front, push the two printed buttons out through the two small holes near the top, collar side in.
2. **Board:** drop the board into the head front, glass first, with the USB-C port at the bottom over the slot. Its PWR button sits behind the left button and BOOT behind the right one (seen from the front). The board holds the buttons in.
3. **Plugs:** plug the speaker into **SPK** and the battery into **BAT** (check that red goes to +).
4. **Speaker and battery:** push the speaker into the frame inside the head back, cone first, until it stops against the four little ledges. Then push the battery in behind it until it clicks past the four catches.
5. **Close the head:** line the four hooks on the head front up with the head back and press until they click. To open it, squeeze the head back at the hooks and pull.
6. **Headphones:** spread them slightly and slide them over the back of the head until the two pegs click into the holes on the sides.
7. **Cable:** thread the cable in through the hole in the backpack, through the body and up out of the neck. Plug it into the board from below.
8. **Head on body:** lower the head onto the collar so the plug drops into the neck channel and the two pegs go into the holes under the head.
9. **Backpack:** push its two pegs into the holes in the body's back until they click.

## Fitting your board

The model uses Waveshare's dimension drawing. If something doesn't line up, measure your board and change these values at the top of `cad/beat_buddy.scad`, then run `cd cad && ./build.sh`:

- `board_d` and `board_t`: the glass diameter, and the depth from the glass to the tops of the brass posts.
- `usb_depth` and `btn_depth`: how far back from the glass the centres of the USB-C port and the PWR/BOOT buttons are.
- `btn_angle`: how far either side of the top the PWR and BOOT buttons are, in degrees.

The build needs OpenSCAD with the Manifold backend (a 2024 or later development snapshot).
