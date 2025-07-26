# OMO Money

A pocket tool designed to help you manage your personal expenses in a simple and efficient way. Organize your expenses by groups, categories, and dates to have total control over your finances.

**Current version: 1.2.1**

## 💰 Main Features

### 📊 Group Management
- **Multiple expense groups**: Organize your finances by different contexts (personal, work, home, etc.)
- **Custom currencies**: Support for USD and EUR with automatic symbols
- **Safe management**: Confirmation before deleting groups

### 🔍 Advanced Search
- **Real-time search**: Find entries and items instantly
- **Multi-field search**: Search in titles, categories, and item descriptions
- **Smart filters**: Combine search with date and category filters
- **Integrated interface**: Search field directly in the main interface

### 📝 Entries and Items
- **Entries**: Organize your expenses in entries with title, date, and category
- **Optional items**: Add detailed items to each entry (optional pricing)
- **Predefined categories**: Food, Home, Health, Entertainment, Transport, Others
- **Transaction types**: Expenses (red) and income (green)

### 📅 Filters and Organization
- **Date filters**: Specific month or all months of the year
- **Category filters**: Filter by specific category or all
- **Date grouping**: Entries organized chronologically
- **Category statistics**: Visualization of expenses by category

### 🎨 Modern Interface
- **Clean design**: Intuitive and easy-to-use interface
- **Smooth animations**: Fluid transitions between states
- **Consistent layout**: Uniform spacing in all states
- **Responsive**: Adaptable to different screen sizes

## 📱 Screenshots

*Screenshots will be added here*

## 🚀 Getting Started

### Prerequisites

- Xcode 15.0+
- iOS 17.0+
- macOS 14.0+ (for development)

### Installation

1. Clone the repository
```bash
git clone https://github.com/omoconcept/omo-money.git
cd omo-money
```

2. Open the project in Xcode
```bash
open "omo-money.xcodeproj"
```

3. Build and run the project
- Select your target device or simulator
- Press `Cmd + R` to build and run

## 🏗️ Architecture

- **Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Pattern**: MVVM (Model-View-ViewModel)
- **Minimum iOS Version**: 17.0

### Project Structure

```
OMO Money/
├── omo-money/
│   ├── ContentView.swift          # Main app interface
│   ├── OmoMoneyApp.swift          # App entry point
│   ├── Entry.swift                # Data models (HomeGroup, Entry, Item)
│   ├── omo-money.entitlements     # Permissions configuration
│   └── Assets.xcassets/           # App assets
├── omo-moneyTests/
│   └── omo_moneyTests.swift       # Unit tests
└── omo-moneyUITests/              # UI tests
```

## 🗄️ Data Model

The app uses SwiftData for local persistence with a hierarchical model:

### HomeGroup
- `id`: Unique identifier (UUID)
- `name`: Group name
- `currency`: Currency code (USD, EUR)
- `createdAt`: Creation date
- `entries`: Relationship with entries (cascade deletion)

### Entry
- `id`: Unique identifier (UUID)
- `title`: Entry title
- `date`: Entry date
- `category`: Category (food, home, health, etc.)
- `type`: Type (false = expense, true = income)
- `homeGroupId`: ID of the group it belongs to

### Item
- `id`: Unique identifier (UUID)
- `money`: Amount (optional, can be 0)
- `amount`: Item quantity (optional)
- `itemDescription`: Item description
- `entryId`: ID of the entry it belongs to

### Support Enums
- **EntryCategory**: Predefined categories with display names
- **Currency**: Supported currencies with symbols

## 🧪 Testing

Run the test suite:

```bash
# Run all tests
xcodebuild test -scheme "omo-money" -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test file
xcodebuild test -scheme "omo-money" -only-testing:omo-moneyTests/omo_moneyTests
```

## 📦 Build & Deploy

### Development Build
```bash
xcodebuild build -scheme "omo-money" -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Archive for App Store
```bash
xcodebuild archive -scheme "omo-money" -archivePath build/omo-money.xcarchive
```

## 🔧 Configuration

### SwiftData Model
The app uses SwiftData for local persistence with a hierarchical model:
- `HomeGroup`: Expense groups with currency
- `Entry`: Main entries with category and type
- `Item`: Detailed items with optional pricing

### Bundle Identifier
- **Bundle ID**: `com.omo.OMO-Money`
- **Team**: Configured for Apple Developer distribution

### Color Scheme
- **Primary**: Red (#FF3B30) for expenses
- **Secondary**: Green (#34C759) for income
- **Categories**: Specific colors per category
- **Text**: System colors for readability
- **Background**: System background colors

## 📈 Roadmap

### Version 1.2.1 (Current)
- [x] Optional pricing for items
- [x] Improved entry listing layout
- [x] Integrated advanced search
- [x] Group management with confirmation
- [x] Date and category filters
- [x] Category statistics

### Version 1.3.0 (Next)
- [ ] Data export
- [ ] Notifications and reminders
- [ ] Recurring transactions
- [ ] Financial goals
- [ ] Cloud synchronization

### Future Features
- [ ] Multiple currency support
- [ ] Receipt photo attachment
- [ ] Advanced analytics and charts
- [ ] Category budgets
- [ ] Bank integration

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Development

### Code Style
- Follow Swift API Design Guidelines
- Use SwiftUI best practices
- Maintain consistent naming conventions
- Add comments for complex logic

### Git Workflow
- Use conventional commits
- Create feature branches for new functionality
- Write descriptive commit messages
- Keep commits atomic and focused

## 📞 Support

- **Email**: omopockettool@gmail.com
- **Issues**: [GitHub Issues](https://github.com/omoconcept/omo-money/issues)
- **Documentation**: [Wiki](https://github.com/omoconcept/omo-money/wiki)

## 🙏 Acknowledgments

- Built with ❤️ using SwiftUI and SwiftData
- Inspired by the need for simple financial tracking
- Thanks to all contributors and beta testers

---

**OMO Money** - Do it your way with OMO 💰 