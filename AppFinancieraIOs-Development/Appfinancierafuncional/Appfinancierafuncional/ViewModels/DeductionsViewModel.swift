import Foundation
import SwiftUI

// MARK: - Deductions ViewModel
@MainActor
class DeductionsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var deductions: [Deduction] = []
    @Published var showAddDeduction = false
    @Published private(set) var currentTaxCalculation: TaxCalculation?
    @Published private(set) var loadingState: LoadingState = .idle
    
    // MARK: - Private Properties
    private let apiClient = APIClient.shared
    private var lastFetchDate: Date?
    private let cacheValidityDuration: TimeInterval = 300 // 5 minutos
    
    // MARK: - Computed Properties
    var isLoading: Bool { loadingState.isLoading }
    var errorMessage: String? { loadingState.errorMessage }
    
    var totalISR: Double {
        deductions.filter { $0.type == .isr }.reduce(0) { $0 + $1.amount }
    }
    
    var totalIMSS: Double {
        deductions.filter { $0.type == .imss }.reduce(0) { $0 + $1.amount }
    }
    
    var totalSubsidy: Double {
        deductions.filter { $0.type == .employmentSubsidy }.reduce(0) { $0 + $1.amount }
    }
    
    var totalOtherDeductions: Double {
        deductions.filter { $0.type != .isr && $0.type != .imss && $0.type != .employmentSubsidy }
            .reduce(0) { $0 + $1.amount }
    }
    
    var totalDeductions: Double {
        deductions.reduce(0) { $0 + $1.amount }
    }
    
    /// Calcula el total neto considerando subsidios como ingreso
    var netDeductions: Double {
        totalISR + totalIMSS + totalOtherDeductions - totalSubsidy
    }
    
    // MARK: - Initialization
    init() {
        Task {
            await fetchDeductions()
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
    
    /// Obtiene las deducciones del servidor
    func fetchDeductions(forceRefresh: Bool = false) async {
        if !forceRefresh && isCacheValid {
            return
        }
        
        loadingState = .loading
        
        do {
            let dtos = try await apiClient.getDeductions()
            self.deductions = dtos.map { dto in
                Deduction(
                    id: dto.id,
                    type: Deduction.DeductionType(rawValue: dto.type) ?? .other,
                    amount: dto.amount,
                    percentage: dto.percentage,
                    date: dto.date,
                    description: dto.description
                )
            }
            self.deductions.sort { $0.date > $1.date }
            self.lastFetchDate = Date()
            updateTaxCalculation()
            loadingState = .loaded
        } catch let error as APIError {
            loadingState = .error(error.errorDescription ?? "Error desconocido")
            logError("fetchDeductions", error: error)
        } catch {
            loadingState = .error("Error de conexión: \(error.localizedDescription)")
            logError("fetchDeductions", error: error)
        }
    }
    
    /// Agrega una nueva deducción
    func addDeduction(_ deduction: Deduction) async {
        loadingState = .loading
        
        do {
            let dto = DeductionDto(
                type: deduction.type.rawValue,
                amount: deduction.amount,
                percentage: deduction.percentage,
                date: deduction.date,
                description: deduction.description
            )
            
            let responseDto = try await apiClient.createDeduction(dto)
            let newDeduction = Deduction(
                id: responseDto.id,
                type: Deduction.DeductionType(rawValue: responseDto.type) ?? .other,
                amount: responseDto.amount,
                percentage: responseDto.percentage,
                date: responseDto.date,
                description: responseDto.description
            )
            
            deductions.insert(newDeduction, at: 0)
            deductions.sort { $0.date > $1.date }
            updateTaxCalculation()
            showAddDeduction = false
            loadingState = .loaded
            
            HapticFeedback.success()
        } catch let error as APIError {
            loadingState = .error(error.errorDescription ?? "Error al crear deducción")
            logError("addDeduction", error: error)
            HapticFeedback.error()
        } catch {
            loadingState = .error("Error al crear deducción: \(error.localizedDescription)")
            logError("addDeduction", error: error)
            HapticFeedback.error()
        }
    }
    
    /// Elimina deducciones en los índices especificados
    func deleteDeduction(at offsets: IndexSet) async {
        let deductionsToDelete = offsets.map { deductions[$0] }
        
        loadingState = .loading
        var deletionFailed = false
        
        for deduction in deductionsToDelete {
            do {
                try await apiClient.deleteDeduction(id: deduction.id)
            } catch {
                deletionFailed = true
                logError("deleteDeduction", error: error)
            }
        }
        
        if !deletionFailed {
            deductions.remove(atOffsets: offsets)
            updateTaxCalculation()
            loadingState = .loaded
            HapticFeedback.success()
        } else {
            loadingState = .error("Error al eliminar algunas deducciones")
            HapticFeedback.error()
            await fetchDeductions(forceRefresh: true)
        }
    }
    
    /// Actualiza una deducción existente
    func updateDeduction(_ deduction: Deduction) async {
        guard let index = deductions.firstIndex(where: { $0.id == deduction.id }) else {
            loadingState = .error("Deducción no encontrada")
            return
        }
        
        loadingState = .loading
        
        do {
            let dto = DeductionDto(
                type: deduction.type.rawValue,
                amount: deduction.amount,
                percentage: deduction.percentage,
                date: deduction.date,
                description: deduction.description
            )
            
            try await apiClient.updateDeduction(id: deduction.id, dto)
            deductions[index] = deduction
            deductions.sort { $0.date > $1.date }
            updateTaxCalculation()
            loadingState = .loaded
            
            HapticFeedback.success()
        } catch let error as APIError {
            loadingState = .error(error.errorDescription ?? "Error al actualizar")
            logError("updateDeduction", error: error)
            HapticFeedback.error()
        } catch {
            loadingState = .error("Error al actualizar: \(error.localizedDescription)")
            logError("updateDeduction", error: error)
            HapticFeedback.error()
        }
    }
    
    // MARK: - Helper Methods
    
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
    
    func clearError() {
        if case .error = loadingState {
            loadingState = .idle
        }
    }
    
    // MARK: - Private Methods
    
    private func updateTaxCalculation() {
        // Calcular basado en el total de deducciones o usar un valor estimado
        let estimatedGrossSalary = max(totalDeductions * 3.5, 0)
        
        if estimatedGrossSalary > 0 {
            currentTaxCalculation = TaxCalculation(grossSalary: estimatedGrossSalary)
        } else {
            currentTaxCalculation = nil
        }
    }
    
    private func logError(_ method: String, error: Error) {
        #if DEBUG
        print("❌ DeductionsViewModel.\(method): \(error.localizedDescription)")
        #endif
    }
}
