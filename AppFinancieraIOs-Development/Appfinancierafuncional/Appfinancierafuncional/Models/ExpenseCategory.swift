import Foundation

enum ExpenseCategory: String, CaseIterable, Codable {
    // Fijos obligatorios
    case rent = "Alquiler/Hipoteca"
    case loans = "Préstamos"
    case taxes = "Impuestos"
    case others = "Otros"
    
    // Fijos reducibles
    case water = "Agua"
    case gas = "Gas"
    case electricity = "Luz"
    case internet = "Internet + Tel + TV"
    case food = "Alimentación"
    case transport = "Transporte"
    case education = "Escolares"
    case contingencies = "Imprevistos"
    
    // Variables
    case leisure = "Ocio"
    case travel = "Viajes"
    case subscriptions = "Suscripciones"
    case otherExpenses = "Otros Gastos"
    
    var icon: String {
        switch self {
        case .rent: return "house.fill"
        case .loans: return "clock.fill"
        case .taxes: return "dollarsign.circle.fill"
        case .others: return "exclamationmark.triangle.fill"
        case .water: return "drop.fill"
        case .gas: return "flame.fill"
        case .electricity: return "lightbulb.fill"
        case .internet: return "wifi"
        case .food: return "cart.fill"
        case .transport: return "bus.fill"
        case .education: return "graduationcap.fill"
        case .contingencies: return "exclamationmark.triangle.fill"
        case .leisure: return "gamecontroller.fill"
        case .travel: return "airplane"
        case .subscriptions: return "arrow.clockwise.circle.fill"
        case .otherExpenses: return "questionmark.circle.fill"
        }
    }
    
    var isMandatory: Bool {
        switch self {
        case .rent, .loans, .taxes, .others:
            return true
        default:
            return false
        }
    }
    
    var isReducible: Bool {
        switch self {
        case .water, .gas, .electricity, .internet, .food, .transport, .education, .contingencies:
            return true
        default:
            return false
        }
    }
    
    var isVariable: Bool {
        switch self {
        case .leisure, .travel, .subscriptions, .otherExpenses:
            return true
        default:
            return false
        }
    }
    
    var color: String {
        if isMandatory { return "red" }
        if isReducible { return "blue" }
        if isVariable { return "orange" }
        return "gray"
    }
}
