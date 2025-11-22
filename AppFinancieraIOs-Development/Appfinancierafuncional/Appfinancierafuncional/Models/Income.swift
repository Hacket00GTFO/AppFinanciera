import Foundation

struct Income: Identifiable, Codable {
    var id = UUID()
    var grossAmount: Double
    var netAmount: Double
    var date: Date
    var type: IncomeType
    var description: String
    var isRecurring: Bool
    var recurringPeriod: RecurringPeriod?
    
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
}
