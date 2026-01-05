import SwiftUI
import SwiftData

struct SettlementView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var transaction: Transaction
    
    @State private var settlementMode: PaymentMode = .cash
    @State private var proofImage: Data?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Transaction Summary") {
                    HStack {
                        Text("Amount")
                        Spacer()
                        Text(FormatterHelper.currency(transaction.amount))
                            .fontWeight(.semibold)
                            .foregroundStyle(transaction.type == .lend ? .green : .red)
                    }
                    
                    HStack {
                        Text("Type")
                        Spacer()
                        Text(transaction.type.rawValue)
                    }
                    
                    if let person = transaction.person {
                        HStack {
                            Text("Person")
                            Spacer()
                            Text(person.name)
                        }
                    }
                }
                
                Section("Settlement Details") {
                    Picker("Payment Mode", selection: $settlementMode) {
                        ForEach(PaymentMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    
                    HStack {
                        Text("Settlement Date")
                        Spacer()
                        Text(FormatterHelper.date(Date()))
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Proof Image (Optional)") {
                    ImagePicker(imageData: $proofImage)
                }
                
                Section {
                    Button {
                        completeSettlement()
                    } label: {
                        Label("Confirm Settlement", systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.white)
                    }
                    .listRowBackground(Color.green)
                }
            }
            .navigationTitle("Mark as Paid")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func completeSettlement() {
        transaction.markAsCompleted(mode: settlementMode, proofImage: proofImage)
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Person.self, Transaction.self, configurations: config)
    
    let person = Person(name: "John Doe", mobile: "+1234567890")
    container.mainContext.insert(person)
    
    let transaction = Transaction(amount: 5000, type: .lend)
    transaction.person = person
    container.mainContext.insert(transaction)
    
    return SettlementView(transaction: transaction)
        .modelContainer(container)
}
