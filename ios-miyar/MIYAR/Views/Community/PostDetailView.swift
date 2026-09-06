import SwiftUI

/// Full post with photos, formula lines, threaded comments and moderation actions.
struct PostDetailView: View {
    @Environment(AppStore.self) private var store
    let postID: UUID

    @State private var comment = ""
    @State private var replyTarget: PostComment?
    @State private var flash: LText?
    @State private var showShare = false
    @State private var expandedReplies: Set<UUID> = []
    @FocusState private var isCommentFocused: Bool

    private var language: AppLanguage { store.language }

    private var post: Post? { store.post(postID) }

    private func profile(_ id: String) -> UserProfile {
        if id == SeedPeople.currentUserID {
            return store.currentUser ?? SeedPeople.newUser(name: "MIYAR", email: "")
        }
        return SeedPeople.byID(id) ?? SeedPeople.newUser(name: id, email: "")
    }

    var body: some View {
        Group {
            if let post {
                content(post)
            } else {
                MiyarEmptyState(symbol: "doc.questionmark", title: S.noResults(language), message: S.noResultsHint(language))
                    .background(Theme.canvas.ignoresSafeArea())
            }
        }
        .background(Theme.canvas.ignoresSafeArea())
        .navigationTitle(post?.kind.label(language) ?? S.community(language))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.canvas, for: .navigationBar)
        .toolbar {
            if let post {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(S.share(language), systemImage: "square.and.arrow.up") { showShare = true }
                        Button(
                            store.isPostSaved(post.id) ? S.bookmarked(language) : S.savePost(language),
                            systemImage: store.isPostSaved(post.id) ? "bookmark.fill" : "bookmark"
                        ) {
                            store.toggleSavePost(post.id)
                        }
                        if post.authorID == SeedPeople.currentUserID {
                            Button(S.delete(language), systemImage: "trash", role: .destructive) {
                                store.deletePost(post.id)
                            }
                        } else {
                            Button(S.report(language), systemImage: "flag") { flash = S.reportSubmitted }
                            Button(
                                store.isBlocked(post.authorID) ? S.unblock(language) : S.block(language),
                                systemImage: "hand.raised"
                            ) {
                                store.toggleBlock(post.authorID)
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel(S.moderation(language))
                }
            }
        }
        .sheet(isPresented: $showShare) {
            if let post {
                ShareSheetContent(text: "\(post.title(language))\n\n\(post.body(language))")
            }
        }
    }

    private func content(_ post: Post) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                authorRow(post)

