# 📘 ChamaWise

### *Modern, transparent chama management for Kenyan groups*

ChamaWise is a **mobile-first Flutter application** built to help Kenyan chamas (self-help groups) manage members, contributions, and financial records with **real-time Firestore updates**, transparency, and robust security.

---

## 📚 Table of Contents

* [Features](#-features)
* [Tech Stack](#️-tech-stack)
* [Project Structure](#-project-structure)
* [Installation](#️-installation)
* [Firebase Setup](#-firebase-setup)
* [Running the App](#️-running-the-app)
* [Firestore Security Rules](#-firestore-security-rules)
* [Roadmap](#-roadmap)
* [Contributing](#-contributing)
* [License](#-license)
* [Support](#-support)

---

## 🚀 Features

### 👥 Chama Management

* Create or join a chama using an invite code
* View chama details and member lists
* Admin privileges for the chama creator
* Real-time updates powered by Firestore

### 💰 Contributions Module

* Log contributions (amount, member, description, timestamp)
* View individual and total contributions
* **Role-based permissions:**

  * Creator logs payments for any member
  * Members log only their own
* Full contribution history per chama

### 📊 Dashboard

* Number of chamas you belong to
* Total contributions
* Personal contribution history

### 🔐 Authentication & Security

* Firebase Authentication (email/password or anonymous)
* Strong Firestore security rules
* Only authenticated users can read/write

---

## 🧱 Tech Stack

| Component        | Technology             |
| ---------------- | ---------------------- |
| Framework        | Flutter                |
| Backend          | Firebase Firestore     |
| Authentication   | Firebase Auth          |
| State Management | Riverpod               |
| Deployment       | Firebase Hosting (Web) |
| Platforms        | Android, Web           |

---

## 📂 Project Structure

```
lib/
├── features/
│   ├── auth/
│   ├── chamas/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   │   ├── dashboard_tab.dart
│   │   │   ├── contributions_screen.dart
│   │   │   ├── chama_details_screen.dart
│   │   │   └── create_join_chama.dart
│   ├── wallet/
│   └── profile/
│
├── services/
│   ├── firestore_service.dart
│   ├── auth_service.dart
│
├── widgets/
├── utils/
└── main.dart
```

---

## ⚙️ Installation

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/chamawise.git
cd chamawise
```

### 2. Install Flutter dependencies

```bash
flutter pub get
```

---

## 🔥 Firebase Setup

Enable these Firebase services:

* Firestore
* Firebase Authentication
* (Optional) App Check
* Firebase Hosting (for web builds)

Add Firebase config files:

* `google-services.json` → `android/app/`
* `GoogleService-Info.plist` → `ios/Runner/`
* Ensure Firebase Web config is in `web/index.html`

---

## ▶️ Running the App

### Android

```bash
flutter run
```

### Web

```bash
flutter run -d chrome
```

### Production Web Build

```bash
flutter build web
```

---

## 🔐 Firestore Security Rules

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }

    match /chamas/{chamaId} {
      allow read: if isMember(chamaId);
      allow write: if isCreator(chamaId);

      match /contributions/{contributionId} {
        allow read: if isMember(chamaId);

        allow write:
          isCreator(chamaId) ||
          (
            request.auth.uid == request.resource.data.userId &&
            isMember(chamaId)
          );
      }
    }

    function isCreator(chamaId) {
      return get(/databases/$(database)/documents/chamas/$(chamaId))
        .data.creatorId == request.auth.uid;
    }

    function isMember(chamaId) {
      return request.auth != null &&
        get(/databases/$(database)/documents/chamas/$(chamaId))
          .data.members
          .hasAny([request.auth.uid]);
    }
  }
}
```

---

## 🗺️ Roadmap

### ✅ Completed

* Core Authentication
* Create/Join Chama
* Chama Dashboard
* Contribution System
* Role-Based Permissions

### 🔜 Coming Next

* ⬜ Wallet Module (withdrawals, loans, savings)
* ⬜ M-Pesa STK Push Integration
* ⬜ Export to PDF
* ⬜ Push Notifications
* ⬜ Enhanced Chama Analytics Dashboard

---

## 🤝 Contributing

Pull requests are welcome!

### Contribution Guidelines

* Follow Flutter best practices
* Use Riverpod for state management
* Keep UI components modular
* Use clear, descriptive commit messages

---

## 📜 License

This project is **proprietary**.
All rights reserved.

---

## 📞 Support

For questions or business inquiries:

**Email:** [marierabill@gmail.com](mailto:marierabill@gmail.com)
**Phone:** +254 711 118 443 / +254 706 712 799

---

If you'd like this:

✅ Wrapped entirely inside a Markdown code block
✅ Redesigned with GitHub badges
✅ Styled with emojis & colored shields
✅ With screenshots or a banner

Just tell me!
