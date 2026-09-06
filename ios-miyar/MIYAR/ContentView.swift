import SwiftUI

/// Root of the app: owns the store and applies language direction globally.
struct ContentView: View {
    @State private var store = AppStore()

    var body: some View {
        ZStack {
            Theme.canvas.ignoresSafeArea()
            if store.isSignedIn {
                MainTabView()
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                AuthFlowView()
                    .transition(.opacity)
            }
        }
        .environment(store)
        .environment(\.layoutDirection, store.language.layoutDirection)
        .environment(\.locale, Locale(identifier: store.language.localeIdentifier))
        .tint(Theme.gold)
        .animation(.easeInOut(duration: 0.3), value: store.isSignedIn)
        .animation(.easeInOut(duration: 0.25), value: store.language)
    }
}

#Preview {
    ContentView()
}
