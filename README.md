# FurTable - Minimalist Recipe PWA

![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Bitrise](https://img.shields.io/badge/Bitrise-CI%2FCD-683D87?style=for-the-badge&logo=bitrise&logoColor=white)
![Sentry](https://img.shields.io/badge/Sentry-Monitoring-362D59?style=for-the-badge&logo=sentry&logoColor=white)

**FurTable** is a high-performance Progressive Web App (PWA) for creating, discovering, and organizing recipes. It features a unique **"Minimalist Manga Monochrome"** design aesthetic inspired by *Beastars*, built with a robust **Feature-First Architecture** and **BLoC** state management.

---

## ✨ Key Features

### 👤 User Experience & Auth
*   **Advanced Authentication:** Email/Password & Google Sign-In with automatic account linking (merging credentials).
*   **Guest Mode:** Browse recipes without an account. Smart onboarding prompts when trying to interact.
*   **Profile Management:** Custom avatars (with local caching), nickname updates, and secure account deletion.
*   **Localization (i18n):** Full support for **English** and **Ukrainian** languages with persisted preferences.

### 🍳 Recipe Management
*   **Smart Creation:** Drag-and-drop image upload with **HEIC support** (auto-conversion to JPEG) and **WebP compression** (client-side).
*   **CRUD Operations:** Create, Read, Update, and Delete recipes with real-time Firestore sync.
*   **Privacy Controls:** Toggle between Public (visible to everyone) and Private (visible only to you) recipes.
*   **Draft System:** Automatic local saving of unsaved recipes prevents data loss.

### 🔍 Discovery & Interaction
*   **Optimized Search:** Search by title or author using Firestore array-contains logic and local history caching.
*   **Favorites System:** Optimistic UI updates for instant "Like" interactions. Secure transaction-based counters.
*   **Responsive Grid:** Masonry layout that adapts perfectly from mobile phones to 4K desktops.

---

## 🏗️ Technical Highlights

This project goes beyond basics, implementing enterprise-level patterns:

*   **State Management:** **BLoC (Business Logic Component)** for predictable state transitions and separation of concerns.
*   **Architecture:** **Feature-First** structure with a clear division between *Presentation* (Screens, Widgets), *Domain/Logic* (BLoC), and *Data* (Repositories, Models).
*   **Performance:**
    *   **WebAssembly (Wasm)** ready.
    *   **Image Pipeline:** Automatic resizing and compression (<100KB) before upload to save bandwidth and storage costs.
    *   **Caching:** `cached_network_image` with custom memory cache settings for smooth scrolling.
    *   **Custom Splash Screen:** CSS/HTML based loader for instant visual feedback before Flutter engine initialization.
*   **Security:**
    *   **Envied:** API keys and secrets are obfuscated in binary code, not stored in plain text.
    *   **Firestore Rules:** Strict Row Level Security (RLS) ensuring users can only modify their own data.
*   **CI/CD:** Automated build and deployment pipeline via **Bitrise** to **Firebase Hosting**.

---

## 🛠️ Tech Stack

*   **Frontend:** Flutter Web (CanvasKit/Wasm)
*   **Backend:** Firebase (Auth, Firestore, Storage)
*   **State Management:** `flutter_bloc`, `equatable`
*   **Data & Networking:** `cloud_firestore`, `firebase_storage`, `shared_preferences`
*   **Utilities:** `image_picker`, `flutter_image_compress`, `heckofaheic` (HEIC converter), `uuid`, `intl`
*   **Monitoring:** Sentry for error tracking.

---

## 📂 Project Structure

lib/
├── core/                  # Global utilities, themes, widgets, env config
├── features/              # Feature-based modules
│   ├── auth/              # Authentication logic & screens
│   ├── create_recipe/     # Recipe creation form & BLoC
│   ├── explore/           # Main feed, Recipe Details, Repositories
│   ├── favorites/         # Favorites logic
│   ├── profile/           # User profile, settings, feedback
│   └── search/            # Search logic & history
├── l10n/                  # Localization files (.arb)
└── main.dart              # Entry point & App configuration
🚀 Getting Started
Prerequisites
Flutter SDK (3.22 or higher recommended)
Firebase Project credentials
Installation
Clone the repository:
code
Sh
git clone https://github.com/your_username/FurTable-Recipe-App.git
cd FurTable-Recipe-App
Install dependencies:
code
Sh
flutter pub get
Configure Environment Variables:
Create a .env file in the root directory and add your keys (required for envied generator):
code
Env
SENTRY_DSN=your_dsn
FB_API_KEY=your_key
# ... other Firebase config keys
Generate Code:
Run build_runner to generate secure configuration files and localization:
code
Sh
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
Run the App:
code
Sh
flutter run -d chrome
📜 License & Credits
Design Inspiration: Beastars (Manga aesthetic).
Course Project: Developed for "Cross-Platform Programming" at Lviv Polytechnic National University.
