import SwiftUI
import SwiftData

struct PersonDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var person: Person
    
    @State private var showingAddTransaction = false
    @State private var selectedTransactionType: TransactionType = .lend
    
    var pendingTransactions: [Transaction] {
        person.transactions.filter { !$0.isCompleted }.sorted { $0.date > $1.date }
    }
    
    var completedTransactions: [Transaction] {
        person.transactions.filter { $0.isCompleted }.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        List {
            // Summary Section
            Section {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Total Lent")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(FormatterHelper.currency(person.totalLent))
                            .font(.headline)
                            .foregroundStyle(.green)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Total Borrowed")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(FormatterHelper.currency(person.totalBorrowed))
                            .font(.headline)
                            .foregroundStyle(.red)
                    }
                }
                
                HStack {
                    Text("Net Balance")
                        .font(.subheadline)
                    Spacer()
                    Text(person.balanceDescription)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(person.netBalance > 0 ? .green : (person.netBalance < 0 ? .red : .secondary))
                }
            } header: {
                Text("Summary")
            }
            
            // Contact Info
            Section("Contact") {
                LabeledContent("Mobile", value: person.mobile)
                if let relationship = person.relationship, !relationship.isEmpty {
                    LabeledContent("Relationship", value: relationship)
                }
            }
            
            // Add Transaction Buttons
            Section {
                HStack(spacing: 16) {
                    Button {
                        selectedTransactionType = .lend
                        showingAddTransaction = true
                    } label: {
                        Label("Lend", systemImage: "arrow.up.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)
                    
                    Button {
                        selectedTransactionType = .borrow
                        showingAddTransaction = true
                    } label: {
                        Label("Borrow", systemImage: "arrow.down.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
                .listRowBackground(Color.clear)
            }
            
            // Pending Transactions
            if !pendingTransactions.isEmpty {
                Section("Pending Transactions") {
                    ForEach(pendingTransactions) { transaction in
                        NavigationLink(destination: TransactionDetailView(transaction: transaction)) {
                            TransactionRowView(transaction: transaction)
                        }
                    }
                    .onDelete(perform: deletePendingTransactions)
                }
            }
            
            // Completed Transactions
            if !completedTransactions.isEmpty {
                Section("Completed Transactions") {
                    ForEach(completedTransactions) { transaction in
                        NavigationLink(destination: TransactionDetailView(transaction: transaction)) {
                            TransactionRowView(transaction: transaction)
                        }
                    }
                }
            }
        }
        .navigationTitle(person.name)
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView(person: person, transactionType: selectedTransactionType)
        }
    }
    
    private func deletePendingTransactions(at offsets: IndexSet) {
        for index in offsets {
            let transaction = pendingTransactions[index]
            modelContext.delete(transaction)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Person.self, Transaction.self, configurations: config)
    
    let person = Person(name: "John Doe", mobile: "+1234567890", relationship: "Friend")
    container.mainContext.insert(person)
    
    return NavigationStack {
        PersonDetailView(person: person)
    }
    .modelContainer(container)
}
