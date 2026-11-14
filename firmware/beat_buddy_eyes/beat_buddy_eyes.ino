// Beat Buddy — animated eyes for the Waveshare ESP32-S3-Touch-AMOLED-1.75.
//
// Four moods, blended smoothly into each other:
//   IDLE       blinks at random and glances around
//   LISTENING  eyes open wide and pulse with your voice
//   THINKING   eyes look up and drift side to side, a little squinted
//   SPEAKING   eyes bounce in time with the reply
//
// Tap the screen or press BOOT to step through the moods, or send i / l / t / s
// over Serial (115200) to jump to one. Until the microphone and Gemini are wired
// in, a simulated voice level drives LISTENING and SPEAKING; setVoiceLevel() is
// where the real audio level will go.
//
// Libraries: "GFX Library for Arduino" and "SensorLib" (Library Manager).
// Board: ESP32S3 Dev Module, PSRAM: OPI PSRAM, Flash Size: 16MB, USB CDC On Boot: Enabled.

#include <Arduino_GFX_Library.h>
#include <TouchDrv.hpp>
#include <Wire.h>

// ---------------------------------------------------------------- board pins
#define LCD_SDIO0 4
#define LCD_SDIO1 5
#define LCD_SDIO2 6
#define LCD_SDIO3 7
#define LCD_SCLK 38
#define LCD_CS 12
#define LCD_RESET 39
#define I2C_SDA 15
#define I2C_SCL 14
#define TP_INT 11
#define TP_RST 40
#define BOOT_BTN 0

#define SCREEN 466
#define SCREEN_ROTATION 0  // change (0–3) if the eyes come out sideways in the head
#define BRIGHTNESS 220

// Only the band the eyes can move through is redrawn each frame; the rest stays black.
// Widen this if you make the eyes bigger or let them look further.
#define CANVAS_X 50
#define CANVAS_Y 100
#define CANVAS_W 366
#define CANVAS_H 240

// ---------------------------------------------------------------- look
const uint16_t EYE_COLOUR = 0xFE87;  // #FFD23A
const uint16_t SHINE_COLOUR = 0xFFFF;
const uint16_t BG_COLOUR = 0x0000;
const float EYE_W = 84, EYE_H = 150;  // matches the eyes in the 3D model
const float EYE_GAP = 82;             // centre of each eye from the middle
const float EYE_Y = -10;              // eyes sit slightly above the middle

// ---------------------------------------------------------------- display + touch
Arduino_DataBus *bus = new Arduino_ESP32QSPI(LCD_CS, LCD_SCLK, LCD_SDIO0, LCD_SDIO1, LCD_SDIO2, LCD_SDIO3);
Arduino_CO5300 *panel = new Arduino_CO5300(bus, LCD_RESET, SCREEN_ROTATION, SCREEN, SCREEN, 6, 0, 0, 0);
Arduino_Canvas *gfx = new Arduino_Canvas(CANVAS_W, CANVAS_H, panel, CANVAS_X, CANVAS_Y);

TouchDrvCST92xx touch;
bool touchOk = false;

// ---------------------------------------------------------------- state
enum Mood { IDLE, LISTENING, THINKING, SPEAKING, MOOD_COUNT };
const char *MOOD_NAMES[] = {"idle", "listening", "thinking", "speaking"};
Mood mood = IDLE;
uint32_t moodSince = 0;

// smoothed values the drawing uses
struct Eyes {
  float lookX = 0, lookY = 0;  // where both eyes point, px
  float scaleW = 1, scaleH = 1;
  float bounce = 0;            // extra vertical offset, px
} eyes;

// blink timeline
uint32_t nextBlinkAt = 0, blinkStart = 0;
bool blinking = false, doubleBlink = false;
const uint32_t BLINK_MS = 150;

// idle glances
uint32_t nextGlanceAt = 0;
float glanceX = 0, glanceY = 0;

// voice level 0..1; real audio will overwrite this, the demo fills it in when it isn't set
float voiceLevel = 0;
uint32_t voiceLevelAt = 0;
void setVoiceLevel(float level) {
  voiceLevel = constrain(level, 0.0f, 1.0f);
  voiceLevelAt = millis();
}

