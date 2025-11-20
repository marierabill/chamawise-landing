# ChamaWise  
A modern, mobile-first platform for managing Kenyan chamas with transparency, automation, and real-time contribution tracking.

ChamaWise helps groups manage contributions, payments, members, and financial records in a clean, simple, and secure way powered by Flutter & Firebase.

---

## 🚀 Features

### 👥 Chama Management
- Create or join a chama using a unique invite code  
- View chama details (name, description, creator, member list)  
- Role-based permissions (Creator vs Member)  
- Creator can update chama info  

### 💰 Contributions
- Log contributions (amount, description, timestamp)  
- View all member payments  
- Automatic total contributions calculation  
- Role-dependent permissions:  
  - Creator can log payments for any member  
  - Members can only log their own  

### 📊 Dashboard & Insights
- Real-time Firestore-powered totals  
- Summary on home screen for quick financial overview  

### 🔐 Authentication & Security
- Firebase Authentication (email/password, Google optional)  
- Firestore security rules with role-based validation  
- Only authenticated users can read/write data  

### ☁️ Cloud Architecture
- Firestore (NoSQL database)  
- Firebase Auth  
- Firebase Hosting / Flutter Web  
- Flutter mobile build (Android / iOS)

---

## 🧱 Tech Stack

| Layer | Technology |
|------|------------|
| Frontend | Flutter 3 (Material 3, Riverpod) |
| Backend | Firebase Cloud Firestore |
| Auth | Firebase Authentication |
| State Management | Riverpod / StateNotifier |
| Hosting | Firebase Hosting (Web) |
| Platform | Android, iOS, Web |

---

## 📂 Project Structure (Flutter)

