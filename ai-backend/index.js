
const express = require("express");
const cors = require("cors");
const path = require("path");
require("dotenv").config();

const admin = require("firebase-admin");
const { GoogleGenAI } = require("@google/genai");

const app = express();

app.use(cors());
app.use(express.json({ limit: "10kb" }));

// ============================================
// Configuration
// ============================================

const PORT = process.env.PORT || 3000;

const MODEL = process.env.GEMINI_MODEL || "gemini-3.8-flash";
const FALLBACK_MODEL =
  process.env.GEMINI_FALLBACK_MODEL || "gemini-3.6-flash";

const DEFAULT_RADIUS_KM = 15;

const MEDICAL_DISCLAIMER =
  "المعلومات المقدمة للتوعية العامة فقط، ولا تُغني عن استشارة الطبيب أو التشخيص الطبي.";

const DAY_NAMES = [
  "saturday",
  "sunday",
  "monday",
  "tuesday",
  "wednesday",
  "thursday",
  "friday",
];

// ============================================
// Firebase initialization
// ============================================

if (!admin.apps.length) {
  const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH
    ? path.resolve(process.env.FIREBASE_SERVICE_ACCOUNT_PATH)
    : path.join(__dirname, "serviceAccountKey.json");

  const serviceAccount = require(serviceAccountPath);

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();

// ============================================
// Gemini initialization
// ============================================

if (!process.env.GEMINI_API_KEY) {
  throw new Error("GEMINI_API_KEY is missing from environment variables.");
}

const genAI = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
});

// ============================================
// General helpers
// ============================================

function isValidCoordinate(latitude, longitude) {
  return (
    typeof latitude === "number" &&
    typeof longitude === "number" &&
    Number.isFinite(latitude) &&
    Number.isFinite(longitude) &&
    latitude >= -90 &&
    latitude <= 90 &&
    longitude >= -180 &&
    longitude <= 180
  );
}

function toNumber(value) {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }

  if (typeof value === "string" && value.trim() !== "") {
    const parsed = Number(value);

    if (Number.isFinite(parsed)) {
      return parsed;
    }
  }

  return null;
}

function getCoordinates(data) {
  const latitude = toNumber(
    data.latitude ?? data.lat
  );

  const longitude = toNumber(
    data.longitude ?? data.lng ?? data.lon
  );

  if (!isValidCoordinate(latitude, longitude)) {
    return null;
  }

  return { latitude, longitude };
}

// ============================================
// Distance calculation
// ============================================

function calculateDistanceKm(lat1, lon1, lat2, lon2) {
  const earthRadiusKm = 6371;

  const toRadians = (degrees) => (degrees * Math.PI) / 180;

  const deltaLatitude = toRadians(lat2 - lat1);
  const deltaLongitude = toRadians(lon2 - lon1);

  const a =
    Math.sin(deltaLatitude / 2) ** 2 +
    Math.cos(toRadians(lat1)) *
      Math.cos(toRadians(lat2)) *
      Math.sin(deltaLongitude / 2) ** 2;

  const safeA = Math.min(1, Math.max(0, a));

  return (
    earthRadiusKm *
    2 *
    Math.atan2(Math.sqrt(safeA), Math.sqrt(1 - safeA))
  );
}

// ============================================
// Doctor schedule normalization
// ============================================

function normalizeSchedule(rawSchedule) {
  const schedule = {};

  if (!rawSchedule || typeof rawSchedule !== "object") {
    return schedule;
  }

  for (const day of DAY_NAMES) {
    const rawDay = rawSchedule[day];

    if (!rawDay || typeof rawDay !== "object") {
      continue;
    }

    const enabled =
      rawDay.enabled === true;

    const startTime =
      typeof rawDay.startTime === "string"
        ? rawDay.startTime.trim()
        : "";

    const endTime =
      typeof rawDay.endTime === "string"
        ? rawDay.endTime.trim()
        : "";

    schedule[day] = {
      enabled,
      startTime,
      endTime,
    };
  }

  return schedule;
}

function isValidTime(value) {
  if (typeof value !== "string") {
    return false;
  }

  const match = value.match(/^([01]\d|2[0-3]):([0-5]\d)$/);

  return Boolean(match);
}