void setMood(Mood m) {
  mood = m;
  moodSince = millis();
  Serial.printf("mood: %s\n", MOOD_NAMES[m]);
}

float approach(float v, float target, float rate, float dt) { return v + (target - v) * (1 - expf(-rate * dt)); }

// cheap smooth noise in -1..1, for the demo voice level and small idle wobbles
float smoothNoise(float t, float seed) {
  return 0.5f * sinf(t * 1.7f + seed) + 0.3f * sinf(t * 3.1f + seed * 2.3f) + 0.2f * sinf(t * 5.3f + seed * 0.7f);
}

// stand-in voice level until the microphone and speaker are wired in
float demoVoiceLevel(float t) {
  if (mood == LISTENING) return 0.35f + 0.35f * smoothNoise(t * 2.2f, 1.3f) + 0.25f * fabsf(sinf(t * 7));
  if (mood == SPEAKING) {
    float syllable = fmaxf(0, sinf(t * 11));                 // ~3.5 syllables a second
    float phrase = smoothNoise(t * 0.6f, 4.1f) > -0.35f ? 1 : 0;  // short pauses between phrases
    return syllable * phrase * (0.6f + 0.4f * smoothNoise(t * 3, 2.2f));
  }
  return 0;
}

void scheduleBlink(uint32_t now) {
  float wait = mood == THINKING ? random(4000, 8000) : random(2200, 6000);
  nextBlinkAt = now + (uint32_t)wait;
}

// 1 = fully open, near 0 = closed
float blinkOpenness(uint32_t now) {
  if (!blinking && now >= nextBlinkAt) {
    blinking = true;
    blinkStart = now;
    doubleBlink = random(100) < 15;
  }
  if (!blinking) return 1;
  uint32_t total = doubleBlink ? BLINK_MS * 2 + 80 : BLINK_MS;
  uint32_t e = now - blinkStart;
  if (e >= total) {
    blinking = false;
    scheduleBlink(now);
    return 1;
  }
  if (doubleBlink && e >= BLINK_MS + 80) e -= BLINK_MS + 80;
  else if (doubleBlink && e >= BLINK_MS) return 1;
  float p = (float)e / BLINK_MS;                 // 0..1
  float closed = p < 0.5f ? p * 2 : (1 - p) * 2;  // 0 → 1 → 0
  return 1 - 0.93f * closed;
}

void updateEyes(uint32_t now, float dt) {
  float t = now / 1000.0f;
  float level = (now - voiceLevelAt < 300) ? voiceLevel : demoVoiceLevel(t);

  float tx = 0, ty = 0, tw = 1, th = 1, tb = 0, rate = 9;
  switch (mood) {
    case IDLE:
      if (now >= nextGlanceAt) {
        bool centre = random(100) < 35;
        glanceX = centre ? 0 : random(-45, 46);
        glanceY = centre ? 0 : random(-25, 21);
        nextGlanceAt = now + random(1500, 4200);
      }
      tx = glanceX + 2 * smoothNoise(t, 0.4f);
      ty = glanceY + 2 * smoothNoise(t, 2.9f);
      rate = 7;
      break;
    case LISTENING:
      tx = 0;
      ty = -6;
      tw = 1.1f + 0.04f * level;
      th = 1.1f + 0.14f * level;
      rate = 14;
      break;
    case THINKING:
      tx = 42 * sinf(t * 1.1f);
      ty = -42 + 4 * sinf(t * 2.3f);
      tw = 0.95f;
      th = 0.78f;
      rate = 5;
      break;
    case SPEAKING:
      tx = 4 * smoothNoise(t * 0.8f, 5.0f);
      ty = 0;
      tw = 1 + 0.05f * level;
      th = 1 - 0.1f * level;
      tb = -14 * level;
      rate = 18;
      break;
    default:
      break;
  }
  eyes.lookX = approach(eyes.lookX, tx, rate, dt);
  eyes.lookY = approach(eyes.lookY, ty, rate, dt);
  eyes.scaleW = approach(eyes.scaleW, tw, rate, dt);
  eyes.scaleH = approach(eyes.scaleH, th, rate, dt);
  eyes.bounce = approach(eyes.bounce, tb, 22, dt);
}

