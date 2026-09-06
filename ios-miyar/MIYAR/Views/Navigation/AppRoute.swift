import SwiftUI

/// Legal and policy documents shown from settings and the marketplace.
nonisolated enum LegalDoc: String, Hashable, Identifiable, CaseIterable, Sendable {
    case terms
    case privacy
    case community
    case market
    case refund

    var id: String { rawValue }

    var title: LText {
        switch self {
        case .terms: S.termsConditions
        case .privacy: S.privacyPolicy
        case .community: S.communityGuidelines
        case .market: S.marketplaceRules
        case .refund: S.refundPolicy
        }
    }

    var symbol: String {
        switch self {
        case .terms: "doc.text"
        case .privacy: "lock.shield"
        case .community: "person.2"
        case .market: "bag"
        case .refund: "arrow.uturn.backward"
        }
    }
}

/// Every push destination in the app, shared by all five navigation stacks.
enum AppRoute: Hashable {
    case formula(UUID)
    case results(UUID)
    case formulaList
    case jeanCarles
    case materials
    case material(String)
    case ifra
    case ifraAdmin
    case glossary
    case glossaryTerm(String)
    case book
    case chapter(Int)
    case listing(UUID)
    case seller(String)
    case wanted
    case collection
    case offers
    case favorites
    case myListings
    case post(UUID)
    case myPosts
    case messages
    case chat(UUID)
    case notifications
    case search
    case assistant
    case aiHistory
    case editProfile
    case security
    case settings
    case legal(LegalDoc)
    case savedItems
    case blocked
}

/// Resolves a route into its screen. Registered once per navigation stack.
struct RouteDestination: View {
    let route: AppRoute

    var body: some View {
        switch route {
        case .formula(let id): FormulaEditorView(formulaID: id)
        case .results(let id): FormulaResultsView(formulaID: id)
        case .formulaList: FormulaListView()
        case .jeanCarles: JeanCarlesView()
        case .materials: MaterialsLibraryView()
        case .material(let id): MaterialDetailView(materialID: id)
        case .ifra: IFRASectionView()
        case .ifraAdmin: IFRAAdminView()
        case .glossary: GlossaryView()
        case .glossaryTerm(let id): GlossaryTermView(termID: id)
        case .book: BookView()
        case .chapter(let id): ChapterReaderView(chapterID: id)
        case .listing(let id): ListingDetailView(listingID: id)
        case .seller(let id): SellerProfileView(userID: id)
        case .wanted: WantedAlertsView()
        case .collection: MyCollectionView()
        case .offers: OffersView()
        case .favorites: FavoritesView()
        case .myListings: MyListingsView()
        case .post(let id): PostDetailView(postID: id)
        case .myPosts: MyPostsView()
        case .messages: MessagesListView()
        case .chat(let id): ChatView(conversationID: id)
        case .notifications: NotificationsView()
        case .search: GlobalSearchView()
        case .assistant: AIAssistantView()
        case .aiHistory: AIHistoryView()
        case .editProfile: EditProfileView()
        case .security: SecurityView()
        case .settings: SettingsView()
        case .legal(let doc): LegalDocumentView(doc: doc)
        case .savedItems: SavedItemsView()
        case .blocked: BlockedUsersView()
        }
    }
}

/// Applies the ivory canvas and the shared navigation chrome to a screen.
struct MiyarScreen<Content: View>: View {
    var title: String?
    var showsLanguageToggle: Bool = false
    @ViewBuilder var content: Content

    var body: some View {
        content
            .background(Theme.canvas.ignoresSafeArea())
            .toolbarBackground(Theme.canvas, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationTitle(title ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if showsLanguageToggle {
                    ToolbarItem(placement: .topBarTrailing) { LanguageToggle() }
                }
            }
    }
}
