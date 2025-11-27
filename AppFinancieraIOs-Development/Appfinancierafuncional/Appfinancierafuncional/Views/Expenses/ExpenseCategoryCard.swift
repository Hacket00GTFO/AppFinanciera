import SwiftUI

struct ExpenseCategoryCard: View {
    let title: String
    let icon: String
    let color: Color
    let categories: [ExpenseCategory]
    @ObservedObject var viewModel: ExpensesViewModel
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                        .frame(width: 32, height: 32)
                        .background(color.opacity(0.15))
                        .cornerRadius(8)
                    
                    Text(title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .padding(16)
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Divider()
                    .padding(.horizontal, 16)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        ExpenseInputField(
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
                .padding(16)
            }
        }
        .glassCard(cornerRadius: 16)
    }
}

struct ExpenseInputField: View {
    let category: ExpenseCategory
    @Binding var amount: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(category.color))
                
                Text(category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            TextField("0.00", value: $amount, format: .currency(code: "MXN"))
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(10)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(10)
    }
}

#Preview {
    ExpenseCategoryCard(
        title: "Fijos obligatorios",
        icon: "exclamationmark.triangle.fill",
        color: .red,
        categories: ExpenseCategory.allCases.filter { $0.isMandatory },
        viewModel: ExpensesViewModel()
    )
}
