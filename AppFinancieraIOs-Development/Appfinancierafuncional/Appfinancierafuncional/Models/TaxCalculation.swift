import Foundation

// MARK: - Tax Bracket for ISR Calculation (Mexico 2024)
/// Tabla de ISR mensual según SAT México 2024
struct TaxBracket {
    let lowerLimit: Decimal
    let upperLimit: Decimal
    let fixedQuota: Decimal
    let marginalRate: Decimal // Porcentaje expresado como decimal (e.g., 0.0192 = 1.92%)
    
    /// Calcula el ISR para un ingreso gravable dado
    func calculateTax(for taxableIncome: Decimal) -> Decimal {
        guard taxableIncome >= lowerLimit else { return 0 }
        
        let excess = taxableIncome - lowerLimit
        let marginalTax = excess * marginalRate
        return fixedQuota + marginalTax
    }
}

// MARK: - Tax Tables (ISR Mexico 2024)
struct TaxTables {
    /// Tabla ISR mensual 2024 según SAT México
    /// Fuente: DOF (Diario Oficial de la Federación)
    static let monthlyISRBrackets: [TaxBracket] = [
        TaxBracket(lowerLimit: 0.01, upperLimit: 746.04, fixedQuota: 0, marginalRate: 0.0192),
        TaxBracket(lowerLimit: 746.05, upperLimit: 6332.05, fixedQuota: 14.32, marginalRate: 0.0640),
        TaxBracket(lowerLimit: 6332.06, upperLimit: 11128.01, fixedQuota: 371.83, marginalRate: 0.1088),
        TaxBracket(lowerLimit: 11128.02, upperLimit: 12935.82, fixedQuota: 893.63, marginalRate: 0.1600),
        TaxBracket(lowerLimit: 12935.83, upperLimit: 15487.71, fixedQuota: 1182.88, marginalRate: 0.1792),
        TaxBracket(lowerLimit: 15487.72, upperLimit: 31236.49, fixedQuota: 1640.18, marginalRate: 0.2136),
        TaxBracket(lowerLimit: 31236.50, upperLimit: 49233.00, fixedQuota: 5004.12, marginalRate: 0.2352),
        TaxBracket(lowerLimit: 49233.01, upperLimit: 93993.90, fixedQuota: 9236.89, marginalRate: 0.3000),
        TaxBracket(lowerLimit: 93993.91, upperLimit: 125325.20, fixedQuota: 22665.17, marginalRate: 0.3200),
        TaxBracket(lowerLimit: 125325.21, upperLimit: 375975.61, fixedQuota: 32691.18, marginalRate: 0.3400),
        TaxBracket(lowerLimit: 375975.62, upperLimit: Decimal.greatestFiniteMagnitude, fixedQuota: 117912.32, marginalRate: 0.3500)
    ]
    
    /// Tabla de subsidio al empleo mensual 2024
    static let employmentSubsidyBrackets: [(lowerLimit: Decimal, upperLimit: Decimal, subsidy: Decimal)] = [
        (0.01, 1768.96, 407.02),
        (1768.97, 2653.38, 406.83),
        (2653.39, 3472.84, 406.62),
        (3472.85, 3537.87, 392.77),
        (3537.88, 4446.15, 382.46),
        (4446.16, 4717.18, 354.23),
        (4717.19, 5335.42, 324.87),
        (5335.43, 6224.67, 294.63),
        (6224.68, 7113.90, 253.54),
        (7113.91, 7382.33, 217.61),
        (7382.34, Decimal.greatestFiniteMagnitude, 0)
    ]
    
    /// Encuentra el bracket de ISR para un ingreso dado
    static func findISRBracket(for income: Decimal) -> TaxBracket? {
        return monthlyISRBrackets.first { bracket in
            income >= bracket.lowerLimit && income <= bracket.upperLimit
        }
    }
    
    /// Calcula el subsidio al empleo para un ingreso dado
    static func calculateEmploymentSubsidy(for income: Decimal) -> Decimal {
        guard let bracket = employmentSubsidyBrackets.first(where: { income >= $0.lowerLimit && income <= $0.upperLimit }) else {
            return 0
        }
        return bracket.subsidy
    }
}

// MARK: - IMSS Calculation
struct IMSSCalculation {
    /// Cuota obrera IMSS (porcentaje sobre salario base de cotización)
    /// Desglose de cuotas obreras 2024:
    /// - Enfermedad y maternidad: 0.625%
    /// - Invalidez y vida: 0.625%
    /// - Cesantía y vejez: 1.125%
    /// - Retiro: 0% (lo paga el patrón)
    static let employeeContributionRate: Decimal = 0.02375 // 2.375% total
    
    /// Tope máximo de cotización (25 UMAs mensuales)
    /// UMA 2024: $108.57 diarios
    static let maxContributionBase: Decimal = 81427.50 // 25 * 108.57 * 30
    
    /// Calcula la cuota obrera del IMSS
    static func calculate(for salary: Decimal) -> Decimal {
        let contributionBase = min(salary, maxContributionBase)
        return contributionBase * employeeContributionRate
    }
}

