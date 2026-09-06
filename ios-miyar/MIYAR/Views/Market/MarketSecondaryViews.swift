import SwiftUI

// MARK: - Seller profile

/// Public profile for a seller or community member.
struct SellerProfileView: View {
    @Environment(AppStore.self) private var store
    let userID: String

    @State private var openChat: UUID?
    @State private var flash: LText?

    private var language: AppLanguage { store.language }

    private var profile: UserProfile? {
        if userID == SeedPeople.currentUserID { return store.currentUser }
        return SeedPeople.byID(userID)
    }

    private var sellerListings: [Listing] {
        store.listings.filter { $0.sellerID == userID }
    }

    private var sellerPosts: [Post] {
        store.posts.filter { $0.authorID == userID }
    }

    var body: some View {
        Group {
            if let profile {
                content(profile)
            } else {
                MiyarEmptyState(symbol: "person.slash", title: S.noResults(language))
            }
        }
        .background(Theme.canvas.ignoresSafeArea())
        .navigationTitle(profile?.name(language) ?? S.sellerProfile(language))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.canvas, for: .navigationBar)
        .toolbar {
            if userID != SeedPeople.currentUserID {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(S.report(language), systemImage: "flag") { flash = S.reportSubmitted }
                        Button(store.isBlocked(userID) ? S.unblock(language) : S.block(language), systemImage: "hand.raised") {
                            store.toggleBlock(userID)
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .navigationDestination(item: $openChat) { id in ChatView(conversationID: id) }
    }

    private func content(_ profile: UserProfile) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(spacing: 12) {
                    AvatarCircle(profile: profile, size: 78)
                    HStack(spacing: 6) {
                        Text(profile.name(language))
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundStyle(Theme.ink)
                        if profile.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(Theme.gold)
                                .accessibilityLabel(S.verifiedMember(language))
                        }
                    }
                    if profile.isVerified {
                        Text(S.verifiedMember(language))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Theme.gold)
                            .padding(.horizontal, 10)
                            .frame(height: 22)
                            .background(Theme.goldSoft, in: .capsule)
                    }
                    if !profile.bio(language).isEmpty {
                        Text(profile.bio(language))
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    if !profile.location(language).isEmpty {
                        Label(profile.location(language), systemImage: "mappin.and.ellipse")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.secondaryText)
                    }
                    HStack(spacing: 0) {
                        stat(String(format: "%.1f", profile.rating), S.sellerRating(language))
                        stat("\(profile.salesCount)", S.sales(language))
                        stat("\(profile.followerCount)", S.followers(language))
                    }
                    if userID != SeedPeople.currentUserID {
                        HStack(spacing: 10) {
                            Button(store.isFollowing(userID) ? S.following(language) : S.follow(language)) {
                                store.toggleFollow(userID)
                            }
                            .buttonStyle(store.isFollowing(userID) ? AnyButtonStyle(InkButtonStyle()) : AnyButtonStyle(GoldButtonStyle()))
                            Button(S.contactSeller(language)) {
                                guard !store.isBlocked(userID) else { return }
                                openChat = store.startConversation(with: userID)
                            }
                            .buttonStyle(InkButtonStyle())
                            .disabled(store.isBlocked(userID) || !profile.allowDirectMessages)
                        }
                        if !profile.allowDirectMessages {
                            Text(S.cannotMessage(language))
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.secondaryText)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .miyarCard(padding: 18)

                if let flash {
                    MiyarBanner(text: flash(language), tone: .success)
                }

                if store.isBlocked(userID) {
                    MiyarBanner(text: S.blockedNotice(language), tone: .error)
                }

                if !sellerListings.isEmpty {
                    SectionHeader(title: S.listings(language))
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        ForEach(sellerListings) { listing in
                            NavigationLink(value: AppRoute.listing(listing.id)) {
                                ListingCard(listing: listing)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if !sellerPosts.isEmpty {
                    SectionHeader(title: S.myPosts(language))
                    ForEach(sellerPosts) { post in
                        NavigationLink(value: AppRoute.post(post.id)) {
                            PostCard(post: post, isCompact: true)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(Theme.margin)
            .padding(.bottom, 26)
        }
    }

    private func stat(_ value: String, _ title: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.miyarMono(16, weight: .semibold))
                .foregroundStyle(Theme.ink)
            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(Theme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

/// Erases a button style so a conditional style stays type-checkable.
struct AnyButtonStyle: ButtonStyle {
    private let makeBodyClosure: (Configuration) -> AnyView

    init<Style: ButtonStyle>(_ style: Style) {
        makeBodyClosure = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        makeBodyClosure(configuration)
    }
}

// MARK: - Favourites

struct FavoritesView: View {
    @Environment(AppStore.self) private var store
    @State private var phase: LoadPhase = .loading

    private var items: [Listing] {
        store.visibleListings.filter { store.isFavorite($0.id) }
    }

    var body: some View {
        let language = store.language
        MiyarScreen(title: S.favorites(language)) {
            ScrollView {
                Group {
                    switch phase {
                    case .loading:
                        MiyarLoadingList(rows: 2, height: 110).padding(Theme.margin)
                    case .failed:
                        MiyarErrorState { Task { await load() } }.padding(.top, 30)
                    case .ready:
                        if items.isEmpty {
                            MiyarEmptyState(symbol: "heart", title: S.emptyListings(language), message: S.emptyListingsHint(language))
                                .padding(.top, 40)
                        } else {
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                                ForEach(items) { listing in
                                    NavigationLink(value: AppRoute.listing(listing.id)) { ListingCard(listing: listing) }
                                        .buttonStyle(.plain)
                                }
                            }
                            .padding(Theme.margin)
                        }
                    }
                }
            }
            .refreshable { await load() }
        }
        .task { if phase != .ready { await load() } }
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
}

// MARK: - My listings

struct MyListingsView: View {
    @Environment(AppStore.self) private var store
    @State private var showCreate = false
    @State private var editing: Listing?
    @State private var pendingDelete: Listing?

    var body: some View {
        let language = store.language
        MiyarScreen(title: S.myListings(language)) {
            ScrollView {
                if store.myListings.isEmpty {
                    MiyarEmptyState(
                        symbol: "tag",
                        title: S.emptyListings(language),
                        message: S.emptyListingsHint(language),
                        actionTitle: S.createListing(language)
                    ) { showCreate = true }
                    .padding(.top, 40)
                } else {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        ForEach(store.myListings) { listing in
                            NavigationLink(value: AppRoute.listing(listing.id)) { ListingCard(listing: listing) }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(S.editListing(language), systemImage: "pencil") { editing = listing }
                                    Button(S.delete(language), systemImage: "trash", role: .destructive) {
                                        pendingDelete = listing
                                    }
                                }
                        }
                    }
                    .padding(Theme.margin)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showCreate = true } label: { Image(systemName: "plus") }
                    .accessibilityLabel(S.createListing(language))
            }
        }
        .sheet(isPresented: $showCreate) { CreateListingView() }
        .sheet(item: $editing) { listing in CreateListingView(editing: listing) }
        .alert(S.delete(language), isPresented: .constant(pendingDelete != nil)) {
            Button(S.cancel(language), role: .cancel) { pendingDelete = nil }
            Button(S.delete(language), role: .destructive) {
                if let pendingDelete { store.deleteListing(pendingDelete.id) }
                pendingDelete = nil
            }
        } message: {
            Text(S.deleteListingConfirm(language))
        }
    }
}

// MARK: - Wanted alerts

struct WantedAlertsView: View {
    @Environment(AppStore.self) private var store

    @State private var keyword = ""
    @State private var category: ListingCategory?
    @State private var maxPrice = ""

    private var language: AppLanguage { store.language }

    var body: some View {
        MiyarScreen(title: S.wantedAlerts(language)) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(S.wantedAlertsHint(language))
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.secondaryText)

                    VStack(alignment: .leading, spacing: 12) {
                        MiyarField(label: S.search(language), text: $keyword)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                MiyarChip(title: S.catAll(language), isSelected: category == nil) { category = nil }
                                ForEach(ListingCategory.allCases) { option in
                                    MiyarChip(title: option.label(language), isSelected: category == option) {
                                        category = category == option ? nil : option
                                    }
                                }
                            }
                        }
                        MiyarField(
                            label: "\(S.maxPrice(language)) (\(store.marketCurrency.symbol(language)))",
                            text: $maxPrice,
                            keyboard: .decimalPad
                        )
                        Button(S.addWanted(language)) { add() }
                            .buttonStyle(GoldButtonStyle())
                            .disabled(keyword.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .miyarCard(padding: 16)

                    if store.wanted.isEmpty {
                        MiyarEmptyState(symbol: "bell.badge", title: S.wantedAlerts(language), message: S.wantedAlertsHint(language))
                    } else {
                        ForEach(store.wanted) { alert in
                            let matches = store.matches(for: alert)
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(alert.keyword)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(Theme.ink)
                                    Spacer()
                                    Button(role: .destructive) {
                                        store.deleteWanted(alert.id)
                                    } label: {
                                        Image(systemName: "trash").font(.system(size: 12)).foregroundStyle(Theme.danger)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel(S.delete(language))
                                }
                                HStack(spacing: 8) {
                                    if let category = alert.category {
                                        MiyarTag(title: category.label(language))
                                    }
                                    if let price = alert.maxPriceUSD {
                                        MiyarTag(title: store.marketCurrency.formatUSD(price, language: language))
                                    }
                                    MiyarTag(title: "\(matches.count) \(S.matchesFound(language))")
                                }
                                ForEach(matches.prefix(3)) { listing in
                                    NavigationLink(value: AppRoute.listing(listing.id)) {
                                        HStack(spacing: 10) {
                                            StoredPhotoView(
                                                photoID: listing.photoIDs.first,
                                                fallbackSeed: listing.artworkSeed,
                                                cornerRadius: 8
                                            )
                                            .frame(width: 38, height: 38)
                                            Text(listing.title(language))
                                                .font(.system(size: 13))
                                                .foregroundStyle(Theme.ink)
                                                .lineLimit(1)
                                            Spacer(minLength: 0)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .miyarCard(padding: 14)
                        }
                    }
                }
                .padding(Theme.margin)
                .padding(.bottom, 26)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private func add() {
        let price = Double(maxPrice.replacingOccurrences(of: ",", with: "."))
        let currency = store.marketCurrency
        store.addWanted(
            WantedAlert(
                keyword: Validation.sanitize(keyword, limit: 60),
                category: category,
                maxPriceUSD: price.map { currency.toUSD($0) }
            )
        )
        keyword = ""
        maxPrice = ""
        category = nil
    }
}

// MARK: - Collection

struct MyCollectionView: View {
    @Environment(AppStore.self) private var store

    @State private var nameAr = ""
    @State private var sizeText = "50"
    @State private var remaining: Double = 100
    @State private var valueText = ""
    @State private var condition: ListingCondition = .likeNew
    @State private var photoIDs: [String] = []
    @State private var showForm = false
    @State private var sellingItem: CollectionItem?

    private var language: AppLanguage { store.language }

    var body: some View {
        MiyarScreen(title: S.myCollection(language)) {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    if showForm {
                        VStack(alignment: .leading, spacing: 12) {
                            PhotoPickerStrip(photoIDs: $photoIDs, limit: 3)
                            MiyarField(label: S.productName(language), text: $nameAr)
                            HStack(spacing: 12) {
                                MiyarField(label: "\(S.size(language)) (\(S.milliliters(language)))", text: $sizeText, keyboard: .decimalPad)
                                MiyarField(
                                    label: "\(S.price(language)) (\(store.marketCurrency.symbol(language)))",
                                    text: $valueText,
                                    keyboard: .decimalPad
                                )
                            }
                            Text("\(S.remaining(language)) — \(remaining.percentText())")
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.secondaryText)
                            Slider(value: $remaining, in: 0...100, step: 5).tint(Theme.gold)
                            HStack(spacing: 8) {
                                ForEach(ListingCondition.allCases) { option in
                                    MiyarChip(title: option.label(language), isSelected: condition == option) { condition = option }
                                }
                            }
                            Button(S.addToCollection(language)) { add() }
                                .buttonStyle(GoldButtonStyle())
                                .disabled(nameAr.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                        .miyarCard(padding: 16)
                    }

                    if store.collection.isEmpty && !showForm {
                        MiyarEmptyState(
                            symbol: "square.stack",
                            title: S.myCollection(language),
                            message: S.addToCollection(language),
                            actionTitle: S.addToCollection(language)
                        ) { withAnimation { showForm = true } }
                    } else {
                        ForEach(store.collection) { item in
                            collectionRow(item)
                        }
                    }
                }
                .padding(Theme.margin)
                .padding(.bottom, 26)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation { showForm.toggle() }
                } label: {
                    Image(systemName: showForm ? "xmark" : "plus")
                }
                .accessibilityLabel(S.addToCollection(language))
            }
        }
        .sheet(item: $sellingItem) { item in
            CreateListingView(collectionItem: item)
        }
    }

    private func collectionRow(_ item: CollectionItem) -> some View {
        let listedID = item.listedListingID
        let isListed = listedID.flatMap { store.listing($0) } != nil
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                StoredPhotoView(photoID: item.photoIDs.first, fallbackSeed: item.artworkSeed, cornerRadius: 10)
                    .frame(width: 56, height: 56)
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.name(language))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Theme.ink)
                    Text("\(Int(item.sizeML)) \(S.milliliters(language)) · \(item.remainingPercent.percentText()) · \(item.condition.label(language))")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.secondaryText)
                }
                Spacer(minLength: 0)
                Text(store.marketCurrency.formatUSD(item.estimatedValueUSD, language: language))
                    .font(.miyarMono(12))
                    .foregroundStyle(Theme.secondaryText)
            }

            if isListed, let listedID {
                NavigationLink(value: AppRoute.listing(listedID)) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal").font(.system(size: 11)).foregroundStyle(Theme.gold)
                        Text(S.alreadyListed(language))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Theme.gold)
                        Spacer(minLength: 0)
                    }
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    sellingItem = item
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.forward.square").font(.system(size: 12, weight: .semibold))
                        Text(S.sellOrExchangeItem(language)).font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(Theme.ink)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(Theme.goldSoft, in: .rect(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .miyarCard(padding: 12, radius: Theme.tileRadius)
        .contextMenu {
            Button(S.delete(language), systemImage: "trash", role: .destructive) {
                store.removeFromCollection(item.id)
            }
        }
    }

    private func add() {
        let currency = store.marketCurrency
        let value = Double(valueText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let name = Validation.sanitize(nameAr, limit: 80)
        store.addToCollection(
            CollectionItem(
                nameAr: name,
                nameEn: name,
                sizeML: Double(sizeText.replacingOccurrences(of: ",", with: ".")) ?? 50,
                remainingPercent: remaining,
                condition: condition,
                estimatedValueUSD: currency.toUSD(value),
                artworkSeed: Int.random(in: 0..<5),
                photoIDs: photoIDs
            )
        )
        nameAr = ""
        valueText = ""
        photoIDs = []
        withAnimation { showForm = false }
    }
}

// MARK: - Offers

struct OffersView: View {
    @Environment(AppStore.self) private var store

    enum Box: String, CaseIterable, Identifiable, Hashable {
        case incoming, outgoing

        var id: String { rawValue }

        var label: LText {
            switch self {
            case .incoming: S.incomingOffers
            case .outgoing: S.outgoingOffers
            }
        }
    }

    @State private var box: Box = .incoming
    @State private var negotiating: ExchangeOffer?
    @State private var negotiationText = ""
    @State private var flash: LText?

    private var language: AppLanguage { store.language }

    private var items: [ExchangeOffer] {
        (box == .incoming ? store.incomingOffers : store.outgoingOffers)
            .sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        MiyarScreen(title: S.myOffers(language)) {
            ScrollView {
                LazyVStack(spacing: 14) {
                    Picker(S.myOffers(language), selection: $box) {
                        ForEach(Box.allCases) { option in
                            Text("\(option.label(language)) (\(option == .incoming ? store.incomingOffers.count : store.outgoingOffers.count))")
                                .tag(option)
                        }
                    }
                    .pickerStyle(.segmented)

                    if let flash {
                        MiyarBanner(text: flash(language), tone: .success)
                    }

                    if items.isEmpty {
                        MiyarEmptyState(
                            symbol: "arrow.left.arrow.right",
                            title: box == .incoming ? S.emptyIncomingOffers(language) : S.emptyOutgoingOffers(language),
                            message: S.wantedAlertsHint(language)
                        )
                        .padding(.top, 20)
                    } else {
                        ForEach(items) { offer in
                            offerCard(offer)
                        }
                    }
                }
                .padding(Theme.margin)
                .padding(.bottom, 26)
            }
        }
        .sheet(item: $negotiating) { offer in
            NavigationStack {
                VStack(alignment: .leading, spacing: 16) {
                    MiyarField(label: S.negotiateMessage(language), text: $negotiationText, lineLimit: 3...6)
                    Button(S.send(language)) {
                        store.updateOffer(offer.id, status: .negotiating, note: negotiationText)
                        negotiationText = ""
                        negotiating = nil
                        flash = S.offerUpdated
                    }
                    .buttonStyle(GoldButtonStyle())
                    .disabled(negotiationText.trimmingCharacters(in: .whitespaces).isEmpty)
                    Spacer()
                }
                .padding(Theme.margin)
                .background(Theme.canvas.ignoresSafeArea())
                .navigationTitle(S.negotiate(language))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(S.cancel(language)) { negotiating = nil }
                    }
                }
            }
            .presentationDetents([.height(300)])
            .environment(\.layoutDirection, language.layoutDirection)
        }
    }

    private func offerCard(_ offer: ExchangeOffer) -> some View {
        let currency = store.marketCurrency
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(offer.listingTitle(language))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(2)
                Spacer(minLength: 6)
                statusPill(offer.status)
            }

            HStack(spacing: 12) {
                StoredPhotoView(
                    photoID: offer.offeredItemPhotoIDs.first,
                    fallbackSeed: offer.offeredItemArtworkSeed,
                    cornerRadius: 10
                )
                .frame(width: 48, height: 48)
                VStack(alignment: .leading, spacing: 3) {
                    Text(offer.offeredItemName(language))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.ink)
                    Text("\(S.difference(language)): \(currency.formatUSD(abs(offer.differenceUSD), language: language))")
                        .font(.miyarMono(11))
                        .foregroundStyle(Theme.secondaryText)
                }
                Spacer(minLength: 0)
            }

