# Changelog

All notable changes to OMO Money will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-07-21

### Added
- **Advanced Filtering System**:
  - Date filter with month/year selection (1970 to current year)
  - Category filter with all predefined categories plus "Todas" option
  - Combined filtering: filter by date AND category simultaneously
  - "Todos los meses" option to view entire year data
  - Filter sheet with intuitive dropdown interface
- **Enhanced Filter Controls**:
  - Dedicated filter button with visual indicators
  - "Restaurar" button to reset filters to current month/year
  - "Aceptar" button to apply selected filters
  - Real-time filter status display in filter button
- **Improved Widget Design**:
  - Redesigned Total Gastado widget with modern styling
  - Integrated quick action button for adding entries
  - Better visual hierarchy with improved typography
  - Shadow effects and rounded corners for modern look
- **Smart Filter Indicators**:
  - Visual feedback showing active filters
  - Date format: "Ene 2025" or "2025" for year view
  - Category display: "Comida", "Hogar", etc.
  - Combined indicators: "Ene 2025 • Comida"

### Changed
- **Navigation Layout**:
  - Changed title display mode from `.large` to `.inline` for better space utilization
  - Reduced header padding for more compact layout
  - Removed duplicate "+" button from header (now in widget)
- **Filter Logic**:
  - Enhanced `filteredEntries` to support both date and category filtering
  - Improved date range calculations for month and year views
  - Added helper functions for category name conversion
- **Widget Functionality**:
  - Total Gastado widget now shows even when no entries exist
  - Integrated entry creation directly in the widget
  - Better visual feedback for empty states

### Technical
- **Filter Architecture**:
  - Added `selectedCategory` and `tempSelectedCategory` state variables
  - Implemented `getCategoryRawValue()` helper function for category conversion
  - Enhanced `filteredEntries` computed property with dual filtering
  - Added `showAllMonths` state for year-wide filtering
- **UI Components**:
  - Created `FiltersSheet` component with comprehensive filter controls
  - Implemented proper state management for temporary filter values
  - Added visual indicators for active filter status
- **Data Processing**:
  - Improved date filtering with proper calendar calculations
  - Enhanced category filtering with display name to raw value conversion
  - Optimized filter performance with computed properties

### Features
- **Multi-Dimensional Filtering**: Filter by date range AND category simultaneously
- **Flexible Date Selection**: Choose specific month/year or entire year
- **Category-Specific Views**: View spending for specific categories
- **Quick Filter Reset**: One-tap reset to current month/year
- **Visual Filter Status**: Always know what filters are active
- **Enhanced Widget**: More functional and visually appealing total display
- **Improved Navigation**: Better space utilization and cleaner layout

### User Experience
- **Intuitive Filtering**: Easy-to-use dropdown interface for all filters
- **Immediate Feedback**: Visual indicators show active filters instantly
- **Quick Actions**: Add entries directly from the total widget
- **Flexible Views**: Switch between monthly and yearly perspectives
- **Clean Interface**: Modern design with better visual hierarchy
- **Efficient Navigation**: Optimized layout with better space usage

## [1.0.0] - 2025-07-15

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