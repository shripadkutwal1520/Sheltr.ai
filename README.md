# Sheltr.ai 🛡️

AI-powered emergency response and campus safety system.

## 🚀 Overview
Sheltr.ai is a cross-platform mobile application designed to provide instant emergency assistance. It leverages Google's **Gemini AI** to automatically classify incidents and notify staff members in real-time.

## ✨ Features
- **Panic Flow:** Instant emergency trigger with a long-press gesture.
- **AI Classification:** Uses Gemini 1.5 Flash to categorize emergencies (Fire, Medical, Crime, etc.) and assign severity levels automatically.
- **Staff Dashboard:** Real-time monitoring of active incidents with status management.
- **Report Generation:** Export incident logs to professionally formatted PDF reports.
- **Dual-OS Compatible:** Fully optimized for both Windows and Linux development environments.

## 🛠️ Tech Stack
- **Frontend:** Flutter (Dart)
- **Backend:** Firebase Cloud Functions (Node.js)
- **Database:** Cloud Firestore
- **AI:** Google Gemini AI (Generative AI SDK)
- **Authentication:** Firebase Auth

## 📂 Project Structure
- `apps/mobile`: Flutter mobile application.
- `backend/functions`: Firebase Cloud Functions and AI service logic.
- `shared/models`: Data models used across the project.

## ⚙️ Setup Instructions

### Prerequisites
- Flutter SDK (v3.11.4+)
- Node.js (v18+)
- Firebase CLI

### Mobile Setup
1. Navigate to `apps/mobile`.
2. Run `flutter pub get`.
3. Add your `google-services.json` to `android/app/`.
4. Run `flutter run`.

### Backend Setup
1. Navigate to `backend/functions`.
2. Run `npm install`.
3. Configure your Gemini API Key:
   ```bash
   firebase functions:secrets:set GEMINI_API_KEY
   ```
4. Deploy:
   ```bash
   firebase deploy --only functions
   ```

## 📄 License
Private Project - Sheltr.ai Development Team
