import Foundation
import SwiftUI

class ReportsViewModel: ObservableObject {
    @Published var periods: [FinancialPeriod] = []
    @Published var expenses: [Expense] = []
    @Published var incomes: [Income] = []
    
    init() {
        loadSampleData()
    }
    
    func getCurrentPeriodData(for periodType: FinancialPeriod.PeriodType) -> FinancialPeriod? {
        let calendar = Calendar.current
        let now = Date()
        
        // Crear el período actual
        let startDate: Date
        switch periodType {
        case .weekly:
            startDate = calendar.date(byAdding: .day, value: -6, to: now) ?? now
        case .biweekly:
            startDate = calendar.date(byAdding: .day, value: -14, to: now) ?? now
        case .monthly:
            startDate = calendar.date(byAdding: .day, value: -29, to: now) ?? now
        }
        
        let endDate = now
        
        // Filtrar datos del período
        let periodExpenses = expenses.filter { expense in
            expense.date >= startDate && expense.date <= endDate
        }
        
        let periodIncomes = incomes.filter { income in
            income.date >= startDate && income.date <= endDate
        }
        
        let totalExpenses = periodExpenses.reduce(0) { $0 + $1.amount }
        let totalIncome = periodIncomes.reduce(0) { $0 + $1.netAmount }
        
        var period = FinancialPeriod(type: periodType, startDate: startDate)
        period.endDate = endDate
        period.totalExpenses = totalExpenses
        period.totalIncome = totalIncome
        period.updateBalance()
        
        return period
    }
    
    func getCategoryAmount(_ category: ExpenseCategory, for periodType: FinancialPeriod.PeriodType) -> Double {
        guard let periodData = getCurrentPeriodData(for: periodType) else { return 0.0 }
        
        let calendar = Calendar.current
        let startDate = periodData.startDate
        let endDate = periodData.endDate
        
        let categoryExpenses = expenses.filter { expense in
            expense.category == category &&
            expense.date >= startDate &&
            expense.date <= endDate
        }
        
        return categoryExpenses.reduce(0) { $0 + $1.amount }
    }
    
    func getTopExpenseCategories(for periodType: FinancialPeriod.PeriodType, limit: Int = 5) -> [(category: ExpenseCategory, amount: Double)] {
        let categories = ExpenseCategory.allCases
        let categoryAmounts = categories.map { category in
            (category: category, amount: getCategoryAmount(category, for: periodType))
        }
        
        return categoryAmounts
            .filter { $0.amount > 0 }
            .sorted { $0.amount > $1.amount }
            .prefix(limit)
            .map { $0 }
    }
    
    func getIncomeVsExpensesData(for periodType: FinancialPeriod.PeriodType) -> [(label: String, amount: Double, color: Color)] {
        guard let periodData = getCurrentPeriodData(for: periodType) else {
            return []
        }
        
        return [
            (label: "Ingresos", amount: periodData.totalIncome, color: .green),
            (label: "Gastos", amount: periodData.totalExpenses, color: .red)
        ]
    }
    
    func getExpensesByCategoryData(for periodType: FinancialPeriod.PeriodType) -> [(category: String, amount: Double, color: Color)] {
        let topCategories = getTopExpenseCategories(for: periodType, limit: 8)
        
        let colors: [Color] = [.blue, .red, .orange, .green, .purple, .pink, .yellow, .gray]
        
        return topCategories.enumerated().map { index, item in
            (category: item.category.rawValue, amount: item.amount, color: colors[index % colors.count])
        }
    }
    
    func getPeriodComparisonData() -> [(period: String, income: Double, expenses: Double, balance: Double)] {
        let calendar = Calendar.current
        let now = Date()
        
        let periods: [(String, Int)] = [
            ("Semana anterior", -7),
            ("Quincena anterior", -14),
            ("Mes anterior", -30)
        ]
        
        return periods.map { periodName, daysOffset in
            let startDate = calendar.date(byAdding: .day, value: daysOffset, to: now) ?? now
            let endDate = calendar.date(byAdding: .day, value: daysOffset + 6, to: now) ?? now
            
            let periodExpenses = expenses.filter { expense in
                expense.date >= startDate && expense.date <= endDate
            }
            
            let periodIncomes = incomes.filter { income in
                income.date >= startDate && income.date <= endDate
            }
            
            let totalExpenses = periodExpenses.reduce(0) { $0 + $1.amount }
            let totalIncome = periodIncomes.reduce(0) { $0 + $1.netAmount }
            let balance = totalIncome - totalExpenses
            
            return (period: periodName, income: totalIncome, expenses: totalExpenses, balance: balance)
        }
    }
    
    func exportReport() {
        // Aquí se implementaría la exportación a PDF
        print("Exportando reporte...")
    }
    
    private func loadSampleData() {
        // Cargar datos de ejemplo para las vistas
        loadSampleExpenses()
        loadSampleIncomes()
    }
    
    private func loadSampleExpenses() {
        let calendar = Calendar.current
        let now = Date()
        
        expenses = [
            Expense(amount: 8000, category: .rent, date: now, description: "Renta mensual"),
            Expense(amount: 2500, category: .food, date: now, description: "Comida del mes"),
            Expense(amount: 1200, category: .transport, date: now, description: "Transporte público"),
            Expense(amount: 800, category: .electricity, date: now, description: "Luz"),
            Expense(amount: 600, category: .internet, date: now, description: "Internet y teléfono"),
            Expense(amount: 1500, category: .leisure, date: now, description: "Entretenimiento"),
            Expense(amount: 400, category: .water, date: now, description: "Agua"),
            Expense(amount: 300, category: .gas, date: now, description: "Gas")
        ]
        
        // Agregar gastos de días anteriores para simular historial
        for i in 1...30 {
            if let pastDate = calendar.date(byAdding: .day, value: -i, to: now) {
                let randomCategory = ExpenseCategory.allCases.randomElement() ?? .food
                let randomAmount = Double.random(in: 100...2000)
                let expense = Expense(
                    amount: randomAmount,
                    category: randomCategory,
                    date: pastDate,
                    description: "Gasto del \(pastDate.formattedString(style: .short))"
                )
                expenses.append(expense)
            }
        }
    }
    
    private func loadSampleIncomes() {
        let calendar = Calendar.current
        let now = Date()
        
        incomes = [
            Income(
                grossAmount: 25000,
                netAmount: 21328,
                date: now,
                type: .freelance,
                description: "Proyecto desarrollo web",
                isRecurring: false
            ),
            Income(
                grossAmount: 15000,
                netAmount: 12799,
                date: calendar.date(byAdding: .day, value: -15, to: now) ?? now,
                type: .freelance,
                description: "Consultoría técnica",
                isRecurring: false
            )
        ]
        
        // Agregar ingresos de días anteriores
        for i in 1...30 {
            if let pastDate = calendar.date(byAdding: .day, value: -i, to: now), i % 7 == 0 {
                let randomGross = Double.random(in: 8000...30000)
                let randomNet = randomGross * 0.85 // Simular deducciones
                let income = Income(
                    grossAmount: randomGross,
                    netAmount: randomNet,
                    date: pastDate,
                    type: .freelance,
                    description: "Ingreso del \(pastDate.formattedString(style: .short))",
                    isRecurring: false
                )
                incomes.append(income)
            }
        }
    }
}
