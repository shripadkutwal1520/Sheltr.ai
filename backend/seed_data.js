const admin = require('firebase-admin');

process.env.FIREBASE_AUTH_EMULATOR_HOST = 'localhost:9099';
process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';

admin.initializeApp({
  projectId: 'demo-no-project'
});

async function seedData() {
  const db = admin.firestore();

  // 1. Seed Rooms
  const rooms = [
    { number: '101', isAvailable: true },
    { number: '102', isAvailable: false },
    { number: '103', isAvailable: true },
    { number: '104', isAvailable: true },
    { number: '105', isAvailable: false },
    { number: '201', isAvailable: true },
    { number: '202', isAvailable: true },
    { number: '203', isAvailable: true },
  ];

  console.log('Seeding rooms...');
  for (const room of rooms) {
    await db.collection('rooms').add(room);
  }
  console.log(`Added ${rooms.length} rooms`);

  // 2. Seed Inventory
  const inventoryItems = [
    { name: 'Blankets', quantity: 45, threshold: 20 },
    { name: 'Pillows', quantity: 38, threshold: 15 },
    { name: 'Towels', quantity: 12, threshold: 25 }, // low stock
    { name: 'Water Bottles', quantity: 150, threshold: 50 },
    { name: 'First Aid Kits', quantity: 5, threshold: 10 }, // low stock
    { name: 'Soap Bars', quantity: 80, threshold: 30 },
  ];

  console.log('Seeding inventory items...');
  for (const item of inventoryItems) {
    await db.collection('inventory').add(item);
  }
  console.log(`Added ${inventoryItems.length} inventory items`);

}

seedData().then(() => {
  console.log('Seeding complete.');
  process.exit();
}).catch(console.error);
