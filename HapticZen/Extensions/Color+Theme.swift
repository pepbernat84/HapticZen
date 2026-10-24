import SwiftUI

extension Color {
    static let zenBackground = Color("ZenBackground", bundle: .main)
    static let zenAccent = Color("AccentColor", bundle: .main)
    
    // Fallbacks and dark theme tokens if asset colors are missing
    static let zenDarkBackground = Color(red: 0.04, green: 0.05, blue: 0.08)
    static let zenCardBackground = Color(red: 0.10, green: 0.12, blue: 0.18, opacity: 0.85)
    static let zenGlow = Color(red: 0.35, green: 0.65, blue: 0.95)
    static let zenTextSecondary = Color.white.opacity(0.65)
}

struct ZenBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Color.zenDarkBackground
                .ignoresSafeArea()
            content
        }
    }
}

extension View {
    func zenBackgroundStyle() -> some View {
        self.modifier(ZenBackgroundModifier())
    }
}
