import Foundation

struct Deduction: Identifiable, Codable {
    var id: UUID
    var type: DeductionType
    var amount: Double
    var percentage: Double?
    var date: Date
    var description: String?
    
    init(
        id: UUID = UUID(),
        type: DeductionType,
        amount: Double,
        percentage: Double? = nil,
        date: Date = Date(),
        description: String? = nil
    ) {
        self.id = id
        self.type = type
        self.amount = amount
        self.percentage = percentage
        self.date = date
        self.description = description
    }
    
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
