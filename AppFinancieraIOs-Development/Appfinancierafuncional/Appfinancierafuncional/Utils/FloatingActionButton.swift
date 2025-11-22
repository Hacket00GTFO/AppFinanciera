import SwiftUI

struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    let color: Color
    let size: CGFloat
    
    @State private var isPressed = false
    @State private var showPulse = false
    
    init(
        icon: String,
        action: @escaping () -> Void,
        color: Color = .primaryBlue,
        size: CGFloat = 56
    ) {
        self.icon = icon
        self.action = action
        self.color = color
        self.size = size
    }
    
    var body: some View {
        Button(action: {
            HapticFeedback.medium()
            action()
        }) {
            ZStack {
                // Efecto de pulso
                if showPulse {
                    Circle()
                        .fill(color.opacity(0.3))
                        .frame(width: size + 20, height: size + 20)
                        .scaleEffect(showPulse ? 1.2 : 1.0)
                        .opacity(showPulse ? 0 : 1)
                        .animation(
                            Animation.easeOut(duration: 1.0)
                                .repeatForever(autoreverses: false),
                            value: showPulse
                        )
                }
                
                // Botón principal
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [color, color.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                    .shadow(
                        color: color.opacity(0.4),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: isPressed)
                
                // Icono
                Image(systemName: icon)
                    .font(.system(size: size * 0.4, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        } perform: {
            // Acción al soltar
        }
        .onAppear {
            withAnimation(.easeOut(duration: 2.0).delay(1.0)) {
                showPulse = true
            }
        }
    }
}

struct SecondaryAction {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    init(icon: String, label: String, color: Color = .gray, action: @escaping () -> Void) {
        self.icon = icon
        self.label = label
        self.color = color
        self.action = action
    }
}

struct MultiFloatingActionButton: View {
    @State private var isExpanded = false
    @State private var rotationAngle: Double = 0
    
    let primaryIcon: String
    let primaryAction: () -> Void
    let secondaryActions: [SecondaryAction]
    let primaryColor: Color
    
    init(
        primaryIcon: String,
        primaryAction: @escaping () -> Void,
        secondaryActions: [SecondaryAction],
        primaryColor: Color = .primaryBlue
    ) {
        self.primaryIcon = primaryIcon
        self.primaryAction = primaryAction
        self.secondaryActions = secondaryActions
        self.primaryColor = primaryColor
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Acciones secundarias
            if isExpanded {
                ForEach(Array(secondaryActions.enumerated()), id: \.offset) { index, action in
                    SecondaryActionButton(
                        icon: action.icon,
                        label: action.label,
                        color: action.color,
                        action: action.action
                    )
                    .opacity(isExpanded ? 1 : 0)
                    .offset(y: isExpanded ? 0 : 20)
                    .animation(
                        .easeOut(duration: 0.3)
                            .delay(Double(index) * 0.1),
                        value: isExpanded
                    )
                }
            }
            
            // Botón principal
            Button(action: {
                HapticFeedback.medium()
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                    rotationAngle = isExpanded ? 45 : 0
                }
                
                if !isExpanded {
                    primaryAction()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [primaryColor, primaryColor.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .shadow(
                            color: primaryColor.opacity(0.4),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                    
                    Image(systemName: isExpanded ? "xmark" : primaryIcon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(rotationAngle))
                        .animation(.easeInOut(duration: 0.3), value: rotationAngle)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct SecondaryActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Label
            Text(label)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.cardBackground)
                        .shadow(
                            color: Color.black.opacity(0.1),
                            radius: 4,
                            x: 0,
                            y: 2
                        )
                )
            
            // Botón
            Button(action: {
                HapticFeedback.light()
                action()
            }) {
                Circle()
                    .fill(color)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    )
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: isPressed)
            }
            .buttonStyle(PlainButtonStyle())
            .onLongPressGesture(minimumDuration: 0) { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressing
                }
            } perform: {
                // Acción al soltar
            }
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1)
            .ignoresSafeArea()
        
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                MultiFloatingActionButton(
                    primaryIcon: "plus",
                    primaryAction: {
                        print("Primary action tapped")
                    },
                    secondaryActions: [
                        SecondaryAction(
                            icon: "dollarsign.circle.fill",
                            label: "Agregar Ingreso",
                            color: Color.green,
                            action: { print("Add income") }
                        ),
                        SecondaryAction(
                            icon: "cart.fill",
                            label: "Agregar Gasto",
                            color: Color.red,
                            action: { print("Add expense") }
                        ),
                        SecondaryAction(
                            icon: "percent",
                            label: "Agregar Deducción",
                            color: Color.orange,
                            action: { print("Add deduction") }
                        )
                    ]
                )
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
    }
}
