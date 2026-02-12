# 🎮 Tic Tac Toe Party - Realtime Multiplayer

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

**Tic Tac Toe Party** is a modern, real-time multiplayer mobile game built with **Flutter** and **Firebase**. It features a stunning "Neon Dark Mode" glassmorphism UI, instant room creation, live scoreboards, and seamless rematch capabilities.

---

## ✨ Features

* **Real-Time Gameplay:** Instant move synchronization using Cloud Firestore.
* **Multiplayer Rooms:** Create a private room and share the 4-digit code to play with friends anywhere.
* **Modern UI:** Sleek, dark-themed interface with neon accents and glassmorphism effects.
* **Live Scoreboard:** Tracks wins (X vs O) persistently throughout the session.
* **Smart Rematch:** "Play Again" feature that automatically swaps players (X becomes O) for fair play.
* **Rejoin Ability:** Accidentally closed the app? Re-enter the room code to reclaim your spot.
* **Player Status:** Detects when opponents join or disconnect.

---

## 📱 Screenshots

| Home Screen | Game Room | Win State |
|:---:|:---:|:---:|
| <img src="screenshots/home.png" width="200"> | <img src="screenshots/game.png" width="200"> | <img src="screenshots/win.png" width="200"> |

*(Note: Add your actual screenshots to a `screenshots` folder in your repo)*

---

## 🛠 Tech Stack

* **Framework:** [Flutter](https://flutter.dev/)
* **Language:** [Dart](https://dart.dev/)
* **Backend:** [Firebase Cloud Firestore](https://firebase.google.com/products/firestore)
* **State Management:** [GetX](https://pub.dev/packages/get)
* **Icons:** [Flutter Launcher Icons](https://pub.dev/packages/flutter_launcher_icons)

---

## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine.

### 1. Prerequisites
Make sure you have the following installed:
* [Flutter SDK](https://docs.flutter.dev/get-started/install)
* [Git](https://git-scm.com/)
* VS Code or Android Studio

### 2. Clone the Repository

```bash
git clone [https://github.com/JhaSourav07/ticTakToe.git](https://github.com/JhaSourav07/ticTakToe.git)
cd tictaktoe
```
# 🔥 Firebase Setup Guide (Required)

This app uses **Firebase Firestore** for real-time multiplayer functionality.  
You must connect the project to your own Firebase project before running the app.

---

## 🚀 Step 1: Create a Firebase Project

1. Go to the **Firebase Console**  
   https://console.firebase.google.com/
2. Click **Add Project**
3. Name it `TicTacToeParty` (or any name you prefer)
4. (Optional) Disable **Google Analytics**
5. Click **Create Project**

---

## 🤖 Step 2: Configure Android

1. In Firebase dashboard, click the **Android icon (🤖)**
2. Find your **Android Package Name**:
   - Open:
     ```
     android/app/build.gradle
     ```
   - Find:
     ```gradle
     applicationId "com.example.tictactoe"
     ```
   - Copy and paste this value into Firebase

3. Click **Register App**
4. Download the file `google-services.json`
5. Move it to:
   ```
   android/app/google-services.json
   ```
   ✅ Android setup complete.

---

## 🍎 Step 3: Configure iOS (Mac Only)

1. Click **Add App → iOS**
2. Find your **iOS Bundle ID**:
- Open:
  ```
  ios/Runner.xcodeproj/project.pbxproj
  ```
- Search for:
  ```
  PRODUCT_BUNDLE_IDENTIFIER
  ```
- Copy that value into Firebase

3. Click **Register App**
4. Download `GoogleService-Info.plist`
5. Move it to:
   ```
   ios/Runner/GoogleService-Info.plist
   ```
✅ iOS setup complete.

---
## 🗄 Step 4: Create Firestore Database

1. In Firebase Console, go to:
  Build → Firestore Database
2. Click **Create Database**
3. Choose a location (e.g., `nam5 (us-central)`)
4. ⚠️ Select **Start in Test Mode**

> Test Mode allows public read/write access for 30 days.  
> For production, you must configure authentication and secure rules.

---
## 🔐 Step 5: Verify Security Rules (Development Only)

Go to the **Rules** tab in Firestore and make sure it looks like this:

```js
rules_version = '2';
service cloud.firestore {
match /databases/{database}/documents {
 match /{document=**} {
   allow read, write: if true;
 }
}
}
```

✅ Final Step

Run:
```bash
flutter pub get
flutter run
```

Your TicTacToe Party app should now connect to Firebase successfully 🎉
---

---

# 🤝 Contributing

Contributions are welcome! 🎉  
If you'd like to improve this project, please follow these steps:

## 📌 How to Contribute

1. **Fork** the repository
2. Create a new branch:

   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Make your changes
4. Commit your changes:
   ```bash
   git commit -m "Add: short description of your feature"
   ```
5. Push to your branch:
   ```bash
   git push origin feature/your-feature-name
   ```
6. Open a Pull Request

---

---

# 🐛 Reporting Issues

If you find a bug or have a feature request:

  1. Open an Issue
  2. Clearly describe the problem
  3. Include screenshots (if applicable)
  4. Provide steps to reproduce

---

---

# 💡 Contribution Ideas

If you find a bug or have a feature request:

  1. Improve UI/UX
  2. Add sound effects
  3. Add player authentication
  4. Improve Firestore security rules
  5. Add game history
  6. Add leaderboard support
  7. Write tests

---

Thank you for contributing and helping improve TicTacToe Party ❤️
---
