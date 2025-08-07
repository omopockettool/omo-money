# OMO Money

A personal expense management app built with SwiftUI and SwiftData.



## Project Structure

```
omo-money/
├── App/
│   ├── OmoMoneyApp.swift          # Main app entry point
│   └── omo-money.entitlements     # App entitlements
├── Models/
│   ├── Core/
│   │   ├── Entry.swift            # Entry data model
│   │   ├── Item.swift             # Item data model
│   │   ├── HomeGroup.swift        # Home group data model
│   │   ├── User.swift             # User data model
│   │   └── HomeGroupUser.swift    # Home group user relationship model
│   └── Enums/
│       └── Enums.swift            # App enums (EntryCategory, Currency)
├── Views/
│   ├── Main/
│   │   ├── ContentView.swift      # Main content view
│   │   └── Components/
│   │       ├── ContentViewComponents.swift # Main view components
│   │       ├── EmptyStateComponents.swift  # Empty state components
│   │       └── FilteringLogic.swift        # Filtering logic
│   ├── Entry/
│   │   ├── EntryFormView.swift    # Entry creation/editing form
│   │   ├── EntryDetailView.swift  # Entry detail view
│   │   └── Components/
│   │       └── EntryRowView.swift # Entry row component
│   ├── HomeGroup/
│   │   ├── HomeGroupManagementSheet.swift # Home group management
│   │   └── AddHomeGroupSheet.swift # Home group creation
│   ├── Category/
│   │   └── CategoryManagementSheet.swift # Category management
│   ├── Filters/
│   │   └── FiltersSheet.swift     # Filter management
│   ├── Info/
│   │   ├── AppInfoSheet.swift     # App information
│   │   └── Components/
│   │       └── InfoComponents.swift # Info components (FeatureRow, AppPreviewRow)
│   └── Item/
│       └── Components/            # Ready for future item components
├── Utils/
│   ├── Extensions/
│   │   └── DateFormatter.swift    # Date formatting utilities
│   ├── Helpers/
│   │   ├── MoneyValidation.swift  # Money input validation
│   │   └── SearchSuggestions.swift # Search suggestions and intelligent search
│   └── Constants/                 # Ready for future constants
├── Services/                      # Ready for future services
└── Assets.xcassets/               # App assets
```

## Architecture Overview

### 1. **App Layer**
- Contains the main app entry point and configuration
- Handles app lifecycle and SwiftData setup

### 2. **Models Layer**
- **Core Models**: SwiftData models for data persistence
- **Enums**: App-wide enumerations and constants

### 3. **Views Layer**
- **Main Views**: Primary app screens
- **Feature Views**: Organized by feature (Entry, HomeGroup, Category, etc.)
- **Components**: Reusable UI components
- **Sheets**: Modal presentations

### 4. **Utils Layer**
- **Extensions**: Swift extensions for common functionality
- **Helpers**: Utility functions and helper classes
- **Constants**: App-wide constants and configuration (ready for future use)

### 5. **Services Layer**
- Business logic and data management (ready for future use)
- Validation and data processing services

## Key Features

- **Expense Tracking**: Track personal and group expenses
- **Category Management**: Organize expenses by categories
- **Home Groups**: Manage expenses for different groups (family, roommates, etc.)
- **Item Details**: Break down expenses into individual items
- **Filtering & Search**: Advanced filtering and search capabilities with intelligent matching
- **Multi-Currency Support**: Support for different currencies
- **Payment Status**: Track paid and pending items
- **Instant Operations**: All actions respond immediately for optimal user experience
- **Search Highlighting**: Visual indicators for search results and dynamic totals

## Data Models

### Entry
- Represents an expense or income entry
- Contains title, date, category, type, and associated items

### Item
- Individual items within an entry
- Contains price, quantity, description, and payment status

### HomeGroup
- Groups for organizing expenses (family, roommates, etc.)
- Contains name, currency, and associated entries

### User
- App users with name and email
- Connected to home groups through relationships

### HomeGroupUser
- Junction table for user-group relationships
- Tracks join date and admin status

## Development Guidelines

### File Naming
- Use PascalCase for file names
- Include feature name in file names (e.g., `EntryFormView.swift`)
- Group related files in feature folders

### Code Organization
- Keep views focused on UI logic
- Move business logic to services
- Use extensions for utility functions
- Maintain clear separation of concerns

### SwiftData Usage
- Use `@Model` for data models
- Implement proper relationships with `@Relationship`
- Handle data operations in services layer

### SwiftUI Best Practices
- Use `@State` for local view state
- Use `@Binding` for parent-child communication
- Use `@Environment` for app-wide values
- Keep views composable and reusable
- Prioritize instant user feedback over animations

### Performance Guidelines
- Avoid artificial delays (`Task.sleep`)
- Use immediate save operations
- Minimize `withAnimation` for critical operations
- Optimize database queries and operations

## Future Enhancements

- **Analytics**: Expense analytics and reporting
- **Export**: Data export functionality
- **Backup**: Cloud backup and sync
- **Notifications**: Payment reminders
- **Budgeting**: Budget planning and tracking
- **Multi-language**: Internationalization support

## Getting Started

1. Open the project in Xcode
2. Build and run the app
3. Create your first home group
4. Start tracking your expenses

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## License

This project is licensed under the MIT License. 