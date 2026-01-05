import Foundation
import SwiftData

@Model
final class Person {
    var name: String
    var mobile: String
    var relationship: String?
    
    @Relationship(deleteRule: .cascade, inverse: \Transaction.person)
    var transactions: [Transaction] = []
    
    init(name: String, mobile: String, relationship: String? = nil) {
        self.name = name
        self.mobile = mobile
        self.relationship = relationship
    }
    
    /// Calculate total amount lent to this person (positive = they owe us)
    var totalLent: Double {
        transactions
            .filter { $0.type == .lend && !$0.isCompleted }
            .reduce(0) { $0 + $1.amount }
    }
    
    /// Calculate total amount borrowed from this person (positive = we owe them)
    var totalBorrowed: Double {
        transactions
            .filter { $0.type == .borrow && !$0.isCompleted }
            .reduce(0) { $0 + $1.amount }
    }
    
    /// Net balance: positive = they owe us, negative = we owe them
    var netBalance: Double {
        totalLent - totalBorrowed
    }
    
    /// Display balance text
    var balanceDescription: String {
        if netBalance > 0 {
            return "To Receive: \(FormatterHelper.currency(netBalance))"
        } else if netBalance < 0 {
            return "To Pay: \(FormatterHelper.currency(abs(netBalance)))"
        } else {
            return "Settled"
        }
    }
}
