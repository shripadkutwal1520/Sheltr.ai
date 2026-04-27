const admin = require('firebase-admin');

process.env.FIREBASE_AUTH_EMULATOR_HOST = 'localhost:9099';
process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';

admin.initializeApp({
  projectId: 'demo-no-project'
});

async function seedUsers() {
  const users = [
    {
      uid: 'guest-user',
      email: 'guest@demo.com',
      password: 'password123',
    },
    {
      uid: 'staff-user',
      email: 'mayureshnehere44@gmail.com',
      password: 'password123',
    }
  ];

  for (const user of users) {
    try {
      await admin.auth().createUser(user);
      console.log(`Created user: ${user.email}`);
    } catch (e) {
      if (e.code === 'auth/email-already-exists') {
        console.log(`User already exists: ${user.email}`);
      } else {
        console.error(`Error creating user ${user.email}:`, e);
      }
    }
  }

  // Set staff role for the staff user in Firestore
  const db = admin.firestore();
  await db.collection('roles').doc('staff-user').set({
    role: 'staff'
  });
  console.log('Set staff role for staff user');
}

seedUsers().then(() => process.exit());