import Foundation

struct Income: Identifiable, Codable {
    var id: UUID
    var grossAmount: Double
    var netAmount: Double
    var date: Date
    var type: IncomeType
    var description: String
    var isRecurring: Bool
    var recurringPeriod: RecurringPeriod?
    
    // Inicializador personalizado para permitir ID opcional
    init(
        id: UUID = UUID(),
        grossAmount: Double,
        netAmount: Double,
        date: Date = Date(),
        type: IncomeType,
        description: String,
        isRecurring: Bool = false,
        recurringPeriod: RecurringPeriod? = nil
    ) {
        self.id = id
        self.grossAmount = grossAmount
        self.netAmount = netAmount
        self.date = date
        self.type = type
        self.description = description
        self.isRecurring = isRecurring
        self.recurringPeriod = recurringPeriod
    }
    
    enum IncomeType: String, CaseIterable, Codable {
        case freelance = "Freelance"
        case employment = "Empleo"
        case investment = "Inversión"
        case other = "Otro"
    }
    
    enum RecurringPeriod: String, CaseIterable, Codable {
        case weekly = "Semanal"
        case biweekly = "Quincenal"
        case monthly = "Mensual"
        case yearly = "Anual"
    }
    
    // Custom coding para mapear campos del backend (camelCase)
    enum CodingKeys: String, CodingKey {
        case id
        case grossAmount
        case netAmount
        case date
        case type
        case description
        case isRecurring
        case recurringPeriod
    }
}

