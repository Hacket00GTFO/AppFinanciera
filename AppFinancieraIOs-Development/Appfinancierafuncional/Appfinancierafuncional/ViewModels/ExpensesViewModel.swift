import Foundation
import SwiftUI

// MARK: - Expenses ViewModel
@MainActor
class ExpensesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var netSalary: Double = 0.0
    @Published var otherIncome: Double = 0.0
    @Published private(set) var expenses: [Expense] = []
    @Published private(set) var categoryExpenses: [ExpenseCategory: Double] = [:]
    @Published var showAddExpense = false
    @Published private(set) var loadingState: LoadingState = .idle
    
    // MARK: - Private Properties
    private let apiClient = APIClient.shared
    private var lastFetchDate: Date?
    private let cacheValidityDuration: TimeInterval = 300 // 5 minutos
    
    // MARK: - Computed Properties
    var isLoading: Bool { loadingState.isLoading }
    var errorMessage: String? { loadingState.errorMessage }
    
    var totalIncome: Double {
        netSalary + otherIncome
    }
    
    var totalExpenses: Double {
        categoryExpenses.values.reduce(0, +)
    }
    
    var balance: Double {
        totalIncome - totalExpenses
    }
    
    var isOverBudget: Bool {
        balance < 0
    }
    
    var mandatoryExpenses: Double {
        ExpenseCategory.allCases
            .filter { $0.isMandatory }
            .compactMap { categoryExpenses[$0] }
            .reduce(0, +)
    }
    
    var reducibleExpenses: Double {
        ExpenseCategory.allCases
            .filter { $0.isReducible }
            .compactMap { categoryExpenses[$0] }
            .reduce(0, +)
    }
    
    var variableExpenses: Double {
        ExpenseCategory.allCases
            .filter { $0.isVariable }
            .compactMap { categoryExpenses[$0] }
            .reduce(0, +)
    }
    
    // MARK: - Initialization
    init() {
        initializeCategoryExpenses()
        Task {
            await fetchExpenses()
        }
    }
    
    // MARK: - Cache Management
    private var isCacheValid: Bool {
        guard let lastFetch = lastFetchDate else { return false }
        return Date().timeIntervalSince(lastFetch) < cacheValidityDuration
    }
    
    func invalidateCache() {
        lastFetchDate = nil
    }
    
    // MARK: - API Methods
    
    /// Obtiene los gastos del servidor
    func fetchExpenses(startDate: Date? = nil, endDate: Date? = nil, category: ExpenseCategory? = nil, forceRefresh: Bool = false) async {
        if !forceRefresh && isCacheValid && startDate == nil && endDate == nil && category == nil {
            return
        }
        
        loadingState = .loading
        
        do {
            let dtos = try await apiClient.getExpenses(
                startDate: startDate,
                endDate: endDate,
                category: category?.rawValue
            )
            
            self.expenses = dtos.map { $0.toExpense() }
            self.lastFetchDate = Date()
            recalculateCategoryTotals()
            loadingState = .loaded
        } catch let error as APIError {
            loadingState = .error(error.errorDescription ?? "Error desconocido")
            logError("fetchExpenses", error: error)
        } catch {
            loadingState = .error("Error de conexión: \(error.localizedDescription)")
            logError("fetchExpenses", error: error)
        }
    }
    
    /// Agrega un nuevo gasto
    func addExpense(_ expense: Expense) async {
        loadingState = .loading
        
        do {
            let dto = ExpenseDto(
                amount: expense.amount,
                category: expense.category.rawValue,
                date: expense.date,
                description: expense.description,
                isRecurring: expense.isRecurring,
                recurringPeriod: expense.recurringPeriod?.rawValue,
                notes: expense.notes,
                receiptImage: expense.receiptImage?.base64EncodedString()
            )
            
            let responseDto = try await apiClient.createExpense(dto)
            let newExpense = responseDto.toExpense()
            
            expenses.insert(newExpense, at: 0)
            expenses.sort { $0.date > $1.date }
            recalculateCategoryTotals()
            showAddExpense = false
            loadingState = .loaded
            
            HapticFeedback.success()
        } catch let error as APIError {
            loadingState = .error(error.errorDescription ?? "Error al crear gasto")
            logError("addExpense", error: error)
            HapticFeedback.error()
        } catch {
            loadingState = .error("Error al crear gasto: \(error.localizedDescription)")
            logError("addExpense", error: error)
            HapticFeedback.error()
        }
    }
    
    /// Elimina un gasto
    func removeExpense(_ expense: Expense) async {
        guard let index = expenses.firstIndex(where: { $0.id == expense.id }) else {
            loadingState = .error("Gasto no encontrado")
            return
        }
        
        loadingState = .loading
        
        do {
            try await apiClient.deleteExpense(id: expense.id)
            expenses.remove(at: index)
            recalculateCategoryTotals()
            loadingState = .loaded
            
            HapticFeedback.success()
        } catch let error as APIError {
            loadingState = .error(error.errorDescription ?? "Error al eliminar")
            logError("removeExpense", error: error)
            HapticFeedback.error()
        } catch {
            loadingState = .error("Error al eliminar: \(error.localizedDescription)")
            logError("removeExpense", error: error)
            HapticFeedback.error()
        }
    }
    
    /// Actualiza un gasto existente
    func updateExpense(_ expense: Expense) async {
        guard let index = expenses.firstIndex(where: { $0.id == expense.id }) else {
            loadingState = .error("Gasto no encontrado")
            return
        }
        
        loadingState = .loading
        
        do {
            let dto = ExpenseDto(
                amount: expense.amount,
                category: expense.category.rawValue,
                date: expense.date,
                description: expense.description,
                isRecurring: expense.isRecurring,
                recurringPeriod: expense.recurringPeriod?.rawValue,
                notes: expense.notes,
                receiptImage: expense.receiptImage?.base64EncodedString()
            )
            
            try await apiClient.updateExpense(id: expense.id, dto)
            expenses[index] = expense
            expenses.sort { $0.date > $1.date }
            recalculateCategoryTotals()
            loadingState = .loaded
            
            HapticFeedback.success()
        } catch let error as APIError {
            loadingState = .error(error.errorDescription ?? "Error al actualizar")
            logError("updateExpense", error: error)
            HapticFeedback.error()
        } catch {
            loadingState = .error("Error al actualizar: \(error.localizedDescription)")
            logError("updateExpense", error: error)
            HapticFeedback.error()
        }
    }
    
    // MARK: - Helper Methods
    
    func getCategoryAmount(_ category: ExpenseCategory) -> Double {
        return categoryExpenses[category] ?? 0.0
    }
    
    func updateCategoryAmount(_ category: ExpenseCategory, amount: Double) {
        guard amount >= 0 else { return } // Validación básica
        categoryExpenses[category] = amount
        objectWillChange.send()
    }
    
    func getExpensesByCategory(_ category: ExpenseCategory) -> [Expense] {
        return expenses.filter { $0.category == category }
    }
    
    func getExpensesByPeriod(_ startDate: Date, _ endDate: Date) -> [Expense] {
        return expenses.filter { expense in
            expense.date >= startDate && expense.date <= endDate
        }
    }
    
    func clearError() {
        if case .error = loadingState {
            loadingState = .idle
        }
    }
    
    /// Limpia todos los gastos (usar con precaución)
    func clearAllExpenses() async {
        loadingState = .loading
        var errors: [Error] = []
        
        for expense in expenses {
            do {
                try await apiClient.deleteExpense(id: expense.id)
            } catch {
                errors.append(error)
                logError("clearAllExpenses", error: error)
            }
        }
        
        if errors.isEmpty {
            expenses.removeAll()
            initializeCategoryExpenses()
            loadingState = .loaded
            HapticFeedback.success()
        } else {
            loadingState = .error("Error al eliminar \(errors.count) gastos")
            HapticFeedback.error()
            // Refrescar para sincronizar
            await fetchExpenses(forceRefresh: true)
        }
    }
    
    // MARK: - Private Methods
    
    private func initializeCategoryExpenses() {
        for category in ExpenseCategory.allCases {
            categoryExpenses[category] = 0.0
        }
    }
    
    private func recalculateCategoryTotals() {
        initializeCategoryExpenses()
        
        for expense in expenses {
            let currentAmount = categoryExpenses[expense.category] ?? 0.0
            categoryExpenses[expense.category] = currentAmount + expense.amount
        }
    }
    
    private func logError(_ method: String, error: Error) {
        #if DEBUG
        print("❌ ExpensesViewModel.\(method): \(error.localizedDescription)")
        #endif
    }
}
