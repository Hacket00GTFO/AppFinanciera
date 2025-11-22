import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var animateCards = false
    @State private var selectedTimeframe = "Mensual"
    
    let timeframes = ["Diario", "Mensual", "Anual"]
    
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
                        // Header con saludo
                        HeaderView()
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : -20)
                        
                        // Tarjeta principal de resumen
                        MainSummaryCard(viewModel: viewModel)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 20)
                        
                        // Selector de período
                        TimeframeSelector(selectedTimeframe: $selectedTimeframe, timeframes: timeframes)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 20)
                        
                        // Grid de métricas
                        MetricsGrid(viewModel: viewModel)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 20)
                        
                        // Períodos activos
                        ActivePeriodsCard(viewModel: viewModel)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 20)
                        
                        // Gastos por categoría
                        TopExpensesCard(viewModel: viewModel)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 20)
                        
                        // Ingresos recientes
                        RecentIncomeCard(viewModel: viewModel)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .refreshable {
                await viewModel.refreshData()
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    animateCards = true
                }
            }
        }
    }
}

struct HeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("¡Hola!")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("Bienvenido a tu dashboard financiero")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Botón de notificaciones
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "bell.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 18))
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }
}

struct MainSummaryCard: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var animateNumbers = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Título principal
            VStack(alignment: .leading, spacing: 8) {
                Text("Resumen Financiero")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Mantén el control de tus finanzas")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Balance principal
            VStack(spacing: 12) {
                Text("Balance Total")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                
                Text(viewModel.monthlyBalance, format: .currency(code: "MXN"))
                    .font(.financialLarge)
                    .foregroundColor(.white)
                    .scaleEffect(animateNumbers ? 1.0 : 0.8)
                    .opacity(animateNumbers ? 1.0 : 0.0)
            }
            
            // Métricas secundarias
            HStack(spacing: 20) {
                MetricItem(
                    title: "Ingresos",
                    value: viewModel.monthlyIncome,
                    color: .green,
                    icon: "arrow.up.circle.fill"
                )
                
                MetricItem(
                    title: "Gastos",
                    value: viewModel.monthlyExpenses,
                    color: .red,
                    icon: "arrow.down.circle.fill"
                )
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

struct MetricItem: View {
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

struct TimeframeSelector: View {
    @Binding var selectedTimeframe: String
    let timeframes: [String]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(timeframes, id: \.self) { timeframe in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTimeframe = timeframe
                    }
                }) {
                    Text(timeframe)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(selectedTimeframe == timeframe ? .white : .blue)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selectedTimeframe == timeframe ? Color.blue : Color.clear)
                        )
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.blue.opacity(0.1))
        )
    }
}

struct MetricsGrid: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            // Tarjeta de ahorros
            MetricCard(
                title: "Ahorros",
                value: max(0, viewModel.monthlyBalance),
                subtitle: "Este mes",
                color: .green,
                icon: "banknote.fill",
                gradient: [Color.green, Color.mint]
            )
            
            // Tarjeta de gastos por categoría
            MetricCard(
                title: "Gastos",
                value: viewModel.monthlyExpenses,
                subtitle: "Este mes",
                color: .red,
                icon: "cart.fill",
                gradient: [Color.red, Color.orange]
            )
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: Double
    let subtitle: String
    let color: Color
    let icon: String
    let gradient: [Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Text(value, format: .currency(code: "MXN"))
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(Spacing.md)
        .background(CardStyle.gradient(LinearGradient(gradient: Gradient(colors: gradient), startPoint: .topLeading, endPoint: .bottomTrailing)))
        .cornerRadius(CornerRadius.lg)
        .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    DashboardView()
}
