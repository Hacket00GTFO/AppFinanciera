import Foundation
import SwiftUI

class DashboardViewModel: ObservableObject {
    @Published var monthlyIncome: Double = 0.0
    @Published var monthlyExpenses: Double = 0.0
    @Published var monthlyDeductions: Double = 0.0
    @Published var activePeriods: [FinancialPeriod] = []
    @Published var topExpenses: [(category: ExpenseCategory, amount: Double)] = []
    @Published var recentIncome: [Income] = []
    
    var monthlyBalance: Double {
        monthlyIncome - monthlyExpenses - monthlyDeductions
    }
    
    init() {
        loadDashboardData()
    }
    
    func loadDashboardData() {
        // Aquí se cargarían los datos desde el servicio de persistencia
        // Por ahora usamos datos de ejemplo
        monthlyIncome = 25000.0
        monthlyExpenses = 15000.0
        monthlyDeductions = 3672.0
        
        loadActivePeriods()
        loadTopExpenses()
        loadRecentIncome()
    }
    
    func loadActivePeriods() {
        let calendar = Calendar.current
        let now = Date()
        
        // Crear períodos activos
        let weeklyStart = calendar.date(byAdding: .day, value: -6, to: now) ?? now
        let biweeklyStart = calendar.date(byAdding: .day, value: -14, to: now) ?? now
        let monthlyStart = calendar.date(byAdding: .day, value: -29, to: now) ?? now
        
        activePeriods = [
            FinancialPeriod(type: .weekly, startDate: weeklyStart),
            FinancialPeriod(type: .biweekly, startDate: biweeklyStart),
            FinancialPeriod(type: .monthly, startDate: monthlyStart)
        ]
        
        // Simular datos de ejemplo
        for i in 0..<activePeriods.count {
            activePeriods[i].totalIncome = Double.random(in: 5000...30000)
            activePeriods[i].totalExpenses = Double.random(in: 3000...20000)
            activePeriods[i].totalDeductions = Double.random(in: 1000...5000)
            activePeriods[i].updateBalance()
        }
    }
    
    func loadTopExpenses() {
        // Simular top 5 gastos por categoría
        let categories = ExpenseCategory.allCases
        topExpenses = categories.map { category in
            (category: category, amount: Double.random(in: 100...5000))
        }.sorted { $0.amount > $1.amount }.prefix(5).map { $0 }
    }
    
    func loadRecentIncome() {
        // Simular ingresos recientes
        recentIncome = [
            Income(grossAmount: 25000, netAmount: 21328, date: Date(), type: .freelance, description: "Proyecto web", isRecurring: false),
            Income(grossAmount: 15000, netAmount: 12799, date: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(), type: .freelance, description: "Consultoría", isRecurring: false)
        ]
    }
    
    @MainActor
    func refreshData() async {
        // Simular carga asíncrona
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        loadDashboardData()
    }
}
