import Foundation
import SwiftUI

struct Constants {
    // MARK: - API Configuration
    struct API {
        // Lee la URL base del Info.plist, fallback a localhost
        static let baseURL: String = {
            if let url = Bundle.main.infoDictionary?["API_BASE_URL"] as? String {
                return url
            }
            // Fallback para desarrollo local
            return "http://localhost:5000/api"
        }()
    }
    
    // Colores de la aplicación - Glass Design
    struct Colors {
        // Colores principales con Glass design
        static let primary = Color.blue
        static let secondary = Color.gray
        static let success = Color.green
        static let warning = Color.orange
        static let danger = Color.red
        
        // Fondos adaptables a Glass
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.systemGray6)
        
        // Colores translúcidos para Glass Morphism
        static let glassTint = Color.blue.opacity(0.1)
        static let glassOverlay = Color.white.opacity(0.15)
        static let glassOverlayDark = Color.black.opacity(0.1)
    }
    
    // Configuración de la aplicación
    struct App {
        static let name = "AppFinancieraIOs"
        static let version = "1.0.0"
        static let build = "1"
    }
    
    // Configuración fiscal
    struct Tax {
        static let isrLowerLimit = 15487.72
        static let isrMarginalRate = 21.36
        static let isrFixedQuota = 1640.18
        static let imssRate = 2.75
        static let currency = "MXN"
    }
    
    // Configuración de períodos
    struct Periods {
        static let weekly = 7
        static let biweekly = 15
        static let monthly = 30
    }
    
    // Configuración de la interfaz
    struct UI {
        static let cornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 2
        static let padding: CGFloat = 16
        static let spacing: CGFloat = 20
    }
    
    // Configuración de notificaciones
    struct Notifications {
        static let weeklyReminder = "weekly_reminder"
        static let biweeklyReminder = "biweekly_reminder"
        static let monthlyReminder = "monthly_reminder"
    }
    
    // Configuración de almacenamiento
    struct Storage {
        static let userDefaultsSuite = "com.appfinanciera.userdefaults"
        static let coreDataModel = "AppFinancieraIOs"
    }
}
