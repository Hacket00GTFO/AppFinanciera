import SwiftUI

struct RecentIncomeCard: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var animateIncomes = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header con icono
            HStack {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
                
                Text("Ingresos Recientes")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {}) {
                    Text("Ver todo")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
            }
            
            if viewModel.recentIncome.isEmpty {
                EmptyIncomeView()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(viewModel.recentIncome.enumerated()), id: \.element.id) { index, income in
                        RecentIncomeRowView(income: income)
                            .opacity(animateIncomes ? 1 : 0)
                            .offset(x: animateIncomes ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(Double(index) * 0.1), value: animateIncomes)
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
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                animateIncomes = true
            }
        }
    }
}

struct EmptyIncomeView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.up.circle")
                .font(.system(size: 48))
                .foregroundColor(.green.opacity(0.6))
            
            Text("No hay ingresos registrados")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Agrega algunos ingresos para ver tu historial")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
    }
}

struct RecentIncomeRowView: View {
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
                
                // Tags
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
            }
            
            Spacer()
            
            // Monto y fecha
            VStack(alignment: .trailing, spacing: 6) {
                Text(income.netAmount, format: .currency(code: "MXN"))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                
                Text(income.date, style: .date)
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

#Preview {
    RecentIncomeCard(viewModel: DashboardViewModel())
}
