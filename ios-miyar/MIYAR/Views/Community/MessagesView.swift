import SwiftUI

/// List of private conversations, newest first.
struct MessagesListView: View {
    @Environment(AppStore.self) private var store

    @State private var query = ""
    @State private var phase: LoadPhase = .loading
    @State private var pendingDelete: Conversation?

    private var language: AppLanguage { store.language }

    private func partner(_ id: String) -> UserProfile {
        SeedPeople.byID(id) ?? SeedPeople.newUser(name: id, email: "")
    }

    private var threads: [Conversation] {
        let all = store.sortedConversations
        guard !query.isEmpty else { return all }
        return all.filter { thread in
            let person = partner(thread.partnerID)
            return person.nameAr.localizedStandardContains(query)
                || person.nameEn.localizedStandardContains(query)
                || thread.messages.contains { $0.bodyAr.localizedStandardContains(query) || $0.bodyEn.localizedStandardContains(query) }
        }
    }

    var body: some View {
        MiyarScreen(title: S.messages(language)) {
            ScrollView {
                LazyVStack(spacing: 10) {
                    MiyarSearchField(placeholder: S.search(language), text: $query)
                        .padding(.bottom, 4)

                    switch phase {
                    case .loading:
                        MiyarLoadingList(rows: 4, height: 44)
                    case .failed:
                        MiyarErrorState { Task { await load() } }
                    case .ready:
                        if threads.isEmpty {
                            MiyarEmptyState(
                                symbol: "bubble.left.and.text.bubble.right",
                                title: S.emptyConversations(language),
                                message: S.emptyConversationsHint(language)
                            )
                        } else {
                            ForEach(threads) { thread in
                                NavigationLink(value: AppRoute.chat(thread.id)) {
                                    threadRow(thread)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(
                                        thread.isMuted ? S.unmuteConversation(language) : S.muteConversation(language),
                                        systemImage: thread.isMuted ? "bell" : "bell.slash"
                                    ) {
                                        store.toggleMute(thread.id)
                                    }
                                    Button(S.block(language), systemImage: "hand.raised") {
                                        store.toggleBlock(thread.partnerID)
                                    }
                                    Button(S.deleteConversation(language), systemImage: "trash", role: .destructive) {
                                        pendingDelete = thread
                                    }
                                }
                            }

                            Text(S.messagesPrivate(language))
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.secondaryText)
                                .multilineTextAlignment(.leading)
                                .padding(.top, 6)
                        }
                    }
                }
                .padding(Theme.margin)
                .padding(.bottom, 26)
            }
            .scrollDismissesKeyboard(.immediately)
            .refreshable { await load() }
        }
        .task { if phase != .ready { await load() } }
        .alert(S.deleteConversation(language), isPresented: .constant(pendingDelete != nil)) {
            Button(S.cancel(language), role: .cancel) { pendingDelete = nil }
            Button(S.delete(language), role: .destructive) {
                if let pendingDelete { store.deleteConversation(pendingDelete.id) }
                pendingDelete = nil
            }
        } message: {
            Text(S.deleteWarning(language))
        }
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

    private func threadRow(_ thread: Conversation) -> some View {
        let person = partner(thread.partnerID)
        let last = thread.lastMessage
        let unread = thread.unreadCount(currentUserID: SeedPeople.currentUserID)
        return HStack(spacing: 12) {
            AvatarCircle(profile: person, size: 48)
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    Text(person.name(language))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                    if person.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Theme.gold)
                    }
                    if thread.isMuted {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 10))
                            .foregroundStyle(Theme.secondaryText)
                            .accessibilityLabel(S.mutedLabel(language))
                    }
                }
                Text(last.map { $0.isImage && $0.body(language).isEmpty ? S.sharedImage(language) : $0.body(language) } ?? "")
                    .font(.system(size: 13, weight: unread > 0 ? .medium : .regular))
                    .foregroundStyle(unread > 0 ? Theme.ink : Theme.secondaryText)
                    .lineLimit(1)
            }
            Spacer(minLength: 6)
            VStack(alignment: .trailing, spacing: 5) {
                Text(thread.updatedAt.relativeText(language))
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.secondaryText)
                if unread > 0 {
                    Text("\(unread)")
                        .font(.miyarMono(10, weight: .bold))
                        .foregroundStyle(Theme.ink)
                        .padding(.horizontal, 6)
                        .frame(minWidth: 20, minHeight: 20)
                        .background(Circle().fill(Theme.gold))
                        .accessibilityLabel("\(unread) \(S.unreadMessages(language))")
                }
            }
        }
        .miyarCard(padding: 12, radius: Theme.tileRadius)
    }
}

