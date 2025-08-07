# Changelog

All notable changes to OMO Money will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.4.1] - 2025-08-07

### 🎨 UI/UX Improvements
- **Enhanced Filters Sheet Design**:
  - Improved contrast with medium to dark gray boxes for better visibility
  - Added subtle borders (0.5px for sections, 1px for dropdowns) for better definition
  - Updated color scheme: `systemGray6` for section backgrounds, `systemGray5` for dropdowns
  - Better visual separation between sections with consistent styling
  - Enhanced appearance on both light and dark themes
- **Category Filter Organization**:
  - Added visual separator (Divider) between "Todas" option and individual categories
  - Consistent structure with month filter dropdown
  - Better visual hierarchy and user experience
  - Clear distinction between "all categories" and specific category options

### 🔧 Technical Improvements
- **Color System Updates**:
  - Replaced `secondarySystemGroupedBackground` with `systemGray6` for better contrast
  - Added border overlays using `systemGray4` and `systemGray3` for definition
  - Consistent color scheme across all filter sections
  - Improved dark mode compatibility and visual hierarchy

### 📱 User Experience
- **Better Visual Contrast**: Gray boxes now provide proper contrast against white backgrounds
- **Consistent Design**: All filter sections now have uniform styling
- **Improved Readability**: Better visual separation between filter options
- **Enhanced Accessibility**: Better contrast ratios for improved readability

## [1.4.0] - 2025-08-07

### 🚀 Performance Optimizations
- **Instant Operations**: Eliminated all artificial delays for instant user feedback
- **Toggle Payment**: Now responds instantly like iOS Reminders app
- **Item Creation**: Removed 0.3s delay, now saves immediately
- **Item Deletion**: Instant deletion without animation delays
- **Entry Deletion**: Instant deletion without animation delays
- **Search Operations**: Optimized search performance and responsiveness
- **Database Operations**: All save operations now execute immediately

### 🎯 UX Improvements
- **Loading Indicators**: Added spinner to "Aplicar" button in filters for better feedback
- **Search Highlighting**: 
  - Magnifying glass icon for entries with matching items
  - Dynamic totals showing only matching items when search is active
  - "Filtrado" indicator in total spent widget during search
  - Visual highlighting of matching items within entries
- **Filters Sheet**: 
  - Redesigned with elegant card-style layout
  - Better organized sections (Search, Category, Period)
  - Improved visual hierarchy and spacing
  - Enhanced user experience with clear visual separation
- **Search Field**: 
  - Clear "X" button for better aesthetics
  - "Cerrar" button in keyboard toolbar for intuitive dismissal
  - Enhanced search suggestions with intelligent matching
  - Improved search performance and responsiveness

### 🔧 Technical Improvements
- **Removed Task.detached**: Eliminated unnecessary async operations
- **Removed Task.sleep**: Eliminated artificial delays (0.3s)
- **Optimized withAnimation**: Removed animations from critical operations
- **Direct Currency Passing**: Optimized currency symbol lookup
- **Immediate Save Operations**: All database operations now save instantly
- **Synchronous Operations**: Converted async operations to sync for better performance
- **Reduced Database Queries**: Optimized currency symbol access patterns

### 📱 User Experience
- **Instant Feedback**: All user actions now respond immediately
- **Smooth Interactions**: Fluid, native iOS-like experience
- **Better Visual Feedback**: Enhanced loading states and indicators
- **Intuitive Navigation**: Improved keyboard handling and dismissal
- **Native iOS Feel**: App now behaves like built-in iOS apps (Reminders, Notes)
- **Responsive Interface**: No more waiting for operations to complete

### 🐛 Bug Fixes
- **Performance Issues**: Fixed slow item creation and deletion
- **Toggle Delays**: Fixed slow payment status changes
- **Search Performance**: Improved search responsiveness after filters
- **Animation Conflicts**: Resolved animation delays affecting user interactions

## [1.4.0] - 2025-08-06

### Added
- **Intelligent Search System with Suggestions**:
  - Advanced search functionality integrated into filter sheet
  - Real-time search suggestions from existing entries and items
  - Intelligent text matching with singular/plural variations (e.g., "zanahorias" finds "zanahoria")
  - Search suggestions with entry/item type indicators
  - Debounced search to prevent excessive API calls
  - Dynamic suggestion list height based on number of results
- **Enhanced Search UX**:
  - One-tap suggestion selection that replaces text and closes list
  - Search suggestions show entry titles and item descriptions
  - Duplicate elimination (only one suggestion per unique name)
  - Case-insensitive and whitespace-normalized search
  - Search across entire group data for standardization
