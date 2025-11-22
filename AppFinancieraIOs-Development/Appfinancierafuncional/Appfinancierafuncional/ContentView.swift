//
//  ContentView.swift
//  Appfinancierafuncional
//
//  Created by Alumno on 11/09/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var animateTabs = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Dashboard")
                }
                .tag(0)
            
            IncomeView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "arrow.up.circle.fill" : "arrow.up.circle")
                    Text("Ingresos")
                }
                .tag(1)
            
            ExpensesView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "cart.fill" : "cart")
                    Text("Gastos")
                }
                .tag(2)
            
            DeductionsView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "percent" : "percent")
                    Text("Deducciones")
                }
                .tag(3)
            
            ReportsView()
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "chart.bar.fill" : "chart.bar")
                    Text("Reportes")
                }
                .tag(4)
        }
        .accentColor(.blue)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animateTabs = true
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
