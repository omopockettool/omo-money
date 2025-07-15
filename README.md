# OMO Money

A simple and intuitive money tracking app built with SwiftUI and SwiftData, designed to help users quickly record expenses and income for better financial control.

## 💰 Features

- **Quick Expense Tracking**: Record expenses with amount, description, and category
- **Income Management**: Track income sources and amounts
- **Category System**: Organize transactions with custom categories
- **Date Tracking**: Keep track of when each transaction occurred
- **Clean Interface**: Modern, intuitive design optimized for iOS
- **Data Persistence**: Secure local storage using SwiftData
- **Edit & Delete**: Full CRUD operations for transaction management
- **Transaction History**: View all your financial activity in chronological order

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
│   ├── omo_moneyApp.swift         # App entry point
│   ├── Item.swift                 # Transaction data model
│   └── Assets.xcassets/           # App assets
├── omo-moneyTests/
│   └── omo_moneyTests.swift       # Unit tests
└── omo-moneyUITests/              # UI tests
```

## 🗄️ Data Model

The app uses SwiftData for local data persistence with a simple transaction model:

### Transaction Entity (Item)
- `id`: Unique identifier (UUID)
- `timestamp`: Date and time of the transaction
- `amount`: Transaction amount (positive for income, negative for expenses)
- `description`: Description of the transaction
- `category`: Transaction category (food, transport, entertainment, etc.)
- `type`: Transaction type (income or expense)

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
The app uses SwiftData for local data persistence with a transaction model:
- `Item`: Core transaction data with amount, description, and category

### Bundle Identifier
- **Bundle ID**: `com.omo.OMO-Money`
- **Team**: Configured for Apple Developer distribution

### Color Scheme
- **Primary**: Green (#34D399) for financial theme
- **Expense Colors**: Red tones for expenses
- **Income Colors**: Green tones for income
- **Text**: System colors for readability
- **Background**: System background colors

## 📈 Roadmap

### Version 0.1.0 (Current)
- [x] Basic transaction recording
- [x] Income and expense tracking
- [x] Category system
- [x] Date tracking
- [x] Clean interface

### Version 0.2.0 (Next Release)
- [ ] Transaction statistics and analytics
- [ ] Budget setting and tracking
- [ ] Export functionality
- [ ] Custom categories
- [ ] Search and filtering

### Future Features
- [ ] Cloud sync
- [ ] Recurring transactions
- [ ] Financial goals tracking
- [ ] Notifications and reminders
- [ ] Multiple currency support
- [ ] Receipt photo attachment

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

**OMO Money** - Take control of your finances with simplicity 💰 