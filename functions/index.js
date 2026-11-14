/**
 * Beat Buddy — Cloud Functions.
 *
 * buddyToken: the robot calls this over Wi-Fi to get a short-lived Gemini Live token,
 * then opens its voice session with Gemini directly. The real Gemini key stays in
 * Secret Manager and never reaches the device.
 *
 * Secrets (set once with `firebase functions:secrets:set NAME`):
 *   GEMINI_API_KEY      Gemini Developer API key (AI Studio)
 *   BUDDY_DEVICE_TOKEN  shared password the robot sends in the X-Buddy-Token header
 */
const crypto = require("node:crypto");
const { onRequest } = require("firebase-functions/https");
const { defineSecret } = require("firebase-functions/params");
const logger = require("firebase-functions/logger");
const { GoogleGenAI, Modality } = require("@google/genai");

const GEMINI_API_KEY = defineSecret("GEMINI_API_KEY");
const BUDDY_DEVICE_TOKEN = defineSecret("BUDDY_DEVICE_TOKEN");

const LIVE_MODEL = "gemini-3.8-live";
const SESSION_MINUTES = 30;

const PERSONA = [
  "You are Beat Buddy, a small, friendly desk robot with big yellow eyes, headphones and a hoodie.",
  "You talk out loud through a tiny speaker, so keep answers short and conversational: one to three sentences unless asked for more.",
  "Be warm, upbeat and a little playful. Never use markdown, lists or emoji, because everything you say is spoken.",
].join(" ");

// The token locks these settings, so the robot can't change the model, persona or tools.
// New abilities for Beat Buddy go in `tools` here.
const LIVE_CONFIG = {
  responseModalities: [Modality.AUDIO],
  systemInstruction: PERSONA,
  inputAudioTranscription: {},
  outputAudioTranscription: {},
};

function sameSecret(given, expected) {
  const a = Buffer.from(given || "");
  const b = Buffer.from(expected || "");
  return a.length > 0 && a.length === b.length && crypto.timingSafeEqual(a, b);
}

exports.buddyToken = onRequest(
  { region: "us-central1", secrets: [GEMINI_API_KEY, BUDDY_DEVICE_TOKEN], maxInstances: 3, timeoutSeconds: 30 },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({ error: "POST only" });
      return;
    }
    if (!sameSecret(req.get("x-buddy-token"), BUDDY_DEVICE_TOKEN.value())) {
      res.status(401).json({ error: "unauthorized" });
      return;
    }
    try {
      const ai = new GoogleGenAI({ apiKey: GEMINI_API_KEY.value(), httpOptions: { apiVersion: "v1alpha" } });
      const now = Date.now();
      const expiresAt = new Date(now + SESSION_MINUTES * 60_000).toISOString();
      const token = await ai.authTokens.create({
        config: {
          uses: 1,
          expireTime: expiresAt,
          newSessionExpireTime: new Date(now + 60_000).toISOString(),
          liveConnectConstraints: { model: LIVE_MODEL, config: LIVE_CONFIG },
        },
      });
      res.json({ token: token.name, model: LIVE_MODEL, expiresAt });
    } catch (err) {
      logger.error("buddyToken failed", err);
      res.status(502).json({ error: "could not create a Gemini token" });
    }
  },
);
