import Foundation

struct Deduction: Identifiable, Codable {
    var id = UUID()
    var type: DeductionType
    var amount: Double
    var percentage: Double?
    var date: Date
    var description: String?
    
    enum DeductionType: String, CaseIterable, Codable {
        case isr = "ISR"
        case imss = "IMSS"
        case employmentSubsidy = "Subsidio al Empleo"
        case other = "Otro"
        
        var icon: String {
            switch self {
            case .isr: return "dollarsign.circle.fill"
            case .imss: return "cross.circle.fill"
            case .employmentSubsidy: return "hand.raised.fill"
            case .other: return "questionmark.circle.fill"
            }
        }
    }
}
