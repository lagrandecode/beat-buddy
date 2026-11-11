# Beat Buddy: build plan

A seated desk robot with a round AMOLED face, chunky headphones and a cosy hoodie. The face shows animated eyes. It blinks, looks around, reacts to touch and motion, and doubles as a desk clock and focus timer. A small backpack clips on its back and holds the USB-C cable, so it charges while it sits on the desk.

This is the same style as CreativeChance's "Neo" Deskimon, but it is our own original model and firmware. If you want Neo exactly, buy the files and software on [CreativeChance's Patreon](https://www.patreon.com/CreativeChance). They're cheap and run on the same board.

## Look

- **Size:** 84 mm wide across the headphones and 114 mm tall, seated.
- **Head:** a white rounded capsule. The screen sits in the front behind a white bezel ring, with a black screen background and glowing yellow eyes. The back of the head has a speaker grille in a hexagon pattern.
- **Headphones:** a black band over the top and round ear cups with a soft ring detail. The PWR and BOOT buttons are reached through a small slot on the side of the head.
- **Hoodie:** a thick hood rolled around the neck, with two drawstrings hanging at the front.
- **Body:** a chubby seated figure with its hands resting on its knees and big rounded feet in front. The wide base keeps it stable.
- **Backpack:** a black cable dock that slides onto the back. A channel inside holds the USB-C plug so it lines up with the board's port. It's removable for when you run on battery.
- **Colours (AMS):** white head, black headphones, backpack and screen frame, and a hoodie in a colour of your choice (red like the photo, or anything else). Yellow is only used on the screen, not in print.

## Inside

| Where | What |
| --- | --- |
| Front of the head | Waveshare ESP32-S3-Touch-AMOLED-1.75, held by the bezel ring |
| Behind the board, in the head | 3.7 V 1000 mAh LiPo battery, the same one as in the photo |
| Back of the head | 8 Ω speaker facing the grille |
| Neck | USB-C port of the board, facing down and backwards into the backpack |

## What to buy

| Item | Qty | Search for | Notes |
| --- | --- | --- | --- |
| Waveshare ESP32-S3-Touch-AMOLED-1.75 | 1 | "Waveshare ESP32-S3 1.75 AMOLED touch" | Standard version, not "-G". Get the kit with the speaker if offered. About C$35–45. |
| 8 Ω 1–2 W speaker, about 20 mm, MX1.25 plug | 1 | "8ohm 2W speaker MX1.25" | Only if the board kit doesn't include one |
| 3.7 V 1000 mAh LiPo, **MX1.25 2-pin** plug | 1 | "3.7V 1000mAh lipo 103040 MX1.25" | Flat battery, at most 10 × 30 × 40 mm. Check the red wire matches + on the board before plugging in. |
| USB-C cable, **right-angle** (90°) plug | 1 | "USB C 90 degree cable" | The backpack holds this plug so it sits neatly at the back |
| Round magnets, 6 × 2 mm | 8 | "6x2mm neodymium magnet" | Hold the head front and back together, so you can open it |
| Small rubber feet or 1 mm silicone sheet | 1 | | Non-slip bottom |

No soldering. Filament: white, black and your hoodie colour, about 120 g in total.

## Print parts

| Part | Colour |
| --- | --- |
| Head front with the bezel ring | White |
| Head back with the speaker grille | White |
| Headphone band and ear cups | Black |
| Body with the hood collar, drawstrings, arms and boots | Hoodie colour |
| Backpack cable dock | Black |

No supports needed.

## Firmware

1. **Eyes:** two rounded yellow eyes that blink at random and glance around.
2. **Moods:** sleepy (droopy eyes, like the first photo), happy, surprised when picked up, dizzy when shaken, heart eyes when you stroke the screen.
3. **Music mode:** the eyes bob to sound picked up by the microphones, which fits the headphones.
4. **Clock and focus timer:** swipe to switch. The time is set over Wi-Fi.
5. **Battery icon,** and it sleeps when the battery is low.

## Build order

1. Order the board, battery, right-angle cable and filament.
2. I make the 3D model from the published board size while it ships.
3. When the board arrives, measure it (diameter, thickness, USB-C and button positions). I adjust the fit.
4. Flash the firmware and test the eyes on the bare board.
5. Print, assemble, plug in.
