import SwiftUI

/// Sort orders offered above the marketplace grid.
enum MarketSort: String, CaseIterable, Identifiable, Hashable {
    case newest
    case priceLow
    case priceHigh
    case rating

    var id: String { rawValue }

    var label: LText {
        switch self {
        case .newest: S.sortNewest
        case .priceLow: S.sortPriceLow
        case .priceHigh: S.sortPriceHigh
        case .rating: S.sortRating
        }
    }
}

/// Marketplace home: two-column listings with search, filters, sorting and paging.
struct MarketHomeView: View {
    @Environment(AppStore.self) private var store

    @State private var query = ""
    @State private var category: ListingCategory?
    @State private var type: ListingType?
    @State private var sort: MarketSort = .newest
    @State private var showCreate = false
    @State private var phase: LoadPhase = .loading
    @State private var visibleCount = 12

    private let pageSize = 12
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    private var language: AppLanguage { store.language }

    private var results: [Listing] {
        let filtered = store.visibleListings.filter { listing in
            let categoryMatch = category == nil || listing.category == category
            let typeMatch: Bool = {
                guard let type else { return true }
                switch type {
                case .sale: return listing.type.allowsSale
                case .exchange: return listing.type.allowsExchange
                case .both: return listing.type == .both
                }
            }()
            return categoryMatch && typeMatch && listing.matches(query)
        }
        return sorted(filtered)
    }

    private func sorted(_ listings: [Listing]) -> [Listing] {
        switch sort {
        case .newest: listings.sorted { $0.createdAt > $1.createdAt }
        case .priceLow: listings.sorted { $0.priceUSD < $1.priceUSD }
        case .priceHigh: listings.sorted { $0.priceUSD > $1.priceUSD }
        case .rating: listings.sorted { rating(for: $0) > rating(for: $1) }
        }
    }

    private func rating(for listing: Listing) -> Double {
        SeedPeople.byID(listing.sellerID)?.rating ?? store.currentUser?.rating ?? 0
    }

    /// Only the current page is rendered; the grid grows on demand.
    private var page: [Listing] { Array(results.prefix(visibleCount)) }

    var body: some View {
        MiyarScreen {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    header
                    MiyarSearchField(placeholder: S.searchMarket(language), text: $query)
                    shortcutsRow
                    categoryRow
                    typeRow
                    sortRow

                    switch phase {
                    case .loading:
                        MiyarLoadingList(rows: 3, height: 120)
                    case .failed:
                        MiyarErrorState { Task { await load() } }
                            .miyarCard(padding: 6)
                    case .ready:
                        if results.isEmpty {
                            MiyarEmptyState(
                                symbol: "bag",
                                title: S.emptyListings(language),
                                message: S.emptyListingsHint(language),
                                actionTitle: S.createListing(language)
                            ) { showCreate = true }
                            .miyarCard(padding: 6)
                        } else {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(page) { listing in
                                    NavigationLink(value: AppRoute.listing(listing.id)) {
                                        ListingCard(listing: listing)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            if results.count > page.count {
                                LoadMoreFooter(remaining: results.count - page.count) {
                                    withAnimation(.easeOut(duration: 0.25)) { visibleCount += pageSize }
                                }
                                .padding(.top, 4)
                            }
                        }
                    }
                }
                .padding(Theme.margin)
                .padding(.bottom, 26)
            }
            .scrollDismissesKeyboard(.immediately)
            .refreshable { await load() }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task { if phase != .ready { await load() } }
        .onChange(of: query) { _, _ in visibleCount = pageSize }
        .onChange(of: category) { _, _ in visibleCount = pageSize }
        .onChange(of: type) { _, _ in visibleCount = pageSize }
        .onChange(of: sort) { _, _ in visibleCount = pageSize }
        .sheet(isPresented: $showCreate) { CreateListingView() }
    }

    private func load() async {
        phase = .loading
        do {
            try await store.refreshFromStorage()
            phase = .ready
        } catch {
            phase = .failed
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 3) {
                Text(S.marketplace(language))
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                Text("\(results.count) \(language == .ar ? "إعلان" : "listings")")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.secondaryText)
            }
            Spacer()
            HStack(spacing: 10) {
                LanguageToggle()
                Button {
                    showCreate = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Theme.gold))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(S.createListing(language))
            }
        }
        .padding(.top, 8)
    }

    private var shortcutsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                shortcut(.favorites, symbol: "heart", title: S.favorites(language), count: store.favoriteListingIDs.count)
                shortcut(.collection, symbol: "square.stack", title: S.myCollection(language), count: store.collection.count)
                shortcut(.wanted, symbol: "bell.badge", title: S.wantedAlerts(language), count: store.wanted.count)
                shortcut(.offers, symbol: "arrow.left.arrow.right", title: S.myOffers(language), count: store.offers.count)
                shortcut(.myListings, symbol: "tag", title: S.myListings(language), count: store.myListings.count)
            }
            .padding(.horizontal, Theme.margin)
        }
        .padding(.horizontal, -Theme.margin)
    }

    private func shortcut(_ route: AppRoute, symbol: String, title: String, count: Int) -> some View {
        NavigationLink(value: route) {
            HStack(spacing: 7) {
                Image(systemName: symbol).font(.system(size: 12, weight: .medium)).foregroundStyle(Theme.gold)
                Text(title).font(.system(size: 13, weight: .medium)).foregroundStyle(Theme.ink)
                if count > 0 {
                    Text("\(count)")
                        .font(.miyarMono(11, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                        .padding(.horizontal, 6)
                        .frame(height: 18)
                        .background(Theme.goldSoft, in: .capsule)
                }
            }
            .padding(.horizontal, 13)
            .frame(height: 38)
            .background(Theme.surface, in: .capsule)
            .overlay(Capsule().strokeBorder(Theme.hairline, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var categoryRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                MiyarChip(title: S.catAll(language), isSelected: category == nil) { category = nil }
                ForEach(ListingCategory.allCases) { option in
                    MiyarChip(title: option.label(language), symbol: option.symbol, isSelected: category == option) {
                        category = category == option ? nil : option
                    }
                }
            }
            .padding(.horizontal, Theme.margin)
        }
        .padding(.horizontal, -Theme.margin)
    }

    private var typeRow: some View {
        HStack(spacing: 8) {
            ForEach(ListingType.allCases) { option in
                MiyarChip(title: option.label(language), isSelected: type == option) {
                    type = type == option ? nil : option
                }
            }
        }
    }

    private var sortRow: some View {
        HStack(spacing: 10) {
            Menu {
                Picker(S.sortBy(language), selection: $sort) {
                    ForEach(MarketSort.allCases) { option in
                        Text(option.label(language)).tag(option)
                    }
                }
            } label: {
                menuLabel(symbol: "arrow.up.arrow.down", text: sort.label(language))
            }

            Menu {
                Picker(S.displayCurrency(language), selection: Bindable(store).marketCurrency) {
                    ForEach(Currency.allCases) { option in
                        Text("\(option.symbol(language)) — \(option.label(language))").tag(option)
                    }
                }
            } label: {
                menuLabel(symbol: "coloncurrencysign.circle", text: store.marketCurrency.symbol(language))
            }

            Spacer(minLength: 0)

            if category != nil || type != nil || !query.isEmpty {
                Button(S.clearFilters(language)) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        category = nil
                        type = nil
                        query = ""
                    }
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.gold)
                .buttonStyle(.plain)
            }
        }
    }

    private func menuLabel(symbol: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbol).font(.system(size: 11, weight: .semibold)).foregroundStyle(Theme.gold)
            Text(text).font(.system(size: 13, weight: .medium)).foregroundStyle(Theme.ink)
            Image(systemName: "chevron.down").font(.system(size: 9, weight: .semibold)).foregroundStyle(Theme.secondaryText)
        }
        .padding(.horizontal, 13)
        .frame(height: 36)
        .background(Theme.surface, in: .capsule)
        .overlay(Capsule().strokeBorder(Theme.hairline, lineWidth: 1))
    }
}

