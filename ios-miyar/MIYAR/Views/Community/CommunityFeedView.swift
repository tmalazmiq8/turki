import SwiftUI

/// Arabic-first community feed with kind filters, paging and a messages entry point.
struct CommunityFeedView: View {
    @Environment(AppStore.self) private var store

    enum Filter: String, Hashable, CaseIterable, Identifiable {
        case latest, following, questions, formulas, saved

        var id: String { rawValue }

        var label: LText {
            switch self {
            case .latest: S.feedLatest
            case .following: S.feedFollowing
            case .questions: S.feedQuestions
            case .formulas: S.feedFormulas
            case .saved: S.savedItems
            }
        }
    }

    @State private var filter: Filter = .latest
    @State private var query = ""
    @State private var showCreate = false
    @State private var phase: LoadPhase = .loading
    @State private var visibleCount = 8

    private let pageSize = 8

    private var language: AppLanguage { store.language }

    private var posts: [Post] {
        store.visiblePosts
            .filter { post in
                switch filter {
                case .latest: return true
                case .following: return store.isFollowing(post.authorID) || post.authorID == SeedPeople.currentUserID
                case .questions: return post.kind == .question
                case .formulas: return post.kind == .formula
                case .saved: return store.isPostSaved(post.id)
                }
            }
            .filter { $0.matches(query) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    /// Only the current page is built; older posts load on demand.
    private var page: [Post] { Array(posts.prefix(visibleCount)) }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                header
                MiyarSearchField(placeholder: S.search(language), text: $query)
                filterRow

                switch phase {
                case .loading:
                    MiyarLoadingList(rows: 3, height: 130)
                case .failed:
                    MiyarErrorState { Task { await load() } }
                case .ready:
                    if posts.isEmpty {
                        MiyarEmptyState(
                            symbol: "bubble.left.and.bubble.right",
                            title: S.emptyFeed(language),
                            message: filter == .following ? S.emptyFeedFollowing(language) : S.noResultsHint(language),
                            actionTitle: S.newPost(language)
                        ) { showCreate = true }
                    } else {
                        ForEach(page) { post in
                            NavigationLink(value: AppRoute.post(post.id)) {
                                PostCard(post: post)
                            }
                            .buttonStyle(.plain)
                        }
                        if posts.count > page.count {
                            LoadMoreFooter(remaining: posts.count - page.count) {
                                withAnimation(.easeOut(duration: 0.25)) { visibleCount += pageSize }
                            }
                        }
                    }
                }
            }
            .padding(Theme.margin)
            .padding(.bottom, 26)
        }
        .scrollDismissesKeyboard(.immediately)
        .refreshable { await load() }
        .background(Theme.canvas.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .task { if phase != .ready { await load() } }
        .onChange(of: filter) { _, _ in visibleCount = pageSize }
        .onChange(of: query) { _, _ in visibleCount = pageSize }
        .sheet(isPresented: $showCreate) { CreatePostView() }
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
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text(S.community(language))
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                Text("\(posts.count) \(language == .ar ? "منشور" : "posts")")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.secondaryText)
            }
            Spacer(minLength: 8)
            HStack(spacing: 8) {
                LanguageToggle()
                NavigationLink(value: AppRoute.messages) {
                    Image(systemName: "paperplane")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Theme.ink)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Theme.surface))
                        .overlay(Circle().strokeBorder(Theme.hairline, lineWidth: 1))
                        .overlay(alignment: .topTrailing) {
                            if store.unreadMessageCount > 0 {
                                Text("\(store.unreadMessageCount)")
                                    .font(.miyarMono(9, weight: .bold))
                                    .foregroundStyle(Theme.ink)
                                    .padding(.horizontal, 5)
                                    .frame(minWidth: 17, minHeight: 17)
                                    .background(Circle().fill(Theme.gold))
                            }
                        }
                }
                .accessibilityLabel(S.messages(language))
                Button {
                    showCreate = true
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Theme.gold))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(S.newPost(language))
            }
        }
        .padding(.top, 6)
    }

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Filter.allCases) { option in
                    MiyarChip(title: option.label(language), isSelected: filter == option) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { filter = option }
                    }
                }
            }
            .padding(.vertical, 2)
        }
        .scrollClipDisabled()
    }
}

// MARK: - Post card

/// Feed card: author, kind badge, photo, excerpt, families and engagement.
struct PostCard: View {
    @Environment(AppStore.self) private var store
    let post: Post
    var isCompact: Bool = false

    private var language: AppLanguage { store.language }

    private var author: UserProfile {
        if post.authorID == SeedPeople.currentUserID {
            return store.currentUser ?? SeedPeople.newUser(name: "MIYAR", email: "")
        }
        return SeedPeople.byID(post.authorID) ?? SeedPeople.newUser(name: post.authorID, email: "")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                AvatarCircle(profile: author, size: 38)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(author.name(language))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.ink)
                        if author.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.gold)
                                .accessibilityLabel(S.verifiedMember(language))
                        }
                    }
                    Text(post.createdAt.relativeText(language))
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.secondaryText)
                }
                Spacer(minLength: 6)
                Label(post.kind.label(language), systemImage: post.kind.symbol)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.secondaryText)
                    .padding(.horizontal, 9)
                    .frame(height: 26)
                    .background(Theme.goldSoft, in: .capsule)
            }

            Text(post.title(language))
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.leading)
                .lineLimit(2)

            if !isCompact {
                Text(post.body(language))
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.secondaryText)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)

                if !post.photoIDs.isEmpty {
                    StoredPhotoView(photoID: post.photoIDs.first, fallbackSeed: post.artworkSeed)
                        .frame(height: 170)
                        .frame(maxWidth: .infinity)
                        .overlay(alignment: .bottomTrailing) {
                            if post.photoIDs.count > 1 {
                                Text("+\(post.photoIDs.count - 1)")
                                    .font(.miyarMono(11, weight: .semibold))
                                    .foregroundStyle(Theme.ink)
                                    .padding(.horizontal, 8)
                                    .frame(height: 24)
                                    .background(Theme.surface.opacity(0.92), in: .capsule)
                                    .padding(8)
                            }
                        }
                } else if post.hasImage {
                    BottleArtwork(seed: post.artworkSeed)
                        .frame(height: 150)
                        .frame(maxWidth: .infinity)
                }

                if !post.families.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(post.families) { family in
                                MiyarTag(title: family.label(language), symbol: family.symbol)
                            }
                        }
                    }
                    .scrollClipDisabled()
                }
            }

            HStack(spacing: 18) {
                Label("\(post.likeCount)", systemImage: post.isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(post.isLiked ? Theme.gold : Theme.secondaryText)
                Label("\(post.commentCount)", systemImage: "bubble.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.secondaryText)
                Spacer(minLength: 0)
                if store.isPostSaved(post.id) {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.gold)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .miyarCard(padding: 14)
    }
}
