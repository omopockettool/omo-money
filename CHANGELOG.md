# Changelog

All notable changes to OMO Money will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-15

### Added
- **Home Group System**:
  - Create and manage multiple home groups (e.g., "Gastos Diarios", "Vacaciones")
  - Each group has its own currency (USD, EUR)
  - Switch between groups with dropdown selector
  - Delete groups with confirmation dialog
- **Enhanced Entry System**:
  - Create entries with title, date, category, and type (income/expense)
  - Automatic item creation with initial amount during entry creation
  - Edit entries by tapping on the title in detail view
  - Color-coded entries: red for expenses, green for income
- **Item Management**:
  - Add multiple items to each entry
  - Edit items by tapping on them
  - Color-coded item amounts based on entry type
  - Support for quantity and description
- **Category System**:
  - Predefined categories: Comida, Hogar, Salud, Ocio, Transporte, Otros
  - Category analysis with money spent per category
  - Progress bars showing spending distribution
  - Category statistics for selected home group
- **Currency Support**:
  - USD and EUR currency options
  - Currency symbols displayed throughout the app
  - Currency-specific formatting
- **Enhanced UI/UX**:
  - Clean, minimalist design with flat colors
  - Widget showing total spent and entry count
  - Intuitive navigation with proper visual hierarchy
  - Responsive design with proper spacing
- **Data Management**:
  - SwiftData integration with proper relationships
  - Cascade deletion for data integrity
  - Isolated database per app instance
- **Analytics Dashboard**:
  - Category spending analysis with progress bars
  - Total spent calculations per group
  - Entry count tracking
  - Visual spending breakdown

### Changed
- **Architecture**: Complete redesign from basic transaction system to home group-based architecture
- **Data Model**: Restructured to support HomeGroup → Entry → Item hierarchy
- **UI Design**: Modernized interface with better visual hierarchy and user experience
- **Navigation**: Improved navigation flow with contextual actions

### Technical
- **SwiftData Models**: HomeGroup, Entry, and Item entities with proper relationships
- **SwiftUI Views**: Comprehensive view hierarchy with proper state management
- **Data Persistence**: Robust SwiftData configuration with migration support
- **Performance**: Optimized queries and data access patterns
- **iOS 17+**: Leverages latest SwiftUI and SwiftData features

### Features
- **Home Group Management**: Create, edit, delete groups with currency selection
- **Entry Management**: Full CRUD operations with automatic item creation
- **Item Management**: Add, edit, delete items within entries
- **Category Analysis**: Visual spending breakdown by category
- **Currency Support**: Multi-currency support with proper formatting
- **Data Integrity**: Proper cascade deletion and relationship management
- **User Experience**: Intuitive interface with clear visual feedback

### Architecture
- **MVVM Pattern**: Clean separation of concerns
- **SwiftData Integration**: Modern data persistence
- **View Composition**: Reusable components and proper state management
- **Relationship Management**: Proper entity relationships with cascade rules

### Technologies Used
- **SwiftUI**: Modern declarative UI framework
- **SwiftData**: Next-generation data persistence
- **iOS 17+**: Latest platform features and APIs

## Development Notes

### Future Enhancements
- Additional currency support
- Budget setting and tracking
- Data export functionality
- Advanced analytics and reporting
- Search and filtering capabilities
- Custom category creation
- Recurring transaction support
- Data backup and sync

### Current Capabilities
- Complete home group management
- Full entry and item lifecycle
- Category-based spending analysis
- Multi-currency support
- Intuitive user interface
- Robust data persistence
- Visual spending insights 