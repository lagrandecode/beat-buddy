# Beat Buddy firmware

`beat_buddy_eyes/` draws Beat Buddy's yellow eyes on the AMOLED and animates four moods:

| Mood | What the eyes do |
| --- | --- |
| Idle | Blink at random and glance around |
| Listening | Open wide and pulse with your voice |
| Thinking | Look up and drift side to side, a little squinted |
| Speaking | Bounce in time with the reply |

Tap the screen or press BOOT to step through them, or send `i`, `l`, `t` or `s` in the Serial Monitor (115200 baud). The microphone and Gemini aren't wired in yet, so a simulated voice level drives Listening and Speaking. `setVoiceLevel()` is where the real audio level goes. It runs at about 31 frames a second.

## Flash it

1. In Arduino IDE, install **esp32 by Espressif Systems** (3.1 or later) and the libraries **GFX Library for Arduino** and **SensorLib**.
2. Open `beat_buddy_eyes/beat_buddy_eyes.ino`.
3. Tools: Board **ESP32S3 Dev Module**, PSRAM **OPI PSRAM**, Flash Size **16MB**, Partition Scheme **16M Flash (3MB APP/9.9MB FATFS)**, USB CDC On Boot **Enabled**.
4. Upload. If the port doesn't show up, hold BOOT, tap the reset/PWR button, release BOOT, and try again.

From the command line, with the Arduino CLI:

```sh
arduino-cli compile --fqbn "esp32:esp32:esp32s3:PSRAM=opi,FlashSize=16M,CDCOnBoot=cdc,PartitionScheme=app3M_fat9M_16MB" beat_buddy_eyes
arduino-cli upload  --fqbn "esp32:esp32:esp32s3:PSRAM=opi,FlashSize=16M,CDCOnBoot=cdc,PartitionScheme=app3M_fat9M_16MB" -p /dev/cu.usbmodem101 beat_buddy_eyes
```

If the eyes come out sideways once the board is in the head, change `SCREEN_ROTATION` (0–3) at the top of the sketch.

## Restore the original firmware

`backup/original_flash_16MB.bin` is a full copy of the board's flash from before Beat Buddy's firmware went on. It's kept out of git because it can contain saved Wi-Fi passwords. To put it back:

```sh
esptool --chip esp32s3 --port /dev/cu.usbmodem101 --baud 460800 write-flash 0 backup/original_flash_16MB.bin
```
