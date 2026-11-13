# Beat Buddy: build plan

A seated desk robot with a round AMOLED face, chunky headphones and a cosy hoodie. The face shows animated eyes. It blinks, looks around, reacts to touch and motion, and doubles as a desk clock and focus timer. A USB-C cable comes in through the backpack, so it charges while it sits on the desk.

This is the same style as CreativeChance's "Neo" Deskimon, but it is our own original model and firmware. If you want Neo exactly, buy the files and software on [CreativeChance's Patreon](https://www.patreon.com/CreativeChance). They're cheap and run on the same board.

## Look

- **Size:** 84 mm wide across the headphones and 114 mm tall, seated.
- **Head:** a white rounded capsule. The screen sits in the front behind a white bezel ring, with a black screen background and glowing yellow eyes. The back of the head has a speaker grille in a hexagon pattern. Two small white buttons on the top edge work the board's PWR and BOOT buttons.
- **Headphones:** one black piece, a band around the back of the head with round ear cups that clip onto the sides.
- **Hoodie:** a thick hood rolled around the neck, with two drawstrings hanging at the front.
- **Body:** a chubby seated figure with its hands resting on its knees and big rounded feet in front. The wide base keeps it stable.
- **Backpack:** a black backpack with the cable coming out of it.
- **Colours:** white head, black headphones and backpack, and a hoodie in a colour of your choice (red like the photo, or anything else). Yellow is only used on the screen, not in print.

## Inside

| Where | What | Held by |
| --- | --- | --- |
| Front of the head | Waveshare ESP32-S3-Touch-AMOLED-1.75 | The bezel lip in front, three pads on the head back pressing on its brass posts |
| Top edge of the head | Two printed push-buttons over PWR and BOOT | Their collars, trapped between the board and the head front |
| Back of the head | 752035 LiPo, then the speaker behind it, facing the grille | A four-column frame: ledges stop the speaker, catches hold the battery |
| Head seam | Four snap hooks on the head front | Click into a groove inside the head back |
| Neck and body | Straight USB-C cable, plugged in from below | A channel down the body that bends back to the backpack |

## What to buy

| Item | Qty | Search for | Notes |
| --- | --- | --- | --- |
| Waveshare ESP32-S3-Touch-AMOLED-1.75 | 1 | "Waveshare ESP32-S3 1.75 AMOLED touch" | Standard version, not "-G". About C$35–45. |
| 8 Ω 2 W speaker | — | | Comes with the board (Waveshare 2030 box speaker, 20 × 30 × 5.5 mm) |
| 3.7 V 500 mAh LiPo, **MX1.25 2-pin** plug | 1 | "3.7V 500mAh lipo 752035 MX1.25" | 7.5 × 20 × 35 mm. Check the red wire matches + on the board before plugging in. |
| USB-C cable, straight plug | 1 | | Stiff part of the plug at most 13 × 8.5 × 24 mm. Most cables fit. |

No soldering, glue, tape, screws or magnets. Filament: white, black and your hoodie colour, about 75 g in total.

## Print parts

| Part | Colour | Supports |
| --- | --- | --- |
| Head front with the bezel and snap hooks | White | None |
| Head back with the grille and the speaker and battery frame | White | Tree (auto), inside the dome only |
| Push-buttons ×2 | White | None |
| Headphones | Black | None |
| Body with the hood collar, drawstrings, arms, boots and cable channel | Hoodie colour | None |
| Backpack | Black | None |

## Firmware

1. **Eyes:** two rounded yellow eyes that blink at random and glance around.
2. **Moods:** sleepy (droopy eyes, like the first photo), happy, surprised when picked up, dizzy when shaken, heart eyes when you stroke the screen.
3. **Music mode:** the eyes bob to sound picked up by the microphones, which fits the headphones.
4. **Clock and focus timer:** swipe to switch. The time is set over Wi-Fi.
5. **Battery icon,** and it sleeps when the battery is low.

## Build order

1. Print the parts (about 10 hours).
2. Flash the firmware and test the eyes on the bare board.
3. Assemble: buttons and board into the head front, speaker and battery into the head back, snap the head shut, add the headphones, run the cable through the body, fit the backpack.