function formatDoctorSchedule(rawSchedule) {
  const schedule = normalizeSchedule(rawSchedule);
  const formattedSchedule = {};

  for (const day of DAY_NAMES) {
    const daySchedule = schedule[day];

    // Do not expose disabled days.
    if (!daySchedule || !daySchedule.enabled) {
      continue;
    }

    // Do not invent or guess missing working hours.
    if (
      !isValidTime(daySchedule.startTime) ||
      !isValidTime(daySchedule.endTime)
    ) {
      continue;
    }

    formattedSchedule[day] = {
      enabled: true,
      workingHours: `${daySchedule.startTime} - ${daySchedule.endTime}`,
    };
  }

  return formattedSchedule;
}

// ============================================
// Doctor normalization
// ============================================

function normalizeDoctor(doc) {
  const data = doc.data() || {};
  const coordinates = getCoordinates(data);

  if (!coordinates) {
    return null;
  }

  const name =
    typeof data.name === "string"
      ? data.name.trim()
      : "";

  const specialty =
    typeof data.specialty === "string"
      ? data.specialty.trim()
      : typeof data.categoryName === "string"
        ? data.categoryName.trim()
        : "";

  const address =
    typeof data.address === "string"
      ? data.address.trim()
      : "";

  return {
    id: doc.id,
    name,
    specialty,
    address,
    latitude: coordinates.latitude,
    longitude: coordinates.longitude,
    weeklySchedule: formatDoctorSchedule(data.schedule),
  };
}

// ============================================
// Nearby doctor search
// ============================================

async function getNearbyDoctors(
  latitude,
  longitude,
  radiusKm = DEFAULT_RADIUS_KM
) {
  if (!isValidCoordinate(latitude, longitude)) {
    return [];
  }

  const snapshot = await db.collection("doctors").get();

  const doctors = [];

  for (const doc of snapshot.docs) {
    const doctor = normalizeDoctor(doc);

    if (!doctor) {
      continue;
    }

    const distanceKm = calculateDistanceKm(
      latitude,
      longitude,
      doctor.latitude,
      doctor.longitude
    );

    if (distanceKm <= radiusKm) {
      doctors.push({
        ...doctor,
        distanceKm: Number(distanceKm.toFixed(2)),
      });
    }
  }

  doctors.sort((a, b) => a.distanceKm - b.distanceKm);

  return doctors;
}

// ============================================
// Emergency keyword screening
// ============================================

// This is a basic keyword screen, not a clinical triage system.
// It can miss emergencies and can trigger on some negated phrases.

function detectEmergency(message) {
  const text = String(message || "")
    .toLowerCase()
    .replace(/[إأآ]/g, "ا")
    .replace(/ة/g, "ه")
    .replace(/\s+/g, " ")
    .trim();

  const patterns = [
    // Severe breathing problems
    /صعوبه شديده في التنفس/,
    /مش قادر اتنفس/,
    /مش قادره اتنفس/,
    /اختناق/,
    /severe difficulty breathing/,
    /cannot breathe/,
    /can't breathe/,
    /unable to breathe/,
    /choking/,

    // Severe chest pain
    /الم شديد في الصدر/,
    /وجع شديد في الصدر/,
    /ضغط شديد على الصدر/,
    /severe chest pain/,
    /crushing chest pain/,

    // Stroke warning signs
    /اعوجاج الفم/,
    /ضعف مفاجئ في جانب/,
    /تنميل مفاجئ في جانب/,
    /صعوبه مفاجئه في الكلام/,
    /علامات جلطه/,
    /face drooping/,
    /sudden weakness on one side/,
    /sudden difficulty speaking/,
    /stroke symptoms/,

    // Unconsciousness
    /فاقد الوعي/,
    /فقدان الوعي/,
    /مش بيفوق/,
    /مش بتفوق/,
    /unconscious/,
    /not waking up/,
    /unresponsive/,

    // Severe bleeding
    /نزيف شديد/,
    /نزيف مش بيقف/,
    /نزيف لا يتوقف/,
    /severe bleeding/,
    /bleeding that won't stop/,

    // Prolonged seizure
    /تشنجات مستمره/,
    /تشنج مستمر/,
    /seizure lasting/,
    /prolonged seizure/,

    // Poisoning and overdose
    /جرعه زائده/,
    /اخدت جرعه كبيره/,
    /تسمم/,
    /ابتلعت ماده سامه/,
    /overdose/,
    /poisoning/,
    /swallowed poison/,

    // Severe allergic reaction
    /حساسيه شديده مع صعوبه التنفس/,
    /تورم اللسان مع صعوبه التنفس/,
    /تورم الحلق مع صعوبه التنفس/,
    /anaphylaxis/,
    /severe allergic reaction/,
  ];

  return patterns.some((pattern) => pattern.test(text));
}

