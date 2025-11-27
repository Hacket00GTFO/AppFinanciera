import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case networkError(Error)
    case httpError(statusCode: Int, message: String)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .invalidResponse:
            return "Respuesta inválida del servidor"
        case .decodingError(let error):
            return "Error al decodificar datos: \(error.localizedDescription)"
        case .networkError(let error):
            return "Error de red: \(error.localizedDescription)"
        case .httpError(let statusCode, let message):
            return "Error HTTP \(statusCode): \(message)"
        case .unknownError:
            return "Error desconocido"
        }
    }
}

class APIClient {
    static let shared = APIClient()
    
    private let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        // Leer baseURL de Info.plist, con fallback a localhost
        if let urlFromPlist = Bundle.main.infoDictionary?["API_BASE_URL"] as? String {
            self.baseURL = urlFromPlist
        } else {
            self.baseURL = "http://localhost:5000/api"
        }
        
        // Configurar URLSession con timeout
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
        
        // Configurar JSONDecoder para manejar fechas ISO8601 y conversión de UUID
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // Configurar JSONEncoder
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
    }
    
    // MARK: - Generic Request Method
    
    private func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let message = String(data: data, encoding: .utf8) ?? "Error desconocido"
                throw APIError.httpError(statusCode: httpResponse.statusCode, message: message)
            }
            
            let decodedData = try decoder.decode(T.self, from: data)
            return decodedData
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Income Endpoints
    
    func getIncomes(startDate: Date? = nil, endDate: Date? = nil) async throws -> [IncomeResponseDto] {
        var endpoint = "/incomes"
        var queryParams: [String] = []
        
        if let startDate = startDate {
            queryParams.append("startDate=\(ISO8601DateFormatter().string(from: startDate))")
        }
        if let endDate = endDate {
            queryParams.append("endDate=\(ISO8601DateFormatter().string(from: endDate))")
        }
        
        if !queryParams.isEmpty {
            endpoint += "?" + queryParams.joined(separator: "&")
        }
        
        return try await request(endpoint: endpoint)
    }
    
    func getIncome(id: UUID) async throws -> IncomeResponseDto {
        try await request(endpoint: "/incomes/\(id.uuidString)")
    }
    
    func createIncome(_ income: IncomeDto) async throws -> IncomeResponseDto {
        try await request(endpoint: "/incomes", method: "POST", body: income)
    }
    
    func updateIncome(id: UUID, _ income: IncomeDto) async throws -> Void {
        _ = try await request(endpoint: "/incomes/\(id.uuidString)", method: "PUT", body: income) as EmptyResponse
    }
    
    func deleteIncome(id: UUID) async throws -> Void {
        _ = try await request(endpoint: "/incomes/\(id.uuidString)", method: "DELETE") as EmptyResponse
    }
    
    func getIncomesSummary(startDate: Date? = nil, endDate: Date? = nil) async throws -> [String: AnyCodable] {
        var endpoint = "/incomes/summary"
        var queryParams: [String] = []
        
        if let startDate = startDate {
            queryParams.append("startDate=\(ISO8601DateFormatter().string(from: startDate))")
        }
        if let endDate = endDate {
            queryParams.append("endDate=\(ISO8601DateFormatter().string(from: endDate))")
        }
        
        if !queryParams.isEmpty {
            endpoint += "?" + queryParams.joined(separator: "&")
        }
        
        return try await request(endpoint: endpoint)
    }
    
    // MARK: - Expense Endpoints
    
    func getExpenses(startDate: Date? = nil, endDate: Date? = nil, category: String? = nil) async throws -> [ExpenseResponseDto] {
        var endpoint = "/expenses"
        var queryParams: [String] = []
        
        if let startDate = startDate {
            queryParams.append("startDate=\(ISO8601DateFormatter().string(from: startDate))")
        }
        if let endDate = endDate {
            queryParams.append("endDate=\(ISO8601DateFormatter().string(from: endDate))")
        }
        if let category = category {
            queryParams.append("category=\(category)")
        }
        
        if !queryParams.isEmpty {
            endpoint += "?" + queryParams.joined(separator: "&")
        }
        
        return try await request(endpoint: endpoint)
    }
    
    func getExpense(id: UUID) async throws -> ExpenseResponseDto {
        try await request(endpoint: "/expenses/\(id.uuidString)")
    }
    
    func createExpense(_ expense: ExpenseDto) async throws -> ExpenseResponseDto {
        try await request(endpoint: "/expenses", method: "POST", body: expense)
    }
    
    func updateExpense(id: UUID, _ expense: ExpenseDto) async throws -> Void {
        _ = try await request(endpoint: "/expenses/\(id.uuidString)", method: "PUT", body: expense) as EmptyResponse
    }
    
    func deleteExpense(id: UUID) async throws -> Void {
        _ = try await request(endpoint: "/expenses/\(id.uuidString)", method: "DELETE") as EmptyResponse
    }
    
    func getExpensesSummary(startDate: Date? = nil, endDate: Date? = nil) async throws -> [String: AnyCodable] {
        var endpoint = "/expenses/summary"
        var queryParams: [String] = []
        
        if let startDate = startDate {
            queryParams.append("startDate=\(ISO8601DateFormatter().string(from: startDate))")
        }
        if let endDate = endDate {
            queryParams.append("endDate=\(ISO8601DateFormatter().string(from: endDate))")
        }
        
        if !queryParams.isEmpty {
            endpoint += "?" + queryParams.joined(separator: "&")
        }
        
        return try await request(endpoint: endpoint)
    }
    
    // MARK: - Deduction Endpoints
    
    func getDeductions() async throws -> [DeductionResponseDto] {
        try await request(endpoint: "/deductions")
    }
    
    func getDeduction(id: UUID) async throws -> DeductionResponseDto {
        try await request(endpoint: "/deductions/\(id.uuidString)")
    }
    
    func createDeduction(_ deduction: DeductionDto) async throws -> DeductionResponseDto {
        try await request(endpoint: "/deductions", method: "POST", body: deduction)
    }
    
    func updateDeduction(id: UUID, _ deduction: DeductionDto) async throws -> Void {
        _ = try await request(endpoint: "/deductions/\(id.uuidString)", method: "PUT", body: deduction) as EmptyResponse
    }
    
    func deleteDeduction(id: UUID) async throws -> Void {
        _ = try await request(endpoint: "/deductions/\(id.uuidString)", method: "DELETE") as EmptyResponse
    }
    
    // MARK: - TaxCalculation Endpoints
    
    func getTaxCalculations() async throws -> [TaxCalculationResponseDto] {
        try await request(endpoint: "/taxcalculations")
    }
    
    func getTaxCalculation(id: UUID) async throws -> TaxCalculationResponseDto {
        try await request(endpoint: "/taxcalculations/\(id.uuidString)")
    }
    
    func calculateTax(_ calculation: TaxCalculationDto) async throws -> TaxCalculationResponseDto {
        try await request(endpoint: "/taxcalculations/calculate", method: "POST", body: calculation)
    }
}

