import Foundation

// MARK: - Financial Period Model
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
    
    // MARK: - Period Type
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
        
        var icon: String {
            switch self {
            case .weekly: return "calendar.badge.clock"
            case .biweekly: return "calendar"
            case .monthly: return "calendar.circle"
            }
        }
        
        var multiplierFromMonthly: Double {
            switch self {
            case .weekly: return 0.25
            case .biweekly: return 0.5
            case .monthly: return 1.0
            }
        }
    }
    
    // MARK: - Initialization
    init(type: PeriodType, startDate: Date) {
        self.type = type
        self.startDate = startDate
        
        // Calcular fecha de fin basada en el tipo de período
        let calendar = Calendar.current
        switch type {
        case .weekly:
            self.endDate = calendar.date(byAdding: .day, value: 6, to: startDate) ?? startDate
        case .biweekly:
            self.endDate = calendar.date(byAdding: .day, value: 14, to: startDate) ?? startDate
        case .monthly:
            // Para período mensual, calcular el último día del mes
            if let nextMonth = calendar.date(byAdding: .month, value: 1, to: startDate),
               let lastDay = calendar.date(byAdding: .day, value: -1, to: nextMonth) {
                self.endDate = lastDay
            } else {
                self.endDate = calendar.date(byAdding: .day, value: 29, to: startDate) ?? startDate
            }
        }
        
        self.totalIncome = 0.0
        self.totalExpenses = 0.0
        self.totalDeductions = 0.0
        self.balance = 0.0
        self.isCompleted = false
    }
    
    // MARK: - Computed Properties
    
    /// Verifica si el período actual está activo
    var isCurrentPeriod: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }
    
    /// Días restantes en el período
    var daysRemaining: Int {
        let calendar = Calendar.current
        let now = Date()
        guard now <= endDate else { return 0 }
        return calendar.dateComponents([.day], from: now, to: endDate).day ?? 0
    }
    
    /// Porcentaje del período transcurrido
    var progressPercentage: Double {
        let calendar = Calendar.current
        let now = Date()
        
        let totalDays = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 1
        let elapsedDays = calendar.dateComponents([.day], from: startDate, to: now).day ?? 0
        
        guard totalDays > 0 else { return 0 }
        return min(1.0, max(0.0, Double(elapsedDays) / Double(totalDays)))
    }
    
    /// Ingreso neto (después de deducciones)
    var netIncome: Double {
        totalIncome - totalDeductions
    }
    
    /// Tasa de ahorro del período
    var savingsRate: Double {
        guard netIncome > 0 else { return 0 }
        return max(0, balance / netIncome)
    }
    
    /// Tasa de gasto del período
    var expenseRate: Double {
        guard netIncome > 0 else { return 0 }
        return min(1.0, totalExpenses / netIncome)
    }
    
    /// Estado financiero del período
    var financialStatus: FinancialStatus {
        if balance > netIncome * 0.2 {
            return .excellent
        } else if balance > 0 {
            return .good
        } else if balance > -netIncome * 0.1 {
            return .warning
        } else {
            return .critical
        }
    }
    
    /// Descripción del rango de fechas
    var dateRangeDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "es_MX")
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
    
    // MARK: - Methods
    
    /// Actualiza el balance del período
    mutating func updateBalance() {
        self.balance = totalIncome - totalExpenses - totalDeductions
    }
    
    /// Marca el período como completado
    mutating func markAsCompleted() {
        self.isCompleted = true
    }
    
    /// Calcula el promedio diario de gastos
    func averageDailyExpense() -> Double {
        let calendar = Calendar.current
        let totalDays = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 1
        guard totalDays > 0 else { return 0 }
        return totalExpenses / Double(totalDays)
    }
    
    /// Proyecta gastos hasta fin del período
    func projectedExpenses() -> Double {
        let avgDaily = averageDailyExpense()
        let remaining = daysRemaining
        return totalExpenses + (avgDaily * Double(remaining))
    }
    
    /// Proyecta el balance final del período
    func projectedBalance() -> Double {
        return totalIncome - projectedExpenses() - totalDeductions
    }
}

// MARK: - Financial Status
enum FinancialStatus: String {
    case excellent = "Excelente"
    case good = "Bueno"
    case warning = "Precaución"
    case critical = "Crítico"
    
    var color: String {
        switch self {
        case .excellent: return "green"
        case .good: return "blue"
        case .warning: return "orange"
        case .critical: return "red"
        }
    }
    
    var icon: String {
        switch self {
        case .excellent: return "star.fill"
        case .good: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .critical: return "xmark.circle.fill"
        }
    }
    
    var description: String {
        switch self {
        case .excellent:
            return "¡Excelente manejo financiero! Estás ahorrando más del 20%."
        case .good:
            return "Buen trabajo. Tu balance es positivo."
        case .warning:
            return "Cuidado. Tus gastos están cerca de tus ingresos."
        case .critical:
            return "Alerta. Tus gastos superan tus ingresos."
        }
    }
}

// MARK: - Financial Period Helpers
extension FinancialPeriod {
    /// Crea un período para el mes actual
    static func currentMonth() -> FinancialPeriod {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        return FinancialPeriod(type: .monthly, startDate: startOfMonth)
    }
    
    /// Crea un período para la semana actual
    static func currentWeek() -> FinancialPeriod {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now
        return FinancialPeriod(type: .weekly, startDate: startOfWeek)
    }
    
    /// Crea un período para la quincena actual
    static func currentBiweekly() -> FinancialPeriod {
        let calendar = Calendar.current
        let now = Date()
        let day = calendar.component(.day, from: now)
        
        var components = calendar.dateComponents([.year, .month], from: now)
        components.day = day <= 15 ? 1 : 16
        
        let startDate = calendar.date(from: components) ?? now
        return FinancialPeriod(type: .biweekly, startDate: startDate)
    }
}
