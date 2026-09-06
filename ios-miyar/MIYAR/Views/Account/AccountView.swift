import SwiftUI

/// The signed-in member's hub: profile, activity, preferences and legal.
struct AccountView: View {
    @Environment(AppStore.self) private var store
    @State private var showSignOutConfirm = false

    private var language: AppLanguage { store.language }

    private var profile: UserProfile {
        store.currentUser ?? SeedPeople.newUser(name: S.appName(language), email: "")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                statsRow
                MiyarBanner(text: S.backendLocalNotice(language), tone: .info)

                group(title: S.marketplace(language)) {
                    NavigationLink(value: AppRoute.myListings) {
                        MiyarRowLabel(symbol: "tag", title: S.myListings(language), trailingText: "\(store.myListings.count)")
                    }
                    MiyarDivider()
                    NavigationLink(value: AppRoute.offers) {
                        MiyarRowLabel(symbol: "arrow.left.arrow.right", title: S.myOffers(language), trailingText: "\(store.offers.count)")
                    }
                    MiyarDivider()
                    NavigationLink(value: AppRoute.collection) {
                        MiyarRowLabel(symbol: "square.stack", title: S.myCollection(language), trailingText: "\(store.collection.count)")
                    }
                    MiyarDivider()
                    NavigationLink(value: AppRoute.favorites) {
                        MiyarRowLabel(symbol: "heart", title: S.favorites(language), trailingText: "\(store.favoriteListingIDs.count)")
                    }
                    MiyarDivider()
                    NavigationLink(value: AppRoute.wanted) {
                        MiyarRowLabel(symbol: "bell.badge", title: S.wantedAlerts(language), trailingText: "\(store.wanted.count)")
                    }
                }

                group(title: S.community(language)) {
                    NavigationLink(value: AppRoute.myPosts) {
                        MiyarRowLabel(symbol: "square.and.pencil", title: S.myPosts(language), trailingText: "\(store.myPosts.count)")
                    }
                    MiyarDivider()
                    NavigationLink(value: AppRoute.messages) {
                        MiyarRowLabel(symbol: "paperplane", title: S.messages(language), trailingText: "\(store.sortedConversations.count)")
                    }
                    MiyarDivider()
                    NavigationLink(value: AppRoute.savedItems) {
                        MiyarRowLabel(
                            symbol: "bookmark",
                            title: S.savedItems(language),
                            trailingText: "\(store.savedPostIDs.count + store.savedMaterialIDs.count + store.glossaryBookmarks.count)"
                        )
                    }
                    MiyarDivider()
                    NavigationLink(value: AppRoute.blocked) {
                        MiyarRowLabel(symbol: "hand.raised", title: S.blockedUsers(language), trailingText: "\(store.blockedIDs.count)")
                    }
                }

                group(title: S.editProfileSecurity(language)) {
                    NavigationLink(value: AppRoute.editProfile) {
                        MiyarRowLabel(symbol: "person.crop.circle", title: S.editProfile(language), subtitle: S.profileSecuritySubtitle(language))
                    }
                    MiyarDivider()
                    NavigationLink(value: AppRoute.security) {
                        MiyarRowLabel(symbol: "lock.shield", title: S.security(language), subtitle: S.encryptedNotice(language))
                    }
                    MiyarDivider()
                    NavigationLink(value: AppRoute.settings) {
                        MiyarRowLabel(symbol: "gearshape", title: S.settingsLegal(language), subtitle: S.settingsSubtitle(language))
                    }
                    MiyarDivider()
                    NavigationLink(value: AppRoute.assistant) {
                        MiyarRowLabel(
                            symbol: "sparkles",
                            title: S.aiAssistant(language),
                            subtitle: "\(S.aiDailyLimit(language)): \(store.aiRemaining)/\(AIUsage.dailyLimit)"
                        )
                    }
                }

                Button {
                    showSignOutConfirm = true
                } label: {
                    Label(S.signOut(language), systemImage: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.danger)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Theme.danger.opacity(0.08), in: .rect(cornerRadius: 14))
                }
                .buttonStyle(.plain)

                Text("\(S.appName(language)) · \(S.localOnly(language))")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.secondaryText)
                    .frame(maxWidth: .infinity)
            }
            .padding(Theme.margin)
            .padding(.bottom, 26)
        }
        .background(Theme.canvas.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog(S.signOutConfirm(language), isPresented: $showSignOutConfirm, titleVisibility: .visible) {
            Button(S.signOut(language), role: .destructive) { store.signOut() }
            Button(S.cancel(language), role: .cancel) {}
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            AvatarCircle(profile: profile, size: 66)
            VStack(alignment: .leading, spacing: 4) {
                Text(profile.name(language))
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                Text(profile.email)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.secondaryText)
                    .lineLimit(1)
                HStack(spacing: 5) {
                    Image(systemName: profile.isEmailVerified ? "checkmark.seal.fill" : "exclamationmark.circle")
                        .font(.system(size: 10))
                        .foregroundStyle(profile.isEmailVerified ? Theme.gold : Theme.secondaryText)
                    Text(profile.isEmailVerified ? S.verified(language) : S.notVerified(language))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Theme.secondaryText)
                }
            }
            Spacer(minLength: 0)
            LanguageToggle()
        }
        .miyarCard(padding: 16)
        .padding(.top, 8)
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            stat("\(store.formulas.count)", S.recentFormulas(language))
            MiyarDivider().frame(width: 1, height: 34)
            stat("\(store.myListings.count)", S.listings(language))
            MiyarDivider().frame(width: 1, height: 34)
            stat("\(store.offers.count)", S.exchanges(language))
            MiyarDivider().frame(width: 1, height: 34)
            stat("\(profile.followerCount)", S.followers(language))
        }
        .miyarCard(padding: 14)
    }

    private func stat(_ value: String, _ title: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.miyarMono(17, weight: .semibold))
                .foregroundStyle(Theme.ink)
            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(Theme.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func group<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).miyarSectionHeader()
            VStack(spacing: 0) { content() }
                .miyarCard(padding: 14)
        }
    }
}

