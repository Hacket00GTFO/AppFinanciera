import SwiftUI

// MARK: - Color Palette
extension Color {
    // Primary Colors
    static let primaryBlue = Color(red: 0.0, green: 0.48, blue: 1.0)
    static let primaryGreen = Color(red: 0.2, green: 0.78, blue: 0.35)
    static let primaryRed = Color(red: 1.0, green: 0.23, blue: 0.19)
    static let primaryOrange = Color(red: 1.0, green: 0.58, blue: 0.0)
    static let primaryPurple = Color(red: 0.69, green: 0.32, blue: 0.87)
    
    // Gradient Colors
    static let gradientBlue = LinearGradient(
        gradient: Gradient(colors: [Color.blue, Color.purple]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let gradientGreen = LinearGradient(
        gradient: Gradient(colors: [Color.green, Color.mint]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let gradientRed = LinearGradient(
        gradient: Gradient(colors: [Color.red, Color.orange]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let gradientOrange = LinearGradient(
        gradient: Gradient(colors: [Color.orange, Color.yellow]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Background Colors
    static let cardBackground = Color(.systemBackground)
    static let secondaryCardBackground = Color(.secondarySystemBackground)
    static let groupedBackground = Color(.systemGroupedBackground)
}

// MARK: - Typography
extension Font {
    // Headers
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    
    // Body Text
    static let headline = Font.system(size: 17, weight: .semibold, design: .default)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
    
    // Financial Numbers
    static let financialLarge = Font.system(size: 36, weight: .bold, design: .rounded)
    static let financialMedium = Font.system(size: 24, weight: .bold, design: .rounded)
    static let financialSmall = Font.system(size: 18, weight: .semibold, design: .rounded)
}

// MARK: - Spacing
struct Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 40
}

// MARK: - Corner Radius
struct CornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
}

// MARK: - Shadow Styles
struct ShadowStyle {
    static let small = (color: Color.black.opacity(0.05), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
    static let medium = (color: Color.black.opacity(0.1), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
    static let large = (color: Color.black.opacity(0.15), radius: CGFloat(12), x: CGFloat(0), y: CGFloat(6))
    static let card = (color: Color.black.opacity(0.05), radius: CGFloat(10), x: CGFloat(0), y: CGFloat(2))
}

// MARK: - Card Styles
struct CardStyle {
    static func primary() -> some View {
        RoundedRectangle(cornerRadius: CornerRadius.lg)
            .fill(Color.cardBackground)
            .shadow(
                color: ShadowStyle.card.color,
                radius: ShadowStyle.card.radius,
                x: ShadowStyle.card.x,
                y: ShadowStyle.card.y
            )
    }
    
    static func secondary() -> some View {
        RoundedRectangle(cornerRadius: CornerRadius.md)
            .fill(Color.secondaryCardBackground)
    }
    
    static func gradient(_ gradient: LinearGradient) -> some View {
        RoundedRectangle(cornerRadius: CornerRadius.lg)
            .fill(gradient)
    }
}

// MARK: - Button Styles
struct ModernButtonStyle: ButtonStyle {
    let style: ButtonStyleType
    let size: ButtonSize
    let isPressed: Bool
    
    enum ButtonStyleType {
        case primary
        case secondary
        case outline
        case gradient(LinearGradient)
    }
    
    enum ButtonSize {
        case small
        case medium
        case large
        
        var padding: EdgeInsets {
            switch self {
            case .small:
                return EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
            case .medium:
                return EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
            case .large:
                return EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32)
            }
        }
        
        var font: Font {
            switch self {
            case .small:
                return .caption
            case .medium:
                return .callout
            case .large:
                return .headline
            }
        }
    }
    
    init(style: ButtonStyleType = .primary, size: ButtonSize = .medium, isPressed: Bool = false) {
        self.style = style
        self.size = size
        self.isPressed = isPressed
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font)
            .fontWeight(.semibold)
            .foregroundColor(textColor)
            .padding(size.padding)
            .background(backgroundView)
            .cornerRadius(CornerRadius.md)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .onTapGesture {
                HapticFeedback.light()
            }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            Color.primaryBlue
        case .secondary:
            Color.secondaryCardBackground
        case .outline:
            Color.clear
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .stroke(Color.primaryBlue, lineWidth: 1)
                )
        case .gradient(let gradient):
            gradient
        }
    }
    
    private var textColor: Color {
        switch style {
        case .primary, .gradient:
            return .white
        case .secondary:
            return .primary
        case .outline:
            return .primaryBlue
        }
    }
}

// MARK: - Icon Styles
struct IconStyle {
    static func circular(
        icon: String,
        color: Color,
        backgroundColor: Color? = nil,
        size: CGFloat = 24
    ) -> some View {
        ZStack {
            if let backgroundColor = backgroundColor {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: size * 2, height: size * 2)
            }
            
            Image(systemName: icon)
                .font(.system(size: size, weight: .medium))
                .foregroundColor(color)
        }
    }
    
    static func square(
        icon: String,
        color: Color,
        backgroundColor: Color? = nil,
        size: CGFloat = 24
    ) -> some View {
        ZStack {
            if let backgroundColor = backgroundColor {
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(backgroundColor)
                    .frame(width: size * 2, height: size * 2)
            }
            
            Image(systemName: icon)
                .font(.system(size: size, weight: .medium))
                .foregroundColor(color)
        }
    }
}

// MARK: - Animation Presets
struct AnimationPresets {
    static let fadeIn = Animation.easeOut(duration: 0.6)
    static let slideIn = Animation.easeOut(duration: 0.5)
    static let scaleIn = Animation.spring(response: 0.6, dampingFraction: 0.8)
    static let bounce = Animation.spring(response: 0.5, dampingFraction: 0.6)
    static let quick = Animation.easeInOut(duration: 0.2)
    static let smooth = Animation.easeOut(duration: 0.4)
}

// MARK: - Haptic Feedback
struct HapticFeedback {
    static func light() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    static func medium() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    static func heavy() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    static func success() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    static func warning() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }
    
    static func error() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
}

// MARK: - Loading States
struct LoadingView: View {
    let message: String
    @State private var isAnimating = false
    
    init(message: String = "Cargando...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 4)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            }
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Empty State Component
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(.secondary.opacity(0.6))
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.primaryBlue)
                        .cornerRadius(12)
                }
            }
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Progress Indicator
struct ProgressIndicator: View {
    let progress: Double
    let color: Color
    let backgroundColor: Color
    
