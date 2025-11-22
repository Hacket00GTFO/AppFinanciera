import SwiftUI

struct ActivePeriodsCard: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var animatePeriods = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header con icono
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                
                Text("Períodos Activos")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(viewModel.activePeriods.count)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            
            if viewModel.activePeriods.isEmpty {
                EmptyPeriodsView()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(viewModel.activePeriods.enumerated()), id: \.element.id) { index, period in
                        PeriodRowView(period: period)
                            .opacity(animatePeriods ? 1 : 0)
                            .offset(x: animatePeriods ? 0 : -20)
                            .animation(.easeOut(duration: 0.5).delay(Double(index) * 0.1), value: animatePeriods)
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
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                animatePeriods = true
            }
        }
    }
}

struct EmptyPeriodsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.blue.opacity(0.6))
            
            Text("No hay períodos activos")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Crea un nuevo período para comenzar a registrar tus finanzas")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
    }
}

struct PeriodRowView: View {
    let period: FinancialPeriod
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icono del período
            ZStack {
                Circle()
                    .fill(period.balance >= 0 ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: period.balance >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(period.balance >= 0 ? .green : .red)
            }
            
            // Información del período
            VStack(alignment: .leading, spacing: 6) {
                Text(period.type.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("\(period.startDate.reportFormat) - \(period.endDate.reportFormat)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Métricas en miniatura
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                        Text("I: \(period.totalIncome, format: .currency(code: "MXN"))")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 6, height: 6)
                        Text("G: \(period.totalExpenses, format: .currency(code: "MXN"))")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                }
            }
            
            Spacer()
            
            // Balance principal
            VStack(alignment: .trailing, spacing: 4) {
                Text(period.balance, format: .currency(code: "MXN"))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(period.balance >= 0 ? .green : .red)
                
                Text(period.balance >= 0 ? "Positivo" : "Negativo")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(period.balance >= 0 ? .green : .red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill((period.balance >= 0 ? Color.green : Color.red).opacity(0.1))
                    )
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

#Preview {
    ActivePeriodsCard(viewModel: DashboardViewModel())
}