// MARK: - DTOs for API Communication

struct IncomeDto: Codable {
    let grossAmount: Double
    let netAmount: Double
    let date: Date
    let type: String
    let description: String
    let isRecurring: Bool
    let recurringPeriod: String?
}

struct IncomeResponseDto: Codable, Identifiable {
    let id: UUID
    let grossAmount: Double
    let netAmount: Double
    let date: Date
    let type: String
    let description: String
    let isRecurring: Bool
    let recurringPeriod: String?
    let createdAt: Date
    let updatedAt: Date
}

struct ExpenseDto: Codable {
    let amount: Double
    let category: String
    let date: Date
    let description: String
    let isRecurring: Bool
    let recurringPeriod: String?
    let notes: String?
    let receiptImage: String?
}

struct ExpenseResponseDto: Codable, Identifiable {
    let id: UUID
    let amount: Double
    let category: String
    let date: Date
    let description: String
    let isRecurring: Bool
    let recurringPeriod: String?
    let notes: String?
    let receiptImage: String?
    let createdAt: Date
    let updatedAt: Date
}

struct DeductionDto: Codable {
    let type: String
    let amount: Double
    let percentage: Double?
    let date: Date
    let description: String?
}

struct DeductionResponseDto: Codable, Identifiable {
    let id: UUID
    let type: String
    let amount: Double
    let percentage: Double?
    let date: Date
    let description: String?
    let createdAt: Date
    let updatedAt: Date
}

struct TaxCalculationDto: Codable {
    let grossSalary: Double
}

struct TaxCalculationResponseDto: Codable, Identifiable {
    let id: UUID
    let grossSalary: Double
    let lowerLimit: Double
    let excessOverLowerLimit: Double
    let marginalPercentage: Double
    let marginalTax: Double
    let fixedTaxQuota: Double
    let totalISR: Double
    let imss: Double
    let employmentSubsidy: Double
    let date: Date
    let netSalary: Double
    let createdAt: Date
    let updatedAt: Date
}

struct EmptyResponse: Codable {}

// MARK: - AnyCodable for dynamic JSON

enum AnyCodable: Codable {
    case null
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    case array([AnyCodable])
    case object([String: AnyCodable])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .null
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([AnyCodable].self) {
            self = .array(array)
        } else if let object = try? container.decode([String: AnyCodable].self) {
            self = .object(object)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode AnyCodable")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .null:
            try container.encodeNil()
        case .bool(let bool):
            try container.encode(bool)
        case .int(let int):
            try container.encode(int)
        case .double(let double):
            try container.encode(double)
        case .string(let string):
            try container.encode(string)
        case .array(let array):
            try container.encode(array)
        case .object(let object):
            try container.encode(object)
        }
    }
}
