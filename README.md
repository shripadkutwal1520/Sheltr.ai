# Sheltr.ai 🛡️

AI-powered emergency response and campus safety system.

## 🚀 Overview
Sheltr.ai is a cross-platform mobile application designed to provide instant emergency assistance. It leverages Google's **Gemini AI** to automatically classify incidents and notify staff members in real-time.

## ✨ Features
- **Panic Flow:** Instant emergency trigger with a long-press gesture.
- **AI Classification:** Uses Gemini 1.5 Flash to categorize emergencies (Fire, Medical, Crime, etc.) and assign severity levels automatically.
- **Staff Dashboard:** Real-time monitoring of active incidents with status management and **Logout** capability.
- **Report Generation:** Export incident logs to professionally formatted PDF reports.
- **Local Development Suite:** Pre-configured for local testing using Firebase Emulators.

## 🛠️ Tech Stack
- **Frontend:** Flutter (Dart)
- **Backend:** Firebase Cloud Functions (Node.js)
- **Database:** Cloud Firestore
- **AI:** Google Gemini AI (Generative AI SDK)
- **Authentication:** Firebase Auth

## 📂 Project Structure
- `apps/mobile`: Flutter mobile application.
- `backend/`: Firebase project root (contains `functions`, `firebase.json`, etc.).
- `backend/functions`: Cloud Functions and AI service logic.

## ⚙️ Setup Instructions

### Prerequisites
- Flutter SDK (v3.11+)
- Node.js (v18+)
- Firebase CLI (`npm install -g firebase-tools`)
- Java Runtime (required for Firebase Emulators)

### Backend & Local Emulator Setup
1. Navigate to the `backend` directory:
   ```bash
   cd backend
   npm install
   ```
2. Start the local emulators (Firestore, Auth, and Functions):
   ```bash
   npx firebase emulators:start
   ```
3. (Optional) Seed the local database with test users:
   Open a new terminal in the `backend` folder and run:
   ```bash
   node seed_users.js
   ```
   *This creates a Guest user (`guest@demo.com`) and a Staff user (`mayureshnehere44@gmail.com`) with the password `password123`.*

### Mobile Setup
1. Navigate to `apps/mobile`:
   ```bash
   cd apps/mobile
   flutter pub get
   ```
2. **Local Backend Connection:**
   The app is configured to connect to your PC's IP during local development. If your IP changes, update the `host` variable in `lib/main.dart`:
   ```dart
   const String host = "YOUR_PC_IP_HERE";
   ```
3. Run the app:
   ```bash
   flutter run
   ```

### Production Deployment
1. Configure your Gemini API Key:
   ```bash
   firebase functions:secrets:set GEMINI_API_KEY
   ```
2. Deploy:
   ```bash
   firebase deploy --only functions
   ```

## 📄 License
Private Project - Sheltr.ai Development Team
