import Foundation
import SwiftData

enum TransactionType: String, Codable, CaseIterable {
    case lend = "Lend"
    case borrow = "Borrow"
}

enum PaymentMode: String, Codable, CaseIterable {
    case cash = "Cash"
    case account = "Account"
    case mfs = "MFS"
}

@Model
final class Transaction {
    var amount: Double
    var date: Date
    var mode: PaymentMode
    @Attribute(.externalStorage)
    var recordImage: Data?
    var returnDate: Date?
    var type: TransactionType
    var isCompleted: Bool
    var completionDate: Date?
    var completionMode: PaymentMode?
    @Attribute(.externalStorage)
    var completionProofImage: Data?
    var note: String?
    
    var person: Person?
    
    init(
        amount: Double,
        date: Date = Date(),
        mode: PaymentMode = .cash,
        recordImage: Data? = nil,
        returnDate: Date? = nil,
        type: TransactionType,
        isCompleted: Bool = false,
        note: String? = nil
    ) {
        self.amount = amount
        self.date = date
        self.mode = mode
        self.recordImage = recordImage
        self.returnDate = returnDate
        self.type = type
        self.isCompleted = isCompleted
        self.note = note
    }
    
    /// Mark transaction as completed/settled
    func markAsCompleted(mode: PaymentMode, proofImage: Data? = nil) {
        self.isCompleted = true
        self.completionDate = Date()
        self.completionMode = mode
        self.completionProofImage = proofImage
    }
}
