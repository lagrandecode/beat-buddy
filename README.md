# Beat Buddy

A seated desk robot with a round AMOLED face, headphones and a red hoodie. The face is a Waveshare ESP32-S3-Touch-AMOLED-1.75, and a small backpack holds the USB-C cable so it charges while it sits on your desk.

![Beat Buddy](renders/beat_buddy_angle.png)

| Front | Side | Back |
| --- | --- | --- |
| ![Front](renders/beat_buddy_front.png) | ![Side](renders/beat_buddy_side.png) | ![Back](renders/beat_buddy_back.png) |

**Size:** 84 mm wide across the headphones, 114 mm tall. See [PLAN.md](PLAN.md) for the parts list and the firmware plan, and open [assembly_guide.html](assembly_guide.html) for the illustrated build guide.

## Files

| File | What's in it |
| --- | --- |
| `print/beat_buddy_WHITE_plate.3mf` | Head front, head back and the speaker holder |
| `print/beat_buddy_BLACK_plate.3mf` | Headphone band, both ear cups, backpack |
| `print/beat_buddy_RED_plate.3mf` | Body |
| `print/beat_buddy_ALL_PARTS.3mf` | All 8 parts on one plate, named by colour |
| `print/beat_buddy_*.stl` | Each part on its own, already in print orientation |
| `cad/beat_buddy.scad` | The editable OpenSCAD model. Board sizes are at the top. |

Every part is a single colour, so you don't need an AMS: print one plate per colour. If you have an AMS, open `ALL_PARTS.3mf` and give each object the colour in its name. Printing per colour plate still saves a lot of purge waste.

## Printing

| Setting | Value |
| --- | --- |
| Material | PLA (matte looks best) |
| Layer height | 0.16 mm for the head and headphones, 0.2 mm for the body |
| Walls | 3 |
| Infill | 15% gyroid |
| Supports | None. If your printer struggles with overhangs, add tree supports under the arms only. |
| Orientation | Already set in the files. Don't rotate them. |

Filament: about 23 g white, 11 g black and 62 g of hoodie colour.

The speaker holder (`beat_buddy_speaker_holder.stl`) is a separate 15-minute print that is hidden inside the head, so any colour works. It also fits a head back printed before the holder existed.

## Parts to buy

- Waveshare ESP32-S3-Touch-AMOLED-1.75 (standard version, not "-G")
- 3.7 V flat LiPo with an MX1.25 2-pin plug: 1000 mAh 103040 (10 × 30 × 40 mm), or 500 mAh 752035 (7.5 × 20 × 35 mm) for about half the run time
- The 8 Ω 2 W speaker that comes with the board (Waveshare 2030 box speaker, 20 × 30 × 5.5 mm)
- 8 × round magnets, 6 mm × 2 mm
- USB-C cable with a **90° up/down-angle** plug
- Super glue, foam tape

## Assembly

1. **Magnets:** press four magnets into the back of the head front and four into the front of the head back. Stack each pair before gluing so the poles attract, and put a drop of super glue in each pocket.
2. **Board:** drop the board into the head front, glass first, with the USB-C port facing the slot at the bottom.
3. **Speaker:** glue the speaker holder inside the head back, centred on the grille, with its curved edge against the dome. Push the speaker into it cone first until both clips snap over its back, with the wire out of the notch at one end.
4. **Battery and plugs:** plug the speaker into **SPK** and the battery into **BAT** on the board. Stick the battery flat behind the board with foam tape.
5. **Close the head:** press the head back on; the magnets hold it.
6. **Headphones:** glue the band ends into the slots on top of the ear cups, then push the cup pegs into the holes on the sides of the head.
7. **Cable:** plug the 90° USB-C plug into the board from below, with the cable pointing backwards. If it points forwards, flip the plug.
8. **Body:** lay the cable into the slot in the collar and down the back, and seat the head on the two pegs in the collar.
9. **Backpack:** run the cable through the backpack's channel and out the hole at the bottom, then push the backpack's pegs into the holes in the body's back.

## Fitting your board

The model uses Waveshare's published board size (48.96 mm across, 10.4 mm thick). When your board arrives, measure it and change these values at the top of `cad/beat_buddy.scad`, then run `cd cad && ./build.sh`:

- `board_d` and `board_t`: the board's diameter and thickness.
- `usb_depth`: how far back from the glass the centre of the USB-C port is.
- `button_angle`: where the side buttons are, in degrees up from the robot's left side.

The build needs OpenSCAD with the Manifold backend (a 2024 or later development snapshot).