            HStack(spacing: 8) {
                MiyarTag(title: offer.delivery.label(language), symbol: "shippingbox")
                if !offer.counterpartyID.isEmpty,
                   let person = SeedPeople.byID(offer.counterpartyID) {
                    MiyarTag(title: person.name(language), symbol: "person")
                }
            }

            if !offer.message.isEmpty {
                Text(offer.message)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            historyTimeline(offer)

            if offer.canRespond {
                HStack(spacing: 8) {
                    Button(S.accept(language)) {
                        store.updateOffer(offer.id, status: .accepted)
                        flash = S.offerUpdated
                    }
                    .buttonStyle(GoldButtonStyle(fullWidth: false))
                    Button(S.negotiate(language)) { negotiating = offer }
                        .buttonStyle(InkButtonStyle(fullWidth: false))
                    Button(S.reject(language)) {
                        store.updateOffer(offer.id, status: .rejected)
                        flash = S.offerUpdated
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.danger)
                }
                Text(S.youCanRespond(language))
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.secondaryText)
            } else if offer.status.isOpen {
                HStack(spacing: 8) {
                    Text(S.awaitingTheirReply(language))
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.secondaryText)
                    Spacer(minLength: 0)
                    Button(S.negotiate(language)) { negotiating = offer }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.gold)
                        .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .miyarCard(padding: 14)
        .contextMenu {
            Button(S.delete(language), systemImage: "trash", role: .destructive) {
                store.deleteOffer(offer.id)
            }
        }
    }

    private func statusPill(_ status: ExchangeOffer.Status) -> some View {
        let tint = status == .rejected ? Theme.danger : Theme.gold
        return HStack(spacing: 4) {
            Image(systemName: status.symbol).font(.system(size: 9, weight: .semibold))
            Text(status.label(language)).font(.system(size: 11, weight: .semibold))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .frame(height: 24)
        .background(tint.opacity(0.12), in: .capsule)
    }

    @ViewBuilder
    private func historyTimeline(_ offer: ExchangeOffer) -> some View {
        if !offer.history.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(S.statusHistory(language)).miyarSectionHeader()
                ForEach(offer.history) { event in
                    HStack(alignment: .top, spacing: 9) {
                        VStack(spacing: 0) {
                            Circle()
                                .fill(event.status == .rejected ? Theme.danger : Theme.gold)
                                .frame(width: 7, height: 7)
                            if event.id != offer.history.last?.id {
                                Rectangle()
                                    .fill(Theme.hairline)
                                    .frame(width: 1)
                                    .frame(maxHeight: .infinity)
                            }
                        }
                        .padding(.top, 4)
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(event.status.label(language))
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Theme.ink)
                                Text("· \(event.byCurrentUser ? S.byYou(language) : S.byThem(language))")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Theme.secondaryText)
                                Spacer(minLength: 0)
                                Text(event.date.relativeText(language))
                                    .font(.system(size: 10))
                                    .foregroundStyle(Theme.secondaryText)
                            }
                            if !event.note.isEmpty {
                                Text(event.note)
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.secondaryText)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Theme.canvas, in: .rect(cornerRadius: 12))
        }
    }
}
