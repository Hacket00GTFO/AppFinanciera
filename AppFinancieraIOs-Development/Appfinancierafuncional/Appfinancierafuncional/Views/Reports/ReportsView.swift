import SwiftUI

struct ReportsView: View {
    @StateObject private var viewModel = ReportsViewModel()
    @State private var selectedPeriod: FinancialPeriod.PeriodType = .monthly
    @State private var animateCards = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo con gradiente
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.05)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header con estadísticas
                        ReportsHeaderCard(viewModel: viewModel, periodType: selectedPeriod)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : -20)
                        
                        // Selector de período
                        PeriodSelectorView(selectedPeriod: $selectedPeriod)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 20)
                        
                        // Resumen del período
                        PeriodSummaryCard(viewModel: viewModel, periodType: selectedPeriod)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 20)
                        
                        // Gráficas
                        ChartsSectionView(viewModel: viewModel, periodType: selectedPeriod)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 20)
                        
                        // Análisis de gastos por categoría
                        ExpensesByCategoryCard(viewModel: viewModel, periodType: selectedPeriod)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 20)
                        
                        // Comparativa de períodos
                        PeriodComparisonCard(viewModel: viewModel)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Reportes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.exportReport() }) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    animateCards = true
                }
            }
        }
    }
}

// MARK: - Reports Header Card
struct ReportsHeaderCard: View {
    @ObservedObject var viewModel: ReportsViewModel
    let periodType: FinancialPeriod.PeriodType
    @State private var animateNumbers = false
    
    private var periodData: FinancialPeriod? {
        viewModel.getCurrentPeriodData(for: periodType)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Título principal
            VStack(alignment: .leading, spacing: 8) {
                Text("Análisis Financiero")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Reportes detallados de tu situación financiera")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if let data = periodData {
                // Métricas principales
                HStack(spacing: 20) {
                    ReportMetricItem(
                        title: "Ingresos",
                        value: data.totalIncome,
                        color: .green,
                        icon: "arrow.up.circle.fill"
                    )
                    
                    ReportMetricItem(
                        title: "Gastos",
                        value: data.totalExpenses,
                        color: .red,
                        icon: "arrow.down.circle.fill"
                    )
                }
                
                // Balance
                HStack {
                    Image(systemName: data.balance >= 0 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                    
                    Text(data.balance >= 0 ? "Balance positivo" : "Balance negativo")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text(data.balance, format: .currency(code: "MXN"))
                        .font(.financialSmall)
                        .foregroundColor(.white)
                }
            } else {
                HStack {
                    Image(systemName: "chart.line.downtrend.xyaxis")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                    
                    Text("No hay datos disponibles para este período")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                }
            }
        }
        .padding(LayoutHelpers.cardPadding())
        .background(CardStyle.gradient(Color.gradientBlue))
        .cornerRadius(CornerRadius.xl)
        .shadow(color: Color.primaryBlue.opacity(0.3), radius: 10, x: 0, y: 5)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                animateNumbers = true
            }
        }
    }
}

struct ReportMetricItem: View {
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

struct PeriodSelectorView: View {
    @Binding var selectedPeriod: FinancialPeriod.PeriodType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Seleccionar Período")
                .font(.headline)
                .foregroundColor(.primary)
            
            Picker("Período", selection: $selectedPeriod) {
                ForEach(FinancialPeriod.PeriodType.allCases, id: \.self) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
        )
    }
}

struct PeriodSummaryCard: View {
    @ObservedObject var viewModel: ReportsViewModel
    let periodType: FinancialPeriod.PeriodType
    
