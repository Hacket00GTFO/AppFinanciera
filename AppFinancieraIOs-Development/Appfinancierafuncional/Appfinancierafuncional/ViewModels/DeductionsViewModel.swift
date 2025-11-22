import Foundation
import SwiftUI

class DeductionsViewModel: ObservableObject {
    @Published var deductions: [Deduction] = []
    @Published var showAddDeduction = false
    @Published var currentTaxCalculation: TaxCalculation?
    
    var totalISR: Double {
        deductions.filter { $0.type == .isr }.reduce(0) { $0 + $1.amount }
    }
    
    var totalIMSS: Double {
        deductions.filter { $0.type == .imss }.reduce(0) { $0 + $1.amount }
    }
    
    var totalOtherDeductions: Double {
        deductions.filter { $0.type != .isr && $0.type != .imss }.reduce(0) { $0 + $1.amount }
    }
    
    var totalDeductions: Double {
        deductions.reduce(0) { $0 + $1.amount }
    }
    
    init() {
        loadSampleData()
    }
    
    func addDeduction(_ deduction: Deduction) {
        deductions.append(deduction)
        updateTaxCalculation()
        objectWillChange.send()
    }
    
    func deleteDeduction(at offsets: IndexSet) {
        deductions.remove(atOffsets: offsets)
        updateTaxCalculation()
        objectWillChange.send()
    }
    
    func updateDeduction(_ deduction: Deduction) {
        if let index = deductions.firstIndex(where: { $0.id == deduction.id }) {
            deductions[index] = deduction
            updateTaxCalculation()
            objectWillChange.send()
        }
    }
    
    private func updateTaxCalculation() {
        // Simular un cálculo fiscal basado en deducciones totales
        let estimatedGrossSalary = totalDeductions * 3.5 // Estimación aproximada
        currentTaxCalculation = TaxCalculation(grossSalary: estimatedGrossSalary)
    }
    
    func getDeductionsByType(_ type: Deduction.DeductionType) -> [Deduction] {
        return deductions.filter { $0.type == type }
    }
    
    func getDeductionsByPeriod(_ startDate: Date, _ endDate: Date) -> [Deduction] {
        return deductions.filter { deduction in
            deduction.date >= startDate && deduction.date <= endDate
        }
    }
    
    func calculateTaxDeduction(for grossSalary: Double) -> TaxCalculation {
        return TaxCalculation(grossSalary: grossSalary)
    }
    
    private func loadSampleData() {
        // Datos de ejemplo
        let sampleDeductions = [
            Deduction(
                type: .isr,
                amount: 3672.0,
                percentage: 21.36,
                date: Date(),
                description: "ISR mensual"
            ),
            Deduction(
                type: .imss,
                amount: 687.23,
                percentage: 2.75,
                date: Date(),
                description: "IMSS mensual"
            ),
            Deduction(
                type: .employmentSubsidy,
                amount: 0.0,
                date: Date(),
                description: "Sin subsidio aplicable"
            )
        ]
        
        deductions = sampleDeductions
        updateTaxCalculation()
    }
}
