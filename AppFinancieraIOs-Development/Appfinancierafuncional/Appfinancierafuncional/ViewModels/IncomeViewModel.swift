import Foundation
import SwiftUI

// MARK: - Loading State
enum LoadingState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }
}

// MARK: - Income ViewModel
@MainActor
class IncomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var incomes: [Income] = []
    @Published var showAddIncome = false
    @Published private(set) var currentTaxCalculation: TaxCalculation?
    @Published private(set) var loadingState: LoadingState = .idle
    
    // MARK: - Private Properties
    private let apiClient = APIClient.shared
    private var lastFetchDate: Date?
    private let cacheValidityDuration: TimeInterval = 300 // 5 minutos
    
    // MARK: - Computed Properties
    var isLoading: Bool { loadingState.isLoading }
    var errorMessage: String? { loadingState.errorMessage }
    
    var totalGrossIncome: Double {
        incomes.reduce(0) { $0 + $1.grossAmount }
    }
    
    var totalNetIncome: Double {
        incomes.reduce(0) { $0 + $1.netAmount }
    }
    
    var totalDeductions: Double {
        incomes.reduce(0) { $0 + ($1.grossAmount - $1.netAmount) }
    }
    
    var recurringIncomes: [Income] {
        incomes.filter { $0.isRecurring }
    }
    
    var estimatedMonthlyIncome: Double {
        var total = 0.0
        for income in incomes {
            if income.isRecurring, let period = income.recurringPeriod {
                switch period {
                case .weekly:
                    total += income.netAmount * 4.33
                case .biweekly:
                    total += income.netAmount * 2
                case .monthly:
                    total += income.netAmount
                case .yearly:
                    total += income.netAmount / 12
                }
            }
        }
        return total
    }
    
    // MARK: - Initialization
    init() {
        Task {
            await fetchIncomes()
        }
    }
    
    // MARK: - Cache Management
    private var isCacheValid: Bool {
        guard let lastFetch = lastFetchDate else { return false }
        return Date().timeIntervalSince(lastFetch) < cacheValidityDuration
    }
    
    func invalidateCache() {
        lastFetchDate = nil
    }
    
    // MARK: - API Methods
    
    /// Obtiene los ingresos del servidor con caché opcional
    func fetchIncomes(startDate: Date? = nil, endDate: Date? = nil, forceRefresh: Bool = false) async {
        // Usar caché si es válida y no se fuerza actualización
        if !forceRefresh && isCacheValid && startDate == nil && endDate == nil {
            return
        }
        
        loadingState = .loading
        
        do {
            let dtos = try await apiClient.getIncomes(startDate: startDate, endDate: endDate)
            self.incomes = dtos.map { $0.toIncome() }
            self.lastFetchDate = Date()
            updateTaxCalculation()
            loadingState = .loaded
        } catch let error as APIError {
            loadingState = .error(error.errorDescription ?? "Error desconocido")
            logError("fetchIncomes", error: error)
        } catch {
            loadingState = .error("Error de conexión: \(error.localizedDescription)")
            logError("fetchIncomes", error: error)
        }
    }
    
    /// Agrega un nuevo ingreso
    func addIncome(_ income: Income) async {
        loadingState = .loading
        
        do {
            let dto = IncomeDto(
                grossAmount: income.grossAmount,
                netAmount: income.netAmount,
                date: income.date,
                type: income.type.rawValue,
                description: income.description,
                isRecurring: income.isRecurring,
                recurringPeriod: income.recurringPeriod?.rawValue
            )
            
            let responseDto = try await apiClient.createIncome(dto)
            let newIncome = responseDto.toIncome()
            
            incomes.insert(newIncome, at: 0) // Insertar al inicio
            incomes.sort { $0.date > $1.date } // Ordenar por fecha descendente
            updateTaxCalculation()
            showAddIncome = false
            loadingState = .loaded
            
            HapticFeedback.success()
        } catch let error as APIError {
            loadingState = .error(error.errorDescription ?? "Error al crear ingreso")
            logError("addIncome", error: error)
            HapticFeedback.error()
        } catch {
            loadingState = .error("Error al crear ingreso: \(error.localizedDescription)")
            logError("addIncome", error: error)
            HapticFeedback.error()
        }
    }
    
    /// Elimina ingresos en los índices especificados
    func deleteIncome(at offsets: IndexSet) async {
        // Guardar ingresos para posible restauración
        let incomesToDelete = offsets.map { incomes[$0] }
        
        loadingState = .loading
        var deletionFailed = false
        
        for income in incomesToDelete {
            do {
                try await apiClient.deleteIncome(id: income.id)
            } catch {
                deletionFailed = true
                logError("deleteIncome", error: error)
            }
        }
        
        if !deletionFailed {
            // Eliminar localmente solo si la API tuvo éxito
            incomes.remove(atOffsets: offsets)
            updateTaxCalculation()
            loadingState = .loaded
            HapticFeedback.success()
        } else {
            loadingState = .error("Error al eliminar algunos ingresos")
            HapticFeedback.error()
            // Refrescar para sincronizar
            await fetchIncomes(forceRefresh: true)
        }
    }
    
    /// Actualiza un ingreso existente
    func updateIncome(_ income: Income) async {
        guard let index = incomes.firstIndex(where: { $0.id == income.id }) else {
            loadingState = .error("Ingreso no encontrado")
            return
        }
        
        loadingState = .loading
        
        do {
            let dto = IncomeDto(
                grossAmount: income.grossAmount,
                netAmount: income.netAmount,
                date: income.date,
                type: income.type.rawValue,
                description: income.description,
                isRecurring: income.isRecurring,
                recurringPeriod: income.recurringPeriod?.rawValue
            )
            
            try await apiClient.updateIncome(id: income.id, dto)
            incomes[index] = income
            incomes.sort { $0.date > $1.date }
            updateTaxCalculation()
            loadingState = .loaded
            
            HapticFeedback.success()
        } catch let error as APIError {
            loadingState = .error(error.errorDescription ?? "Error al actualizar")
            logError("updateIncome", error: error)
            HapticFeedback.error()
        } catch {
            loadingState = .error("Error al actualizar: \(error.localizedDescription)")
            logError("updateIncome", error: error)
            HapticFeedback.error()
        }
    }
    
    // MARK: - Helper Methods
    
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
    
    func clearError() {
        if case .error = loadingState {
            loadingState = .idle
        }
    }
    
    // MARK: - Private Methods
    
    private func updateTaxCalculation() {
        if let highestIncome = incomes.max(by: { $0.grossAmount < $1.grossAmount }) {
            currentTaxCalculation = TaxCalculation(grossSalary: highestIncome.grossAmount)
        } else {
            currentTaxCalculation = nil
        }
    }
    
    private func logError(_ method: String, error: Error) {
        #if DEBUG
        print("❌ IncomeViewModel.\(method): \(error.localizedDescription)")
        #endif
    }
}
