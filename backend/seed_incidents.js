const admin = require('firebase-admin');

process.env.FIREBASE_AUTH_EMULATOR_HOST = 'localhost:9099';
process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';

// Only initialize if not already initialized
if (!admin.apps.length) {
  admin.initializeApp({
    projectId: 'demo-no-project'
  });
}

async function seedIncidents() {
  const db = admin.firestore();

  const incidents = [
    {
      type: 'Fire Outbreak',
      severity: 'critical',
      status: 'active',
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      latitude: 20.0015,
      longitude: 73.7920,
      userId: 'guest-user',
      description: 'Major fire reported near the northern market area.',
      location: 'Northern Market'
    },
    {
      type: 'Flooding',
      severity: 'high',
      status: 'active',
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      latitude: 19.9900,
      longitude: 73.7800,
      userId: 'guest-user',
      description: 'Streets flooded, impassable for vehicles.',
      location: 'South District'
    },
    {
      type: 'Roadblock / Debris',
      severity: 'medium',
      status: 'active',
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      latitude: 20.0100,
      longitude: 73.7750,
      userId: 'guest-user',
      description: 'Fallen trees blocking the main highway.',
      location: 'West Highway'
    }
  ];

  console.log('Seeding incidents...');
  for (const incident of incidents) {
    await db.collection('incidents').add(incident);
  }
  console.log(`Added ${incidents.length} incidents`);
}

seedIncidents().then(() => {
  console.log('Incident seeding complete.');
  process.exit();
}).catch(console.error);