function buildEmergencyReply(language) {
  if (language === "en") {
    return [
      "## ⚠️ Seek emergency medical help now",
      "",
      "The symptoms you described may indicate a medical emergency.",
      "",
      "- Call your local emergency number or go to the nearest emergency department immediately.",
      "- Do not drive yourself if you feel seriously unwell.",
      "- If possible, ask someone nearby to stay with you while help is arranged.",
      "",
      "Do not delay emergency care to continue chatting with this assistant.",
    ].join("\n");
  }

  return [
    "## ⚠️ اطلب المساعدة الطبية الطارئة فورًا",
    "",
    "الأعراض اللي وصفتها ممكن تشير إلى حالة طبية طارئة.",
    "",
    "- اتصل برقم الإسعاف المحلي أو توجّه لأقرب قسم طوارئ فورًا.",
    "- لو حالتك شديدة، ما تسوقش بنفسك.",
    "- لو أمكن، خلي شخص قريب منك يفضل معاك لحد ما المساعدة توصل.",
    "",
    "**ما تأخرش طلب المساعدة الطبية علشان تكمل المحادثة مع المساعد.**",
  ].join("\n");
}

// ============================================
// Chat history
// ============================================

function normalizeHistory(history) {
  if (!Array.isArray(history)) {
    return [];
  }

  return history
    .filter(
      (item) =>
        item &&
        typeof item.content === "string" &&
        ["user", "assistant", "model"].includes(item.role)
    )
    .slice(-8)
    .map((item) => ({
      role: item.role === "assistant" ? "model" : item.role,
      content: item.content.trim().slice(0, 1000),
    }))
    .filter((item) => item.content.length > 0);
}

// ============================================
// Response formatting
// ============================================

function normalizeAIResponse(response) {
  if (typeof response !== "string") {
    return "";
  }

  return response
    .replace(/\r\n/g, "\n")
    .replace(/\r/g, "\n")
    // Remove trailing spaces while preserving line breaks.
    .replace(/[ \t]+\n/g, "\n")
    // Limit excessive blank lines to a single blank line.
    .replace(/\n{3,}/g, "\n\n")
    .trim();
}

function removeRatingMentions(response) {
  const forbiddenPatterns = [
    /تقييم(?:ه|ها|ات)?/i,
    /عدد النجوم/i,
    /نجوم/i,
    /reviews?/i,
    /ratings?/i,
    /out of 5/i,
  ];

  return response
    .split("\n")
    .filter(
      (line) =>
        !forbiddenPatterns.some((pattern) => pattern.test(line))
    )
    .join("\n")
    .replace(/\n{3,}/g, "\n\n")
    .trim();
}

// ============================================
// Language detection
// ============================================

function detectLanguage(message) {
  const arabicCharacters = (String(message).match(/[\u0600-\u06FF]/g) || [])
    .length;

  return arabicCharacters > 0 ? "ar" : "en";
}

// ============================================
// Medical prompt
// ============================================

