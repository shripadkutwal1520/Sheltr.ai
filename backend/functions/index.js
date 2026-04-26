const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { defineSecret } = require('firebase-functions/params');
const gemini = require('./services/gemini');
const notification = require('./services/notification');

// Define the secret for the Gemini API key
const geminiApiKey = defineSecret('GEMINI_API_KEY');

admin.initializeApp();

/**
 * triggerPanic — HTTPS Callable
 * Client calls this to create a new panic incident.
 * Firestore write is server-side — userId comes from auth context, NOT client.
 */
exports.triggerPanic = functions.https.onCall(async (data, context) => {
  // 1. Auth check
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
  }

  // 2. userId from auth context — NEVER from client data (security fix)
  const userId = context.auth.uid;
  const { latitude, longitude } = data;

  // 3. Log panic trigger
  functions.logger.info(`Panic triggered by user ${userId}`);

  // 4. Server-side Firestore write
  const incidentRef = admin.firestore().collection('incidents').doc();
  await incidentRef.set({
    type: 'panic',
    status: 'active',
    severity: 'pending',
    latitude: latitude || null,
    longitude: longitude || null,
    userId: userId,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    source: 'mobile',
    notified: false,
  });

  return { incidentId: incidentRef.id, success: true };
});

/**
 * classifySeverity — Firestore onCreate
 * Fires when a new incident is created.
 * Attempts Gemini first, falls back to keyword rules, guaranteed valid severity.
 */
exports.classifySeverity = functions
  .runWith({ secrets: [geminiApiKey] })
  .firestore.document('incidents/{incidentId}')
  .onCreate(async (snap, context) => {
    functions.logger.info(`Classifying incident ${snap.id}`);

    const incident = snap.data();
    const { severity } = await gemini.classifySeverity(incident.type);

    await snap.ref.update({
      severity,
      severityClassifiedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    functions.logger.info(`Severity classified as ${severity} for incident ${snap.id}`);
  });

/**
 * sendNotification — Firestore onUpdate
 * Fires when an incident is updated.
 * Sends FCM push only when severity transitions from 'pending' to classified.
 * Guards against duplicate runs via notified flag.
 */
exports.sendNotification = functions.firestore
  .document('incidents/{incidentId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Guard: safety check
    if (!before || !after) return;

    // Guard: skip if already notified
    if (after.notified) return;

    // Guard: only trigger when severity transitions from 'pending' to classified
    if (before.severity === 'pending' && after.severity !== 'pending') {
      try {
        await notification.sendPushNotification(after.userId, {
          ...after,
          incidentId: change.after.id,
        });

        await change.after.ref.update({
          notified: true,
          notifiedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        functions.logger.info(`Notification sent for ${change.after.id}`);
      } catch (err) {
        functions.logger.error('Notification failed:', err);
      }
    }
  });
