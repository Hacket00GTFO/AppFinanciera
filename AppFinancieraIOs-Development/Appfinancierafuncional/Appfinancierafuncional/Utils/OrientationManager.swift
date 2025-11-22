import SwiftUI
import UIKit

// MARK: - Orientation Manager
class OrientationManager: ObservableObject {
    @Published var isLandscape: Bool = false
    @Published var screenSize: CGSize = UIScreen.main.bounds.size
    
    private var orientationObserver: NSObjectProtocol?
    
    init() {
        updateOrientation()
        setupOrientationObserver()
    }
    
    deinit {
        if let observer = orientationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func setupOrientationObserver() {
        orientationObserver = NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateOrientation()
        }
    }
    
    private func updateOrientation() {
        let orientation = UIDevice.current.orientation
        let screenSize = UIScreen.main.bounds.size
        
        self.screenSize = screenSize
        
        switch orientation {
        case .landscapeLeft, .landscapeRight:
            self.isLandscape = true
        case .portrait, .portraitUpsideDown:
            self.isLandscape = false
        default:
            // Use screen dimensions as fallback
            self.isLandscape = screenSize.width > screenSize.height
        }
    }
}

// MARK: - Dynamic Font System
struct DynamicFont {
    static func title2(isLandscape: Bool) -> Font {
        return .system(size: isLandscape ? 26.0 : 22.0, weight: .bold, design: .rounded)
    }
    
    static func headline(isLandscape: Bool) -> Font {
        return .system(size: isLandscape ? 20.0 : 17.0, weight: .semibold, design: .default)
    }
    
    static func subheadline(isLandscape: Bool) -> Font {
        return .system(size: isLandscape ? 18.0 : 15.0, weight: .regular, design: .default)
    }
    
    static func caption(isLandscape: Bool) -> Font {
        return .system(size: isLandscape ? 14.0 : 12.0, weight: .regular, design: .default)
    }
    
    static func caption2(isLandscape: Bool) -> Font {
        return .system(size: isLandscape ? 13.0 : 11.0, weight: .regular, design: .default)
    }
    
    // Financial specific fonts
    static func financialLarge(isLandscape: Bool) -> Font {
        return .system(size: isLandscape ? 42.0 : 36.0, weight: .bold, design: .rounded)
    }
    
    static func financialMedium(isLandscape: Bool) -> Font {
        return .system(size: isLandscape ? 28.0 : 24.0, weight: .bold, design: .rounded)
    }
    
    static func financialSmall(isLandscape: Bool) -> Font {
        return .system(size: isLandscape ? 22.0 : 18.0, weight: .semibold, design: .rounded)
    }
    
    // Chart specific fonts
    static func chartTitle(isLandscape: Bool) -> Font {
        return .system(size: isLandscape ? 12.0 : 11.0, weight: .medium, design: .default)
    }
    
    static func chartAmount(isLandscape: Bool) -> Font {
        return .system(size: isLandscape ? 16.0 : 14.0, weight: .bold, design: .rounded)
    }
    
    static func categoryName(isLandscape: Bool) -> Font {
        return .system(size: isLandscape ? 17.0 : 15.0, weight: .medium, design: .default)
    }
    
    static func categoryAmount(isLandscape: Bool) -> Font {
        return .system(size: isLandscape ? 17.0 : 15.0, weight: .semibold, design: .default)
    }
    
    static func categoryPercentage(isLandscape: Bool) -> Font {
        return .system(size: isLandscape ? 14.0 : 12.0, weight: .regular, design: .default)
    }
    
    static func rankNumber(isLandscape: Bool) -> Font {
        return .system(size: isLandscape ? 14.0 : 12.0, weight: .bold, design: .default)
    }
}

// MARK: - Dynamic Sizing Helper
struct DynamicSizing {
    static func chartSize(isLandscape: Bool) -> CGFloat {
        return isLandscape ? 140 : 120
    }
    
    static func rankCircleSize(isLandscape: Bool) -> CGFloat {
        return isLandscape ? 32 : 28
    }
    
    static func progressBarWidth(isLandscape: Bool) -> CGFloat {
        return isLandscape ? 100 : 80
    }
    
    static func iconSize(isLandscape: Bool) -> CGFloat {
        return isLandscape ? 20 : 18
    }
    
    static func categoryIconSize(isLandscape: Bool) -> CGFloat {
        return isLandscape ? 22 : 18
    }
}
