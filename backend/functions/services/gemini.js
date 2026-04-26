const { GoogleGenerativeAI } = require('@google/generative-ai');
const functions = require('firebase-functions');

// Keyword-based fallback rules — used when Gemini fails or returns invalid
const FALLBACK_RULES = [
  { keywords: ['smoke', 'fire', 'gas leak', 'explosion'], severity: 'critical' },
  { keywords: ['flood', 'water', 'drowning', 'tsunami'], severity: 'high' },
  { keywords: ['vibration', 'shaking', 'tremor', 'earthquake'], severity: 'medium' },
  { keywords: ['medical', 'heart', 'stroke', 'injury', 'accident'], severity: 'high' },
  { keywords: ['theft', 'burglary', 'robbery', 'attack', 'assault'], severity: 'high' },
];

const DEFAULT_SEVERITY = 'low';

const VALID_SEVERITIES = ['critical', 'high', 'medium', 'low'];

/**
 * classifySeverity — classifies incident type into a severity level.
 * Attempts Gemini first; falls back to keyword rules on error or invalid response.
 * Always returns a valid severity.
 */
async function classifySeverity(incidentType) {
  // 1. Try Gemini first
  try {
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      throw new Error('Gemini API key not configured via Secret Manager');
    }

    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });

    const prompt = `Classify this emergency incident type into one of these severity levels: critical, high, medium, low.
Incident type: "${incidentType}"
Respond with only the severity word, nothing else.`;

    const result = await model.generateContent(prompt);
    const text = result.response.text().trim().toLowerCase();

    if (VALID_SEVERITIES.includes(text)) {
      return { severity: text, method: 'gemini' };
    }

    // Gemini returned invalid response — fall through to keyword fallback
    functions.logger.warn(`Gemini returned invalid severity "${text}" for "${incidentType}" — using fallback`);
  } catch (err) {
    // Gemini failed (API error, timeout, not configured) — fall through to keyword fallback
    functions.logger.warn(`Gemini unavailable: ${err.message} — using keyword fallback`);
  }

  // 2. Keyword fallback (runs when Gemini fails or returns invalid)
  const fallback = classifyWithFallback(incidentType);
  if (fallback) {
    return { severity: fallback, method: 'fallback' };
  }

  // 3. Final guarantee — always return a valid severity
  return { severity: DEFAULT_SEVERITY, method: 'default' };
}

/**
 * classifyWithFallback — synchronous keyword-based classification.
 * Returns null if no keywords match.
 */
function classifyWithFallback(incidentType) {
  const type = (incidentType || '').toLowerCase();
  for (const rule of FALLBACK_RULES) {
    if (rule.keywords.some((kw) => type.includes(kw))) {
      return rule.severity;
    }
  }
  return null;
}

module.exports = { classifySeverity };