// MARK: - Chat

/// A private conversation with a keyboard-safe composer, typing status and receipts.
struct ChatView: View {
    @Environment(AppStore.self) private var store
    let conversationID: UUID

    @State private var draft = ""
    @State private var flash: LText?
    @State private var visibleCount = 25
    @State private var showReport = false
    @FocusState private var isFocused: Bool

    private let pageSize = 25

    private var language: AppLanguage { store.language }

    private var conversation: Conversation? { store.conversation(conversationID) }

    private var partner: UserProfile {
        guard let id = conversation?.partnerID else { return SeedPeople.newUser(name: "MIYAR", email: "") }
        return SeedPeople.byID(id) ?? SeedPeople.newUser(name: id, email: "")
    }

    private var isBlocked: Bool {
        guard let id = conversation?.partnerID else { return false }
        return store.isBlocked(id)
    }

    /// Newest messages only; older ones load on demand.
    private var visibleMessages: [ChatMessage] {
        let all = conversation?.messages ?? []
        guard all.count > visibleCount else { return all }
        return Array(all.suffix(visibleCount))
    }

    private var hiddenCount: Int {
        max(0, (conversation?.messages.count ?? 0) - visibleMessages.count)
    }

    var body: some View {
        Group {
            if let conversation {
                thread(conversation)
            } else {
                VStack {
                    MiyarEmptyState(symbol: "bubble.left.slash", title: S.emptyConversations(language), message: S.emptyConversationsHint(language))
                    Spacer()
                }
            }
        }
        .background(Theme.canvas.ignoresSafeArea())
        .navigationTitle(partner.name(language))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.canvas, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    NavigationLink(value: AppRoute.seller(partner.id)) {
                        Label(S.sellerProfile(language), systemImage: "person")
                    }
                    if let conversation {
                        Button(
                            conversation.isMuted ? S.unmuteConversation(language) : S.muteConversation(language),
                            systemImage: conversation.isMuted ? "bell" : "bell.slash"
                        ) {
                            store.toggleMute(conversationID)
                        }
                    }
                    Button(S.report(language), systemImage: "flag") { showReport = true }
                    Button(isBlocked ? S.unblock(language) : S.block(language), systemImage: "hand.raised") {
                        store.toggleBlock(partner.id)
                    }
                    Button(S.deleteConversation(language), systemImage: "trash", role: .destructive) {
                        store.deleteConversation(conversationID)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel(S.moderation(language))
            }
        }
        .alert(S.report(language), isPresented: $showReport) {
            Button(S.cancel(language), role: .cancel) {}
            Button(S.report(language)) { flash = S.reportSubmitted }
        } message: {
            Text(S.guidelinesReminder(language))
        }
        .task(id: conversationID) {
            store.markConversationRead(conversationID)
        }
    }

    private func thread(_ conversation: Conversation) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 10) {
                    if let flash {
                        MiyarBanner(text: flash(language), tone: .success)
                    }

                    if conversation.messages.isEmpty {
                        MiyarEmptyState(
                            symbol: "bubble.left",
                            title: S.emptyConversations(language),
                            message: S.emptyConversationsHint(language)
                        )
                    }

                    if hiddenCount > 0 {
                        Button {
                            withAnimation(.easeOut(duration: 0.25)) { visibleCount += pageSize }
                        } label: {
                            Text("\(S.loadEarlierMessages(language)) (\(hiddenCount))")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Theme.gold)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(Theme.surface, in: .capsule)
                                .overlay(Capsule().strokeBorder(Theme.hairline, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }

                    ForEach(visibleMessages) { message in
                        bubble(message).id(message.id)
                    }

                    if conversation.partnerIsTyping {
                        typingBubble
                    }

                    Text(S.messagesPrivate(language))
                        .font(.system(size: 10))
                        .foregroundStyle(Theme.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)

                    Color.clear.frame(height: 1).id("bottom")
                }
                .padding(Theme.margin)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom, spacing: 0) { composer }
            .onAppear { proxy.scrollTo("bottom", anchor: .bottom) }
            .onChange(of: conversation.messages.count) { _, _ in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
            .onChange(of: conversation.partnerIsTyping) { _, isTyping in
                guard isTyping else { return }
                withAnimation(.easeOut(duration: 0.25)) { proxy.scrollTo("bottom", anchor: .bottom) }
            }
        }
    }

    private func bubble(_ message: ChatMessage) -> some View {
        let isMine = message.senderID == SeedPeople.currentUserID
        return HStack {
            if isMine { Spacer(minLength: 44) }
            VStack(alignment: isMine ? .trailing : .leading, spacing: 6) {
                if let photoID = message.photoID {
                    StoredPhotoView(photoID: photoID, fallbackSeed: message.artworkSeed ?? 0, cornerRadius: 12)
                        .frame(width: 190, height: 190)
                } else if let seed = message.artworkSeed {
                    BottleArtwork(seed: seed, cornerRadius: 12)
                        .frame(width: 168, height: 168)
                }
                if !message.body(language).isEmpty {
                    Text(message.body(language))
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack(spacing: 4) {
                    Text(message.sentAt.timeText(language))
                        .font(.system(size: 10))
                        .foregroundStyle(Theme.secondaryText)
                    if isMine {
                        Image(systemName: message.isRead ? "checkmark.circle.fill" : "checkmark")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(message.isRead ? Theme.gold : Theme.secondaryText)
                            .accessibilityLabel(message.isRead ? S.messageRead(language) : S.messageSent(language))
                    }
                }
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 10)
            .background(isMine ? Theme.goldSoft : Theme.surface, in: .rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isMine ? Color.clear : Theme.hairline, lineWidth: 1)
            )
            if !isMine { Spacer(minLength: 44) }
        }
    }

    private var typingBubble: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Theme.secondaryText.opacity(0.6))
                        .frame(width: 6, height: 6)
                        .phaseAnimator([false, true]) { dot, active in
                            dot.opacity(active ? 1 : 0.3)
                                .offset(y: active ? -2 : 0)
                        } animation: { _ in
                            .easeInOut(duration: 0.45).delay(Double(index) * 0.15)
                        }
                }
                Text(S.typing(language))
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.secondaryText)
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 10)
            .background(Theme.surface, in: .rect(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Theme.hairline, lineWidth: 1))
            Spacer(minLength: 44)
        }
        .transition(.opacity)
    }

    @ViewBuilder
    private var composer: some View {
        VStack(spacing: 8) {
            if isBlocked {
                MiyarBanner(text: S.blockedConversationNotice(language), tone: .error)
            } else {
                HStack(spacing: 10) {
                    ChatPhotoPicker { photoID in
                        store.sendMessage("", in: conversationID, photoID: photoID)
                        acknowledgeDelivery()
                    }

                    TextField(S.typeMessage(language), text: $draft, axis: .vertical)
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.ink)
                        .lineLimit(1...5)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .background(Theme.surface, in: .rect(cornerRadius: 20))
                        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Theme.hairline, lineWidth: 1))
                        .focused($isFocused)

                    Button {
                        store.sendMessage(draft, in: conversationID)
                        draft = ""
                        acknowledgeDelivery()
                    } label: {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Theme.ink)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(draft.trimmingCharacters(in: .whitespaces).isEmpty ? Theme.goldSoft : Theme.gold))
                    }
                    .buttonStyle(.plain)
                    .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityLabel(S.send(language))
                }
            }
        }
        .padding(.horizontal, Theme.margin)
        .padding(.vertical, 10)
        .background(Theme.canvas)
        .overlay(alignment: .top) { MiyarDivider() }
    }

    /// Mirrors the partner's presence: they start typing, then read the message.
    /// The backend replaces this with live presence and read receipts.
    private func acknowledgeDelivery() {
        Task {
            try? await Task.sleep(for: .milliseconds(700))
            withAnimation(.easeInOut(duration: 0.2)) {
                store.setPartnerTyping(true, in: conversationID)
            }
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.easeInOut(duration: 0.2)) {
                store.setPartnerTyping(false, in: conversationID)
            }
            store.markOwnMessagesRead(in: conversationID)
        }
    }
}