// cx, cy are screen coordinates; the canvas starts at CANVAS_X, CANVAS_Y
void drawEye(float cx, float cy, float w, float h) {
  cx -= CANVAS_X;
  cy -= CANVAS_Y;
  int16_t ew = max(4, (int)lroundf(w)), eh = max(4, (int)lroundf(h));
  int16_t x = (int16_t)lroundf(cx - ew / 2.0f), y = (int16_t)lroundf(cy - eh / 2.0f);
  gfx->fillRoundRect(x, y, ew, eh, min(ew, eh) / 2, EYE_COLOUR);
  if (eh > 50) {  // small shine near the top, hidden while the eye is nearly shut
    gfx->fillCircle((int16_t)lroundf(cx - ew * 0.2f), (int16_t)lroundf(cy - eh * 0.27f), (int16_t)lroundf(ew * 0.11f), SHINE_COLOUR);
  }
}

void drawFrame(uint32_t now) {
  float open = blinkOpenness(now);
  float w = EYE_W * eyes.scaleW;
  float h = EYE_H * eyes.scaleH * open;
  float cy = SCREEN / 2.0f + EYE_Y + eyes.lookY + eyes.bounce;
  gfx->fillScreen(BG_COLOUR);
  for (int side = -1; side <= 1; side += 2) {
    // the eye on the side it looks towards gets a touch bigger, so glances read as turning
    float turn = 1 + 0.0018f * eyes.lookX * side;
    drawEye(SCREEN / 2.0f + side * EYE_GAP + eyes.lookX, cy, w * turn, h * turn);
  }
  gfx->flush();
}

// ---------------------------------------------------------------- input
bool bootWasDown = false, touchWasDown = false;
uint32_t bootChangedAt = 0;

void nextMood() { setMood((Mood)((mood + 1) % MOOD_COUNT)); }

void readInputs(uint32_t now) {
  bool bootDown = digitalRead(BOOT_BTN) == LOW;
  if (bootDown != bootWasDown && now - bootChangedAt > 30) {
    bootChangedAt = now;
    bootWasDown = bootDown;
    if (bootDown) nextMood();
  }
  if (touchOk) {
    bool touchDown = touch.getTouchPoints().hasPoints();
    if (touchDown && !touchWasDown) nextMood();
    touchWasDown = touchDown;
  }
  while (Serial.available()) {
    switch (Serial.read()) {
      case 'i': setMood(IDLE); break;
      case 'l': setMood(LISTENING); break;
      case 't': setMood(THINKING); break;
      case 's': setMood(SPEAKING); break;
    }
  }
}

// ---------------------------------------------------------------- main
void setup() {
  Serial.begin(115200);
  delay(300);
  Serial.println("Beat Buddy eyes");

  pinMode(BOOT_BTN, INPUT_PULLUP);
  randomSeed(esp_random());

  if (!gfx->begin()) {
    Serial.println("display failed to start (is PSRAM enabled in Tools > PSRAM?)");
    while (true) delay(1000);
  }
  panel->setBrightness(BRIGHTNESS);
  panel->fillScreen(BG_COLOUR);  // whole panel once; afterwards only the canvas is redrawn

  // touch is optional: BOOT and Serial still work without it
  pinMode(TP_RST, OUTPUT);
  digitalWrite(TP_RST, LOW);
  delay(30);
  digitalWrite(TP_RST, HIGH);
  delay(80);
  Wire.begin(I2C_SDA, I2C_SCL);
  touch.setPins(TP_RST, TP_INT);
  touchOk = touch.begin(Wire, 0x5A, I2C_SDA, I2C_SCL);
  Serial.println(touchOk ? "touch ready" : "touch not found, use BOOT or Serial");

  uint32_t now = millis();
  scheduleBlink(now);
  nextGlanceAt = now + 1200;
  setMood(IDLE);
}

void loop() {
  static uint32_t last = millis(), frames = 0, fpsAt = millis();
  uint32_t now = millis();
  float dt = (now - last) / 1000.0f;
  last = now;

  readInputs(now);
  updateEyes(now, dt);
  drawFrame(now);

  frames++;
  if (now - fpsAt >= 5000) {
    Serial.printf("%.1f fps\n", frames * 1000.0f / (now - fpsAt));
    frames = 0;
    fpsAt = now;
  }
}
