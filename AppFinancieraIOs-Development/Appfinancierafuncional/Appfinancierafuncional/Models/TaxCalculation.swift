import Foundation

struct TaxCalculation: Identifiable, Codable {
    var id: UUID
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
    
    init(
        id: UUID = UUID(),
        grossSalary: Double,
        lowerLimit: Double = 15487.72,
        excessOverLowerLimit: Double? = nil,
        marginalPercentage: Double = 21.36,
        marginalTax: Double? = nil,
        fixedTaxQuota: Double = 1640.18,
        totalISR: Double? = nil,
        imss: Double? = nil,
        employmentSubsidy: Double = 0.0,
        date: Date = Date()
    ) {
        self.id = id
        self.grossSalary = grossSalary
        self.lowerLimit = lowerLimit
        self.excessOverLowerLimit = excessOverLowerLimit ?? max(0, grossSalary - lowerLimit)
        self.marginalPercentage = marginalPercentage
        self.marginalTax = marginalTax ?? (self.excessOverLowerLimit * (marginalPercentage / 100))
        self.fixedTaxQuota = fixedTaxQuota
        self.totalISR = totalISR ?? (self.marginalTax + fixedTaxQuota)
        self.imss = imss ?? (grossSalary * 0.0275)
        self.employmentSubsidy = employmentSubsidy
        self.date = date
    }
    
    var netSalary: Double {
        grossSalary - totalISR - imss + employmentSubsidy
    }
}
