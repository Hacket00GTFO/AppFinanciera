import Foundation

struct TaxCalculation: Identifiable, Codable {
    var id = UUID()
    var grossSalary: Double
    var lowerLimit: Double
    var excessOverLowerLimit: Double
    var marginalPercentage: Double
    var marginalTax: Double
    var fixedTaxQuota: Double
    var totalISR: Double
    var imss: Double
    var employmentSubsidy: Double
    var date: Date
    
    init(grossSalary: Double) {
        self.grossSalary = grossSalary
        self.lowerLimit = 15487.72 // Límite inferior 2024
        self.excessOverLowerLimit = max(0, grossSalary - lowerLimit)
        self.marginalPercentage = 21.36 // Porcentaje sobre excedente
        self.marginalTax = excessOverLowerLimit * (marginalPercentage / 100)
        self.fixedTaxQuota = 1640.18 // Cuota fija del impuesto
        self.totalISR = marginalTax + fixedTaxQuota
        self.imss = grossSalary * 0.0275 // 2.75% del IMSS
        self.employmentSubsidy = 0.0 // Se calcula según tablas del SAT
        self.date = Date()
    }
    
    var netSalary: Double {
        grossSalary - totalISR - imss + employmentSubsidy
    }
}