/// Grid card for one listing.
struct ListingCard: View {
    @Environment(AppStore.self) private var store
    let listing: Listing

    private var seller: UserProfile? {
        listing.sellerID == SeedPeople.currentUserID ? store.currentUser : SeedPeople.byID(listing.sellerID)
    }

    var body: some View {
        let language = store.language
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                StoredPhotoView(
                    photoID: listing.photoIDs.first,
                    fallbackSeed: listing.artworkSeed,
                    cornerRadius: Theme.tileRadius
                )
                .frame(height: 132)
                Button {
                    store.toggleFavorite(listing.id)
                } label: {
                    Image(systemName: store.isFavorite(listing.id) ? "heart.fill" : "heart")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(store.isFavorite(listing.id) ? Theme.gold : Theme.ink.opacity(0.55))
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(Theme.surface.opacity(0.92)))
                }
                .buttonStyle(.plain)
                .padding(8)
                .accessibilityLabel(S.favorites(language))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(listing.title(language))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(height: 34, alignment: .topLeading)

                HStack(spacing: 5) {
                    Text(listing.condition.label(language))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Theme.secondaryText)
                    Text("·").foregroundStyle(Theme.secondaryText)
                    Text("\(Int(listing.sizeML)) \(S.milliliters(language))")
                        .font(.miyarMono(10))
                        .foregroundStyle(Theme.secondaryText)
                    if listing.remainingPercent < 100 {
                        Text("·").foregroundStyle(Theme.secondaryText)
                        Text(listing.remainingPercent.percentText())
                            .font(.miyarMono(10))
                            .foregroundStyle(Theme.secondaryText)
                    }
                }

                if let seller {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill").font(.system(size: 8)).foregroundStyle(Theme.gold)
                        Text(String(format: "%.1f", seller.rating))
                            .font(.miyarMono(10))
                            .foregroundStyle(Theme.secondaryText)
                        Text("· \(listing.location(language))")
                            .font(.system(size: 10))
                            .foregroundStyle(Theme.secondaryText)
                            .lineLimit(1)
                    }
                }

                HStack(alignment: .firstTextBaseline) {
                    Text(listing.type == .exchange
                         ? S.forExchange(language)
                         : store.marketCurrency.formatUSD(listing.priceUSD, language: language))
                        .font(.miyarMono(13, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    if listing.type != .sale {
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Theme.gold)
                    }
                }
            }
            .padding(11)
        }
        .background(Theme.surface, in: .rect(cornerRadius: Theme.cardRadius))
        .overlay(RoundedRectangle(cornerRadius: Theme.cardRadius).strokeBorder(Theme.hairline, lineWidth: 1))
    }
}
