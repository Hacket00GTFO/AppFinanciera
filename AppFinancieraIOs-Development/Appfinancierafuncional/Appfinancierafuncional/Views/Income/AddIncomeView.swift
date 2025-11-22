import SwiftUI

struct AddIncomeView: View {
    @ObservedObject var viewModel: IncomeViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var grossAmount: Double = 0.0
    @State private var netAmount: Double = 0.0
    @State private var selectedType: Income.IncomeType = .freelance
    @State private var description: String = ""
    @State private var date = Date()
    @State private var isRecurring = false
    @State private var selectedRecurringPeriod: Income.RecurringPeriod = .monthly
    @State private var showTaxCalculation = false
    @State private var animateCards = false
    
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
                        // Header con icono
                        AddIncomeHeaderView()
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : -20)
                        
                        // Formulario principal
                        IncomeFormCard(
                            grossAmount: $grossAmount,
                            netAmount: $netAmount,
                            selectedType: $selectedType,
                            description: $description,
                            date: $date,
                            isRecurring: $isRecurring,
                            selectedRecurringPeriod: $selectedRecurringPeriod
                        )
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 20)
                        
                        // Resumen y cálculo fiscal
                        if grossAmount > 0 && netAmount > 0 {
                            IncomeSummaryCard(
                                grossAmount: grossAmount,
                                netAmount: netAmount,
                                showTaxCalculation: $showTaxCalculation
                            )
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 20)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Agregar Ingreso")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveIncome()
                    }
                    .buttonStyle(ModernButtonStyle(style: .gradient(Color.gradientGreen), size: .small))
                    .disabled(grossAmount <= 0 || netAmount <= 0)
                }
            }
            .sheet(isPresented: $showTaxCalculation) {
                TaxCalculationDetailView(grossSalary: grossAmount)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    animateCards = true
                }
            }
        }
    }
    
    private func saveIncome() {
        let income = Income(
            grossAmount: grossAmount,
            netAmount: netAmount,
            date: date,
            type: selectedType,
            description: description.isEmpty ? selectedType.rawValue : description,
            isRecurring: isRecurring,
            recurringPeriod: isRecurring ? selectedRecurringPeriod : nil
        )
        
        viewModel.addIncome(income)
        dismiss()
    }
}

// MARK: - Add Income Header
struct AddIncomeHeaderView: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
            }
            
            VStack(spacing: 8) {
                Text("Nuevo Ingreso")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Registra un nuevo ingreso en tu historial financiero")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 20)
    }
}

// MARK: - Income Form Card
struct IncomeFormCard: View {
    @Binding var grossAmount: Double
    @Binding var netAmount: Double
    @Binding var selectedType: Income.IncomeType
    @Binding var description: String
    @Binding var date: Date
    @Binding var isRecurring: Bool
    @Binding var selectedRecurringPeriod: Income.RecurringPeriod
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
                
                Text("Detalles del Ingreso")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                // Montos
                VStack(spacing: 12) {
                    ModernTextField(
                        title: "Monto Bruto",
                        value: $grossAmount,
                        placeholder: "0.00",
                        icon: "dollarsign.circle.fill",
                        color: .green
                    )
                    
                    ModernTextField(
                        title: "Monto Neto",
                        value: $netAmount,
                        placeholder: "0.00",
                        icon: "checkmark.circle.fill",
                        color: .mint
                    )
                }
                
                // Tipo de ingreso
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tipo de Ingreso")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Picker("Tipo de ingreso", selection: $selectedType) {
                        ForEach(Income.IncomeType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: incomeTypeIcon(type))
                                    .foregroundColor(.green)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                
                // Descripción
                VStack(alignment: .leading, spacing: 8) {
                    Text("Descripción")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Descripción del ingreso", text: $description)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                }
                
                // Fecha
                VStack(alignment: .leading, spacing: 8) {
                    Text("Fecha")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    DatePicker("Fecha", selection: $date, displayedComponents: .date)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                }
                
                // Opciones adicionales
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Opciones Adicionales")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    Toggle("Ingreso recurrente", isOn: $isRecurring)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    
                    if isRecurring {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Período de Recurrencia")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Picker("Período", selection: $selectedRecurringPeriod) {
                                ForEach(Income.RecurringPeriod.allCases, id: \.self) { period in
                                    Text(period.rawValue).tag(period)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
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

// MARK: - Modern Text Field
struct ModernTextField: View {
    let title: String
    @Binding var value: Double
    let placeholder: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 20)
                
                TextField(placeholder, value: $value, format: .currency(code: "MXN"))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}

// MARK: - Income Summary Card
struct IncomeSummaryCard: View {
    let grossAmount: Double
    let netAmount: Double
    @Binding var showTaxCalculation: Bool
    
    private var totalDeductions: Double {
        grossAmount - netAmount
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                
                Text("Resumen")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                SummaryRow(
                    title: "Ingreso Bruto",
                    amount: grossAmount,
                    color: .green,
                    icon: "arrow.up.circle.fill"
                )
                
                SummaryRow(
                    title: "Deducciones Totales",
                    amount: totalDeductions,
                    color: .red,
                    icon: "minus.circle.fill"
                )
                
                Divider()
                
                SummaryRow(
                    title: "Ingreso Neto",
                    amount: netAmount,
                    color: .green,
                    icon: "checkmark.circle.fill",
                    isTotal: true
                )
            }
            
            Button(action: { showTaxCalculation = true }) {
                HStack {
                    Image(systemName: "doc.text.magnifyingglass")
                    Text("Ver cálculo fiscal detallado")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(12)
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

struct SummaryRow: View {
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

struct TaxCalculationDetailView: View {
    let grossSalary: Double
    @Environment(\.dismiss) private var dismiss
    
    private var taxCalculation: TaxCalculation {
        TaxCalculation(grossSalary: grossSalary)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section("Desglose del cálculo fiscal") {
                    DetailRow(title: "Sueldo bruto", value: taxCalculation.grossSalary, color: .primary)
                    DetailRow(title: "Límite inferior", value: taxCalculation.lowerLimit, color: .secondary)
                    DetailRow(title: "Excedente del límite inferior", value: taxCalculation.excessOverLowerLimit, color: .secondary)
                    DetailRow(title: "Porcentaje sobre excedente", value: taxCalculation.marginalPercentage, color: .secondary, isPercentage: true)
                    DetailRow(title: "Impuesto marginal", value: taxCalculation.marginalTax, color: .red)
                    DetailRow(title: "Cuota fija del impuesto", value: taxCalculation.fixedTaxQuota, color: .red)
                    DetailRow(title: "ISR", value: -taxCalculation.totalISR, color: .red)
                    DetailRow(title: "IMSS", value: -taxCalculation.imss, color: .red)
                    DetailRow(title: "Subsidio al empleo", value: taxCalculation.employmentSubsidy, color: .green)
                }
                
                Section("Resultado") {
                    DetailRow(title: "Salario neto", value: taxCalculation.netSalary, color: .green, isBold: true)
                }
            }
            .navigationTitle("Cálculo Fiscal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: Double
    let color: Color
    var isPercentage: Bool = false
    var isBold: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(isBold ? .bold : .regular)
            Spacer()
            if isPercentage {
                Text("\(value, specifier: "%.2f")%")
                    .foregroundColor(color)
                    .fontWeight(isBold ? .bold : .regular)
            } else {
                Text(value, format: .currency(code: "MXN"))
                    .foregroundColor(color)
                    .fontWeight(isBold ? .bold : .regular)
            }
        }
    }
}

#Preview {
    AddIncomeView(viewModel: IncomeViewModel())
}
