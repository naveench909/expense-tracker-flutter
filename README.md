# Expense Tracker - Flutter

A beautiful, offline-first personal expense tracking application built with Flutter. Track your daily expenses, categorize spending, and gain insights into your financial habits - all stored securely on your device.

## Features

### Core Functionality
- **Add Transactions**: Log expenses with amount, merchant, date, category, payment method, and optional notes
- **Edit & Delete**: Modify or remove transactions with swipe gestures
- **Search & Filter**: Find transactions by merchant name, category, or payment method
- **Offline First**: All data stored locally using SQLite - works without internet connection

### Analytics & Insights
- **Monthly Summary**: View total spending for current or past months
- **Category Breakdown**: Visual breakdown of spending by category with percentages
- **Recent Transactions**: Quick view of latest expenses on home screen
- **Statistics**: Track transaction count and average spending per transaction

### Categories
- **8 Default Categories**: Food & Dining, Transportation, Shopping, Bills & Utilities, Entertainment, Healthcare, Education, Others
- **Custom Categories**: Create your own categories with custom icons and colors
- **Category Management**: Edit and delete custom categories (default categories are protected)

### Payment Methods
Track expenses across multiple payment types:
- Cash
- Card
- UPI
- Net Banking

### User Experience
- **Material Design 3**: Modern, beautiful UI with smooth animations
- **Pull to Refresh**: Update data with a simple gesture
- **Swipe to Delete**: Quick transaction deletion with confirmation
- **Empty States**: Helpful guidance when no data is available
- **Loading Indicators**: Clear feedback during data operations

## Tech Stack

- **Framework**: Flutter 3.11.5+
- **Language**: Dart
- **Database**: SQLite (via sqflite)
- **State Management**: Provider
- **Date Formatting**: intl package
- **Architecture**: Clean Architecture with separation of concerns

## Project Structure

```
lib/
├── main.dart                          # App entry point with providers
├── models/
│   ├── category.dart                  # Category data model
│   └── transaction.dart               # Transaction data model
├── services/
│   └── database_service.dart          # SQLite database operations
├── providers/
│   ├── category_provider.dart         # Category state management
│   └── transaction_provider.dart      # Transaction state management
├── screens/
│   ├── home_screen.dart               # Dashboard with summary
│   ├── add_transaction_screen.dart    # Add/Edit transaction form
│   ├── transaction_list_screen.dart   # All transactions with filters
│   ├── monthly_summary_screen.dart    # Monthly spending overview
│   ├── category_breakdown_screen.dart # Spending by category
│   └── manage_categories_screen.dart  # Custom category management
├── widgets/
│   └── transaction_card.dart          # Reusable transaction list item
└── utils/
    └── constants.dart                 # App constants and helpers
```

## Installation

### Prerequisites
- Flutter SDK (3.11.5 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android Emulator or iOS Simulator (or physical device)

### Steps

1. **Clone the repository**
```bash
git clone https://github.com/naveench909/expense-tracker-flutter.git
cd expense-tracker-flutter
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
# For Android
flutter run

# For iOS (macOS only)
flutter run -d ios

# For Web
flutter run -d chrome
```

## Usage

### Adding a Transaction
1. Tap the "Add Transaction" floating button on the home screen
2. Fill in the transaction details:
   - Amount (required)
   - Merchant/Description (required)
   - Date (defaults to today)
   - Category (required)
   - Payment Method (required)
   - Notes (optional)
3. Tap "Add Transaction" to save

### Viewing Transactions
- **Home Screen**: See recent 5 transactions and current month total
- **All Transactions**: Tap "View All" to see complete transaction list
- **Search**: Use the search bar to find transactions by merchant name
- **Filter**: Filter by category or payment method using filter chips

### Monthly Summary
1. Navigate to "Summary" from the home screen
2. Use arrow buttons to change months
3. View total spending, transaction count, and average per transaction
4. Tap "View Category Breakdown" for detailed analysis

### Managing Categories
1. Tap the menu icon (top-right) on home screen
2. Select "Manage Categories"
3. View default categories (locked)
4. Add custom categories with unique icons and colors
5. Edit or delete custom categories as needed

## Database Schema

### Categories Table
```sql
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  icon TEXT NOT NULL,
  color TEXT NOT NULL,
  is_default INTEGER NOT NULL DEFAULT 0
)
```

### Transactions Table
```sql
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  amount REAL NOT NULL,
  merchant TEXT NOT NULL,
  date TEXT NOT NULL,
  category_id TEXT NOT NULL,
  payment_method TEXT NOT NULL,
  notes TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (category_id) REFERENCES categories (id)
)
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  sqflite: ^2.3.0      # SQLite database
  path: ^1.8.3         # Path manipulation
  provider: ^6.1.1     # State management
  intl: ^0.19.0        # Internationalization and formatting
```

## Future Enhancements

- [ ] Export data to CSV/Excel
- [ ] Data backup and restore
- [ ] Charts and graphs (using fl_chart)
- [ ] Budget setting and alerts
- [ ] Recurring transactions
- [ ] Multi-currency support
- [ ] Dark mode toggle
- [ ] Cloud sync (optional)
- [ ] Receipt photo attachment
- [ ] Split transactions

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is open source and available under the [MIT License](LICENSE).

## Contact

Naveen - [@naveench909](https://github.com/naveench909)

Project Link: [https://github.com/naveench909/expense-tracker-flutter](https://github.com/naveench909/expense-tracker-flutter)

---

Made with ❤️ using Flutter
