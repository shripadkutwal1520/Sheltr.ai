# Sheltr.ai

**Intelligent Emergency Response & Real-time Safety Infrastructure**

[![Tech Stack](https://img.shields.io/badge/Stack-Flutter%20%7C%20Firebase%20%7C%20Gemini%20AI-blue)](https://github.com/your-repo/sheltr-ai)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

## Overview

In critical situations, every second counts. Traditional emergency reporting often lacks the immediate context responders need to prioritize effectively. **Sheltr.ai** is a production-grade safety ecosystem designed to bridge this gap. By combining low-latency mobile triggers with Google's Gemini AI, the system automatically classifies incident severity and routes intelligent alerts to the right people in real-time.

## The Problem
Emergency systems often suffer from "alert fatigue" or insufficient data. Users in distress cannot always provide detailed descriptions, and responders are often overwhelmed by uncategorized notifications. Sheltr.ai solves this by using AI to analyze incident types and metadata, ensuring high-priority emergencies are surfaced instantly.

## Key Features

- **⚡ One-Touch Panic Trigger**: Optimized for speed, allowing users to broadcast distress signals with a single interaction, even when GPS data is sparse.
- **🤖 AI Incident Classification**: Integrated with **Google Gemini 1.5 Flash** to automatically categorize emergencies (Critical, High, Medium, Low) based on context and type.
- **📍 Real-time Incident Mapping**: Live visualization of active emergencies using Firestore's real-time listeners and specialized map views.
- **🔔 Smart Notifications**: Context-aware push notifications sent via FCM, triggered only after AI classification to reduce noise and increase response accuracy.
- **👥 Role-Based Access**: Dedicated workflows for standard users (reporting) and staff members (management and response).

## System Architecture

The system operates on a reactive, event-driven architecture:

```text
[ Mobile App ] --(triggerPanic)--> [ Cloud Functions ]
                                         |
                                         v
[ Push Notification ] <--(FCM)-- [ Firestore ] --(onCreate)--> [ Gemini AI ]
      (Alert)                                                  (Classification)
```

1.  **Trigger**: User activates the Panic Button; app attempts a 3s location lock but proceeds regardless to ensure delivery.
2.  **Ingestion**: Firebase Cloud Function validates the user and writes a "pending" incident to Firestore.
3.  **Analysis**: A background Firestore trigger invokes Gemini AI to classify severity based on incident metadata.
4.  **Distribution**: Once classified, the Notification Service dispatches FCM alerts to relevant staff members.

## Tech Stack

- **Frontend**: Flutter (iOS & Android)
- **Backend**: Node.js / Firebase Cloud Functions
- **Database**: Firebase Firestore (NoSQL)
- **AI**: Google Gemini Pro (@google/generative-ai)
- **Auth**: Firebase Authentication
- **Security**: Google Cloud Secret Manager

## Project Structure

```text
sheltr-ai/
├── apps/
│   └── mobile/              # Flutter mobile application
├── backend/
│   └── functions/           # Node.js Firebase Cloud Functions
│       ├── services/        # Gemini and Notification logic
│       └── index.js         # Cloud Function entry points
├── docs/                    # Architecture and API documentation
├── shared/                  # Shared models and schemas
└── scripts/                 # Deployment and setup automation
```

## Getting Started

### Prerequisites
- Flutter SDK (Latest Stable)
- Node.js (v18+)
- Firebase CLI
- Google Cloud Project with Gemini API access

### Installation

1.  **Clone the Repository**
    ```bash
    git clone https://github.com/your-username/sheltr-ai.git
    cd sheltr-ai
    ```

2.  **Setup Mobile App**
    ```bash
    cd apps/mobile
    flutter pub get
    ```

3.  **Setup Backend**
    ```bash
    cd ../../backend/functions
    npm install
    ```

4.  **Configure Environment & Secrets**
    Ensure your Firebase project is initialized. Set your Gemini API key using Secret Manager:
    ```bash
    firebase secrets:set GEMINI_API_KEY
    ```

5.  **Run the Application**
    ```bash
    cd ../../apps/mobile
    flutter run
    ```

## Screenshots

| Panic Trigger | Incident Feed | AI Insights |
| :---: | :---: | :---: |
| ![Placeholder] | ![Placeholder] | ![Placeholder] |

## Future Roadmap

- [ ] **SMS Fallback**: Twilio integration for alerts when data connectivity is unavailable.
- [ ] **Live Tracking**: Real-time breadcrumbs for users after a panic alert is triggered.
- [ ] **Wearable Integration**: Support for Apple Watch and WearOS complications.
- [ ] **Edge Inference**: On-device incident classification for offline support.

---
*Developed with focus on reliability, speed, and safety.*
