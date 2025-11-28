import SwiftUI

struct DeductionsView: View {
    @StateObject private var viewModel = DeductionsViewModel()
    @State private var animateCards = false
    @State private var showAddDeduction = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo con gradiente
                LinearGradient(
                    gradient: Gradient(colors: [Color.red.opacity(0.1), Color.orange.opacity(0.05)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header con estadísticas
                        DeductionsHeaderCard(viewModel: viewModel)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : -20)
                        
                        // Resumen de deducciones
                        DeductionSummaryCard(viewModel: viewModel)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 20)
                        
                        // Cálculo automático
                    if let taxCalculation = viewModel.currentTaxCalculation {
                        AutomaticTaxCalculationView(taxCalculation: taxCalculation)
                                .opacity(animateCards ? 1 : 0)
                                .offset(y: animateCards ? 0 : 20)
                        }
                        
                        // Lista de deducciones
                        if viewModel.deductions.isEmpty {
                            EmptyDeductionsStateView()
                                .opacity(animateCards ? 1 : 0)
                                .offset(y: animateCards ? 0 : 20)
                        } else {
                            DeductionsListSection(viewModel: viewModel)
                                .opacity(animateCards ? 1 : 0)
                                .offset(y: animateCards ? 0 : 20)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Deducciones")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddDeduction = true }) {
                        ZStack {
                            Circle()
                                .fill(Color.red.opacity(0.1))
                                .frame(width: 36, height: 36)
                            
                        Image(systemName: "plus")
                                .foregroundColor(.red)
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddDeduction) {
                AddDeductionView(viewModel: viewModel)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    animateCards = true
                }
            }
        }
    }

// MARK: - Deductions Header Card
struct DeductionsHeaderCard: View {
    @ObservedObject var viewModel: DeductionsViewModel
    @State private var animateNumbers = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Título principal
            VStack(alignment: .leading, spacing: 8) {
                Text("Control de Deducciones")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Gestiona tus deducciones fiscales")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Métricas principales
            HStack(spacing: 20) {
                DeductionMetricItem(
                    title: "Total ISR",
                    value: viewModel.totalISR,
                    color: .red,
                    icon: "minus.circle.fill"
                )
                
                DeductionMetricItem(
                    title: "Total IMSS",
                    value: viewModel.totalIMSS,
                    color: .orange,
                    icon: "shield.fill"
                )
            }
            
            // Indicador de estado
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                
                Text("Deducciones registradas: \(viewModel.deductions.count)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
            }
        }
        .padding(LayoutHelpers.cardPadding())
        .background(CardStyle.gradient(Color.gradientRed))
        .cornerRadius(CornerRadius.xl)
        .shadow(color: Color.primaryRed.opacity(0.3), radius: 10, x: 0, y: 5)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                animateNumbers = true
            }
        }
    }
}

struct DeductionMetricItem: View {
    let title: String
    let value: Double
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 26))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(1)
            
            Text(value, format: .currency(code: "MXN"))
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

// MARK: - Empty State
struct EmptyDeductionsStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "minus.circle")
                .font(.system(size: 64))
                .foregroundColor(.red.opacity(0.6))
            
            Text("No hay deducciones registradas")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Comienza agregando tus primeras deducciones para mantener un control fiscal completo")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
        )
    }
}

// MARK: - Deductions List Section
struct DeductionsListSection: View {
    @ObservedObject var viewModel: DeductionsViewModel
    @State private var animateRows = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.bullet")
                    .font(.system(size: 20))
                    .foregroundColor(.red)
                
                Text("Deducciones del Mes")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(viewModel.deductions.count)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .cornerRadius(12)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(Array(viewModel.deductions.enumerated()), id: \.element.id) { index, deduction in
                    ModernDeductionRowView(deduction: deduction)
                        .opacity(animateRows ? 1 : 0)
                        .offset(x: animateRows ? 0 : -20)
                        .animation(.easeOut(duration: 0.5).delay(Double(index) * 0.1), value: animateRows)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                animateRows = true
            }
        }
    }
}

// MARK: - Modern Deduction Row
struct ModernDeductionRowView: View {
    let deduction: Deduction
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icono del tipo de deducción
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: deduction.type.icon)
                    .font(.system(size: 20))
                    .foregroundColor(.red)
            }
            
            // Información de la deducción
            VStack(alignment: .leading, spacing: 6) {
                Text(deduction.type.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                if let description = deduction.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Text(deduction.date, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Monto y porcentaje
            VStack(alignment: .trailing, spacing: 4) {
                Text(deduction.amount, format: .currency(code: "MXN"))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.red)
                
                if let percentage = deduction.percentage {
                    Text("\(percentage, specifier: "%.2f")%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Indicador de estado
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 6, height: 6)
                    
                    Text("Deducido")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
    }
}

struct DeductionSummaryCard: View {
    @ObservedObject var viewModel: DeductionsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.red)
                
                Text("Resumen de Deducciones")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 16) {
            HStack {
                    VStack(alignment: .leading, spacing: 8) {
                    Text("ISR")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                    Text(viewModel.totalISR, format: .currency(code: "MXN"))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                    VStack(alignment: .center, spacing: 8) {
                    Text("IMSS")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                    Text(viewModel.totalIMSS, format: .currency(code: "MXN"))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                    VStack(alignment: .trailing, spacing: 8) {
                    Text("Otros")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                    Text(viewModel.totalOtherDeductions, format: .currency(code: "MXN"))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
            }
            
            Divider()
            
            HStack {
                    Text("Total Deducciones")
                    .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                Spacer()
                    
                Text(viewModel.totalDeductions, format: .currency(code: "MXN"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
            }
        }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
        )
    }
}

struct DeductionRowView: View {
    let deduction: Deduction
    
    var body: some View {
        HStack {
            Image(systemName: deduction.type.icon)
                .foregroundColor(.red)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(deduction.type.rawValue)
                    .font(.headline)
                if let description = deduction.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Text(deduction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(deduction.amount, format: .currency(code: "MXN"))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                
                if let percentage = deduction.percentage {
                    Text("\(percentage, specifier: "%.2f")%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct AutomaticTaxCalculationView: View {
    let taxCalculation: TaxCalculation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cálculo automático basado en ingresos")
                .font(.headline)
            
            HStack {
                Text("Ingreso bruto")
                Spacer()
                Text(taxCalculation.grossSalaryDouble, format: .currency(code: "MXN"))
            }
            
            HStack {
                Text("ISR calculado")
                Spacer()
                Text(taxCalculation.totalISRDouble, format: .currency(code: "MXN"))
                    .foregroundColor(.red)
            }
            
            HStack {
                Text("IMSS calculado")
                Spacer()
                Text(taxCalculation.imssDouble, format: .currency(code: "MXN"))
                    .foregroundColor(.red)
            }
            
            HStack {
                Text("Subsidio al empleo")
                Spacer()
                Text(taxCalculation.employmentSubsidyDouble, format: .currency(code: "MXN"))
                    .foregroundColor(.green)
            }
            
            Divider()
            
            HStack {
                Text("Salario neto")
                Spacer()
                Text(taxCalculation.netSalaryDouble, format: .currency(code: "MXN"))
                    .foregroundColor(.green)
                    .fontWeight(.semibold)
            }
            
            HStack {
                Text("Tasa efectiva")
                Spacer()
                Text(String(format: "%.2f%%", taxCalculation.effectiveTaxRateDouble * 100))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

}

#Preview {
    DeductionsView()
}
