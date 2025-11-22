import Foundation
import SwiftUI

class IncomeViewModel: ObservableObject {
    @Published var incomes: [Income] = []
    @Published var showAddIncome = false
    @Published var currentTaxCalculation: TaxCalculation?
    
    var totalGrossIncome: Double {
        incomes.reduce(0) { $0 + $1.grossAmount }
    }
    
    var totalNetIncome: Double {
        incomes.reduce(0) { $0 + $1.netAmount }
    }
    
    var totalDeductions: Double {
        incomes.reduce(0) { $0 + ($1.grossAmount - $1.netAmount) }
    }
    
    init() {
        loadSampleData()
    }
    
    func addIncome(_ income: Income) {
        incomes.append(income)
        updateTaxCalculation()
        objectWillChange.send()
    }
    
    func deleteIncome(at offsets: IndexSet) {
        incomes.remove(atOffsets: offsets)
        updateTaxCalculation()
        objectWillChange.send()
    }
    
    func updateIncome(_ income: Income) {
        if let index = incomes.firstIndex(where: { $0.id == income.id }) {
            incomes[index] = income
            updateTaxCalculation()
            objectWillChange.send()
        }
    }
    
    private func updateTaxCalculation() {
        if let highestIncome = incomes.max(by: { $0.grossAmount < $1.grossAmount }) {
            currentTaxCalculation = TaxCalculation(grossSalary: highestIncome.grossAmount)
        } else {
            currentTaxCalculation = nil
        }
    }
    
    func getIncomeByPeriod(_ startDate: Date, _ endDate: Date) -> [Income] {
        return incomes.filter { income in
            income.date >= startDate && income.date <= endDate
        }
    }
    
    func getIncomeByType(_ type: Income.IncomeType) -> [Income] {
        return incomes.filter { $0.type == type }
    }
    
    func getRecurringIncomes() -> [Income] {
        return incomes.filter { $0.isRecurring }
    }
    
    private func loadSampleData() {
        // Datos de ejemplo
        let sampleIncomes = [
            Income(
                grossAmount: 25000,
                netAmount: 21328,
                date: Date(),
                type: .freelance,
                description: "Proyecto desarrollo web",
                isRecurring: true,
                recurringPeriod: .monthly
            ),
            Income(
                grossAmount: 15000,
                netAmount: 12799,
                date: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date(),
                type: .freelance,
                description: "Consultoría técnica",
                isRecurring: false
            )
        ]
        
        incomes = sampleIncomes
        updateTaxCalculation()
    }
}
