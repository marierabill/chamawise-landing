📘 ChamaWise
Modern, transparent chama management for Kenyan groups






ChamaWise is a mobile-first Flutter application designed to help Kenyan chamas (groups) manage contributions, members, and financial records with transparency and real-time updates.

📚 Table of Contents

Features

Tech Stack

Project Structure

Installation

Firebase Setup

Running the App

Firestore Security Rules

Roadmap

Contributing

License

Support

🚀 Features
👥 Chama Management

Create or join a chama using an invite code

View chama details and members

Creator has admin privileges

Real-time updates through Firestore

💰 Contributions Module

Log contributions (amount, member, description, timestamp)

View individual and total contributions

Role-based permissions:

Creator can log payments for any member

Members can only log their own

Contribution history per chama

📊 Dashboard

Summary of chama count

Total contributions

Personal contribution history

🔐 Authentication & Security

Firebase Authentication (email/password or anonymous)

Firestore rules with strict role enforcement

Only authenticated users can read/write data

🧱 Tech Stack
Component	Technology
Framework	Flutter
Backend	Firebase Firestore
Auth	Firebase Authentication
State Management	Riverpod
Hosting	Firebase Hosting (Web)
Platforms	Android, Web
📂 Project Structure
lib/
 ├── features/
 │    ├── auth/
 │    ├── chamas/
 │    │     ├── data/
 │    │     ├── domain/
 │    │     ├── presentation/
 │    │     │     ├── dashboard_tab.dart
 │    │     │     ├── contributions_screen.dart
 │    │     │     ├── chama_details_screen.dart
 │    │     │     └── create_join_chama.dart
 │    ├── wallet/
 │    └── profile/
 │
 ├── services/
 │    ├── firestore_service.dart
 │    ├── auth_service.dart
 │
 ├── widgets/
 ├── utils/
 └── main.dart

⚙️ Installation
1. Clone the repository
git clone https://github.com/yourusername/chamawise.git
cd chamawise

2. Get Flutter packages
flutter pub get

🔥 Firebase Setup
Enable the following Firebase services:

Firestore

Firebase Authentication

(Optional) App Check

Firebase Hosting if deploying web build

Add Firebase config:

Add google-services.json → android/app/

Add GoogleService-Info.plist → ios/Runner/

Ensure web config is in web/index.html

▶️ Running the App
Mobile (Android)
flutter run

Web
flutter run -d chrome

Production Web Build
flutter build web

🔐 Firestore Security Rules

Copy these into Firestore Rules:

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

🗺️ Roadmap
Completed

✔ Core authentication
✔ Create/join chama
✔ Chama dashboard
✔ Contributions system
✔ Role-based permissions

Coming Next

⬜ Wallet module (withdrawals, loans, savings)
⬜ M-Pesa STK push integration
⬜ Export to PDF
⬜ Push notifications
⬜ Chama analytics dashboard

🤝 Contributing

Pull requests are welcome.

Guidelines:

Follow Flutter best practices

Use Riverpod for state management

Keep UI modular

Commit with clear messages

📜 License

This project is proprietary.
All rights reserved.

📞 Support

For questions or business inquiries contact:

Email: marierabill@gmail.com

Phone: +254 711 118 443 / +254 706 712 799 