    private var periodData: FinancialPeriod? {
        viewModel.getCurrentPeriodData(for: periodType)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                
                Text("Resumen del Período")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            if let data = periodData {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ingresos")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(data.totalIncome, format: .currency(code: "MXN"))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .center, spacing: 8) {
                            Text("Gastos")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(data.totalExpenses, format: .currency(code: "MXN"))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 8) {
                            Text("Balance")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(data.balance, format: .currency(code: "MXN"))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(data.balance >= 0 ? .green : .red)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Período")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(data.startDate, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("-")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(data.endDate, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.6))
                    
                    Text("No hay datos disponibles")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Para este período no se encontraron registros financieros")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 20)
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

struct ChartsSectionView: View {
    @ObservedObject var viewModel: ReportsViewModel
    let periodType: FinancialPeriod.PeriodType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                
                Text("Gráficas")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                // Gráfica de ingresos vs gastos
                ModernIncomeVsExpensesChart(viewModel: viewModel, periodType: periodType)
                
                // Gráfica de gastos por categoría
                ModernExpensesByCategoryChart(viewModel: viewModel, periodType: periodType)
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

// MARK: - Modern Income vs Expenses Chart
struct ModernIncomeVsExpensesChart: View {
    @ObservedObject var viewModel: ReportsViewModel
    let periodType: FinancialPeriod.PeriodType
    
    private var periodData: FinancialPeriod? {
        viewModel.getCurrentPeriodData(for: periodType)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingresos vs Gastos")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let data = periodData {
                HStack(spacing: 20) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.1))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.green)
                        }
                        
                        Text("Ingresos")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text(data.totalIncome, format: .currency(code: "MXN"))
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.red.opacity(0.1))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.red)
                        }
                        
                        Text("Gastos")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text(data.totalExpenses, format: .currency(code: "MXN"))
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                }
                
                // Barra de progreso visual
                VStack(spacing: 8) {
                    HStack {
                        Text("Balance")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(data.balance, format: .currency(code: "MXN"))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(data.balance >= 0 ? .green : .red)
                    }
                    
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: geometry.size.width * (data.totalIncome / (data.totalIncome + data.totalExpenses)))
                            
                            Rectangle()
                                .fill(Color.red)
                                .frame(width: geometry.size.width * (data.totalExpenses / (data.totalIncome + data.totalExpenses)))
                        }
                    }
                    .frame(height: 8)
                    .cornerRadius(4)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary.opacity(0.6))
                    
                    Text("Sin datos para mostrar")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(height: 120)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Modern Expenses by Category Chart
struct ModernExpensesByCategoryChart: View {
    @ObservedObject var viewModel: ReportsViewModel
    let periodType: FinancialPeriod.PeriodType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Gastos por Categoría")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 14) {
                ForEach(ExpenseCategory.allCases.prefix(5), id: \.self) { category in
                    HStack(spacing: 14) {
                        Image(systemName: category.icon)
                            .foregroundColor(Color(category.color))
                            .font(.system(size: 18))
                            .frame(width: 24)
                        
                        Text(category.rawValue)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        Spacer()
                        
                        Text(viewModel.getCategoryAmount(category, for: periodType), format: .currency(code: "MXN"))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.red)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .padding(.vertical, 6)
                    
                    if category != ExpenseCategory.allCases.prefix(5).last {
                        Divider()
                            .padding(.horizontal, 4)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct IncomeVsExpensesChart: View {
    @ObservedObject var viewModel: ReportsViewModel
    let periodType: FinancialPeriod.PeriodType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ingresos vs Gastos")
                .font(.headline)
            
            // Aquí iría la implementación de Charts (iOS 16+)
            // Por ahora mostramos un placeholder
            HStack {
                VStack {
                    Text("Ingresos")
                        .font(.caption)
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: 60, height: 100)
                    Text("$25,000")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
                VStack {
                    Text("Gastos")
                        .font(.caption)
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 60, height: 60)
                    Text("$15,000")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
            .frame(height: 120)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}

struct ExpensesByCategoryChart: View {
    @ObservedObject var viewModel: ReportsViewModel
    let periodType: FinancialPeriod.PeriodType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Gastos por Categoría")
                .font(.headline)
            
            // Placeholder para gráfica de dona
            ZStack {
                Circle()
                    .stroke(Color.blue, lineWidth: 20)
                    .frame(width: 100, height: 100)
                
                Circle()
                    .stroke(Color.red, lineWidth: 20)
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                
                Circle()
                    .stroke(Color.orange, lineWidth: 20)
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(90))
                
                VStack {
                    Text("Total")
                        .font(.caption)
                    Text("$15,000")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            .frame(height: 120)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}

struct ExpensesByCategoryCard: View {
    @ObservedObject var viewModel: ReportsViewModel
    let periodType: FinancialPeriod.PeriodType
    
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
            
            VStack(spacing: 16) {
                ForEach(ExpenseCategory.allCases.prefix(8), id: \.self) { category in
                    HStack(spacing: 16) {
                        Image(systemName: category.icon)
                            .foregroundColor(Color(category.color))
                            .font(.system(size: 20))
                            .frame(width: 28)
                        
                        Text(category.rawValue)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        Spacer()
                        
                        Text(viewModel.getCategoryAmount(category, for: periodType), format: .currency(code: "MXN"))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.red)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
                    
                    if category != ExpenseCategory.allCases.prefix(8).last {
                        Divider()
                            .padding(.horizontal, 8)
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

struct PeriodComparisonCard: View {
    @ObservedObject var viewModel: ReportsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 20))
                    .foregroundColor(.purple)
                
                Text("Comparativa de Períodos")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Semana Anterior")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("$5,200")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("Balance")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 8) {
                        Text("Quincena Anterior")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("$12,800")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("Balance")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("Mes Anterior")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("$24,500")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("Balance")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Tendencia")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right")
                            .foregroundColor(.green)
                            .font(.system(size: 14))
                        
                        Text("Creciente")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
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

#Preview {
    ReportsView()
}
