# Life League App

A SwiftUI-based personal activity tracker featuring a comprehensive multi-mode calendar system.

## 🏗 Architectural Overview

This project follows modern Swift and SwiftUI architectural patterns, emphasizing clean state management and safe data handling.

### 1. State Management (`ActivityStore.swift`)
The app uses the **Observation framework** (`@Observable`) introduced in Swift 5.9. 
- **Centralized Data:** All activities are stored in a single `ActivityStore` class.
- **Environment Injection:** The store is injected into the app's `environment`, making data accessible to any view without complex prop-drilling.
- **Reactive UI:** Views automatically observe and react to changes in the data store, ensuring the UI stays in sync.

### 2. Data Model (`Activity.swift`)
Activities are defined as `Identifiable` and `Codable` structs.
- `UUID`: Ensures each activity is uniquely trackable by SwiftUI's diffing engine.
- `Codable`: Prepared for future implementation of local storage or cloud sync.

### 3. Calendar Engine (`CalendarUtils.swift`)
Date calculations are isolated into a utility structure to ensure reliability.
- **Safe Iteration:** Uses bounded `for-in` loops rather than `while` loops to prevent infinite execution and crashes.
- **Native APIs:** Leverages Apple's `Calendar.dateInterval` and `DateComponents` for accurate calculations across different locales and daylight saving changes.

### 4. User Interface (`CalendarView.swift`)
The calendar provides four distinct perspectives of the user's data:
- **Daily:** Detailed list view of activities for a specific date.
- **Weekly:** A horizontal timeline showing the distribution of activities across the week.
- **Monthly:** A 7-column `LazyVGrid` highlighting activity presence with visual indicators.
- **Yearly:** A high-level overview of the entire year using mini-month grids.

## 🎓 Learning Concepts for Students

- **Declarative UI:** Learning how SwiftUI views describe *what* the UI should look like based on the current state.
- **Dependency Injection:** Using `.environment()` to share data between unrelated parts of the app.
- **Bounded Iteration:** Understanding why fixed-range loops are safer than conditional loops in performance-critical UI code.
- **Component Decoupling:** Breaking large views into smaller, reusable sub-views (like `WeeklyDayRow`) for better maintainability.

## 🛠 Tech Stack
- **Language:** Swift 6.0
- **Framework:** SwiftUI
- **API:** Observation Framework