                Text(post.title(language))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)

                if !post.photoIDs.isEmpty {
                    PhotoPager(photoIDs: post.photoIDs, fallbackSeed: post.artworkSeed, height: 240)
                } else if post.hasImage {
                    BottleArtwork(seed: post.artworkSeed)
                        .frame(height: 210)
                        .frame(maxWidth: .infinity)
                }

                Text(post.body(language))
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.ink.opacity(0.86))
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)

                if !post.formulaLines.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(S.postFormula(language)).miyarSectionHeader()
                        ForEach(Array(post.formulaLines.enumerated()), id: \.offset) { _, line in
                            HStack(spacing: 8) {
                                Circle().fill(Theme.gold).frame(width: 5, height: 5)
                                Text(line(language))
                                    .font(.miyarMono(13))
                                    .foregroundStyle(Theme.ink)
                                Spacer(minLength: 0)
                            }
                        }
                        Text(S.ifraNoAutoCompliance(language))
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.secondaryText)
                            .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .miyarCard(padding: 14)
                }

                if !post.families.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(post.families) { family in
                            MiyarTag(title: family.label(language), symbol: family.symbol)
                        }
                        Spacer(minLength: 0)
                    }
                }

                engagementRow(post)

                if let flash {
                    MiyarBanner(text: flash(language), tone: .success)
                }

                if store.isBlocked(post.authorID) {
                    MiyarBanner(text: S.blockedNotice(language), tone: .error)
                }

                SectionHeader(title: "\(S.comments(language)) · \(post.commentCount)")

                if post.comments.isEmpty {
                    MiyarEmptyState(symbol: "bubble.left", title: S.emptyComments(language), message: S.writeComment(language))
                } else {
                    ForEach(post.rootComments) { item in
                        commentThread(item, in: post)
                    }
                }
            }
            .padding(Theme.margin)
            .padding(.bottom, 12)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom, spacing: 0) { composer(post) }
    }

    private func authorRow(_ post: Post) -> some View {
        let author = profile(post.authorID)
        return HStack(spacing: 10) {
            NavigationLink(value: AppRoute.seller(post.authorID)) {
                HStack(spacing: 10) {
                    AvatarCircle(profile: author, size: 44)
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text(author.name(language))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Theme.ink)
                            if author.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Theme.gold)
                                    .accessibilityLabel(S.verifiedMember(language))
                            }
                        }
                        Text(post.createdAt.relativeText(language))
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.secondaryText)
                    }
                }
            }
            .buttonStyle(.plain)
            Spacer(minLength: 6)
            if post.authorID != SeedPeople.currentUserID {
                Button(store.isFollowing(post.authorID) ? S.following(language) : S.follow(language)) {
                    store.toggleFollow(post.authorID)
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.ink)
                .padding(.horizontal, 14)
                .frame(height: 34)
                .background(store.isFollowing(post.authorID) ? Theme.goldSoft : Theme.gold, in: .capsule)
                .buttonStyle(.plain)
            }
        }
    }

    private func engagementRow(_ post: Post) -> some View {
        HStack(spacing: 10) {
            Button {
                store.toggleLike(post.id)
            } label: {
                Label("\(post.likeCount)", systemImage: post.isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(post.isLiked ? Theme.gold : Theme.secondaryText)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Theme.surface, in: .rect(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Theme.hairline, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(S.likes(language))

            Button {
                replyTarget = nil
                isCommentFocused = true
            } label: {
                Label("\(post.commentCount)", systemImage: "bubble.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.secondaryText)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Theme.surface, in: .rect(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Theme.hairline, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(S.comments(language))

            Button {
                showShare = true
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.secondaryText)
                    .frame(width: 52, height: 44)
                    .background(Theme.surface, in: .rect(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Theme.hairline, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(S.share(language))

            Button {
                store.toggleSavePost(post.id)
            } label: {
                Image(systemName: store.isPostSaved(post.id) ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(store.isPostSaved(post.id) ? Theme.gold : Theme.secondaryText)
                    .frame(width: 52, height: 44)
                    .background(Theme.surface, in: .rect(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Theme.hairline, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(S.savePost(language))
        }
    }

    @ViewBuilder
    private func commentThread(_ item: PostComment, in post: Post) -> some View {
        let replies = post.replies(to: item.id)
        VStack(alignment: .leading, spacing: 10) {
            commentRow(item, in: post)

            if !replies.isEmpty {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if expandedReplies.contains(item.id) {
                            expandedReplies.remove(item.id)
                        } else {
                            expandedReplies.insert(item.id)
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: expandedReplies.contains(item.id) ? "chevron.up" : "chevron.down")
                            .font(.system(size: 9, weight: .bold))
                        Text("\(replies.count) \(S.repliesCount(language))")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(Theme.gold)
                }
                .buttonStyle(.plain)
                .padding(.leading, 42)

                if expandedReplies.contains(item.id) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(replies) { reply in
                            commentRow(reply, in: post, isReply: true)
                        }
                    }
                    .padding(.leading, 26)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }

    private func commentRow(_ item: PostComment, in post: Post, isReply: Bool = false) -> some View {
        let author = profile(item.authorID)
        return HStack(alignment: .top, spacing: 10) {
            AvatarCircle(profile: author, size: isReply ? 28 : 32)
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(author.name(language))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                    if author.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(Theme.gold)
                    }
                    Text(item.createdAt.relativeText(language))
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.secondaryText)
                }
                Text(item.body(language))
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.ink.opacity(0.86))
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 16) {
                    Button {
                        store.toggleCommentLike(item.id, in: post.id)
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: item.isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 11, weight: .medium))
                            Text("\(item.likeCount)")
                                .font(.miyarMono(11))
                        }
                        .foregroundStyle(item.isLiked ? Theme.gold : Theme.secondaryText)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(S.likeComment(language))

                    if !isReply {
                        Button {
                            replyTarget = item
                            expandedReplies.insert(item.id)
                            isCommentFocused = true
                        } label: {
                            Text(S.reply(language))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Theme.secondaryText)
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer(minLength: 0)

                    if item.authorID == SeedPeople.currentUserID {
                        Button(role: .destructive) {
                            store.deleteComment(item.id, in: post.id)
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.danger.opacity(0.8))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(S.deleteComment(language))
                    } else {
                        Button {
                            flash = S.reportSubmitted
                        } label: {
                            Image(systemName: "flag")
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.secondaryText.opacity(0.8))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(S.report(language))
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .miyarCard(padding: 12, radius: Theme.tileRadius)
    }

    private func composer(_ post: Post) -> some View {
        VStack(spacing: 8) {
            if let replyTarget {
                HStack(spacing: 8) {
                    Image(systemName: "arrowshape.turn.up.left")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Theme.gold)
                    Text("\(S.replyingTo(language)) \(profile(replyTarget.authorID).name(language))")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.secondaryText)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Button(S.cancelReply(language)) {
                        self.replyTarget = nil
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.gold)
                    .buttonStyle(.plain)
                }
                .transition(.opacity)
            }

            HStack(spacing: 10) {
                TextField(replyTarget == nil ? S.writeComment(language) : S.reply(language), text: $comment, axis: .vertical)
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1...4)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(Theme.surface, in: .rect(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Theme.hairline, lineWidth: 1))
                    .focused($isCommentFocused)

                Button {
                    store.addComment(comment, to: post.id, parentID: replyTarget?.id)
                    comment = ""
                    replyTarget = nil
                    isCommentFocused = false
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.ink)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(comment.trimmingCharacters(in: .whitespaces).isEmpty ? Theme.goldSoft : Theme.gold))
                }
                .buttonStyle(.plain)
                .disabled(comment.trimmingCharacters(in: .whitespaces).isEmpty)
                .accessibilityLabel(S.send(language))
            }
        }
        .padding(.horizontal, Theme.margin)
        .padding(.vertical, 10)
        .background(Theme.canvas)
        .overlay(alignment: .top) { MiyarDivider() }
        .animation(.easeInOut(duration: 0.2), value: replyTarget?.id)
    }
}

/// Simple text share sheet used by posts and formulas.
struct ShareSheetContent: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let text: String

    var body: some View {
        let language = store.language
        NavigationStack {
            ScrollView {
                Text(text)
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .miyarCard(padding: 14)
                    .padding(Theme.margin)
            }
            .background(Theme.canvas.ignoresSafeArea())
            .navigationTitle(S.share(language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(S.close(language)) { dismiss() }
                }
                ToolbarItem(placement: .bottomBar) {
                    ShareLink(item: text) {
                        Label(S.share(language), systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
        .environment(\.layoutDirection, language.layoutDirection)
    }
}

/// The signed-in member's own posts.
struct MyPostsView: View {
    @Environment(AppStore.self) private var store
    @State private var showCreate = false

    var body: some View {
        let language = store.language
        MiyarScreen(title: S.myPosts(language)) {
            ScrollView {
                LazyVStack(spacing: 14) {
                    if store.myPosts.isEmpty {
                        MiyarEmptyState(
                            symbol: "square.and.pencil",
                            title: S.emptyFeed(language),
                            message: S.guidelinesReminder(language),
                            actionTitle: S.newPost(language)
                        ) { showCreate = true }
                    } else {
                        ForEach(store.myPosts) { post in
                            NavigationLink(value: AppRoute.post(post.id)) { PostCard(post: post) }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(S.delete(language), systemImage: "trash", role: .destructive) {
                                        store.deletePost(post.id)
                                    }
                                }
                        }
                    }
                }
                .padding(Theme.margin)
                .padding(.bottom, 26)
            }
        }
        .sheet(isPresented: $showCreate) { CreatePostView() }
    }
}
