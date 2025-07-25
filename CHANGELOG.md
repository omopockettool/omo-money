# Changelog

All notable changes to OMO Money will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2025-07-25

### Added
- **Advanced Search Functionality**:
  - Integrated search field directly in main interface (no sheet)
  - Real-time search across entries and items
  - Search in entry titles, categories, and item descriptions
  - Case-insensitive search with whitespace trimming
  - Search button positioned on the right side of the interface
  - Auto-focus and keyboard activation when search is activated
- **Enhanced Group Management**:
  - Confirmation alert when deleting home groups
  - Custom alert with group name: "¿Estás seguro de eliminar [Group Name]?"
  - Delete button in red, Cancel button in gray
  - Tap selected group to close management sheet
  - Improved visual feedback with trash icon button
- **Improved Date Formatting**:
  - Updated date headers in entry list with bullet separator
  - Format: "15 Jul 2025 • 3" (date • count)
  - Consistent bullet formatting across the app
  - Better visual separation between date and entry count

### Changed
- **Search Implementation**:
  - Replaced search sheet with integrated search field
  - Search field appears/disappears with smooth animation
  - Magnifying glass icon moves to right side of search field
  - Search button changes to X when active with red background
  - Auto-clear search when deactivating search mode
- **Group Management UX**:
  - Removed swipe-to-delete (caused visual glitches)
  - Added dedicated trash button for each group
  - Confirmation required before group deletion
  - Double-tap selected group to confirm and close sheet
- **Search Results Handling**:
  - Different messages for "no search results" vs "no entries in group"
  - Search results message: "No hay entries o items que coincidan con '[search term]'"
  - Clear search button when no results found
  - Maintains compatibility with existing filters

### Technical
- **Search Architecture**:
  - `@State private var isSearchActive: Bool` for search field visibility
  - `@FocusState private var isSearchFieldFocused: Bool` for keyboard control
  - Enhanced `filteredEntries` computed property with search logic
  - Whitespace trimming: `searchText.trimmingCharacters(in: .whitespacesAndNewlines)`
  - Search across multiple fields: title, category, and item descriptions
- **Group Management**:
  - `@State private var showingDeleteAlert: Bool` for confirmation alerts
  - `@State private var groupsToDelete: [HomeGroup]` for deletion tracking
  - Custom alert implementation with dynamic group names
  - Proper state management for group selection and deletion
- **UI Improvements**:
  - Smooth animations with `.easeInOut(duration: 0.3)`
  - Transition effects: `.move(edge: .top).combined(with: .opacity)`
  - Improved button styling with conditional backgrounds
  - Better visual hierarchy and spacing

### Features
- **Smart Search**: Find entries and items instantly as you type
- **Flexible Search**: Search across titles, categories, and item descriptions
- **Safe Group Deletion**: Confirmation alerts prevent accidental deletions
- **Improved Navigation**: Double-tap to confirm group selection
- **Better Visual Feedback**: Clear indicators for active states

### User Experience
- **Intuitive Search**: Integrated search field with auto-focus
- **Safe Operations**: Confirmation dialogs for destructive actions
- **Visual Clarity**: Better date formatting and visual separators
- **Responsive Interface**: Real-time search results and smooth animations
- **Consistent Design**: Unified bullet formatting across the app

### Search Capabilities
- **Multi-field Search**: Search in entry titles, categories, and item descriptions
- **Case-insensitive**: No distinction between uppercase and lowercase
- **Whitespace Handling**: Automatic trimming of leading/trailing spaces
- **Real-time Results**: Instant filtering as you type
- **Filter Compatibility**: Works with existing date and category filters

## [1.2.0] - 2025-07-24

### Added
- **App Sharing Functionality**:
  - New "Compartir OMO Money" section in app info
  - Native iOS sharing sheet integration
  - Share app description and download link via WhatsApp, Messages, Email, etc.
  - Custom sharing message with app description and App Store link
  - ShareSheet component using UIActivityViewController
- **Enhanced App Information**:
  - Reorganized AppInfoSheet with clear section separation
  - Improved visual layout with proper dividers covering full width
  - Better section organization: App Title, About, Donations, Share, Ecosystem, Contact
  - Updated app description to "herramienta de bolsillo"
- **Improved UI Structure**:
  - Each section now in separate VStack for better organization
  - Consistent padding and spacing between sections
  - Full-width dividers between sections
  - Better visual hierarchy and readability

### Changed
- **AppInfoSheet Layout**:
  - Restructured into 6 distinct sections with proper separation
  - Section 1: App Icon and Title
  - Section 2: About OMO Money (updated description)
  - Section 3: Donations (¿Te gusta OMO Money?)
  - Section 4: Share App (new section)
  - Section 5: OMO Ecosystem
  - Section 6: Contact, Developer signature, and Version
- **Sharing Implementation**:
  - Simplified ShareSheet component for better performance
  - Removed unnecessary activity type exclusions
  - Optimized for iPhone and iPad compatibility
  - Clean sharing message with emoji and proper formatting

### Technical
- **ShareSheet Component**:
  - UIViewControllerRepresentable implementation
  - UIActivityViewController integration
  - iPad popover configuration
  - Proper state management with @State variables
- **App Info Architecture**:
  - Modular section-based layout
  - Consistent spacing and padding system
  - Proper divider implementation
  - State management for sharing functionality

### Features
- **Native App Sharing**: Share OMO Money via any installed app
- **WhatsApp Integration**: Direct sharing to WhatsApp contacts
- **Multi-Platform Sharing**: Support for Messages, Email, Social Media, etc.
- **Professional App Info**: Well-organized information sections
- **Developer Recognition**: "Con 🤍 Dennis" signature section
- **Ecosystem Promotion**: Link to OMO Pocket Tool catalog

### User Experience
- **Easy App Sharing**: One-tap sharing with native iOS interface
- **Clear Information Structure**: Well-organized app information
- **Professional Presentation**: Clean, modern app info layout
- **Social Sharing**: Encourage app adoption through easy sharing
- **Developer Connection**: Personal touch with developer signature

### Social Features
- **Viral Sharing**: Easy way to share app with friends and family
- **Professional Messaging**: Pre-formatted sharing message
- **App Store Integration**: Direct link to download page
- **Community Building**: Encourage user adoption and feedback

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