function buildMedicalPrompt(message, doctors, history) {
  const language = detectLanguage(message);

  const doctorDirectory = doctors.map((doctor) => ({
    id: doctor.id,
    name: doctor.name,
    specialty: doctor.specialty,
    address: doctor.address,
    distanceKm: doctor.distanceKm,
    weeklySchedule: doctor.weeklySchedule,
  }));

  const conversationHistory = history.map((item) => ({
    role: item.role,
    content: item.content,
  }));

  return `
You are a careful medical information assistant inside a healthcare application.

LANGUAGE:
- Reply in the same language as the user's latest message.
- If the user writes Arabic, use natural, clear Arabic suitable for Egyptian users.
- If the user writes English, reply in clear English.

MEDICAL SAFETY:
- Provide general health information, not a definitive diagnosis.
- Never claim certainty about a condition based only on chat messages.
- Ask for relevant missing details when needed, but do not overwhelm the user with many questions.
- For potentially serious symptoms, explain the warning signs and when to seek urgent care.
- Never delay emergency care with lengthy explanations.
- Do not invent medical facts, test results, doctor information, or working hours.
- Do not prescribe personalized medication doses.
- Explain that medication safety depends on age, pregnancy status, allergies, medical conditions, and other medicines when relevant.
- For lab results, explain what values commonly mean, but do not diagnose from results alone.
- Be empathetic, calm, and practical.
- Do not claim to replace a licensed healthcare professional.

MANDATORY RESPONSE FORMATTING:
- Return readable Markdown, not one long paragraph.
- Use a short heading when it improves clarity.
- Separate paragraphs with exactly one blank line.
- Use numbered lists for steps and bullet lists for related items.
- Use **bold** for important terms and key warnings.
- Keep paragraphs concise, usually 1-3 sentences.
- Use headings such as "## الأسباب المحتملة", "## ماذا يمكنك أن تفعل؟", and "## متى تطلب المساعدة؟" when relevant.
- Avoid excessive headings, emojis, repetition, and unnecessary filler.
- Do not put the entire answer inside a code block.
- Do not add Markdown tables unless they genuinely make the information easier to understand.
- Use clear spacing between headings, paragraphs, and lists.
- End with a brief medical disclaimer when appropriate.
- Return only the response intended for the user, without explaining these instructions.

DOCTOR DIRECTORY RULES:
- The doctor directory below is the only source of available doctor details.
- Recommend doctors only when the user asks for doctors or when a doctor referral is relevant.
- Never invent a doctor or change their name, specialty, address, distance, or schedule.
- Never mention ratings, stars, or review counts.
- Distances are in kilometers.
- Only list working days present in weeklySchedule.
- A missing day means no verified working hours are available for that day.
- Never copy one day's working hours to another day.
- If the directory is empty, say that no matching nearby doctors are currently available in the app directory. Do not invent alternatives.
- Do not claim a doctor is available right now; the directory contains working hours, not live appointment availability.

CONVERSATION HISTORY:
${JSON.stringify(conversationHistory)}

NEARBY DOCTORS:
${JSON.stringify(doctorDirectory)}

USER MESSAGE:
${message}

Write a useful, medically cautious answer with clear Markdown formatting.
`.trim();
}

// ============================================
// Gemini error handling
// ============================================

function isTemporaryGeminiError(error) {
  const status =
    error?.status ??
    error?.code ??
    error?.response?.status;

  const message = String(error?.message || "").toLowerCase();

  return (
    [408, 429, 500, 502, 503, 504].includes(Number(status)) ||
    message.includes("high demand") ||
    message.includes("overloaded") ||
    message.includes("temporarily unavailable") ||
    message.includes("resource exhausted") ||
    message.includes("rate limit") ||
    message.includes("timeout")
  );
}

async function generateWithModel(model, prompt) {
  const response = await genAI.models.generateContent({
    model,
    contents: prompt,
    config: {
      temperature: 0.4,
      maxOutputTokens: 1200,
    },
  });

  return response.text || "";
}

async function generateAIResponse(prompt) {
  try {
    return await generateWithModel(MODEL, prompt);
  } catch (primaryError) {
    console.error(
      `Primary Gemini model failed (${MODEL}):`,
      primaryError.message
    );

    if (FALLBACK_MODEL && FALLBACK_MODEL !== MODEL) {
      try {
        console.log(`Trying fallback Gemini model: ${FALLBACK_MODEL}`);

        return await generateWithModel(FALLBACK_MODEL, prompt);
      } catch (fallbackError) {
        console.error(
          `Fallback Gemini model failed (${FALLBACK_MODEL}):`,
          fallbackError.message
        );

        throw fallbackError;
      }
    }

    throw primaryError;
  }
}

// ============================================
// Health check
// ============================================

