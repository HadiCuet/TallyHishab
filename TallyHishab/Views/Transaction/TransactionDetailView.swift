import SwiftUI
import SwiftData

struct TransactionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var transaction: Transaction
    
    @State private var showingSettlementSheet = false
    
    var body: some View {
        List {
            // Status Section
            Section {
                HStack {
                    Text("Status")
                    Spacer()
                    Text(transaction.isCompleted ? "Completed" : "Pending")
                        .foregroundStyle(transaction.isCompleted ? .green : .orange)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Type")
                    Spacer()
                    Text(transaction.type.rawValue)
                        .foregroundStyle(transaction.type == .lend ? .green : .red)
                }
            }
            
            // Amount Section
            Section("Amount") {
                HStack {
                    Text(FormatterHelper.currency(transaction.amount))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(transaction.type == .lend ? .green : .red)
                }
            }
            
            // Transaction Details
            Section("Transaction Details") {
                LabeledContent("Date", value: FormatterHelper.date(transaction.date))
                LabeledContent("Payment Mode", value: transaction.mode.rawValue)
                
                if let returnDate = transaction.returnDate {
                    LabeledContent("Expected Return", value: FormatterHelper.date(returnDate))
                }
                
                if let note = transaction.note, !note.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Note")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(note)
                    }
                }
            }
            
            // Original Receipt Image
            if let imageData = transaction.recordImage, let uiImage = UIImage(data: imageData) {
                Section("Receipt") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                }
            }
            
            // Completion Details (if completed)
            if transaction.isCompleted {
                Section("Settlement Details") {
                    if let completionDate = transaction.completionDate {
                        LabeledContent("Settled On", value: FormatterHelper.date(completionDate))
                    }
                    
                    if let completionMode = transaction.completionMode {
                        LabeledContent("Settlement Mode", value: completionMode.rawValue)
                    }
                }
                
                if let proofData = transaction.completionProofImage, let proofImage = UIImage(data: proofData) {
                    Section("Settlement Proof") {
                        Image(uiImage: proofImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                    }
                }
            }
            
            // Mark as Paid Button (if not completed)
            if !transaction.isCompleted {
                Section {
                    Button {
                        showingSettlementSheet = true
                    } label: {
                        Label("Mark as Paid", systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.white)
                    }
                    .listRowBackground(Color.green)
                }
            }
        }
        .navigationTitle("Transaction")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingSettlementSheet) {
            SettlementView(transaction: transaction)
        }
    }
}

struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(FormatterHelper.currency(transaction.amount))
                    .font(.headline)
                    .foregroundStyle(transaction.type == .lend ? .green : .red)
                
                HStack(spacing: 8) {
                    Text(FormatterHelper.shortDate(transaction.date))
                    Text("•")
                    Text(transaction.mode.rawValue)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Image(systemName: transaction.type == .lend ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .foregroundStyle(transaction.type == .lend ? .green : .red)
                
                if transaction.isCompleted {
                    Text("Settled")
                        .font(.caption2)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.green)
                        .cornerRadius(4)
                }
            }
        }
        .padding(.vertical, 4)
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
    
    return NavigationStack {
        TransactionDetailView(transaction: transaction)
    }
    .modelContainer(container)
}
