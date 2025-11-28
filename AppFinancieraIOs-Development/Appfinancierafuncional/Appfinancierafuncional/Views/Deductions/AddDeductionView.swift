import SwiftUI

struct AddDeductionView: View {
    @ObservedObject var viewModel: DeductionsViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: Deduction.DeductionType = .isr
    @State private var amount: Double = 0.0
    @State private var percentage: Double = 0.0
    @State private var date = Date()
    @State private var description: String = ""
    @State private var animateCards = false
    
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
                        // Header con icono
                        AddDeductionHeaderView()
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : -20)
                        
                        // Formulario principal
                        DeductionFormCard(
                            selectedType: $selectedType,
                            amount: $amount,
                            percentage: $percentage,
                            date: $date,
                            description: $description
                        )
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 20)
                        
                        // Resumen
                        if amount > 0 {
                            DeductionSummaryCard(
                                type: selectedType,
                                amount: amount,
                                percentage: percentage,
                                description: description
                            )
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 20)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Agregar Deducción")
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
                        saveDeduction()
                    }
                    .buttonStyle(ModernButtonStyle(style: .gradient(Color.gradientRed), size: .small))
                    .disabled(amount <= 0)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    animateCards = true
                }
            }
        }
    }
    
    private func saveDeduction() {
        let deduction = Deduction(
            type: selectedType,
            amount: amount,
            percentage: percentage > 0 ? percentage : nil,
            date: date,
            description: description.isEmpty ? nil : description
        )
        
        Task {
            await viewModel.addDeduction(deduction)
        }
        dismiss()
    }
}

// MARK: - Add Deduction Header
struct AddDeductionHeaderView: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 8) {
                Text("Nueva Deducción")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Registra una nueva deducción fiscal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 20)
    }
}

// MARK: - Deduction Form Card
struct DeductionFormCard: View {
    @Binding var selectedType: Deduction.DeductionType
    @Binding var amount: Double
    @Binding var percentage: Double
    @Binding var date: Date
    @Binding var description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.red)
                
                Text("Detalles de la Deducción")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                // Tipo de deducción
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tipo de Deducción")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Picker("Tipo de deducción", selection: $selectedType) {
                        ForEach(Deduction.DeductionType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                    .foregroundColor(.red)
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
                
                // Monto
                VStack(alignment: .leading, spacing: 8) {
                    Text("Monto")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.red)
                            .frame(width: 20)
                        
                        TextField("0.00", value: $amount, format: .currency(code: "MXN"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                
                // Porcentaje
                VStack(alignment: .leading, spacing: 8) {
                    Text("Porcentaje (Opcional)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Image(systemName: "percent")
                            .foregroundColor(.red)
                            .frame(width: 20)
                        
                        TextField("0.00", value: $percentage, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
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
                
                // Descripción
                VStack(alignment: .leading, spacing: 8) {
                    Text("Descripción (Opcional)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Descripción de la deducción", text: $description)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
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

// MARK: - Deduction Summary Card
struct DeductionSummaryCard: View {
    let type: Deduction.DeductionType
    let amount: Double
    let percentage: Double
    let description: String
    
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
                DeductionSummaryRow(
                    title: "Tipo",
                    value: type.rawValue,
                    icon: type.icon,
                    color: .red
                )
                
                DeductionSummaryRow(
                    title: "Monto",
                    value: amount,
                    icon: "dollarsign.circle.fill",
                    color: .red,
                    isAmount: true
                )
                
                if percentage > 0 {
                    DeductionSummaryRow(
                        title: "Porcentaje",
                        value: String(format: "%.2f%%", percentage),
                        icon: "percent",
                        color: .secondary
                    )
                }
                
                if !description.isEmpty {
                    DeductionSummaryRow(
                        title: "Descripción",
                        value: description,
                        icon: "text.alignleft",
                        color: .secondary
                    )
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

struct DeductionSummaryRow: View {
    let title: String
    let value: Any
    let icon: String
    let color: Color
    var isAmount: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
            
            if isAmount, let amount = value as? Double {
                Text(amount, format: .currency(code: "MXN"))
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            } else if let stringValue = value as? String {
                Text(stringValue)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    AddDeductionView(viewModel: DeductionsViewModel())
}