- **Improved Filter System**:
  - Search filter integrated with date and category filters
  - Combined filtering: search + date + category simultaneously
  - "Limpiar filtros" button resets all filters (date, category, search)
  - Filter sheet always opens in full size for better suggestion visibility
  - Enhanced filter indicators showing active search state
- **Data Standardization**:
  - Automatic whitespace trimming when creating entries and items
  - Consistent text normalization for better search results
  - Prevention of duplicate entries/items with trailing spaces
  - Improved data quality for statistics and reporting

### Changed
- **Search Architecture**:
  - Moved search from real-time to filter sheet for better performance
  - Search only activates on "Aceptar" button to reduce CPU usage
  - Eliminated real-time search that caused high CPU usage with 300+ entries
  - Improved search performance and battery life
- **Filter Sheet Design**:
  - Changed from `.medium` to `.large` detent for full visibility
  - Added search section with intelligent suggestions
  - Improved filter button indicators to show search state
  - Better visual hierarchy in filter interface
- **Empty State Messages**:
  - Simplified date filter messages to "No hay entradas para los filtros aplicados"
  - Removed verbose date-specific information from empty states
  - Updated button icons to use appropriate symbols (reset/clear instead of +)
  - Consistent empty state design across all filter combinations
- **Month Order Correction**:
  - Fixed month dropdown to start from "Enero" instead of "Diciembre"
  - Proper chronological order for better user experience
  - Consistent with Spanish date conventions

### Technical
- **SearchSuggestionsManager**:
  - ObservableObject for managing search suggestions with debounce
  - Intelligent text normalization and stemming for Spanish words
  - Duplicate elimination using case-insensitive and trimmed comparison
  - Performance optimization with configurable debounce interval
- **IntelligentSearchHelper**:
  - Text normalization with diacritic and case insensitivity
  - Spanish word variations (singular/plural, basic rules)
  - Intelligent matching algorithm for partial and exact matches
  - Whitespace handling for consistent search results
- **SearchFieldWithSuggestionsView**:
  - Reusable SwiftUI component for search with suggestions
  - Dynamic height calculation based on suggestion count
  - Proper keyboard handling and focus management
  - Clean suggestion selection with immediate text replacement
- **Data Model Improvements**:
  - Automatic whitespace trimming in entry and item creation
  - Consistent text storage for better search and statistics
  - Prevention of data inconsistencies from user input

### User Experience
- **Intelligent Search**: Find entries and items with smart text matching
- **Performance Optimized**: No more high CPU usage during search
- **Standardized Data**: Consistent naming for better statistics
- **Intuitive Filtering**: Combined search, date, and category filters
- **Better Suggestions**: Relevant search suggestions with type indicators
- **Clean Interface**: Simplified empty states and appropriate icons

### Benefits
- **Reduced CPU Usage**: Search only when needed, not in real-time
- **Better Search Results**: Intelligent matching finds more relevant items
- **Data Consistency**: Automatic cleaning prevents duplicate entries
- **Improved Performance**: Debounced search and optimized suggestions
- **Enhanced UX**: One-tap selection and immediate feedback
- **Standardized Names**: Better statistics and reporting capabilities

### Search Capabilities
- **Multi-field Search**: Search in entry titles and item descriptions
- **Intelligent Matching**: Handles singular/plural variations
- **Whitespace Normalization**: Consistent results regardless of spacing
- **Duplicate Prevention**: Only unique suggestions shown
- **Type Indicators**: Clear distinction between entries and items
- **Group-wide Search**: Suggestions from entire group for standardization

## [1.4.0] - 2025-08-05

### Added
- **Enhanced Item Creation UX**:
  - Improved user experience when creating and editing items
  - Loading indicator replaces "Guardar" button during save operations
  - Smooth transitions without layout shifts during item operations
  - Better visual feedback for save operations with progress indicator
- **Asynchronous Item Operations**:
  - Non-blocking item creation and editing with async/await
  - Immediate sheet closure after successful save operations
  - Form fields are disabled during save operations to prevent conflicts
  - Proper error handling for database operations

### Changed
- **Item Creation Flow**:
  - Eliminated the jarring experience of fields clearing before sheet closure
  - Sheet now closes immediately after save operation starts
  - Form reset happens after sheet dismissal for smoother UX
  - Loading state prevents multiple save attempts
