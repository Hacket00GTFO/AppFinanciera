import Foundation
import SwiftUI

class DeductionsViewModel: ObservableObject {
    @Published var deductions: [Deduction] = []
    @Published var showAddDeduction = false
    @Published var currentTaxCalculation: TaxCalculation?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient = APIClient.shared
    
    var totalISR: Double {
        deductions.filter { $0.type == .isr }.reduce(0) { $0 + $1.amount }
    }
    
    var totalIMSS: Double {
        deductions.filter { $0.type == .imss }.reduce(0) { $0 + $1.amount }
    }
    
    var totalOtherDeductions: Double {
        deductions.filter { $0.type != .isr && $0.type != .imss }.reduce(0) { $0 + $1.amount }
    }
    
    var totalDeductions: Double {
        deductions.reduce(0) { $0 + $1.amount }
    }
    
    init() {
        Task {
            await fetchDeductions()
        }
    }
    
    // MARK: - API Methods
    
    @MainActor
    func fetchDeductions() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let dtos = try await apiClient.getDeductions()
            let deductionsList = dtos.map { dto -> Deduction in
                Deduction(
                    id: dto.id,
                    type: Deduction.DeductionType(rawValue: dto.type) ?? .other,
                    amount: dto.amount,
                    percentage: dto.percentage,
                    date: dto.date,
                    description: dto.description
                )
            }
            self.deductions = deductionsList
            updateTaxCalculation()
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Error al cargar deducciones: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    @MainActor
    func addDeduction(_ deduction: Deduction) async {
        isLoading = true
        errorMessage = nil
        
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
            
            deductions.append(newDeduction)
            updateTaxCalculation()
            showAddDeduction = false
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Error al agregar deducción: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    @MainActor
    func deleteDeduction(at offsets: IndexSet) async {
        isLoading = true
        errorMessage = nil
        
        var deletedIndices: [Int] = []
        for index in offsets {
            let deduction = deductions[index]
            do {
                try await apiClient.deleteDeduction(id: deduction.id)
                deletedIndices.append(index)
            } catch let error as APIError {
                errorMessage = error.errorDescription
                break
            } catch {
                errorMessage = "Error al eliminar deducción: \(error.localizedDescription)"
                break
            }
        }
        
        // Eliminar solo los que se eliminaron exitosamente
        for index in deletedIndices.reversed() {
            deductions.remove(at: index)
        }
        
        if !deletedIndices.isEmpty {
            updateTaxCalculation()
        }
        
        isLoading = false
    }
    
    @MainActor
    func updateDeduction(_ deduction: Deduction) async {
        isLoading = true
        errorMessage = nil
        
        guard let index = deductions.firstIndex(where: { $0.id == deduction.id }) else {
            errorMessage = "Deducción no encontrada"
            isLoading = false
            return
        }
        
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
            updateTaxCalculation()
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Error al actualizar deducción: \(error.localizedDescription)"
        }
        
        isLoading = false
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
    
    private func updateTaxCalculation() {
        // Simular un cálculo fiscal basado en deducciones totales
        let estimatedGrossSalary = totalDeductions * 3.5 // Estimación aproximada
        currentTaxCalculation = TaxCalculation(grossSalary: estimatedGrossSalary)
    }
}
