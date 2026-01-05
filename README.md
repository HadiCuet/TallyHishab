# TallyHishab - Personal Lend & Borrow Tracker

A SwiftUI app for iOS 17+ to track personal lend and borrow transactions (zero interest).

## Features

### Core Features
- **Contact Integration**: Pick a person from iOS Contacts or create one manually (name, mobile)
- **Transaction Entry**: Create lend/borrow transactions with amount, date, mode, optional receipt image, and return date
- **Settlement View**: "Mark as Paid" flow that records completion date, payment mode, and optional proof image

### Dashboard
- **Summary View**: Total Lent vs Total Borrowed with per-user breakdown
- **User List View**: List of people showing current net balance (to receive / to pay)

## Data Models

### Person
- `name`: String
- `mobile`: String
- `relationship`: String (optional)
- `transactions`: [Transaction] - Relationship

### Transaction
- `amount`: Double
- `date`: Date
- `mode`: PaymentMode (Cash / Account / MFS)
- `recordImage`: Data (optional) - External storage
- `returnDate`: Date (optional)
- `type`: TransactionType (Lend / Borrow)
- `isCompleted`: Bool
- `completionDate`: Date (optional)
- `completionMode`: PaymentMode (optional)
- `completionProofImage`: Data (optional) - External storage
- `note`: String (optional)

## Tech Stack
- SwiftUI
- SwiftData
- PhotosUI (for images)
- ContactsUI (for contact picking)

## Requirements
- iOS 17.0+
- Xcode 15.0+

## Installation

1. Clone the repository
2. Open `TallyHishab.xcodeproj` in Xcode
3. Build and run on simulator or device

## Privacy Permissions

The app requires the following permissions:
- **Contacts**: To pick contacts for quick person addition
- **Photo Library**: To attach receipt/proof images to transactions

## Project Structure

```
TallyHishab/
├── TallyHishabApp.swift          # App entry point
├── Models/
│   ├── Person.swift              # Person data model
│   └── Transaction.swift         # Transaction data model
├── Views/
│   ├── ContentView.swift         # Main tab view
│   ├── CreateTally/
│   │   └── CreateTallyView.swift # Quick tally creation with search
│   ├── Dashboard/
│   │   └── DashboardView.swift   # Summary and overview
│   ├── Person/
│   │   ├── PersonListView.swift  # List of all people
│   │   ├── AddPersonView.swift   # Add/edit person
│   │   └── PersonDetailView.swift# Person details with transactions
│   ├── Transaction/
│   │   ├── AddTransactionView.swift      # Add lend/borrow
│   │   └── TransactionDetailView.swift   # Transaction details
│   └── Settlement/
│       └── SettlementView.swift  # Mark as paid flow
├── Helpers/
│   ├── FormatterHelper.swift     # Currency and date formatting
│   ├── ContactPicker.swift       # iOS Contacts integration
│   └── ImagePicker.swift         # PhotosUI integration
└── Assets.xcassets/              # App icons and colors
```

## License

MIT License - See [LICENSE](LICENSE) for details.
