import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var people: [Person]
    @Query(filter: #Predicate<Transaction> { !$0.isCompleted }) private var pendingTransactions: [Transaction]
    
    var totalLent: Double {
        pendingTransactions
            .filter { $0.type == .lend }
            .reduce(0) { $0 + $1.amount }
    }
    
    var totalBorrowed: Double {
        pendingTransactions
            .filter { $0.type == .borrow }
            .reduce(0) { $0 + $1.amount }
    }
    
    var netBalance: Double {
        totalLent - totalBorrowed
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary Cards
                    SummaryCardView(
                        totalLent: totalLent,
                        totalBorrowed: totalBorrowed,
                        netBalance: netBalance
                    )
                    
                    // User Breakdown
                    if !people.isEmpty {
                        UserBreakdownView(people: people)
                    }
                    
                    // Recent Transactions
                    if !pendingTransactions.isEmpty {
                        RecentTransactionsView(transactions: pendingTransactions)
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct SummaryCardView: View {
    let totalLent: Double
    let totalBorrowed: Double
    let netBalance: Double
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Total Lent Card
                VStack(spacing: 8) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title)
                        .foregroundStyle(.green)
                    
                    Text("Total Lent")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(FormatterHelper.currency(totalLent))
                        .font(.headline)
                        .foregroundStyle(.green)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                
                // Total Borrowed Card
                VStack(spacing: 8) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.title)
                        .foregroundStyle(.red)
                    
                    Text("Total Borrowed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(FormatterHelper.currency(totalBorrowed))
                        .font(.headline)
                        .foregroundStyle(.red)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
            }
            
            // Net Balance Card
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Net Balance")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(netBalanceDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(FormatterHelper.currency(abs(netBalance)))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(netBalance > 0 ? .green : (netBalance < 0 ? .red : .secondary))
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }
    
    var netBalanceDescription: String {
        if netBalance > 0 {
            return "You are owed this amount"
        } else if netBalance < 0 {
            return "You owe this amount"
        } else {
            return "All settled"
        }
    }
}

struct UserBreakdownView: View {
    let people: [Person]
    
    var sortedPeople: [Person] {
        people
            .filter { $0.netBalance != 0 }
            .sorted { abs($0.netBalance) > abs($1.netBalance) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Per-User Breakdown")
                .font(.headline)
            
            if sortedPeople.isEmpty {
                Text("No pending transactions")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(sortedPeople) { person in
                    NavigationLink(destination: PersonDetailView(person: person)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(person.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                
                                Text(person.mobile)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(FormatterHelper.currency(abs(person.netBalance)))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(person.netBalance > 0 ? .green : .red)
                                
                                Text(person.netBalance > 0 ? "To Receive" : "To Pay")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
}

struct RecentTransactionsView: View {
    let transactions: [Transaction]
    
    var recentTransactions: [Transaction] {
        Array(transactions.sorted { $0.date > $1.date }.prefix(5))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Pending")
                .font(.headline)
            
            ForEach(recentTransactions) { transaction in
                if let person = transaction.person {
                    NavigationLink(destination: TransactionDetailView(transaction: transaction)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(person.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                
                                Text(FormatterHelper.shortDate(transaction.date))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Text(FormatterHelper.currency(transaction.amount))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(transaction.type == .lend ? .green : .red)
                                
                                Image(systemName: transaction.type == .lend ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                    .foregroundStyle(transaction.type == .lend ? .green : .red)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [Person.self, Transaction.self], inMemory: true)
}