- **Save Button Behavior**:
  - "Guardar" button is completely replaced by loading indicator during save
  - No more layout shifts or button movement during operations
  - Consistent button positioning and visual stability
  - Clear visual feedback for operation status
- **Form State Management**:
  - Form fields are disabled during save operations
  - Keyboard navigation is disabled during save
  - Cancel button is disabled during save operations
  - Better state isolation during async operations

### Technical
- **Async/Await Implementation**:
  - Converted item save operations to use async/await pattern
  - Added `@MainActor` for proper UI updates
  - Implemented `Task.detached` for database operations
  - Added artificial delay (0.3s) for better UX feedback
- **State Management**:
  - Added `@State private var isSavingItem: Bool` for loading state
  - Proper state reset after sheet dismissal
  - Enhanced form validation during save operations
  - Better error handling and user feedback
- **UI Component Updates**:
  - Updated `AddItemSheet` to support loading state
  - Enhanced toolbar with conditional loading indicator
  - Improved form field accessibility during operations
  - Better visual hierarchy during save operations

### User Experience
- **Smooth Item Creation**: No more jarring field clearing before sheet closure
- **Clear Visual Feedback**: Loading indicator shows operation progress
- **Stable Interface**: No layout shifts or button movement during operations
- **Immediate Response**: Sheet closes instantly after save operation starts
- **Better Error Handling**: Proper feedback for failed operations
- **Consistent Behavior**: Same smooth experience for both create and edit operations

### Benefits
- **Professional Feel**: Smooth, polished user experience
- **Reduced Confusion**: Clear visual feedback for all operations
- **Better Performance**: Non-blocking operations with proper async handling
- **Stable Interface**: No more jarring visual changes during operations
- **Enhanced Reliability**: Proper error handling and state management
- **Improved Accessibility**: Better support for users with different needs

## [1.4.0] - 2025-08-04

### Added
- **Navigation Form System**:
  - New navigation-based form interface for better user experience
  - Step-by-step entry creation process with clear progression
  - Form validation with real-time feedback
  - Improved form accessibility and keyboard navigation
- **Detailed Entry View**:
  - Enhanced entry detail view with comprehensive information display
  - Better visual hierarchy for entry information
  - Improved item listing and management within entries
  - Enhanced editing capabilities for entry details
- **Enhanced Form Validation**:
  - Real-time validation feedback during form completion
  - Clear error messages and visual indicators
  - Improved user guidance through form completion process
  - Better handling of required vs optional fields
- **Smart Advanced Options Behavior**:
  - Advanced options are now always visible when editing entries
  - Collapsible behavior only applies when creating new entries
  - All fields (date, category, group, type) are directly accessible when editing
  - Improved user experience for entry modification

### Changed
- **Form Navigation Flow**:
  - Replaced modal sheet with navigation-based form interface
  - Improved form progression with clear step indicators
  - Better keyboard handling and focus management
  - Enhanced accessibility for form interactions
- **Entry Detail Interface**:
  - Redesigned entry detail view for better information display
  - Improved layout and spacing for entry information
  - Enhanced visual feedback for entry status and details
  - Better integration with item management features
- **User Experience Improvements**:
  - Smoother transitions between form steps
  - Better visual feedback for form completion status
  - Improved error handling and user guidance
  - Enhanced overall form usability
- **Advanced Options UX**:
  - Collapsible advanced options only for new entry creation
  - Direct field access when editing existing entries
  - Cleaner interface for entry modification
  - Better distinction between creation and editing workflows

### Technical
- **Navigation Architecture**:
  - Implemented NavigationStack for form progression
  - Enhanced state management for multi-step forms
  - Improved form validation and error handling
  - Better keyboard and accessibility support
- **Detail View Enhancements**:
  - Redesigned entry detail view architecture
  - Improved data display and interaction patterns
  - Enhanced item management within entries
  - Better visual hierarchy and information organization
- **Form Validation System**:
  - Real-time validation with immediate feedback
  - Enhanced error message display and handling
  - Improved form completion tracking
  - Better user guidance through validation process
- **Conditional UI Logic**:
  - Advanced options visibility based on `isEditing` state
  - Different styling for creation vs editing modes
  - Improved form layout management
  - Better state handling for different form contexts

### User Experience
- **Intuitive Form Flow**: Clear step-by-step progression through entry creation
- **Enhanced Detail View**: Better organization and display of entry information
- **Improved Validation**: Real-time feedback and clear error messages
- **Better Accessibility**: Enhanced keyboard navigation and screen reader support
- **Smoother Interactions**: Improved transitions and visual feedback
- **Smart Advanced Options**: Context-aware behavior for creation vs editing

