//
//  ContentView.swift
//  Appfinancierafuncional
//
//  Created by Alumno on 11/09/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: selectedTab == 0 ? "house.fill" : "house")
                }
                .tag(0)
                .accessibilityLabel("Panel principal")
                .accessibilityHint("Muestra el resumen de tu situación financiera")
            
            IncomeView()
                .tabItem {
                    Label("Ingresos", systemImage: selectedTab == 1 ? "arrow.up.circle.fill" : "arrow.up.circle")
                }
                .tag(1)
                .accessibilityLabel("Ingresos")
                .accessibilityHint("Gestiona tus ingresos")
            
            ExpensesView()
                .tabItem {
                    Label("Gastos", systemImage: selectedTab == 2 ? "cart.fill" : "cart")
                }
                .tag(2)
                .accessibilityLabel("Gastos")
                .accessibilityHint("Gestiona tus gastos por categoría")
            
            DeductionsView()
                .tabItem {
                    Label("Deducciones", systemImage: selectedTab == 3 ? "percent" : "percent")
                }
                .tag(3)
                .accessibilityLabel("Deducciones fiscales")
                .accessibilityHint("Gestiona tus deducciones de ISR e IMSS")
            
            ReportsView()
                .tabItem {
                    Label("Reportes", systemImage: selectedTab == 4 ? "chart.bar.fill" : "chart.bar")
                }
                .tag(4)
                .accessibilityLabel("Reportes financieros")
                .accessibilityHint("Visualiza gráficas y análisis de tus finanzas")
        }
        .tint(colorScheme == .dark ? .cyan : .blue)
        // No forzamos colorScheme para respetar preferencias del usuario
    }
}

#Preview {
    ContentView()
}

#Preview("Dark Mode") {
    ContentView()
        .preferredColorScheme(.dark)
}