/// Row label shared by the account sections; matches `MiyarRow` visually but
/// works inside a `NavigationLink`.
struct MiyarRowLabel: View {
    let symbol: String
    let title: String
    var subtitle: String?
    var trailingText: String?
    var isDestructive: Bool = false

    @Environment(\.layoutDirection) private var direction

    var body: some View {
        HStack(spacing: 13) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(isDestructive ? Theme.danger : Theme.gold)
                .frame(width: 30, height: 30)
                .background(Circle().fill(isDestructive ? Theme.danger.opacity(0.1) : Theme.goldSoft))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(isDestructive ? Theme.danger : Theme.ink)
                    .multilineTextAlignment(.leading)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.secondaryText)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
            }
            Spacer(minLength: 8)
            if let trailingText {
                Text(trailingText)
                    .font(.miyarMono(13))
                    .foregroundStyle(Theme.secondaryText)
            }
            Image(systemName: direction == .rightToLeft ? "chevron.left" : "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.secondaryText.opacity(0.6))
        }
        .padding(.vertical, 11)
        .contentShape(.rect)
    }
}

// MARK: - Saved items

/// Everything the member bookmarked: posts, materials, glossary terms and AI replies.
struct SavedItemsView: View {
    @Environment(AppStore.self) private var store

    private var language: AppLanguage { store.language }

    private var savedPosts: [Post] { store.visiblePosts.filter { store.isPostSaved($0.id) } }
    private var savedMaterials: [Material] { SeedMaterials.all.filter { store.isMaterialSaved($0.id) } }
    private var savedTerms: [GlossaryTerm] { SeedGlossary.all.filter { store.isBookmarked(term: $0.id) } }

    private var isEmpty: Bool {
        savedPosts.isEmpty && savedMaterials.isEmpty && savedTerms.isEmpty && store.savedAIResponses.isEmpty
    }

    var body: some View {
        MiyarScreen(title: S.savedItems(language)) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    if isEmpty {
                        MiyarEmptyState(symbol: "bookmark", title: S.savedItems(language), message: S.noResultsHint(language))
                            .padding(.top, 30)
                    }

                    if !savedMaterials.isEmpty {
                        SectionHeader(title: S.materialsLibrary(language))
                        VStack(spacing: 0) {
                            ForEach(savedMaterials) { material in
                                NavigationLink(value: AppRoute.material(material.id)) {
                                    MiyarRowLabel(symbol: material.stage.symbol, title: material.name(language), subtitle: material.family.label(language))
                                }
                                .buttonStyle(.plain)
                                if material.id != savedMaterials.last?.id { MiyarDivider() }
                            }
                        }
                        .miyarCard(padding: 14)
                    }

                    if !savedTerms.isEmpty {
                        SectionHeader(title: S.glossary(language))
                        VStack(spacing: 0) {
                            ForEach(savedTerms) { term in
                                NavigationLink(value: AppRoute.glossaryTerm(term.id)) {
                                    MiyarRowLabel(symbol: "text.book.closed", title: term.term(language))
                                }
                                .buttonStyle(.plain)
                                if term.id != savedTerms.last?.id { MiyarDivider() }
                            }
                        }
                        .miyarCard(padding: 14)
                    }

                    if !savedPosts.isEmpty {
                        SectionHeader(title: S.community(language))
                        ForEach(savedPosts) { post in
                            NavigationLink(value: AppRoute.post(post.id)) { PostCard(post: post, isCompact: true) }
                                .buttonStyle(.plain)
                        }
                    }

                    if !store.savedAIResponses.isEmpty {
                        SectionHeader(title: S.aiAssistant(language))
                        ForEach(Array(store.savedAIResponses.enumerated()), id: \.offset) { _, text in
                            Text(text)
                                .font(.system(size: 14))
                                .foregroundStyle(Theme.ink)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .miyarCard(padding: 14)
                        }
                    }
                }
                .padding(Theme.margin)
                .padding(.bottom, 26)
            }
        }
    }
}

// MARK: - Blocked users

struct BlockedUsersView: View {
    @Environment(AppStore.self) private var store

    private var language: AppLanguage { store.language }

    private var people: [UserProfile] {
        store.blockedIDs.compactMap { SeedPeople.byID($0) }.sorted { $0.id < $1.id }
    }

    var body: some View {
        MiyarScreen(title: S.blockedUsers(language)) {
            ScrollView {
                VStack(spacing: 12) {
                    if people.isEmpty {
                        MiyarEmptyState(symbol: "hand.raised", title: S.noBlockedUsers(language))
                            .padding(.top, 30)
                    } else {
                        ForEach(people) { person in
                            HStack(spacing: 12) {
                                AvatarCircle(profile: person, size: 44)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(person.name(language))
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(Theme.ink)
                                    Text(person.location(language))
                                        .font(.system(size: 12))
                                        .foregroundStyle(Theme.secondaryText)
                                }
                                Spacer(minLength: 6)
                                Button(S.unblock(language)) { store.toggleBlock(person.id) }
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Theme.ink)
                                    .padding(.horizontal, 14)
                                    .frame(height: 34)
                                    .background(Theme.goldSoft, in: .capsule)
                                    .buttonStyle(.plain)
                            }
                            .miyarCard(padding: 12, radius: Theme.tileRadius)
                        }
                    }
                }
                .padding(Theme.margin)
                .padding(.bottom, 26)
            }
        }
    }
}
