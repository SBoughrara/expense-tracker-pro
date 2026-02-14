# Expense Tracker Pro

Name: Seif Eddine Bougrara  
Matricola: 345766

---

## Project Title

Expense Tracker Pro – Multi-currency Expense Management App

---

## Overview

Expense Tracker Pro is a Flutter application that allows users to track daily expenses, categorize them, visualize statistics, and convert amounts using live exchange rates retrieved from a remote API. The application focuses on clean UI design, responsive layout, and structured state management.

---

## Main Features

- Add and delete expenses
- Categorize expenses (Food, Transport, Shopping, etc.)
- View total spending
- Visual statistics by category
- Multi-currency support
- Live currency conversion via remote REST API
- Dark mode
- Local data persistence
- Web support (multiplatform)

---

## User Experience Overview

The user can:

1. Add a new expense from the main screen by pressing the "+" button.
2. Enter title, amount, category, and confirm.
3. View the list of expenses immediately updated.
4. Navigate to the statistics screen to see category distribution.
5. Change currency in settings (conversion handled automatically).
6. Switch between light and dark mode.

---

## Technology and Implementation Choices

### Flutter & Dart
The app is built using Flutter to support multiple platforms (Android and Web).

### State Management
Provider was used to manage application state cleanly and separate UI from business logic.

### Local Storage
SharedPreferences is used to persist expense data locally so that user data remains saved between app restarts.

### Remote Communication
The HTTP package is used to retrieve real-time exchange rates from a public currency exchange API.  
This satisfies the requirement of communication with a remote service (V4).

All expenses are internally stored in a base currency (USD) and converted dynamically in the UI to ensure consistent calculations and correct statistics.

### Responsive Design
The UI adapts to different screen sizes using layout constraints and flexible widgets, allowing the app to run correctly on both mobile and web.

### Challenges Encountered
During implementation, handling dynamic currency conversion while maintaining consistent statistics required restructuring how expense data was stored. The issue was solved by storing all values in a base currency and applying conversion only when rendering the UI.

---

## How to Run the Project

1. Clone the repository
2. Run `flutter pub get`
3. Run `flutter run`

To build for web:
1.  flutter run -d chrome
---

