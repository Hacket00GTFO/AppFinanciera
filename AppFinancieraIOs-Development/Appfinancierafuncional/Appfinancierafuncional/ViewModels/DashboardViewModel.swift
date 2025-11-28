import Foundation
import SwiftUI

class DashboardViewModel: ObservableObject {
    @Published var monthlyIncome: Double = 0.0
    @Published var monthlyExpenses: Double = 0.0
    @Published var monthlyDeductions: Double = 0.0
    @Published var activePeriods: [FinancialPeriod] = []
    @Published var topExpenses: [(category: ExpenseCategory, amount: Double)] = []
    @Published var recentIncome: [Income] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient = APIClient.shared
    
    var monthlyBalance: Double {
        monthlyIncome - monthlyExpenses - monthlyDeductions
    }
    
    init() {
        Task {
            await loadDashboardData()
        }
    }
    
    @MainActor
    func loadDashboardData() async {
        isLoading = true
        errorMessage = nil
        
        // Calcular fechas del mes actual
        let calendar = Calendar.current
        let now = Date()
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) else {
            isLoading = false
            return
        }
        
        do {
            // Cargar ingresos del mes
            let incomes = try await apiClient.getIncomes(startDate: monthStart, endDate: monthEnd)
            monthlyIncome = incomes.reduce(0) { $0 + $1.netAmount }
            recentIncome = incomes.prefix(5).map { $0.toIncome() }
            
            // Cargar gastos del mes
            let expenses = try await apiClient.getExpenses(startDate: monthStart, endDate: monthEnd)
            monthlyExpenses = expenses.reduce(0) { $0 + $1.amount }
            
            // Calcular top gastos por categoría
            let expenseModels = expenses.map { $0.toExpense() }
            var categoryTotals: [ExpenseCategory: Double] = [:]
            for expense in expenseModels {
                categoryTotals[expense.category, default: 0] += expense.amount
            }
            topExpenses = categoryTotals.map { (category: $0.key, amount: $0.value) }
                .sorted { $0.amount > $1.amount }
                .prefix(5)
                .map { $0 }
            
            // Cargar deducciones del mes
            let deductions = try await apiClient.getDeductions()
            let monthDeductions = deductions.filter { deduction in
                deduction.date >= monthStart && deduction.date <= monthEnd
            }
            monthlyDeductions = monthDeductions.reduce(0) { $0 + $1.amount }
            
            // Cargar períodos activos
            loadActivePeriods(incomes: incomes.map { $0.toIncome() }, expenses: expenses.map { $0.toExpense() })
            
        } catch let error as APIError {
            errorMessage = error.errorDescription
            // Usar datos por defecto si hay error
            loadDefaultData()
        } catch {
            errorMessage = "Error al cargar datos del dashboard: \(error.localizedDescription)"
            loadDefaultData()
        }
        
        isLoading = false
    }
    
    private func loadDefaultData() {
        monthlyIncome = 0.0
        monthlyExpenses = 0.0
        monthlyDeductions = 0.0
        recentIncome = []
        topExpenses = []
        loadActivePeriods()
    }
    
    func loadActivePeriods(incomes: [Income] = [], expenses: [Expense] = []) {
        let calendar = Calendar.current
        let now = Date()
        
        // Crear períodos activos
        let weeklyStart = calendar.date(byAdding: .day, value: -6, to: now) ?? now
        let biweeklyStart = calendar.date(byAdding: .day, value: -14, to: now) ?? now
        let monthlyStart = calendar.date(byAdding: .day, value: -29, to: now) ?? now
        
        var periods = [
            FinancialPeriod(type: .weekly, startDate: weeklyStart),
            FinancialPeriod(type: .biweekly, startDate: biweeklyStart),
            FinancialPeriod(type: .monthly, startDate: monthlyStart)
        ]
        
        // Calcular datos reales si están disponibles
        for i in 0..<periods.count {
            let period = periods[i]
            periods[i].totalIncome = incomes.filter { income in
                income.date >= period.startDate && income.date <= period.endDate
            }.reduce(0) { $0 + $1.netAmount }
            
            periods[i].totalExpenses = expenses.filter { expense in
                expense.date >= period.startDate && expense.date <= period.endDate
            }.reduce(0) { $0 + $1.amount }
            
            periods[i].updateBalance()
        }
        
        activePeriods = periods
    }
    
    @MainActor
    func refreshData() async {
        await loadDashboardData()
    }
}
