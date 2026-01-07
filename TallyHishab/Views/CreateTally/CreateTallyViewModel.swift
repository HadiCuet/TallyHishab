import Foundation
import SwiftData

@MainActor
final class CreateTallyViewModel: ObservableObject {
    // Person selection
    @Published var selectedPerson: Person?

    // Transaction details
    @Published var transactionType: TransactionType = .borrow
    @Published var amount: Double = 0
    @Published var date = Date()
    @Published var mode: PaymentMode = .cash
    @Published var returnDate: Date? = nil
    @Published var recordImage: Data?
    @Published var note = ""

    // Sheets/UI
    @Published var showingTransactionDatePicker = false
    @Published var showingReturnDatePicker = false

    // Used to drive DatePicker for optional return date
    @Published var returnDateDraft = Date()

    @Published var showingSuccessAlert = false
    @Published var savedTransactionType: TransactionType = .lend

    init() {}

    var isFormValid: Bool {
        selectedPerson != nil && amount > 0
    }

    func prepareReturnDatePicker() {
        let today = Calendar.current.startOfDay(for: Date())
        if let existing = returnDate {
            returnDateDraft = max(existing, today)
        } else {
            returnDateDraft = today
        }
        showingReturnDatePicker = true
    }

    func didChangeReturnDateDraft(_ newValue: Date) {
        returnDate = newValue
        showingReturnDatePicker = false
    }

    func clearReturnDate() {
        returnDate = nil
        showingReturnDatePicker = false
    }

    func dismissTransactionDatePicker() {
        showingTransactionDatePicker = false
    }

    func createPerson(using modelContext: ModelContext, name: String, mobile: String, relationship: String?) -> Person {
        let person = Person(name: name, mobile: mobile, relationship: relationship)
        modelContext.insert(person)
        return person
    }

    func saveTally(using modelContext: ModelContext) {
        guard let person = selectedPerson, isFormValid else { return }

        let transaction = Transaction(
            amount: amount,
            date: date,
            mode: mode,
            recordImage: recordImage,
            returnDate: returnDate,
            type: transactionType,
            note: note.isEmpty ? nil : note
        )
        transaction.person = person
        modelContext.insert(transaction)

        savedTransactionType = transactionType
        showingSuccessAlert = true
    }

    func resetForm() {
        selectedPerson = nil
        transactionType = .lend
        amount = 0
        date = Date()
        mode = .cash
        returnDate = nil
        recordImage = nil
        note = ""

        showingTransactionDatePicker = false
        showingReturnDatePicker = false
    }
}
