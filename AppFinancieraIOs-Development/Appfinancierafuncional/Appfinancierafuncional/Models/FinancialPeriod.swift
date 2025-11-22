import Foundation

struct FinancialPeriod: Identifiable, Codable {
    var id = UUID()
    var type: PeriodType
    var startDate: Date
    var endDate: Date
    var totalIncome: Double
    var totalExpenses: Double
    var totalDeductions: Double
    var balance: Double
    var isCompleted: Bool
    
    enum PeriodType: String, CaseIterable, Codable {
        case weekly = "Semanal"
        case biweekly = "Quincenal"
        case monthly = "Mensual"
        
        var days: Int {
            switch self {
            case .weekly: return 7
            case .biweekly: return 15
            case .monthly: return 30
            }
        }
    }
    
    init(type: PeriodType, startDate: Date) {
        self.type = type
        self.startDate = startDate
        self.endDate = Calendar.current.date(byAdding: .day, value: type.days - 1, to: startDate) ?? startDate
        self.totalIncome = 0.0
        self.totalExpenses = 0.0
        self.totalDeductions = 0.0
        self.balance = 0.0
        self.isCompleted = false
    }
    
    mutating func updateBalance() {
        self.balance = totalIncome - totalExpenses - totalDeductions
    }
    
    var isCurrentPeriod: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }
}