### Benefits
- **Better Form Experience**: Navigation-based forms are more intuitive and accessible
- **Enhanced Detail View**: Clearer presentation of entry information
- **Improved Validation**: Users get immediate feedback on form completion
- **Better Accessibility**: Enhanced support for users with accessibility needs
- **Professional Interface**: More polished and user-friendly form interactions
- **Optimized Editing**: Direct access to all fields when modifying entries

## [1.4.0] - 2025-08-01

### Added
- **User Management System**:
  - New `User` entity with name, email, and creation date
  - User authentication and identification system
  - Support for multiple users in the same app instance
  - User-specific group access and permissions
- **HomeGroupUser Relationship Entity**:
  - Intermediate entity linking users to home groups
  - `dateJoined` property to track when user joined a group
  - `isAdmin` property for permission management
  - Foundation for future collaboration features
- **Enhanced Data Architecture**:
  - Separated entities into individual Swift files for better organization
  - `User.swift` - User management entity
  - `HomeGroup.swift` - Home group entity with user relationships
  - `HomeGroupUser.swift` - User-group relationship entity
  - `Entry.swift` - Entry entity (simplified)
  - `Item.swift` - Item entity (simplified)
  - `Enums.swift` - Centralized enumerations
- **Permission System Foundation**:
  - Admin permissions for group creators
  - User-group relationship tracking
  - Date-based membership tracking
  - Scalable architecture for future collaboration features

### Changed
- **Data Model Restructuring**:
  - Moved from single `Entry.swift` file to modular entity structure
  - Enhanced `HomeGroup` entity with `homeGroupUsers` relationship
  - Updated `User` entity with `homeGroupUsers` relationship
  - Improved data organization and maintainability
- **User Interface Updates**:
  - Group selection now filters based on user membership
  - Only shows groups that the current user belongs to
  - Automatic user association when creating new groups
  - User-specific data isolation and access control
- **Entity Relationships**:
  - User ↔ HomeGroupUser ↔ HomeGroup (many-to-many through intermediate)
  - HomeGroup → Entry (one-to-many)
  - Entry → Item (one-to-many)
  - Proper cascade deletion rules for data integrity

### Technical
- **SwiftData Architecture**:
  - Modular entity structure with separate files
  - Proper relationship management with intermediate entities
  - Enhanced query optimization for user-specific data
  - Improved data model scalability
- **User Management**:
  - Automatic user creation and group association
  - User-specific group filtering and access control
  - Admin permission assignment for group creators
  - Foundation for multi-user collaboration
- **Data Integrity**:
  - Proper cascade deletion rules
  - Relationship validation and consistency
  - User data isolation and security
  - Scalable permission system architecture

### Features
- **Multi-User Support**: Foundation for multiple users in the same app
- **Permission Management**: Admin rights for group creators
- **User-Group Relationships**: Track membership and join dates
- **Data Isolation**: Users only see their associated groups
- **Collaboration Ready**: Architecture prepared for future sharing features
- **Modular Code**: Better organization and maintainability

### User Experience
- **Personalized Interface**: Users only see their relevant groups
- **Automatic Setup**: New groups are automatically associated with the creator
- **Clean Organization**: Better code structure and maintainability
- **Future-Ready**: Foundation for collaboration and sharing features

### Architecture Improvements
- **Modular Design**: Separated entities into individual files
- **Relationship Management**: Proper many-to-many relationships through intermediate entities
- **Permission System**: Scalable admin and user permission framework
- **Data Isolation**: User-specific data access and filtering
- **Collaboration Foundation**: Ready for future multi-user features

### Benefits
- **Better Code Organization**: Modular entity structure
- **Scalable Architecture**: Foundation for future features
- **User Data Security**: Proper isolation and access control
- **Collaboration Ready**: Prepared for sharing and team features
- **Maintainable Code**: Cleaner, more organized codebase

## [1.3.1] - 2025-07-30

### Added
- **Payment Status Icons**:
  - Visual indicators for entry payment status in entry rows
  - Green checkmark (✅) for fully paid entries
  - Orange triangle (⚠️) for entries with pending payments
  - Orange circle (🟠) for partially paid entries
  - Icons positioned next to category badges for better visual integration
- **Enhanced Payment Status Display**:
  - Clear distinction between paid and unpaid items
  - Shows total paid amount and pending amounts separately
  - "Items pendientes" label for unpaid items with 0.00 price
  - Consistent color coding: green for paid, orange for pending

