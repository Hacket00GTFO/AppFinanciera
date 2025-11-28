import Foundation
import SwiftUI

class IncomeViewModel: ObservableObject {
    @Published var incomes: [Income] = []
    @Published var showAddIncome = false
    @Published var currentTaxCalculation: TaxCalculation?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient = APIClient.shared
    
    var totalGrossIncome: Double {
        incomes.reduce(0) { $0 + $1.grossAmount }
    }
    
    var totalNetIncome: Double {
        incomes.reduce(0) { $0 + $1.netAmount }
    }
    
    var totalDeductions: Double {
        incomes.reduce(0) { $0 + ($1.grossAmount - $1.netAmount) }
    }
    
    init() {
        Task {
            await fetchIncomes()
        }
    }
    
    // MARK: - API Methods
    
    @MainActor
    func fetchIncomes(startDate: Date? = nil, endDate: Date? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let dtos = try await apiClient.getIncomes(startDate: startDate, endDate: endDate)
            // Usar el conversor de DTOs para mapeo correcto de tipos
            self.incomes = dtos.map { $0.toIncome() }
            updateTaxCalculation()
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Error al cargar ingresos: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    @MainActor
    func addIncome(_ income: Income) async {
        isLoading = true
        errorMessage = nil
        
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
            
            incomes.append(newIncome)
            updateTaxCalculation()
            showAddIncome = false
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Error al agregar ingreso: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    @MainActor
    func deleteIncome(at offsets: IndexSet) async {
        isLoading = true
        errorMessage = nil
        
        var deletedIndices: [Int] = []
        for index in offsets {
            let income = incomes[index]
            do {
                try await apiClient.deleteIncome(id: income.id)
                deletedIndices.append(index)
            } catch let error as APIError {
                errorMessage = error.errorDescription
                break
            } catch {
                errorMessage = "Error al eliminar ingreso: \(error.localizedDescription)"
                break
            }
        }
        
        // Eliminar solo los que se eliminaron exitosamente
        for index in deletedIndices.reversed() {
            incomes.remove(at: index)
        }
        
        if !deletedIndices.isEmpty {
            updateTaxCalculation()
        }
        
        isLoading = false
    }
    
    @MainActor
    func updateIncome(_ income: Income) async {
        isLoading = true
        errorMessage = nil
        
        guard let index = incomes.firstIndex(where: { $0.id == income.id }) else {
            errorMessage = "Ingreso no encontrado"
            isLoading = false
            return
        }
        
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
            updateTaxCalculation()
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Error al actualizar ingreso: \(error.localizedDescription)"
        }
        
        isLoading = false
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
    
    private func updateTaxCalculation() {
        if let highestIncome = incomes.max(by: { $0.grossAmount < $1.grossAmount }) {
            currentTaxCalculation = TaxCalculation(grossSalary: highestIncome.grossAmount)
        } else {
            currentTaxCalculation = nil
        }
    }
}
