import SwiftUI

struct AddExpenseView: View {
    @ObservedObject var viewModel: ExpensesViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategory: ExpenseCategory = .food
    @State private var amount: Double = 0.0
    @State private var description: String = ""
    @State private var date = Date()
    @State private var isRecurring = false
    @State private var selectedRecurringPeriod: Expense.RecurringPeriod = .monthly
    @State private var notes: String = ""
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
                        AddExpenseHeaderView()
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : -20)
                        
                        // Formulario principal
                        ExpenseFormCard(
                            selectedCategory: $selectedCategory,
                            amount: $amount,
                            description: $description,
                            date: $date,
                            isRecurring: $isRecurring,
                            selectedRecurringPeriod: $selectedRecurringPeriod,
                            notes: $notes
                        )
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 20)
                        
                        // Resumen
                        if amount > 0 {
                            ExpenseSummaryCard(
                                category: selectedCategory,
                                amount: amount,
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
            .navigationTitle("Agregar Gasto")
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
                        saveExpense()
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
    
    private func saveExpense() {
        let expense = Expense(
            amount: amount,
            category: selectedCategory,
            date: date,
            description: description.isEmpty ? selectedCategory.rawValue : description,
            isRecurring: isRecurring,
            recurringPeriod: isRecurring ? selectedRecurringPeriod : nil,
            notes: notes.isEmpty ? nil : notes
        )
        
        Task {
            await viewModel.addExpense(expense)
        }
        dismiss()
    }
}

// MARK: - Add Expense Header
struct AddExpenseHeaderView: View {
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
                Text("Nuevo Gasto")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Registra un nuevo gasto en tu historial financiero")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 20)
    }
}

// MARK: - Expense Form Card
struct ExpenseFormCard: View {
    @Binding var selectedCategory: ExpenseCategory
    @Binding var amount: Double
    @Binding var description: String
    @Binding var date: Date
    @Binding var isRecurring: Bool
    @Binding var selectedRecurringPeriod: Expense.RecurringPeriod
    @Binding var notes: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.red)
                
                Text("Detalles del Gasto")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                // Categoría
                VStack(alignment: .leading, spacing: 8) {
                    Text("Categoría")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Picker("Categoría", selection: $selectedCategory) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(Color(category.color))
                                Text(category.rawValue)
                            }
                            .tag(category)
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
                
                // Descripción
                VStack(alignment: .leading, spacing: 8) {
                    Text("Descripción")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Descripción del gasto", text: $description)
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
                    
                    Toggle("Gasto recurrente", isOn: $isRecurring)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    
                    if isRecurring {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Período de Recurrencia")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Picker("Período", selection: $selectedRecurringPeriod) {
                                ForEach(Expense.RecurringPeriod.allCases, id: \.self) { period in
                                    Text(period.rawValue).tag(period)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notas Adicionales")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextField("Notas adicionales", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
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
}

// MARK: - Expense Summary Card
struct ExpenseSummaryCard: View {
    let category: ExpenseCategory
    let amount: Double
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
                ExpenseSummaryRow(
                    title: "Categoría",
                    value: category.rawValue,
                    icon: category.icon,
                    color: Color(category.color)
                )
                
                ExpenseSummaryRow(
                    title: "Monto",
                    value: amount,
                    icon: "dollarsign.circle.fill",
                    color: .red,
                    isAmount: true
                )
                
                if !description.isEmpty {
                    ExpenseSummaryRow(
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

struct ExpenseSummaryRow: View {
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
    AddExpenseView(viewModel: ExpensesViewModel())
}
