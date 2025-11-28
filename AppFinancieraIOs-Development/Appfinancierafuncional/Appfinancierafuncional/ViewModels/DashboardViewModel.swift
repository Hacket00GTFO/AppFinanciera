import Foundation
import SwiftUI

// MARK: - Dashboard ViewModel
@MainActor
class DashboardViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var monthlyIncome: Double = 0.0
    @Published private(set) var monthlyExpenses: Double = 0.0
    @Published private(set) var monthlyDeductions: Double = 0.0
    @Published private(set) var activePeriods: [FinancialPeriod] = []
    @Published private(set) var topExpenses: [(category: ExpenseCategory, amount: Double)] = []
    @Published private(set) var recentIncome: [Income] = []
    @Published private(set) var loadingState: LoadingState = .idle
    
    // MARK: - Private Properties
    private let apiClient = APIClient.shared
    private var lastRefreshDate: Date?
    private let refreshInterval: TimeInterval = 60 // 1 minuto
    
    // MARK: - Computed Properties
    var isLoading: Bool { loadingState.isLoading }
    var errorMessage: String? { loadingState.errorMessage }
    
    var monthlyBalance: Double {
        monthlyIncome - monthlyExpenses - monthlyDeductions
    }
    
    var isPositiveBalance: Bool {
        monthlyBalance >= 0
    }
    
    var savingsRate: Double {
        guard monthlyIncome > 0 else { return 0 }
        return max(0, monthlyBalance / monthlyIncome)
    }
    
    var expenseRate: Double {
        guard monthlyIncome > 0 else { return 0 }
        return min(1, monthlyExpenses / monthlyIncome)
    }
    
    // MARK: - Initialization
    init() {
        loadDashboardData()
    }
    
    // MARK: - Public Methods
    
    func loadDashboardData() {
        // Datos de demostración mientras no hay conexión con API
        // En producción, estos se cargarían de la API
        monthlyIncome = 25000.0
        monthlyExpenses = 15000.0
        monthlyDeductions = 3672.0
        
        loadActivePeriods()
        loadTopExpenses()
        loadRecentIncome()
    }
    
    func refreshData() async {
        // Evitar actualizaciones muy frecuentes
        if let lastRefresh = lastRefreshDate,
           Date().timeIntervalSince(lastRefresh) < refreshInterval {
            return
        }
        
        loadingState = .loading
        
        // Simular carga de datos desde API
        do {
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 segundos
            
            // Cargar datos reales de la API
            await loadRealData()
            
            lastRefreshDate = Date()
            loadingState = .loaded
        } catch {
            loadingState = .error("Error al actualizar datos")
        }
    }
    
    func clearError() {
        if case .error = loadingState {
            loadingState = .idle
        }
    }
    
    // MARK: - Private Methods
    
    private func loadRealData() async {
        do {
            // Obtener ingresos del mes actual
            let calendar = Calendar.current
            let now = Date()
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
            let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) ?? now
            
            let incomes = try await apiClient.getIncomes(startDate: startOfMonth, endDate: endOfMonth)
            monthlyIncome = incomes.reduce(0) { $0 + $1.netAmount }
            recentIncome = incomes.prefix(5).map { $0.toIncome() }
            
            // Obtener gastos del mes actual
            let expenses = try await apiClient.getExpenses(startDate: startOfMonth, endDate: endOfMonth)
            monthlyExpenses = expenses.reduce(0) { $0 + $1.amount }
            
            // Calcular top gastos por categoría
            var categoryTotals: [String: Double] = [:]
            for expense in expenses {
                categoryTotals[expense.category, default: 0] += expense.amount
            }
            
            topExpenses = categoryTotals
                .compactMap { (categoryString, amount) -> (ExpenseCategory, Double)? in
                    if let category = ExpenseCategory(fromServerValue: categoryString) {
                        return (category, amount)
                    }
                    return nil
                }
                .sorted { $0.1 > $1.1 }
                .prefix(5)
                .map { $0 }
            
            // Obtener deducciones del mes actual
            let deductions = try await apiClient.getDeductions()
            let monthlyDeductionsList = deductions.filter { dto in
                dto.date >= startOfMonth && dto.date <= endOfMonth
            }
            monthlyDeductions = monthlyDeductionsList.reduce(0) { $0 + $1.amount }
            
            loadActivePeriods()
            
        } catch {
            // Si falla la API, mantener datos de demostración
            #if DEBUG
            print("⚠️ Error cargando datos reales: \(error.localizedDescription)")
            #endif
        }
    }
    
    private func loadActivePeriods() {
        let calendar = Calendar.current
        let now = Date()
        
        // Crear períodos activos basados en la fecha actual
        let weeklyStart = calendar.date(byAdding: .day, value: -6, to: now) ?? now
        let biweeklyStart = calendar.date(byAdding: .day, value: -14, to: now) ?? now
        let monthlyStart = calendar.date(byAdding: .day, value: -29, to: now) ?? now
        
        var periods = [
            FinancialPeriod(type: .weekly, startDate: weeklyStart),
            FinancialPeriod(type: .biweekly, startDate: biweeklyStart),
            FinancialPeriod(type: .monthly, startDate: monthlyStart)
        ]
        
        // Simular datos para cada período (en producción se calcularían de datos reales)
        for i in 0..<periods.count {
            let multiplier: Double
            switch periods[i].type {
            case .weekly:
                multiplier = 0.25
            case .biweekly:
                multiplier = 0.5
            case .monthly:
                multiplier = 1.0
            }
            
            periods[i].totalIncome = monthlyIncome * multiplier
            periods[i].totalExpenses = monthlyExpenses * multiplier
            periods[i].totalDeductions = monthlyDeductions * multiplier
            periods[i].updateBalance()
        }
        
        activePeriods = periods
    }
    
    private func loadTopExpenses() {
        // Si no hay datos de API, usar datos de demostración
        if topExpenses.isEmpty {
            let categories = ExpenseCategory.allCases
            topExpenses = categories.map { category in
                // Generar montos realistas basados en el tipo de categoría
                let baseAmount: Double
                switch category {
                case .rent:
                    baseAmount = 8000
                case .food:
                    baseAmount = 3000
                case .transport:
                    baseAmount = 1500
                case .electricity, .gas, .water:
                    baseAmount = 500
                case .internet:
                    baseAmount = 800
                case .leisure:
                    baseAmount = 1000
                default:
                    baseAmount = Double.random(in: 200...1000)
                }
                return (category: category, amount: baseAmount)
            }
            .sorted { $0.amount > $1.amount }
            .prefix(5)
            .map { $0 }
        }
    }
    
    private func loadRecentIncome() {
        // Si no hay datos de API, usar datos de demostración
        if recentIncome.isEmpty {
            let calendar = Calendar.current
            let now = Date()
            
            recentIncome = [
                Income(
                    grossAmount: 25000,
                    netAmount: 21328,
                    date: now,
                    type: .freelance,
                    description: "Proyecto web",
                    isRecurring: false
                ),
                Income(
                    grossAmount: 15000,
                    netAmount: 12799,
                    date: calendar.date(byAdding: .day, value: -7, to: now) ?? now,
                    type: .freelance,
                    description: "Consultoría",
                    isRecurring: false
                )
            ]
        }
    }
}
