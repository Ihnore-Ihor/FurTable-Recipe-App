# FurTable - A Minimalist Recipe PWA

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)

A minimalist Progressive Web App (PWA) for creating and discovering recipes, featuring a unique monochrome, manga-inspired design. Built with Flutter & Firebase.

---

## ✨ Features & Preview

FurTable allows users to create, share, and organize their favorite recipes in a clean, artistic interface. The layout is inspired by modern content-browsing apps, while the aesthetic is drawn from high-contrast manga art.


![FurTable App Preview](<img width="215" height="377" alt="image" src="https://github.com/user-attachments/assets/9b8b52af-f27c-4f5f-9e3d-efa7744503a1" />)

### Key Features:
*   🔐 **Authentication:** Secure user registration and login using Firebase Authentication.
*   🖋️ **Recipe Creation:** Create detailed recipes with photos, ingredients, and instructions.
*   👀 **Public & Private Recipes:** Choose to keep recipes private for personal use or share them publicly with the community.
*   ❤️ **Favorites System:** Users can browse the public feed and save recipes from other creators to their personal "Favorites" list.
*   - **Personal Dashboard:** A dedicated space to view and manage your own public/private recipes and your collection of favorites.
*   🔍 **Search & Discovery:** A simple yet powerful search to find recipes by name.

---

## 🛠️ Tech Stack

*   **Framework:** [Flutter](https://flutter.dev/) (for Web)
*   **Language:** [Dart](https://dart.dev/)
*   **Backend & Database:** [Firebase](https://firebase.google.com/)
    *   **Authentication:** For user management.
    *   **Firestore:** For storing recipe and user data.
    *   **Storage:** For hosting recipe images.
*   **UI Design:** "Minimalist Manga Monochrome" aesthetic, inspired by *Beastars*.

---

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

*   You must have the [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.

### Installation & Setup

1.  **Clone the repo:**
    ```sh
    git clone https://github.com/your_username/FurTable-Recipe-App.git
    cd FurTable-Recipe-App
    ```

2.  **Install dependencies:**
    ```sh
    flutter pub get
    ```

3.  **Setup Firebase:**
    *   Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.
    *   Add a **Web App** to your Firebase project.
    *   In the project settings, find your Firebase configuration object.
    *   Create a new file `lib/firebase_options.dart` and paste your configuration there. (This is necessary because the original file is in `.gitignore` to protect secrets).

4.  **Run the app:**
    ```sh
    flutter run -d chrome
    ```

---

## About This Project

This application was developed as a course project for the "Cross-Platform Programming" discipline at Lviv Polytechnic National University.
