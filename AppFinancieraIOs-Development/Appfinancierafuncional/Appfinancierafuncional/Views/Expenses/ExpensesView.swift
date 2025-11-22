import SwiftUI

struct ExpensesView: View {
    @StateObject private var viewModel = ExpensesViewModel()
    @State private var animateCards = false
    @State private var showAddExpense = false
    
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
                        ExpensesHeaderCard(viewModel: viewModel)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : -20)
                        
                        // Ingresos mensuales
                        IncomeSectionView(viewModel: viewModel)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 20)
                        
                        // Gastos por categoría
                        ExpenseCategoriesSectionView(viewModel: viewModel)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Gastos")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddExpense = true }) {
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
            .sheet(isPresented: $showAddExpense) {
                AddExpenseView(viewModel: viewModel)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    animateCards = true
                }
            }
        }
    }
}

// MARK: - Expenses Header Card
struct ExpensesHeaderCard: View {
    @ObservedObject var viewModel: ExpensesViewModel
    @State private var animateNumbers = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Título principal
            VStack(alignment: .leading, spacing: 8) {
                Text("Control de Gastos")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Mantén el control de tus gastos mensuales")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Métricas principales
            HStack(spacing: 20) {
                ExpenseMetricItem(
                    title: "Total Gastos",
                    value: viewModel.totalExpenses,
                    color: .red,
                    icon: "cart.fill"
                )
                
                ExpenseMetricItem(
                    title: "Presupuesto",
                    value: viewModel.netSalary + viewModel.otherIncome,
                    color: .green,
                    icon: "dollarsign.circle.fill"
                )
            }
            
            // Indicador de balance
            let balance = (viewModel.netSalary + viewModel.otherIncome) - viewModel.totalExpenses
            if balance >= 0 {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                    
                    Text("Balance positivo: \(balance, format: .currency(code: "MXN"))")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                }
            } else {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                    
                    Text("Gastos excedidos: \(abs(balance), format: .currency(code: "MXN"))")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                }
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

struct ExpenseMetricItem: View {
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

struct IncomeSectionView: View {
    @ObservedObject var viewModel: ExpensesViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
                
                Text("Ingresos Mensuales")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Salario Neto")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Importe", value: $viewModel.netSalary, format: .currency(code: "MXN"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Otros Ingresos")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Importe", value: $viewModel.otherIncome, format: .currency(code: "MXN"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                    }
                }
                
                // Total de ingresos
                HStack {
                    Text("Total Ingresos")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text((viewModel.netSalary + viewModel.otherIncome), format: .currency(code: "MXN"))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.green.opacity(0.1))
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

struct ExpenseCategoriesSectionView: View {
    @ObservedObject var viewModel: ExpensesViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.orange)
                
                Text("Gastos por Categoría")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Fijos obligatorios
            ModernExpenseCategoryCard(
                title: "Fijos Obligatorios",
                icon: "exclamationmark.triangle.fill",
                color: .red,
                categories: ExpenseCategory.allCases.filter { $0.isMandatory },
                viewModel: viewModel
            )
            
            // Fijos reducibles
            ModernExpenseCategoryCard(
                title: "Fijos Reducibles",
                icon: "gear.circle.fill",
                color: .blue,
                categories: ExpenseCategory.allCases.filter { $0.isReducible },
                viewModel: viewModel
            )
            
            // Variables
            ModernExpenseCategoryCard(
                title: "Variables",
                icon: "chart.line.uptrend.xyaxis",
                color: .orange,
                categories: ExpenseCategory.allCases.filter { $0.isVariable },
                viewModel: viewModel
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
        )
    }
}

// MARK: - Modern Expense Category Card
struct ModernExpenseCategoryCard: View {
    let title: String
    let icon: String
    let color: Color
    let categories: [ExpenseCategory]
    @ObservedObject var viewModel: ExpensesViewModel
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: { 
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                        .frame(width: 24)
                    
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.easeInOut(duration: 0.3), value: isExpanded)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        ModernExpenseInputField(
                            category: category,
                            amount: Binding(
                                get: { viewModel.getCategoryAmount(category) },
                                set: { newValue in
                                    viewModel.updateCategoryAmount(category, amount: newValue)
                                }
                            )
                        )
                    }
                }
                .padding(.top, 12)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .move(edge: .top))
                ))
            }
        }
    }
}

// MARK: - Modern Expense Input Field
struct ModernExpenseInputField: View {
    let category: ExpenseCategory
    @Binding var amount: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: category.icon)
                    .foregroundColor(Color(category.color))
                    .font(.system(size: 18))
                
                Text(category.rawValue)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            
            TextField("0.00", value: $amount, format: .currency(code: "MXN"))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 15, weight: .medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(10)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    ExpensesView()
}