// MARK: - Tax Calculation Model
struct TaxCalculation: Identifiable, Codable {
    var id: UUID
    var grossSalary: Decimal
    var lowerLimit: Decimal
    var excessOverLowerLimit: Decimal
    var marginalPercentage: Decimal
    var marginalTax: Decimal
    var fixedTaxQuota: Decimal
    var totalISR: Decimal
    var imss: Decimal
    var employmentSubsidy: Decimal
    var date: Date
    
    /// Salario neto calculado
    var netSalary: Decimal {
        grossSalary - totalISR - imss + employmentSubsidy
    }
    
    /// Tasa efectiva de impuesto
    var effectiveTaxRate: Decimal {
        guard grossSalary > 0 else { return 0 }
        return (totalISR + imss - employmentSubsidy) / grossSalary
    }
    
    /// Inicializador que calcula automáticamente todos los valores fiscales
    init(
        id: UUID = UUID(),
        grossSalary: Double,
        date: Date = Date()
    ) {
        self.id = id
        self.grossSalary = Decimal(grossSalary)
        self.date = date
        
        // Encontrar el bracket de ISR correspondiente
        let salary = Decimal(grossSalary)
        
        if let bracket = TaxTables.findISRBracket(for: salary) {
            self.lowerLimit = bracket.lowerLimit
            self.excessOverLowerLimit = max(0, salary - bracket.lowerLimit)
            self.marginalPercentage = bracket.marginalRate * 100 // Convertir a porcentaje para display
            self.fixedTaxQuota = bracket.fixedQuota
            self.marginalTax = self.excessOverLowerLimit * bracket.marginalRate
            self.totalISR = bracket.calculateTax(for: salary)
        } else {
            // Valores por defecto si el salario está fuera de rango
            self.lowerLimit = 0
            self.excessOverLowerLimit = 0
            self.marginalPercentage = 0
            self.fixedTaxQuota = 0
            self.marginalTax = 0
            self.totalISR = 0
        }
        
        // Calcular IMSS
        self.imss = IMSSCalculation.calculate(for: salary)
        
        // Calcular subsidio al empleo
        self.employmentSubsidy = TaxTables.calculateEmploymentSubsidy(for: salary)
    }
    
    /// Inicializador completo para valores del servidor
    init(
        id: UUID,
        grossSalary: Decimal,
        lowerLimit: Decimal,
        excessOverLowerLimit: Decimal,
        marginalPercentage: Decimal,
        marginalTax: Decimal,
        fixedTaxQuota: Decimal,
        totalISR: Decimal,
        imss: Decimal,
        employmentSubsidy: Decimal,
        date: Date
    ) {
        self.id = id
        self.grossSalary = grossSalary
        self.lowerLimit = lowerLimit
        self.excessOverLowerLimit = excessOverLowerLimit
        self.marginalPercentage = marginalPercentage
        self.marginalTax = marginalTax
        self.fixedTaxQuota = fixedTaxQuota
        self.totalISR = totalISR
        self.imss = imss
        self.employmentSubsidy = employmentSubsidy
        self.date = date
    }
}

// MARK: - Decimal to Double Helpers for SwiftUI
extension TaxCalculation {
    /// Convierte grossSalary a Double para uso en SwiftUI
    var grossSalaryDouble: Double { NSDecimalNumber(decimal: grossSalary).doubleValue }
    var netSalaryDouble: Double { NSDecimalNumber(decimal: netSalary).doubleValue }
    var totalISRDouble: Double { NSDecimalNumber(decimal: totalISR).doubleValue }
    var imssDouble: Double { NSDecimalNumber(decimal: imss).doubleValue }
    var employmentSubsidyDouble: Double { NSDecimalNumber(decimal: employmentSubsidy).doubleValue }
    var lowerLimitDouble: Double { NSDecimalNumber(decimal: lowerLimit).doubleValue }
    var excessOverLowerLimitDouble: Double { NSDecimalNumber(decimal: excessOverLowerLimit).doubleValue }
    var marginalPercentageDouble: Double { NSDecimalNumber(decimal: marginalPercentage).doubleValue }
    var marginalTaxDouble: Double { NSDecimalNumber(decimal: marginalTax).doubleValue }
    var fixedTaxQuotaDouble: Double { NSDecimalNumber(decimal: fixedTaxQuota).doubleValue }
    var effectiveTaxRateDouble: Double { NSDecimalNumber(decimal: effectiveTaxRate).doubleValue }
}

// MARK: - Tax Calculation Summary
extension TaxCalculation {
    /// Genera un resumen legible del cálculo fiscal
    var summary: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_MX")
        formatter.currencyCode = "MXN"
        
        let grossStr = formatter.string(from: NSDecimalNumber(decimal: grossSalary)) ?? "$0.00"
        let netStr = formatter.string(from: NSDecimalNumber(decimal: netSalary)) ?? "$0.00"
        let isrStr = formatter.string(from: NSDecimalNumber(decimal: totalISR)) ?? "$0.00"
        let imssStr = formatter.string(from: NSDecimalNumber(decimal: imss)) ?? "$0.00"
        let subsidyStr = formatter.string(from: NSDecimalNumber(decimal: employmentSubsidy)) ?? "$0.00"
        
        return """
        📊 Resumen Fiscal
        ────────────────────
        Salario Bruto: \(grossStr)
        ISR: -\(isrStr)
        IMSS: -\(imssStr)
        Subsidio: +\(subsidyStr)
        ────────────────────
        Salario Neto: \(netStr)
        """
    }
}
