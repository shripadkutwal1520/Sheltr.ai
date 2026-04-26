const admin = require('firebase-admin');

/**
 * sendPushNotification — sends FCM push notification to a user.
 * Looks up the user's FCM token in Firestore 'users/{userId}'.
 * Gracefully handles missing users or tokens (no crashes).
 */
async function sendPushNotification(userId, incident) {
  if (!userId) {
    console.warn('sendPushNotification called with no userId — skipping');
    return;
  }

  let fcmToken;

  try {
    const userDoc = await admin.firestore().collection('users').doc(userId).get();

    if (!userDoc.exists) {
      console.warn(`User ${userId} not found in Firestore — skipping notification`);
      return;
    }

    const userData = userDoc.data();
    if (!userData) {
      console.warn(`User ${userId} document is empty — skipping notification`);
      return;
    }
    fcmToken = userData.fcmToken;
  } catch (err) {
    console.error(`Failed to fetch FCM token for user ${userId}:`, err.message);
    return;
  }

  if (!fcmToken) {
    console.warn(`No FCM token for user ${userId} — skipping notification`);
    return;
  }

  const message = {
    notification: {
      title: 'Emergency Alert',
      body: `New incident reported — severity: ${(incident.severity || 'unknown').toUpperCase()}`,
    },
    data: {
      incidentId: incident.incidentId || '',
      type: incident.type || 'panic',
      severity: incident.severity || 'unknown',
      latitude: String(incident.latitude || ''),
      longitude: String(incident.longitude || ''),
    },
    token: fcmToken,
  };

  try {
    await admin.messaging().send(message);
    console.log(`FCM notification sent to user ${userId}`);
  } catch (err) {
    console.error(`Failed to send FCM notification to user ${userId}:`, err.message);
  }
}

module.exports = { sendPushNotification };
