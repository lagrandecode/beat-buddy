# Beat Buddy: where we are

Last updated: Nov 14, 2026.

## Done

**Hardware (printed and assembled, working)**
- 3D model and print files in `cad/` and `print/`.
- PWR/BOOT push-buttons got grip ribs so they don't fall out when the robot is turned over (`btn_grip` in `cad/beat_buddy.scad`). Pushed to GitHub (`lagrandecode/beat-buddy`), commit dated Nov 13.

**Firmware: animated eyes (flashed and running on the board)**
- `firmware/beat_buddy_eyes/beat_buddy_eyes.ino`, about 31 fps.
- Four moods: idle (blinks, glances), listening (wide, pulses), thinking (looks up, drifts), speaking (bounces).
- Tap the screen or press BOOT to cycle moods; Serial `i` / `l` / `t` / `s` jumps to one.
- A simulated voice level drives listening and speaking until the mic is wired in; `setVoiceLevel()` is the hook.
- Full backup of the board's original flash: `firmware/backup/original_flash_16MB.bin` (git-ignored). Restore steps in `firmware/README.md`.
- Board: Waveshare ESP32-S3-Touch-AMOLED-1.75 on `/dev/cu.usbmodem101`. Libraries: GFX Library for Arduino 1.6.9, SensorLib 0.5.2, esp32 core 3.3.11.

**Cloud: Gemini through Firebase (deployed and tested)**
- Firebase project `beat-buddy-ai` ("Beat Buddy"), billed to the TD card billing account.
- Secret Manager: `GEMINI_API_KEY` (AI Studio key on the Beat Buddy project) and `BUDDY_DEVICE_TOKEN` (the robot's password; local copy in `device_token.local`, git-ignored).
- Cloud Function `buddyToken`: `https://us-central1-beat-buddy-ai.cloudfunctions.net/buddyToken`. POST with header `X-Buddy-Token`. Returns a 30-minute single-use ephemeral token for `gemini-3.8-live`, with Beat Buddy's persona locked in. Code in `functions/index.js`.
- Tested: without the password it returns 401; with it, a Gemini Live session spoke back "Hey there, I'm Beat Buddy and it's awesome to meet you!"
- Build-image cleanup policy set to 1 day.

## Not committed yet

`firmware/`, `functions/`, `firebase.json`, `.firebaserc`, `.gitignore`, this file.

## Next

1. Firmware: Wi-Fi setup (first boot makes a hotspot; enter Wi-Fi name, password and the device token from a phone; saved to the board's settings storage).
2. Firmware: hold BOOT to talk. Call `buddyToken`, open the Gemini Live WebSocket, stream the ES7210 mics as 16 kHz PCM, play the 24 kHz reply through the ES8311 speaker, and switch the eyes between listening, thinking and speaking from the real audio levels.
3. Add tools (new abilities) to `LIVE_CONFIG` in `functions/index.js`, then redeploy with `firebase deploy --only functions`.
4. Later from PLAN.md: wake word, clock, focus timer, music mode, battery icon.

## Decisions

- Gemini, not Meta Muse: the user prefers Beat Buddy's own yellow eyes, and Gemini allows unlimited custom tools with no subscription.
- The Gemini key never goes on the board; the board only ever gets short-lived tokens.
