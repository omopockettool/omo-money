# Changelog

All notable changes to OMO Money will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.4] - 2025-07-30

### Added
- **Enhanced Date Selection UX**:
  - Two-step date confirmation system for better user control
  - "Confirmar fecha" button appears after selecting a date
  - Prevents accidental date selection and widget closure
  - Clear visual feedback when date is selected but not confirmed
- **Improved Dark Mode Support**:
  - Consistent color scheme across all UI elements
  - Proper contrast for all interactive elements in dark mode
  - Unified background colors using `secondarySystemGroupedBackground`

### Changed
- **Widget Background Consistency**:
  - Total Gastado widget now uses `secondarySystemGroupedBackground`
  - Consistent appearance in both light and dark modes
  - Matches the visual style of list items
- **Interactive Elements Styling**:
  - Dropdown de Grupo uses `secondarySystemGroupedBackground`
  - Filtros button uses `secondarySystemGroupedBackground`
  - Search button uses `secondarySystemGroupedBackground`
  - All buttons now have consistent background colors
- **Search Field Visibility**:
  - Search field background changed to `systemBackground`
  - Better contrast against the main background
  - Clear visual distinction when search is active
- **Date Picker Interaction**:
  - Removed automatic closure on date selection
  - Added confirmation step to prevent accidental closures
  - Better handling of month/year navigation without closing widget

### Technical
- **Color System Updates**:
  - Replaced `systemGray6` with `secondarySystemGroupedBackground` for consistency
  - Updated search field to use `systemBackground` for better visibility
  - Unified color scheme across all interactive elements
- **Date Selection Logic**:
  - Added `@State private var dateSelected: Bool` for tracking selection state
  - Implemented confirmation button instead of automatic closure
  - Better state management for date picker interactions
- **UI Consistency**:
  - All dropdowns and buttons now use the same background color
  - Consistent visual hierarchy across the entire interface
  - Improved dark mode compatibility

### User Experience
- **Consistent Visual Design**: All interactive elements have the same appearance
- **Better Dark Mode**: Proper contrast and visibility in dark mode
- **Controlled Date Selection**: No more accidental date picker closures
- **Clear Visual Feedback**: Search field is clearly distinguishable
- **Unified Interface**: Consistent styling across all UI components

## [1.2.2] - 2025-07-30

### Changed
- **Search Button Styling**:
  - Changed search button background from red to gray when active
  - Updated search button icon color to gray when active
  - More subtle visual feedback for active search state
  - Consistent with overall app color scheme

### Technical
- **Color Updates**:
  - Search button active state: `Color.gray.opacity(0.1)` instead of red
  - Search button icon: `.gray` color when active instead of primary
  - Better visual consistency with other UI elements

## [1.2.1] - 2025-07-30

### Changed
- **Widget Background Fix**:
  - Fixed Total Gastado widget visibility in dark mode
  - Changed from `systemBackground` to `secondarySystemGroupedBackground`
  - Ensures widget is visible in both light and dark modes
  - Matches the background color of list items

### Technical
- **Dark Mode Compatibility**:
  - Widget now uses the same background as list items
  - Consistent appearance across all themes
  - Proper contrast in both light and dark modes

## [1.2.1] - 2025-07-26

### Added
- **Optional Price for Items**:
  - Items can now be created without specifying a price
  - Price field is now optional in AddItemSheet
  - Items without price display "Sin precio" instead of $0.00
  - Improved UX for items that don't require pricing
- **Enhanced Entry Listing Layout**:
  - Fixed spacing issues between navigation bar and controls row
  - Eliminated white space when search returns no results
  - Consistent layout behavior with/without keyboard open
  - Improved visual consistency across all app states
  - Added Spacer() to maintain content alignment when no entries are listed

### Changed
- **Item Creation Flow**:
  - Price field is now clearly marked as optional
  - Better validation for items without prices
  - Improved user feedback for optional pricing
- **Layout Consistency**:
  - VStack(spacing: 0) for main container to control spacing manually
  - Consistent padding for controls row (8pt top/bottom)
  - Fixed layout behavior when keyboard opens/closes
  - Eliminated unwanted white space in various app states

### Technical
- **Layout Improvements**:
  - Added Spacer() to VStack when no entries are listed
  - Manual spacing control instead of automatic VStack spacing
  - Consistent padding values across interface elements
  - Fixed keyboard interaction with layout stability

## [1.2.0] - 2025-07-25
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