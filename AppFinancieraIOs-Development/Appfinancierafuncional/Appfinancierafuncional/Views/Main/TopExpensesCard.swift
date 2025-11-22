import SwiftUI

struct TopExpensesCard: View {
    @ObservedObject var viewModel: DashboardViewModel
    @StateObject private var orientationManager = OrientationManager()
    @State private var animateChart = false
    @State private var animateRows = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header con icono
            HStack {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: DynamicSizing.iconSize(isLandscape: orientationManager.isLandscape)))
                    .foregroundColor(.orange)
                
                Text("Gastos por Categoría")
                    .font(DynamicFont.title2(isLandscape: orientationManager.isLandscape))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {}) {
                    Text("Ver todo")
                        .font(DynamicFont.caption(isLandscape: orientationManager.isLandscape))
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
            }
            
            if viewModel.topExpenses.isEmpty {
                EmptyExpensesView(orientationManager: orientationManager)
            } else {
                HStack(spacing: 20) {
                    // Gráfico circular
                    CircularChartView(expenses: viewModel.topExpenses, orientationManager: orientationManager)
                        .frame(width: DynamicSizing.chartSize(isLandscape: orientationManager.isLandscape), 
                               height: DynamicSizing.chartSize(isLandscape: orientationManager.isLandscape))
                        .scaleEffect(animateChart ? 1.0 : 0.8)
                        .opacity(animateChart ? 1.0 : 0.0)
                    
                    // Lista de gastos
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(viewModel.topExpenses.enumerated()), id: \.element.category) { index, item in
                            TopExpenseRowView(
                                rank: index + 1,
                                category: item.category,
                                amount: item.amount,
                                percentage: calculatePercentage(item.amount, total: viewModel.topExpenses.map(\.amount).reduce(0, +)),
                                orientationManager: orientationManager
                            )
                            .opacity(animateRows ? 1 : 0)
                            .offset(x: animateRows ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(Double(index) * 0.1), value: animateRows)
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
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                animateChart = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
                animateRows = true
            }
        }
    }
    
    private func calculatePercentage(_ amount: Double, total: Double) -> Double {
        guard total > 0 else { return 0 }
        return (amount / total) * 100
    }
}

struct EmptyExpensesView: View {
    @ObservedObject var orientationManager: OrientationManager
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.pie")
                .font(.system(size: orientationManager.isLandscape ? 56.0 : 48.0))
                .foregroundColor(.orange.opacity(0.6))
            
            Text("No hay gastos registrados")
                .font(DynamicFont.headline(isLandscape: orientationManager.isLandscape))
                .foregroundColor(.secondary)
            
            Text("Agrega algunos gastos para ver el análisis por categorías")
                .font(DynamicFont.caption(isLandscape: orientationManager.isLandscape))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
    }
}

struct CircularChartView: View {
    let expenses: [(category: ExpenseCategory, amount: Double)]
    @ObservedObject var orientationManager: OrientationManager
    @State private var animateProgress = false
    
    private var totalAmount: Double {
        expenses.map(\.amount).reduce(0, +)
    }
    
    private var chartData: [(category: ExpenseCategory, amount: Double, percentage: Double, color: Color)] {
        expenses.map { expense in
            let percentage = totalAmount > 0 ? (expense.amount / totalAmount) * 100 : 0
            return (
                category: expense.category,
                amount: expense.amount,
                percentage: percentage,
                color: Color(expense.category.color)
            )
        }
    }
    
    var body: some View {
        ZStack {
            let chartSize = DynamicSizing.chartSize(isLandscape: orientationManager.isLandscape)
            let lineWidth: CGFloat = orientationManager.isLandscape ? 10 : 8
            
            // Fondo del círculo
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
                .frame(width: chartSize * 0.83, height: chartSize * 0.83)
            
            // Segmentos del gráfico
            ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                Circle()
                    .trim(from: 0, to: animateProgress ? data.percentage / 100 : 0)
                    .stroke(
                        data.color,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .frame(width: chartSize * 0.83, height: chartSize * 0.83)
                    .rotationEffect(.degrees(-90))
                    .rotationEffect(.degrees(calculateRotation(for: index)))
                    .animation(.easeOut(duration: 1.0).delay(Double(index) * 0.2), value: animateProgress)
            }
            
            // Texto central mejorado
            VStack(spacing: 4) {
                Text("Total")
                    .font(DynamicFont.chartTitle(isLandscape: orientationManager.isLandscape))
                    .foregroundColor(.secondary)
                
                Text(totalAmount, format: .currency(code: "MXN"))
                    .font(DynamicFont.chartAmount(isLandscape: orientationManager.isLandscape))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).delay(0.5)) {
                animateProgress = true
            }
        }
    }
    
    private func calculateRotation(for index: Int) -> Double {
        let previousPercentage = chartData.prefix(index).map(\.percentage).reduce(0, +)
        return previousPercentage * 3.6 // 360 degrees / 100%
    }
}

struct TopExpenseRowView: View {
    let rank: Int
    let category: ExpenseCategory
    let amount: Double
    let percentage: Double
    @ObservedObject var orientationManager: OrientationManager
    @State private var isPressed = false
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Ranking
            ZStack {
                Circle()
                    .fill(rankColor)
                    .frame(width: DynamicSizing.rankCircleSize(isLandscape: orientationManager.isLandscape), 
                           height: DynamicSizing.rankCircleSize(isLandscape: orientationManager.isLandscape))
                
                Text("\(rank)")
                    .font(DynamicFont.rankNumber(isLandscape: orientationManager.isLandscape))
                    .foregroundColor(.white)
            }
            
            // Icono de categoría
            Image(systemName: category.icon)
                .foregroundColor(Color(category.color))
                .font(.system(size: DynamicSizing.categoryIconSize(isLandscape: orientationManager.isLandscape)))
                .frame(width: orientationManager.isLandscape ? 28.0 : 24.0)
            
            // Información de categoría
            VStack(alignment: .leading, spacing: 4) {
                Text(category.rawValue)
                    .font(DynamicFont.categoryName(isLandscape: orientationManager.isLandscape))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text("\(String(format: "%.1f", percentage))%")
                    .font(DynamicFont.categoryPercentage(isLandscape: orientationManager.isLandscape))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Monto y barra de progreso
            VStack(alignment: .trailing, spacing: 6) {
                Text(amount, format: .currency(code: "MXN"))
                    .font(DynamicFont.categoryAmount(isLandscape: orientationManager.isLandscape))
                    .foregroundColor(.red)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                // Barra de progreso mejorada
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.red.opacity(0.15))
                        .frame(height: orientationManager.isLandscape ? 8.0 : 6.0)
                        .overlay(
                            HStack {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.red)
                                    .frame(width: geometry.size.width * min(percentage / 100, 1.0))
                                
                                Spacer(minLength: 0)
                            }
                        )
                }
                .frame(width: DynamicSizing.progressBarWidth(isLandscape: orientationManager.isLandscape), 
                       height: orientationManager.isLandscape ? 8.0 : 6.0)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemBackground))
                .opacity(isPressed ? 0.7 : 1.0)
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

#Preview {
    TopExpensesCard(viewModel: DashboardViewModel())
}
