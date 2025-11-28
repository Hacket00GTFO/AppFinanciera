import SwiftUI

struct IncomeView: View {
    @StateObject private var viewModel = IncomeViewModel()
    @State private var animateCards = false
    @State private var showAddIncome = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo con gradiente
                LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.1), Color.mint.opacity(0.05)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header con estadísticas
                        IncomeHeaderCard(viewModel: viewModel)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : -20)
                        
                        // Resumen fiscal
                    if let taxCalculation = viewModel.currentTaxCalculation {
                            TaxSummaryCard(taxCalculation: taxCalculation)
                                .opacity(animateCards ? 1 : 0)
                                .offset(y: animateCards ? 0 : 20)
                        }
                        
                        // Lista de ingresos
                        if viewModel.incomes.isEmpty {
                            EmptyIncomeStateView()
                                .opacity(animateCards ? 1 : 0)
                                .offset(y: animateCards ? 0 : 20)
                        } else {
                            IncomeListSection(viewModel: viewModel)
                                .opacity(animateCards ? 1 : 0)
                                .offset(y: animateCards ? 0 : 20)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Ingresos")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddIncome = true }) {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.1))
                                .frame(width: 36, height: 36)
                            
                        Image(systemName: "plus")
                                .foregroundColor(.green)
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddIncome) {
                AddIncomeView(viewModel: viewModel)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    animateCards = true
                }
            }
        }
    }
}

// MARK: - Income Header Card
struct IncomeHeaderCard: View {
    @ObservedObject var viewModel: IncomeViewModel
    @State private var animateNumbers = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Título principal
            VStack(alignment: .leading, spacing: 8) {
                Text("Resumen de Ingresos")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Controla tus ingresos mensuales")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Métricas principales
            HStack(spacing: 20) {
                IncomeMetricItem(
                    title: "Ingresos Brutos",
                    value: viewModel.totalGrossIncome,
                    color: .green,
                    icon: "dollarsign.circle.fill"
                )
                
                IncomeMetricItem(
                    title: "Ingresos Netos",
                    value: viewModel.totalNetIncome,
                    color: .mint,
                    icon: "checkmark.circle.fill"
                )
            }
            
            // Indicador de crecimiento
            if viewModel.totalNetIncome > 0 {
                HStack {
                    Image(systemName: "arrow.up.right")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                    
                    Text("Balance positivo este mes")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                }
            }
        }
        .padding(LayoutHelpers.cardPadding())
        .background(CardStyle.gradient(Color.gradientGreen))
        .cornerRadius(CornerRadius.xl)
        .shadow(color: Color.primaryGreen.opacity(0.3), radius: 10, x: 0, y: 5)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                animateNumbers = true
            }
        }
    }
}

struct IncomeMetricItem: View {
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

// MARK: - Tax Summary Card
struct TaxSummaryCard: View {
    let taxCalculation: TaxCalculation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                
                Text("Resumen Fiscal")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                TaxSummaryRow(
                    title: "ISR",
                    amount: taxCalculation.totalISRDouble,
                    color: .red,
                    icon: "minus.circle.fill"
                )
                
                TaxSummaryRow(
                    title: "IMSS",
                    amount: taxCalculation.imssDouble,
                    color: .red,
                    icon: "minus.circle.fill"
                )
                
                TaxSummaryRow(
                    title: "Subsidio",
                    amount: taxCalculation.employmentSubsidyDouble,
                    color: .green,
                    icon: "plus.circle.fill"
                )
                
                Divider()
                
                TaxSummaryRow(
                    title: "Salario Neto",
                    amount: taxCalculation.netSalaryDouble,
                    color: .green,
                    icon: "checkmark.circle.fill",
                    isTotal: true
                )
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

struct TaxSummaryRow: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    var isTotal: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(isTotal ? .headline : .body)
                .fontWeight(isTotal ? .bold : .medium)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(amount, format: .currency(code: "MXN"))
                .font(isTotal ? .title3 : .body)
                .fontWeight(isTotal ? .bold : .semibold)
                .foregroundColor(color)
        }
    }
}

// MARK: - Empty State
struct EmptyIncomeStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "arrow.up.circle")
                .font(.system(size: 64))
                .foregroundColor(.green.opacity(0.6))
            
            Text("No hay ingresos registrados")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Comienza agregando tu primer ingreso para mantener un control financiero completo")
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

// MARK: - Income List Section
struct IncomeListSection: View {
    @ObservedObject var viewModel: IncomeViewModel
    @State private var animateRows = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.bullet")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
                
                Text("Ingresos del Mes")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(viewModel.incomes.count)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .cornerRadius(12)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(Array(viewModel.incomes.enumerated()), id: \.element.id) { index, income in
                    ModernIncomeRowView(income: income)
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

// MARK: - Modern Income Row
struct ModernIncomeRowView: View {
    let income: Income
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icono del tipo de ingreso
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: incomeTypeIcon(income.type))
                    .font(.system(size: 20))
                    .foregroundColor(.green)
            }
            
            // Información del ingreso
            VStack(alignment: .leading, spacing: 6) {
                Text(income.description)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(income.type.rawValue)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue)
                        )
                    
                    if income.isRecurring {
                        HStack(spacing: 4) {
                            Image(systemName: "repeat")
                                .font(.caption2)
                            Text(income.recurringPeriod?.rawValue ?? "")
                                .font(.caption2)
                        }
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.green)
                        )
                    }
                }
                
                Text(income.date, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Montos
            VStack(alignment: .trailing, spacing: 4) {
                Text(income.netAmount, format: .currency(code: "MXN"))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                
                Text("Bruto: \(income.grossAmount, format: .currency(code: "MXN"))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                // Indicador de estado
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    
                    Text("Recibido")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
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
    
    private func incomeTypeIcon(_ type: Income.IncomeType) -> String {
        switch type {
        case .employment:
            return "briefcase.fill"
        case .freelance:
            return "person.fill"
        case .investment:
            return "chart.line.uptrend.xyaxis"
        case .other:
            return "plus.circle.fill"
        }
    }
}

struct IncomeRowView: View {
    let income: Income
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(income.description)
                        .font(.headline)
                    Text(income.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(income.netAmount, format: .currency(code: "MXN"))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Bruto: \(income.grossAmount, format: .currency(code: "MXN"))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text(income.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if income.isRecurring {
                    Spacer()
                    Text(income.recurringPeriod?.rawValue ?? "")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct TaxCalculationRowView: View {
    let taxCalculation: TaxCalculation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cálculo fiscal - \(taxCalculation.date, style: .date)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text("ISR")
                Spacer()
                Text(taxCalculation.totalISR, format: .currency(code: "MXN"))
                    .foregroundColor(.red)
            }
            
            HStack {
                Text("IMSS")
                Spacer()
                Text(taxCalculation.imss, format: .currency(code: "MXN"))
                    .foregroundColor(.red)
            }
            
            HStack {
                Text("Subsidio")
                Spacer()
                Text(taxCalculation.employmentSubsidy, format: .currency(code: "MXN"))
                    .foregroundColor(.green)
            }
            
            Divider()
            
            HStack {
                Text("Salario neto")
                    .fontWeight(.semibold)
                Spacer()
                Text(taxCalculation.netSalary, format: .currency(code: "MXN"))
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
        }
    }
}

#Preview {
    IncomeView()
}