### Changed
- **Entry Row Layout**:
  - Payment status icons moved next to category badges
  - Smaller icon size (caption) for better visual balance
  - No icons shown when entry has no items (cleaner interface)
  - Better visual hierarchy with grouped status indicators
- **Payment Status Logic**:
  - Optional `payed` property to handle existing data without payment status
  - Backward compatibility with items that don't have payment information
  - Default behavior treats items without payment status as pending
  - Improved handling of items with 0.00 price
- **Total Amount Display**:
  - Always shows price for paid items (even if 0.00)
  - Separate display for paid and pending amounts
  - Clear visual distinction between payment status and monetary value
  - Consistent formatting across all entry types

### Technical
- **Data Model Updates**:
  - Changed `payed` property from `Bool` to `Bool?` for backward compatibility
  - Updated all payment status checks to handle optional values
  - Maintained existing data integrity while adding new functionality
- **Payment Status Computation**:
  - Enhanced `paymentStatus` computed property with clear logic
  - Proper handling of items with `nil` payment status
  - Consistent icon and color assignment based on payment state
- **UI Component Updates**:
  - Added `paymentStatusIconSmall` for compact display
  - Conditional icon display based on item presence
  - Improved visual integration with existing category badges

### User Experience
- **Visual Payment Tracking**: Clear indicators for payment status at a glance
- **Consistent Interface**: Payment icons integrate seamlessly with existing design
- **Backward Compatibility**: Existing data works without issues
- **Clean Layout**: No unnecessary icons when entries have no items
- **Clear Information**: Distinction between payment status and monetary amounts

### Benefits
- **Quick Status Assessment**: Instantly see which entries are paid or pending
- **Better Organization**: Visual grouping of related information
- **Data Safety**: Existing data remains intact and functional
- **Improved Clarity**: Clear separation between payment status and amounts
- **Enhanced Workflow**: Better visual feedback for payment management

## [1.3.0] - 2025-07-30

### Added
- **Advanced Options Collapsible Section**:
  - Moved date, category, group, and type fields into collapsible "Opciones Avanzadas" section
  - Reduces form complexity and makes entry creation less overwhelming
  - Smooth animation when expanding/collapsing advanced options
  - Gear icon with chevron indicator for intuitive interaction
- **Simplified Entry Form**:
  - Main form now only shows essential fields: description and price
  - Advanced options are hidden by default but easily accessible
  - Better focus on primary information needed for quick entry creation
  - Improved user experience for frequent entry creation

### Changed
- **Form Layout Restructuring**:
  - Date selection moved to advanced options section
  - Category selection moved to advanced options section
  - Home group selection moved to advanced options section
  - Entry type selection moved to advanced options section
  - Main form now focuses on description and optional price
- **Advanced Options Design**:
  - Collapsible section with gear icon and "Opciones Avanzadas" label
  - Smooth expand/collapse animation with `.easeInOut(duration: 0.3)`
  - Visual chevron indicator showing expand/collapse state
  - Subtle background color for expanded content area
- **Default Values**:
  - Date defaults to current date
  - Category defaults to "otros" (other)
  - Group defaults to current group
  - Type defaults to "gasto" (expense)

### Technical
- **State Management**:
  - Added `@State private var showAdvancedOptions: Bool = false` for collapsible section
  - Maintained all existing functionality while reorganizing UI
  - Proper animation timing for smooth user experience
- **UI Architecture**:
  - Restructured AddEntrySheet to separate essential and advanced fields
  - Maintained all existing validation and interaction logic
  - Preserved keyboard navigation and focus management
- **User Experience**:
  - Reduced cognitive load for new entry creation
  - Maintained full functionality for power users
  - Better balance between simplicity and advanced features

### User Experience
- **Simplified Workflow**: Quick entry creation with essential fields only
- **Advanced Access**: Full customization available when needed
- **Visual Clarity**: Clear separation between basic and advanced options
- **Smooth Interactions**: Animated transitions for better feedback
- **Intuitive Design**: Gear icon clearly indicates advanced functionality

### Benefits
- **Faster Entry Creation**: Users can quickly add entries with minimal input
- **Reduced Overwhelm**: Less visual clutter in the main form
- **Flexible Usage**: Advanced users can still access all customization options
- **Better Onboarding**: New users see a simpler, less intimidating interface
- **Maintained Functionality**: All existing features remain fully accessible

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