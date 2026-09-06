import SwiftUI

/// The five primary destinations. Each tab keeps its own navigation stack so
/// switching tabs never loses the user's place.
struct MainTabView: View {
    @Environment(AppStore.self) private var store

    @State private var selection: Tab = .home
    @State private var homePath: [AppRoute] = []
    @State private var calculatorPath: [AppRoute] = []
    @State private var marketPath: [AppRoute] = []
    @State private var communityPath: [AppRoute] = []
    @State private var accountPath: [AppRoute] = []

    enum Tab: Hashable {
        case home, calculator, market, community, account
    }

    var body: some View {
        @Bindable var store = store

        TabView(selection: tabSelection) {
            stack(path: $homePath) { HomeView() }
                .tabItem { Label(S.tabHome(store.language), systemImage: "house") }
                .tag(Tab.home)

            stack(path: $calculatorPath) { FormulaListView() }
                .tabItem { Label(S.tabCalculator(store.language), systemImage: "slider.horizontal.3") }
                .tag(Tab.calculator)

            stack(path: $marketPath) { MarketHomeView() }
                .tabItem { Label(S.tabMarket(store.language), systemImage: "bag") }
                .tag(Tab.market)

            stack(path: $communityPath) { CommunityFeedView() }
                .tabItem { Label(S.tabCommunity(store.language), systemImage: "bubble.left.and.bubble.right") }
                .tag(Tab.community)

            stack(path: $accountPath) { AccountView() }
                .tabItem { Label(S.tabAccount(store.language), systemImage: "person") }
                .tag(Tab.account)
        }
        .tint(Theme.gold)
        .toolbarBackground(Theme.surface, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }

    /// Tapping the active tab pops that stack back to its root.
    private var tabSelection: Binding<Tab> {
        Binding(
            get: { selection },
            set: { newValue in
                if newValue == selection {
                    switch newValue {
                    case .home: homePath.removeAll()
                    case .calculator: calculatorPath.removeAll()
                    case .market: marketPath.removeAll()
                    case .community: communityPath.removeAll()
                    case .account: accountPath.removeAll()
                    }
                }
                selection = newValue
            }
        )
    }

    private func stack<Root: View>(path: Binding<[AppRoute]>, @ViewBuilder root: () -> Root) -> some View {
        NavigationStack(path: path) {
            root()
                .navigationDestination(for: AppRoute.self) { RouteDestination(route: $0) }
        }
    }
}
