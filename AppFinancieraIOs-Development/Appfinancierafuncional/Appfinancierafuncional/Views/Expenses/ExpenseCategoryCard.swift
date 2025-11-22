import SwiftUI

struct ExpenseCategoryCard: View {
    let title: String
    let icon: String
    let color: Color
    let categories: [ExpenseCategory]
    @ObservedObject var viewModel: ExpensesViewModel
    @State private var isExpanded = false
    
    var body: some View {
        VStack {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                    Text(title)
                        .font(.headline)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
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
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct ExpenseInputField: View {
    let category: ExpenseCategory
    @Binding var amount: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(Color(category.color))
                Text(category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            TextField("Importe", value: $amount, format: .currency(code: "MXN"))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
        }
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
