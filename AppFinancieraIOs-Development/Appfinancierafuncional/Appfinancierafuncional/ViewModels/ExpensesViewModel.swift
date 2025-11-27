import Foundation
import SwiftUI

class ExpensesViewModel: ObservableObject {
    @Published var netSalary: Double = 0.0
    @Published var otherIncome: Double = 0.0
    @Published var expenses: [Expense] = []
    @Published var categoryExpenses: [ExpenseCategory: Double] = [:]
    @Published var showAddExpense = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient = APIClient.shared
    
    var totalIncome: Double {
        netSalary + otherIncome
    }
    
    var totalExpenses: Double {
        categoryExpenses.values.reduce(0, +)
    }
    
    var balance: Double {
        totalIncome - totalExpenses
    }
    
    init() {
        // Inicializar todas las categorías con 0
        for category in ExpenseCategory.allCases {
            categoryExpenses[category] = 0.0
        }
        
        Task {
            await fetchExpenses()
        }
    }
    
    // MARK: - API Methods
    
    @MainActor
    func fetchExpenses(startDate: Date? = nil, endDate: Date? = nil, category: ExpenseCategory? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let dtos = try await apiClient.getExpenses(
                startDate: startDate,
                endDate: endDate,
                category: category?.rawValue
            )
            
            let expensesList = dtos.map { dto -> Expense in
                Expense(
                    id: dto.id,
                    amount: dto.amount,
                    category: ExpenseCategory(rawValue: dto.category) ?? .other,
                    date: dto.date,
                    description: dto.description,
                    isRecurring: dto.isRecurring,
                    recurringPeriod: dto.recurringPeriod.flatMap { Expense.RecurringPeriod(rawValue: $0) },
                    notes: dto.notes
                )
            }
            
            self.expenses = expensesList
            recalculateCategoryTotals()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func addExpense(_ expense: Expense) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let dto = ExpenseDto(
                amount: expense.amount,
                category: expense.category.rawValue,
                date: expense.date,
                description: expense.description,
                isRecurring: expense.isRecurring,
                recurringPeriod: expense.recurringPeriod?.rawValue,
                notes: expense.notes,
                receiptImage: nil
            )
            
            let responseDto = try await apiClient.createExpense(dto)
            let newExpense = Expense(
                id: responseDto.id,
                amount: responseDto.amount,
                category: ExpenseCategory(rawValue: responseDto.category) ?? .other,
                date: responseDto.date,
                description: responseDto.description,
                isRecurring: responseDto.isRecurring,
                recurringPeriod: responseDto.recurringPeriod.flatMap { Expense.RecurringPeriod(rawValue: $0) },
                notes: responseDto.notes
            )
            
            expenses.append(newExpense)
            recalculateCategoryTotals()
            showAddExpense = false
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func removeExpense(_ expense: Expense) async {
        isLoading = true
        errorMessage = nil
        
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            do {
                try await apiClient.deleteExpense(id: expense.id)
                expenses.remove(at: index)
                recalculateCategoryTotals()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        
        isLoading = false
    }
    
    @MainActor
    func updateExpense(_ expense: Expense) async {
        isLoading = true
        errorMessage = nil
        
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            do {
                let dto = ExpenseDto(
                    amount: expense.amount,
                    category: expense.category.rawValue,
                    date: expense.date,
                    description: expense.description,
                    isRecurring: expense.isRecurring,
                    recurringPeriod: expense.recurringPeriod?.rawValue,
                    notes: expense.notes,
                    receiptImage: nil
                )
                
                try await apiClient.updateExpense(id: expense.id, dto)
                expenses[index] = expense
                recalculateCategoryTotals()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        
        isLoading = false
    }
    
    // MARK: - Helper Methods
    
    func getCategoryAmount(_ category: ExpenseCategory) -> Double {
        return categoryExpenses[category] ?? 0.0
    }
    
    func updateCategoryAmount(_ category: ExpenseCategory, amount: Double) {
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
    
    @MainActor
    func clearAllExpenses() async {
        isLoading = true
        errorMessage = nil
        
        do {
            for expense in expenses {
                try await apiClient.deleteExpense(id: expense.id)
            }
            expenses.removeAll()
            for category in ExpenseCategory.allCases {
                categoryExpenses[category] = 0.0
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func recalculateCategoryTotals() {
        for category in ExpenseCategory.allCases {
            categoryExpenses[category] = 0.0
        }
        
        for expense in expenses {
            let currentAmount = categoryExpenses[expense.category] ?? 0.0
            categoryExpenses[expense.category] = currentAmount + expense.amount
        }
    }
}
