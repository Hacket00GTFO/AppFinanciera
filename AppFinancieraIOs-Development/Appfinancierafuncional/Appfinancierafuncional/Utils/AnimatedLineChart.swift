import SwiftUI

struct AnimatedLineChart: View {
    let data: [Double]
    let color: Color
    let lineWidth: CGFloat
    let showDots: Bool
    let showGradient: Bool
    
    @State private var animationProgress: CGFloat = 0
    @State private var animateDots = false
    
    init(
        data: [Double],
        color: Color = .blue,
        lineWidth: CGFloat = 3,
        showDots: Bool = true,
        showGradient: Bool = true
    ) {
        self.data = data
        self.color = color
        self.lineWidth = lineWidth
        self.showDots = showDots
        self.showGradient = showGradient
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if showGradient {
                    // Gradiente de fondo
                    Path { path in
                        createPath(in: geometry, path: &path)
                        path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                        path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [color.opacity(0.3), color.opacity(0.05)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(animationProgress)
                }
                
                // Línea principal
                Path { path in
                    createPath(in: geometry, path: &path)
                }
                .trim(from: 0, to: animationProgress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                )
                .opacity(animationProgress)
                
                // Puntos de datos
                if showDots && animateDots {
                    ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                        Circle()
                            .fill(color)
                            .frame(width: 8, height: 8)
                            .position(
                                x: CGFloat(index) * (geometry.size.width / CGFloat(max(1, data.count - 1))),
                                y: geometry.size.height - (value / maxValue) * geometry.size.height
                            )
                            .scaleEffect(animateDots ? 1.0 : 0.0)
                            .opacity(animateDots ? 1.0 : 0.0)
                            .animation(
                                .easeOut(duration: 0.3)
                                    .delay(Double(index) * 0.1),
                                value: animateDots
                            )
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                animationProgress = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 0.8)) {
                    animateDots = true
                }
            }
        }
    }
    
    private var maxValue: Double {
        data.max() ?? 1
    }
    
    private func createPath(in geometry: GeometryProxy, path: inout Path) {
        guard data.count > 1 else { return }
        
        let stepX = geometry.size.width / CGFloat(max(1, data.count - 1))
        let maxVal = maxValue
        
        for (index, value) in data.enumerated() {
            let x = CGFloat(index) * stepX
            let y = geometry.size.height - (value / maxVal) * geometry.size.height
            
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
    }
}

struct AnimatedBarChart: View {
    let data: [BarData]
    let color: Color
    let showAnimation: Bool
    
    @State private var animateBars = false
    
    init(data: [BarData], color: Color = .blue, showAnimation: Bool = true) {
        self.data = data
        self.color = color
        self.showAnimation = showAnimation
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(Array(data.enumerated()), id: \.offset) { index, barData in
                    VStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [color, color.opacity(0.7)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: animateBars ? barHeight(for: barData.value, in: geometry) : 0)
                            .animation(
                                .easeOut(duration: 0.8)
                                    .delay(Double(index) * 0.1),
                                value: animateBars
                            )
                        
                        if !barData.label.isEmpty {
                            Text(barData.label)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .rotationEffect(.degrees(-45))
                        }
                    }
                }
            }
        }
        .onAppear {
            if showAnimation {
                withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                    animateBars = true
                }
            } else {
                animateBars = true
            }
        }
    }
    
    private func barHeight(for value: Double, in geometry: GeometryProxy) -> CGFloat {
        let maxValue = data.map(\.value).max() ?? 1
        return (value / maxValue) * geometry.size.height * 0.8
    }
}

struct BarData {
    let value: Double
    let label: String
    
    init(value: Double, label: String = "") {
        self.value = value
        self.label = label
    }
}

struct CircularProgressView: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    let showPercentage: Bool
    
    @State private var animateProgress = false
    
    init(
        progress: Double,
        color: Color = .blue,
        lineWidth: CGFloat = 8,
        showPercentage: Bool = true
    ) {
        self.progress = progress
        self.color = color
        self.lineWidth = lineWidth
        self.showPercentage = showPercentage
    }
    
    var body: some View {
        ZStack {
            // Fondo del círculo
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            
            // Progreso animado
            Circle()
                .trim(from: 0, to: animateProgress ? progress : 0)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.5), value: animateProgress)
            
            // Texto del porcentaje
            if showPercentage {
                VStack(spacing: 4) {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(color)
                    
                    Text("Completado")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .opacity(animateProgress ? 1 : 0)
                .animation(.easeOut(duration: 0.8).delay(0.5), value: animateProgress)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                animateProgress = true
            }
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        // Gráfico de líneas
        AnimatedLineChart(
            data: [100, 120, 80, 150, 200, 180, 220],
            color: .blue,
            showDots: true,
            showGradient: true
        )
        .frame(height: 150)
        
        // Gráfico de barras
        AnimatedBarChart(
            data: [
                BarData(value: 100, label: "Ene"),
                BarData(value: 150, label: "Feb"),
                BarData(value: 80, label: "Mar"),
                BarData(value: 200, label: "Abr"),
                BarData(value: 120, label: "May")
            ],
            color: .green
        )
        .frame(height: 150)
        
        // Progreso circular
        CircularProgressView(
            progress: 0.75,
            color: .purple,
            showPercentage: true
        )
        .frame(width: 100, height: 100)
    }
    .padding()
}
