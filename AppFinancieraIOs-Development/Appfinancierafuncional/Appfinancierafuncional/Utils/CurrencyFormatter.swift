import Foundation

struct CurrencyFormatter {
    static let shared = CurrencyFormatter()
    
    private let formatter: NumberFormatter
    
    private init() {
        formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_MX")
        formatter.currencyCode = "MXN"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
    }
    
    // Formateo básico de moneda
    func format(_ amount: Double) -> String {
        return formatter.string(from: NSNumber(value: amount)) ?? "0.00"
    }
    
    // Formateo con símbolo de moneda personalizado
    func format(_ amount: Double, currencyCode: String) -> String {
        let tempFormatter = NumberFormatter()
        tempFormatter.numberStyle = .currency
        tempFormatter.locale = Locale(identifier: "es_MX")
        tempFormatter.currencyCode = currencyCode
        tempFormatter.minimumFractionDigits = 2
        tempFormatter.maximumFractionDigits = 2
        
        return tempFormatter.string(from: NSNumber(value: amount)) ?? "0.00"
    }
    
    // Formateo sin símbolo de moneda
    func formatWithoutSymbol(_ amount: Double) -> String {
        let tempFormatter = NumberFormatter()
        tempFormatter.numberStyle = .decimal
        tempFormatter.minimumFractionDigits = 2
        tempFormatter.maximumFractionDigits = 2
        tempFormatter.groupingSeparator = ","
        tempFormatter.decimalSeparator = "."
        
        return tempFormatter.string(from: NSNumber(value: amount)) ?? "0.00"
    }
    
    // Formateo compacto para grandes cantidades
    func formatCompact(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        
        if amount >= 1_000_000 {
            return "\(formatter.string(from: NSNumber(value: amount / 1_000_000)) ?? "0")M"
        } else if amount >= 1_000 {
            return "\(formatter.string(from: NSNumber(value: amount / 1_000)) ?? "0")K"
        } else {
            return format(amount)
        }
    }
    
    // Formateo para porcentajes
    func formatPercentage(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: value / 100)) ?? "0.00%"
    }
    
    // Formateo para rangos de fechas con montos
    func formatRange(from startAmount: Double, to endAmount: Double) -> String {
        return "\(format(startAmount)) - \(format(endAmount))"
    }
    
    // Formateo para comparativas (con signo)
    func formatWithSign(_ amount: Double) -> String {
        let sign = amount >= 0 ? "+" : ""
        return "\(sign)\(format(amount))"
    }
    
    // Formateo para diferencias
    func formatDifference(from original: Double, to current: Double) -> String {
        let difference = current - original
        let sign = difference >= 0 ? "+" : ""
        let percentage = original > 0 ? (difference / original) * 100 : 0
        
        return "\(sign)\(format(difference)) (\(sign)\(formatPercentage(percentage)))"
    }
    
    // Formateo para resúmenes
    func formatSummary(income: Double, expenses: Double, deductions: Double) -> String {
        let balance = income - expenses - deductions
        let balanceText = balance >= 0 ? "Balance positivo" : "Balance negativo"
        
        return """
        Ingresos: \(format(income))
        Gastos: \(format(expenses))
        Deducciones: \(format(deductions))
        \(balanceText): \(format(balance))
        """
    }
}

// Extension para usar directamente en Double
extension Double {
    var currencyFormatted: String {
        return CurrencyFormatter.shared.format(self)
    }
    
    var compactCurrencyFormatted: String {
        return CurrencyFormatter.shared.formatCompact(self)
    }
    
    var percentageFormatted: String {
        return CurrencyFormatter.shared.formatPercentage(self)
    }
}