    init(progress: Double, color: Color = .blue, backgroundColor: Color = .gray.opacity(0.3)) {
        self.progress = progress
        self.color = color
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(backgroundColor)
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: geometry.size.width * min(max(progress, 0), 1), height: 8)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 8)
    }
}

// MARK: - Badge Component
struct Badge: View {
    let text: String
    let color: Color
    let backgroundColor: Color
    
    init(text: String, color: Color = .white, backgroundColor: Color = .blue) {
        self.text = text
        self.color = color
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
            )
    }
}

// MARK: - Card Container
struct CardContainer<Content: View>: View {
    let content: Content
    let padding: EdgeInsets
    let cornerRadius: CGFloat
    let shadowColor: Color
    let shadowRadius: CGFloat
    
    init(
        padding: EdgeInsets = EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
        cornerRadius: CGFloat = 16,
        shadowColor: Color = Color.black.opacity(0.05),
        shadowRadius: CGFloat = 10,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.systemBackground))
                    .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 2)
            )
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let icon: String?
    let color: Color
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        title: String,
        icon: String? = nil,
        color: Color = .primary,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

// MARK: - Layout Helpers
struct LayoutHelpers {
    static func cardPadding() -> EdgeInsets {
        EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
    }
    
    static func sectionSpacing() -> CGFloat {
        Spacing.lg
    }
    
    static func itemSpacing() -> CGFloat {
        Spacing.md
    }
    
    static func screenPadding() -> EdgeInsets {
        EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
    }
    
    static func safeAreaPadding() -> EdgeInsets {
        EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    }
}
