import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let person: Person
    let transactionType: TransactionType
    
    @State private var amount: Double = 0
    @State private var date = Date()
    @State private var mode: PaymentMode = .cash
    @State private var returnDate: Date?
    @State private var hasReturnDate = false
    @State private var recordImage: Data?
    @State private var note = ""
    
    var isValid: Bool {
        amount > 0
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Transaction Details") {
                    HStack {
                        Text("Type")
                        Spacer()
                        Text(transactionType.rawValue)
                            .foregroundStyle(transactionType == .lend ? .green : .red)
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("Amount", value: $amount, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    Picker("Payment Mode", selection: $mode) {
                        ForEach(PaymentMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                }
                
                Section("Return Date (Optional)") {
                    Toggle("Set Return Date", isOn: $hasReturnDate)
                    
                    if hasReturnDate {
                        DatePicker("Return By", selection: Binding(
                            get: { returnDate ?? Date() },
                            set: { returnDate = $0 }
                        ), displayedComponents: .date)
                    }
                }
                
                Section("Note (Optional)") {
                    TextField("Add a note", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Receipt Image (Optional)") {
                    ImagePicker(imageData: $recordImage)
                }
            }
            .navigationTitle(transactionType == .lend ? "Lend Money" : "Borrow Money")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTransaction()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private func saveTransaction() {
        let transaction = Transaction(
            amount: amount,
            date: date,
            mode: mode,
            recordImage: recordImage,
            returnDate: hasReturnDate ? returnDate : nil,
            type: transactionType,
            note: note.isEmpty ? nil : note
        )
        transaction.person = person
        modelContext.insert(transaction)
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Person.self, Transaction.self, configurations: config)
    let person = Person(name: "John Doe", mobile: "+1234567890")
    container.mainContext.insert(person)
    
    return AddTransactionView(person: person, transactionType: .lend)
        .modelContainer(container)
}
