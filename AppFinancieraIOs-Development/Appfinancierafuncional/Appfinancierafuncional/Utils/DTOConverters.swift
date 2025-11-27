import Foundation

// MARK: - Income Type Conversion Helper

extension Income.IncomeType {
    /// Convierte una cadena del servidor API a IncomeType
    /// El servidor envía valores como: "Freelance", "Employment", "Investment", "Other"
    /// Pero nuestro enum espera: "freelance", "employment", "investment", "other"
    init?(fromServerValue value: String) {
        // Intentar directo primero
        if let type = Income.IncomeType(rawValue: value) {
            self = type
            return
        }
        
        // Si no funciona, intentar con lowercased
        let lowercased = value.lowercased()
        if let type = Income.IncomeType(rawValue: lowercased) {
            self = type
            return
        }
        
        // Si aún no funciona, mapear manualmente
        switch lowercased {
        case "freelance":
            self = .freelance
        case "employment", "empleo":
            self = .employment
        case "investment", "inversión":
            self = .investment
        case "other", "otro":
            self = .other
        default:
            return nil
        }
    }
}

// MARK: - Recurring Period Conversion Helper

extension Income.RecurringPeriod {
    /// Convierte una cadena del servidor API a RecurringPeriod
    /// El servidor envía valores como: "Weekly", "Biweekly", "Monthly", "Yearly"
    /// Pero nuestro enum espera: "weekly", "biweekly", "monthly", "yearly"
    init?(fromServerValue value: String) {
        // Intentar directo primero
        if let period = Income.RecurringPeriod(rawValue: value) {
            self = period
            return
        }
        
        // Si no funciona, intentar con lowercased
        let lowercased = value.lowercased()
        if let period = Income.RecurringPeriod(rawValue: lowercased) {
            self = period
            return
        }
        
        // Si aún no funciona, mapear manualmente
        switch lowercased {
        case "weekly", "semanal":
            self = .weekly
        case "biweekly", "quincenal":
            self = .biweekly
        case "monthly", "mensual":
            self = .monthly
        case "yearly", "anual":
            self = .yearly
        default:
            return nil
        }
    }
}

// MARK: - DTO to Model Conversion

extension IncomeResponseDto {
    /// Convierte un DTO del servidor a un modelo Income
    func toIncome() -> Income {
        Income(
            id: id,
            grossAmount: grossAmount,
            netAmount: netAmount,
            date: date,
            type: Income.IncomeType(fromServerValue: type) ?? .other,
            description: description,
            isRecurring: isRecurring,
            recurringPeriod: recurringPeriod.flatMap { Income.RecurringPeriod(fromServerValue: $0) }
        )
    }
}

// MARK: - Expense Type Conversion Helper

extension ExpenseCategory {
    /// Convierte una cadena del servidor API a ExpenseCategory
    init?(fromServerValue value: String) {
        if let category = ExpenseCategory(rawValue: value) {
            self = category
            return
        }
        
        let lowercased = value.lowercased()
        if let category = ExpenseCategory(rawValue: lowercased) {
            self = category
            return
        }
        
        // Mapeo manual si es necesario
        switch lowercased {
        case "food", "comida", "groceries":
            self = .food
        case "transportation", "transporte":
            self = .transportation
        case "entertainment", "entretenimiento":
            self = .entertainment
        case "utilities", "servicios":
            self = .utilities
        case "healthcare", "salud":
            self = .healthcare
        case "shopping", "compras":
            self = .shopping
        case "other", "otro":
            self = .other
        default:
            return nil
        }
    }
}

// MARK: - Expense DTO to Model Conversion

extension ExpenseResponseDto {
    /// Convierte un DTO del servidor a un modelo Expense
    func toExpense() -> Expense {
        Expense(
            id: id,
            amount: amount,
            category: ExpenseCategory(fromServerValue: category) ?? .other,
            date: date,
            description: description,
            isRecurring: isRecurring,
            recurringPeriod: recurringPeriod.flatMap { Income.RecurringPeriod(fromServerValue: $0) },
            notes: notes,
            receiptImage: receiptImage
        )
    }
}

// MARK: - Logging Helper para debugging

func logDTOConversion(_ label: String, serverValue: String, mappedValue: String) {
    #if DEBUG
    print("🔄 DTO Conversion: \(label)")
    print("  📤 Server value: \(serverValue)")
    print("  📥 Mapped value: \(mappedValue)")
    #endif
}
