# WakeLock — Focus Alarm ⏰

> **The Ultimate Anti-Snooze Alarm & Wake-Up Challenge Suite for Heavy Sleepers**

WakeLock (Focus Alarm) is an open-source, feature-rich Flutter application designed to guarantee you never oversleep. Built with **Flutter**, **Riverpod**, **Isar Database**, and native **Android Foreground Services**, WakeLock combines unbreakable alarm scheduling with interactive wake-up challenges (Missions) such as Math, Memory Grids, Shake detection, Step counting, and Typing.

---

## 📸 Core Features & Highlights

### 🔔 Smart Alarm Management & Scheduling
- **Custom Schedules:** Set alarms for specific times with recurring day preferences (Monday through Sunday).
- **Custom Audio & Ringtones:** Support for system ringtones and custom local audio files via `file_picker`.
- **Snooze Controls & Limits:** Configure custom snooze durations or lock snoozing entirely.
- **Hardcore Mode:** Prevents volume reduction, disables accidental snoozing, and ensures maximum wake-up pressure.
- **Awake Verification Check:** Triggers a post-dismissal confirmation prompt after a set time to prevent falling back asleep.

### 🎯 Interactive Wake-Up Missions
To dismiss an active alarm, users must complete configurable cognitive or physical missions:
- **🧮 Math Mission:** Solve arithmetic problems with selectable difficulty levels (Easy, Medium, Hard) and problem counts.
- **🧠 Memory Mission:** Memorize and repeat pattern grids to activate cognitive alertness.
- **📱 Shake Mission:** Uses phone accelerometer sensors (`sensors_plus`) requiring physical shaking to turn off the alarm.
- **🚶 Step Count Mission:** Requires physical movement and steps to ensure you get out of bed.
- **⌨️ Typing Mission:** Type out randomized motivational quotes or custom text blocks accurately.

### 📊 History & Analytics Tracking
- **Wake-Up Stats:** View historical alarm activity including completion times, snooze counts, and dismissals.
- **Performance Metrics:** Track overall wake-up consistency and streak metrics stored locally in Isar DB.

### 🛡️ System & Permission Service Integration
- **Reliable Background Execution:** Powered by native Android Foreground Services and `android_alarm_manager_plus`.
- **Wakelock Integration:** Utilizes `wakelock_plus` to keep the screen active during ringing state.
- **Permissions Wizard:** In-app guide for granting exact alarms (`SCHEDULE_EXACT_ALARM`), system notifications, overlay drawing, and battery optimization exemptions.

---

## 🛠️ Tech Stack & Architecture

| Layer | Technology |
| :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev/) (Dart SDK ^3.12.2) |
| **State Management** | [Flutter Riverpod 3](https://riverpod.dev/) |
| **Local Database** | [Isar DB](https://isar.dev/) (`isar`, `isar_flutter_libs`) |
| **Alarm Scheduler** | [android_alarm_manager_plus](https://pub.dev/packages/android_alarm_manager_plus) |
| **Background & Service** | Native Android Kotlin `AlarmForegroundService` |
| **Notifications** | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) |
| **Screen & Display** | [wakelock_plus](https://pub.dev/packages/wakelock_plus) |
| **Sensors & Input** | [sensors_plus](https://pub.dev/packages/sensors_plus), [file_picker](https://pub.dev/packages/file_picker) |
| **Audio Playback** | [just_audio](https://pub.dev/packages/just_audio) |
| **Theme & UI** | Material Dark Mode with Custom Color Schemes |

---

## 📁 Project Structure

```text
lib/
├── main.dart               # App entry point, Riverpod provider scope, & routing setup
├── core/                   # Core services, utilities, and database models
│   ├── db/
│   │   ├── isar_service.dart      # Isar database initialization & CRUD handlers
│   │   └── models/
│   │       ├── alarm.dart          # Alarm entity & mission configuration schema
│   │       └── alarm_history.dart  # Alarm history & statistics schema
│   ├── services/
│   │   ├── alarm_scheduler.dart    # Android alarm manager orchestration
│   │   └── permissions_service.dart # Platform permission checks & requests
│   └── utils/                     # Formatting & helper utilities
└── features/               # Modular feature views & business logic
    ├── alarms/             # Alarm list screen & creation/edit modals
    │   └── views/
    │       ├── alarm_edit_screen.dart
    │       └── alarm_list_screen.dart
    ├── missions/           # Interactive challenge host & mission views
    │   ├── models/
    │   └── views/
    │       ├── math_mission_view.dart
    │       ├── memory_mission_view.dart
    │       ├── mission_host_screen.dart
    │       ├── shake_mission_view.dart
    │       ├── step_mission_view.dart
    │       └── typing_mission_view.dart
    ├── permissions/        # Permission request screens
    └── stats/              # Alarm history and stats visualization
        └── views/
            └── stats_screen.dart
```

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed on your machine:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.12.2` or later)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / Xcode (Android device or emulator required for testing native alarm services)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/WakeLock.git
   cd WakeLock
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate Isar Database Code (if modifying models):**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the Application:**
   ```bash
   # Launch on an Android physical device or emulator
   flutter run
   ```

---

## 📄 License

This project is licensed under the MIT License - see the `LICENSE` file for details.

