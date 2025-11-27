import Foundation

struct Expense: Identifiable, Codable {
    var id: UUID
    var amount: Double
    var category: ExpenseCategory
    var date: Date
    var description: String
    var isRecurring: Bool
    var recurringPeriod: RecurringPeriod?
    var notes: String?
    var receiptImage: Data?
    
    enum RecurringPeriod: String, CaseIterable, Codable {
        case weekly = "Semanal"
        case biweekly = "Quincenal"
        case monthly = "Mensual"
        case yearly = "Anual"
    }
    
    init(
        id: UUID = UUID(),
        amount: Double,
        category: ExpenseCategory,
        date: Date = Date(),
        description: String = "",
        isRecurring: Bool = false,
        recurringPeriod: RecurringPeriod? = nil,
        notes: String? = nil,
        receiptImage: Data? = nil
    ) {
        self.id = id
        self.amount = amount
        self.category = category
        self.date = date
        self.description = description
        self.isRecurring = isRecurring
        self.recurringPeriod = recurringPeriod
        self.notes = notes
        self.receiptImage = receiptImage
    }
    
    // Custom coding para ignorar receiptImage en JSON (binario local)
    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case category
        case date
        case description
        case isRecurring
        case recurringPeriod
        case notes
    }
}
