import SwiftUI

// MARK: - Animation Extensions
extension Animation {
    static let smoothSpring = Animation.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)
    static let bouncySpring = Animation.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)
    static let gentleEaseOut = Animation.easeOut(duration: 0.4)
    static let quickEaseInOut = Animation.easeInOut(duration: 0.2)
}

// MARK: - View Modifiers for Animations
struct FadeInModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(.easeOut(duration: 0.6).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

struct SlideInFromLeftModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(x: isVisible ? 0 : -30)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

struct ScaleInModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isVisible ? 1 : 0.8)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.bouncySpring.delay(delay)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Custom View Modifiers
extension View {
    func fadeIn(delay: Double = 0) -> some View {
        self.modifier(FadeInModifier(delay: delay))
    }
    
    func slideInFromLeft(delay: Double = 0) -> some View {
        self.modifier(SlideInFromLeftModifier(delay: delay))
    }
    
    func scaleIn(delay: Double = 0) -> some View {
        self.modifier(ScaleInModifier(delay: delay))
    }
    
    func pulseAnimation() -> some View {
        self
            .scaleEffect(1.0)
            .animation(
                Animation.easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true),
                value: UUID()
            )
    }
    
    func shimmerEffect() -> some View {
        self
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.0),
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.0)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .rotationEffect(.degrees(30))
                    .offset(x: -200)
                    .animation(
                        Animation.linear(duration: 1.5)
                            .repeatForever(autoreverses: false),
                        value: UUID()
                    )
            )
            .clipped()
    }
}


// MARK: - Custom Button Styles
struct SimpleButtonStyle: ButtonStyle {
    let color: Color
    let isPressed: Bool
    
    init(color: Color = .blue, isPressed: Bool = false) {
        self.color = color
        self.isPressed = isPressed
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.quickEaseInOut, value: configuration.isPressed)
            .onTapGesture {
                HapticFeedback.light()
            }
    }
}

struct GradientButtonStyle: ButtonStyle {
    let gradient: LinearGradient
    let isPressed: Bool
    
    init(gradient: LinearGradient, isPressed: Bool = false) {
        self.gradient = gradient
        self.isPressed = isPressed
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.quickEaseInOut, value: configuration.isPressed)
            .onTapGesture {
                HapticFeedback.medium()
            }
    }
}
