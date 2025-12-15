<div align="center">

# 🌿 BookBuddies

**BookBuddies** is a community-driven, peer-to-peer book lending platform built with Flutter. It connects readers, allowing them to share their personal libraries, borrow new reads, and build a reputation within a gamified community of book lovers.

<br>

<img src="https://github.com/user-attachments/assets/8f31f000-7f48-4f46-8f49-4bb8d112ac72" alt="BookBuddies Banner" width="800" />

</div>

---

## ✨ Features

### 📚 Library Management
* **Add Books:** Easily list books manually or auto-fill details using the Google Books API.
* **Manage Inventory:** Edit or delete your listings. Track availability status automatically.
* **Rich Details:** Upload multiple real photos, set book condition, language, and edition.

### 🤝 Borrowing System
* **Request & Approve:** Browse available books and send borrow requests. Owners can approve or reject requests.
* **Active Loan Tracking:** Dedicated dashboards for "Incoming Requests," "Active Loans," and "My Requests."
* **Return Flow:** Simple one-click return process that updates inventory and triggers the rating system.

### 🏆 Community & Gamification
* **Leaderboard:** A visual "Hall of Fame" podium ranking the top contributors.
* **Scoring System:** Users earn Favor Points for lending and maintaining a high Star Rating.
* **User Profiles:** Public profiles displaying stats, bio, and reputation (e.g., "Grand Archivist").

### 🎨 Modern UI/UX
* **Responsive Web Design:** Optimized for desktop and mobile web with a sidebar/drawer and responsive grids.
* **Nature-Themed UI:** A calming palette of Forest Green, Sage, and Warm Beige.
* **Interactive Elements:** Custom carousels, hover effects, and animated status badges.

---

## 📸 Screenshots

| Dashboard & Stats | Book Details |
|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/ef2ef8b5-b84d-496b-a86b-0693e1bea0af" width="100%" /> | <img src="https://github.com/user-attachments/assets/8aa63237-caa5-4215-8d8a-d4a967e162b5" width="100%" /> |

<div align="center">
  <p><strong>Add Book / Mobile View</strong></p>
  <img src="https://github.com/user-attachments/assets/426feacb-4039-4a73-8b8f-a50bd2420226" width="400" />
</div>

---

## 🛠️ Tech Stack

* **Framework:** Flutter (Web Optimized)
* **Backend:** Firebase
* **Authentication:** Email/Password & User Management.
* **Firestore:** NoSQL database for users, books, and transactions.
* **Storage:** Firebase storage for book images.
* **External APIs:** Google Books API (for metadata fetching).

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK installed.
* A Firebase project set up (Authentication, Firestore, Storage enabled).

### Installation & Dependencies

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/yourusername/bookbuddies.git](https://github.com/yourusername/bookbuddies.git)
   cd bookbuddies
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Firebase Configuration:**
   * Install the FlutterFire CLI.
   * Run the configure command to connect your project and generate ```firebase_options.dart```
  ```bash
  flutterfire configure
  ```

4. **Run the app:**
   ```bash
   flutter run
   ```

###Project Structure
