import SwiftUI

// MARK: - Glass Card Modifier
struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 20
    var shadowRadius: CGFloat = 10
    var opacity: Double = 0.1
    
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(opacity), radius: shadowRadius, x: 0, y: 4)
    }
}

// MARK: - Glass Background Modifier
struct GlassBackground: ViewModifier {
    var material: Material = .regularMaterial
    var cornerRadius: CGFloat = 20
    
    func body(content: Content) -> some View {
        content
            .background(material)
            .cornerRadius(cornerRadius)
    }
}

// MARK: - Frosted Blur View
struct FrostedBlur: View {
    var radius: CGFloat = 10
    var material: Material = .ultraThinMaterial
    
    var body: some View {
        Rectangle()
            .fill(material)
            .blur(radius: radius)
    }
}

// MARK: - Glass Button Style
struct GlassButtonStyle: ButtonStyle {
    var backgroundColor: Color = .blue
    var foregroundColor: Color = .white
    var cornerRadius: CGFloat = 12
    var padding: CGFloat = 12
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(padding)
            .background(backgroundColor.opacity(configuration.isPressed ? 0.7 : 0.85))
            .cornerRadius(cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Glass Card View Container
struct GlassCardContainer<Content: View>: View {
    @ViewBuilder let content: Content
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 16
    
    var body: some View {
        content
            .padding(padding)
            .modifier(GlassCard(cornerRadius: cornerRadius))
            .padding(.horizontal, 16)
    }
}

// MARK: - Extension for easy application
extension View {
    func glassCard(cornerRadius: CGFloat = 20, shadowRadius: CGFloat = 10, opacity: Double = 0.1) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, shadowRadius: shadowRadius, opacity: opacity))
    }
    
    func glassBackground(material: Material = .regularMaterial, cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassBackground(material: material, cornerRadius: cornerRadius))
    }
    
    func glassButtonStyle(
        backgroundColor: Color = .blue,
        foregroundColor: Color = .white,
        cornerRadius: CGFloat = 12,
        padding: CGFloat = 12
    ) -> some View {
        buttonStyle(GlassButtonStyle(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            cornerRadius: cornerRadius,
            padding: padding
        ))
    }
}

// MARK: - Gradient Extensions
extension LinearGradient {
    static var glassGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.2),
                Color.white.opacity(0.05)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var glassGradientDark: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.black.opacity(0.1),
                Color.black.opacity(0.05)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
