import Foundation
import SwiftUI

class ExpensesViewModel: ObservableObject {
    @Published var netSalary: Double = 0.0
    @Published var otherIncome: Double = 0.0
    @Published var expenses: [Expense] = []
    @Published var categoryExpenses: [ExpenseCategory: Double] = [:]
    @Published var showAddExpense = false
    
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
    }
    
    func getCategoryAmount(_ category: ExpenseCategory) -> Double {
        return categoryExpenses[category] ?? 0.0
    }
    
    func updateCategoryAmount(_ category: ExpenseCategory, amount: Double) {
        categoryExpenses[category] = amount
        objectWillChange.send()
    }
    
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
        // Actualizar el monto de la categoría
        let currentAmount = categoryExpenses[expense.category] ?? 0.0
        categoryExpenses[expense.category] = currentAmount + expense.amount
        objectWillChange.send()
    }
    
    func removeExpense(_ expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses.remove(at: index)
            // Reducir el monto de la categoría
            let currentAmount = categoryExpenses[expense.category] ?? 0.0
            categoryExpenses[expense.category] = max(0, currentAmount - expense.amount)
            objectWillChange.send()
        }
    }
    
    func getExpensesByCategory(_ category: ExpenseCategory) -> [Expense] {
        return expenses.filter { $0.category == category }
    }
    
    func getExpensesByPeriod(_ startDate: Date, _ endDate: Date) -> [Expense] {
        return expenses.filter { expense in
            expense.date >= startDate && expense.date <= endDate
        }
    }
    
    func clearAllExpenses() {
        expenses.removeAll()
        for category in ExpenseCategory.allCases {
            categoryExpenses[category] = 0.0
        }
        objectWillChange.send()
    }
}