app.get("/health", (req, res) => {
  res.status(200).json({
    status: "ok",
    service: "medical-assistant",
  });
});

// ============================================
// Assistant chat endpoint
// ============================================

app.post("/api/assistant/chat", async (req, res) => {
  try {
    // 1. Verify Firebase authentication.
    const authorization = req.headers.authorization || "";
    const tokenMatch = authorization.match(/^Bearer\s+(.+)$/i);

    if (!tokenMatch) {
      return res.status(401).json({
        error: "Unauthorized",
        message: "A valid Firebase ID token is required.",
      });
    }

    let decodedToken;

    try {
      decodedToken = await admin.auth().verifyIdToken(tokenMatch[1]);
    } catch (authError) {
      return res.status(401).json({
        error: "Unauthorized",
        message: "The Firebase ID token is invalid or expired.",
      });
    }

    // 2. Validate the message.
    const message =
      typeof req.body?.message === "string"
        ? req.body.message.trim()
        : "";

    if (!message || message.length > 1000) {
      return res.status(400).json({
        error: "Invalid message",
        message: "Message must contain between 1 and 1000 characters.",
      });
    }

    // 3. Emergency keyword screen.
    // This is a basic precaution, not a validated clinical system.
    if (detectEmergency(message)) {
      return res.status(200).json({
        reply: buildEmergencyReply(detectLanguage(message)),
        triage: {
          level: "emergency",
          disclaimer: MEDICAL_DISCLAIMER,
        },
        doctors: [],
        radiusInKm: DEFAULT_RADIUS_KM,
      });
    }

    // 4. Optional location.
    const rawLocation = req.body?.location;
    const latitude = toNumber(rawLocation?.latitude);
    const longitude = toNumber(rawLocation?.longitude);

    const hasValidLocation = isValidCoordinate(latitude, longitude);

    // 5. Normalize chat history.
    const history = normalizeHistory(req.body?.history);

    // 6. Load nearby doctors when valid coordinates are provided.
    let doctors = [];

    if (hasValidLocation) {
      try {
        doctors = await getNearbyDoctors(
          latitude,
          longitude,
          DEFAULT_RADIUS_KM
        );
      } catch (doctorError) {
        console.error(
          "Nearby doctor lookup failed:",
          doctorError.message
        );

        // Continue with general medical information if Firestore fails.
        doctors = [];
      }
    }

    // 7. Generate a formatted medical answer.
    const prompt = buildMedicalPrompt(message, doctors, history);

    let rawReply;

    try {
      rawReply = await generateAIResponse(prompt);
    } catch (aiError) {
      console.error("Gemini generation failed:", aiError.message);

      if (isTemporaryGeminiError(aiError)) {
        return res.status(503).json({
          error: "AI temporarily unavailable",
          message:
            "The medical assistant is temporarily busy. Please try again shortly.",
        });
      }

      return res.status(502).json({
        error: "AI service error",
        message: "The medical assistant could not generate a response.",
      });
    }

    // 8. Preserve Markdown while cleaning unnecessary whitespace.
    let reply = normalizeAIResponse(rawReply);

    // Remove explicit ratings if the model mentions them.
    reply = removeRatingMentions(reply);

    if (!reply) {
      reply =
        detectLanguage(message) === "ar"
          ? "عذرًا، لم أتمكن من إعداد رد مناسب الآن. حاول مرة أخرى."
          : "Sorry, I could not prepare a suitable response right now. Please try again.";
    }

    // 9. Return the response.
    return res.status(200).json({
      reply,
      triage: {
        level: "routine",
        disclaimer: MEDICAL_DISCLAIMER,
      },
      doctors,
      radiusInKm: DEFAULT_RADIUS_KM,
    });
  } catch (error) {
    console.error("Assistant endpoint error:", error);

    return res.status(500).json({
      error: "Internal server error",
      message: "An unexpected error occurred.",
    });
  }
});

// ============================================
// Start server
// ============================================

app.listen(PORT, () => {
  console.log(`Medical assistant backend running on port ${PORT}`);
  console.log(`Primary Gemini model: ${MODEL}`);
  console.log(`Fallback Gemini model: ${FALLBACK_MODEL}`);
});
