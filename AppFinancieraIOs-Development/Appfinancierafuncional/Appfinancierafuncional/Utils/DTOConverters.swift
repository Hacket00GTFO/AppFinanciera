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
        // Intentar directo primero (rawValue en español)
        if let category = ExpenseCategory(rawValue: value) {
            self = category
            return
        }
        
        let lowercased = value.lowercased()
        
        // Mapeo de valores del servidor (inglés/español) a categorías locales
        switch lowercased {
        // Fijos obligatorios
        case "rent", "alquiler", "hipoteca", "alquiler/hipoteca":
            self = .rent
        case "loans", "préstamos", "prestamos":
            self = .loans
        case "taxes", "impuestos":
            self = .taxes
        case "others", "otros":
            self = .others
        // Fijos reducibles
        case "water", "agua":
            self = .water
        case "gas":
            self = .gas
        case "electricity", "luz", "electricidad":
            self = .electricity
        case "internet", "internet + tel + tv", "telefono", "teléfono":
            self = .internet
        case "food", "alimentación", "alimentacion", "comida", "groceries":
            self = .food
        case "transport", "transportation", "transporte":
            self = .transport
        case "education", "escolares", "escuela":
            self = .education
        case "contingencies", "imprevistos":
            self = .contingencies
        // Variables
        case "leisure", "ocio", "entretenimiento", "entertainment":
            self = .leisure
        case "travel", "viajes":
            self = .travel
        case "subscriptions", "suscripciones":
            self = .subscriptions
        case "otherexpenses", "otros gastos", "other":
            self = .otherExpenses
        default:
            return nil
        }
    }
}

// MARK: - Expense Recurring Period Conversion Helper

extension Expense.RecurringPeriod {
    /// Convierte una cadena del servidor API a RecurringPeriod
    init?(fromServerValue value: String) {
        // Intentar directo primero
        if let period = Expense.RecurringPeriod(rawValue: value) {
            self = period
            return
        }
        
        let lowercased = value.lowercased()
        
        // Mapeo manual
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

// MARK: - Expense DTO to Model Conversion

extension ExpenseResponseDto {
    /// Convierte un DTO del servidor a un modelo Expense
    func toExpense() -> Expense {
        // Convertir receiptImage de String? a Data? si es base64
        var receiptData: Data? = nil
        if let receiptString = receiptImage {
            receiptData = Data(base64Encoded: receiptString)
        }
        
        return Expense(
            id: id,
            amount: amount,
            category: ExpenseCategory(fromServerValue: category) ?? .otherExpenses,
            date: date,
            description: description,
            isRecurring: isRecurring,
            recurringPeriod: recurringPeriod.flatMap { Expense.RecurringPeriod(fromServerValue: $0) },
            notes: notes,
            receiptImage: receiptData
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
