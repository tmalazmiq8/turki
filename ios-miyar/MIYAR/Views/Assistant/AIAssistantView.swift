import SwiftUI

/// Arabic/English perfume assistant. All requests go through the secure server
/// proxy — the app never holds a provider key.
struct AIAssistantView: View {
    @Environment(AppStore.self) private var store

    /// When set, the screen opens an existing thread from the history screen.
    var conversationID: UUID?

    @State private var activeID: UUID?
    @State private var draft = ""
    @State private var attachFormula = false
    @State private var isSending = false
    @State private var errorText: LText?
    @State private var flash: LText?
    @FocusState private var isFocused: Bool

    private var language: AppLanguage { store.language }

    private var conversation: AIConversation? {
        guard let activeID else { return nil }
        return store.aiConversation(activeID)
    }

    private var messages: [AIMessage] { conversation?.messages ?? [] }

    private var quotaReached: Bool { store.aiRemaining <= 0 }

    var body: some View {
        VStack(spacing: 0) {
            quotaBar

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        if messages.isEmpty {
                            emptyState
                        }

                        ForEach(messages) { message in
                            bubble(message).id(message.id)
                        }

                        if isSending {
                            HStack(spacing: 8) {
                                ProgressView().tint(Theme.gold)
                                Text(S.aiThinking(language))
                                    .font(.system(size: 13))
                                    .foregroundStyle(Theme.secondaryText)
                            }
                            .padding(.horizontal, 4)
                        }

                        if let errorText {
                            MiyarBanner(text: errorText(language), tone: .error)
                        }
                        if let flash {
                            MiyarBanner(text: flash(language), tone: .success)
                        }

                        Text(S.aiDisclaimer(language))
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.secondaryText)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)

                        Color.clear.frame(height: 1).id("bottom")
                    }
                    .padding(Theme.margin)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: messages.count) { _, _ in
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
                .onChange(of: isSending) { _, _ in
                    withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                }
            }

            composer
        }
        .background(Theme.canvas.ignoresSafeArea())
        .navigationTitle(S.aiAssistant(language))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.canvas, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(S.aiNewChat(language), systemImage: "plus.bubble") {
                        activeID = store.newAIConversation().id
                        errorText = nil
                    }
                    NavigationLink(value: AppRoute.aiHistory) {
                        Label(S.aiHistory(language), systemImage: "clock.arrow.circlepath")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel(S.aiHistory(language))
            }
        }
        .onAppear(perform: prepare)
    }

    // MARK: Pieces

    private var quotaBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 12))
                .foregroundStyle(Theme.gold)
            Text("\(S.aiDailyLimit(language)): \(store.aiRemaining)/\(AIUsage.dailyLimit)")
                .font(.miyarMono(12))
                .foregroundStyle(Theme.secondaryText)
            Spacer(minLength: 0)
            MiyarProgressBar(value: Double(store.aiRemaining) / Double(AIUsage.dailyLimit), height: 4)
                .frame(width: 96)
        }
        .padding(.horizontal, Theme.margin)
        .padding(.vertical, 10)
        .background(Theme.surface)
        .overlay(alignment: .bottom) { MiyarDivider() }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 26, weight: .light))
                    .foregroundStyle(Theme.gold)
                    .frame(width: 62, height: 62)
                    .background(Circle().fill(Theme.goldSoft))
                Text(S.aiEmptyTitle(language))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                Text(S.aiSubtitle(language))
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)

            ForEach([S.aiSuggestion1, S.aiSuggestion2, S.aiSuggestion3], id: \.self) { suggestion in
                Button {
                    draft = suggestion(language)
                    isFocused = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.up.forward")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Theme.gold)
                        Text(suggestion(language))
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.ink)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .miyarCard(padding: 13, radius: Theme.tileRadius)
                }
                .buttonStyle(.plain)
            }

            if store.currentFormula != nil {
                Button {
                    attachFormula = true
                    draft = S.aiAnalyzeBalance(language)
                    isFocused = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "flask")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Theme.gold)
                        Text(S.aiAnalyzeBalance(language))
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.ink)
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .miyarCard(padding: 13, radius: Theme.tileRadius)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func bubble(_ message: AIMessage) -> some View {
        let isUser = message.role == .user
        return HStack(alignment: .top) {
            if isUser { Spacer(minLength: 40) }
            VStack(alignment: .leading, spacing: 8) {
                if message.hasFormulaContext {
                    Label(S.aiFormulaAttached(language), systemImage: "flask")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Theme.secondaryText)
                }
                Text(message.text)
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.ink)
                    .lineSpacing(5)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                if !isUser {
                    HStack(spacing: 14) {
                        Button {
                            UIPasteboard.general.string = message.text
                            withAnimation { flash = S.aiCopied }
                        } label: {
                            Label(S.aiCopy(language), systemImage: "doc.on.doc")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Theme.secondaryText)
                        }
                        .buttonStyle(.plain)
                        Button {
                            store.saveAIResponse(message.text)
                            withAnimation { flash = S.aiResponseSaved }
                        } label: {
                            Label(S.aiSaveResponse(language), systemImage: "bookmark")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Theme.secondaryText)
                        }
                        .buttonStyle(.plain)
                        if let id = activeID, !message.isReported {
                            Button {
                                store.markReported(messageID: message.id, in: id)
                                withAnimation { flash = S.reportSubmitted }
                            } label: {
                                Label(S.aiReport(language), systemImage: "flag")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(Theme.secondaryText)
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer(minLength: 0)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(isUser ? Theme.goldSoft : Theme.surface, in: .rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isUser ? Color.clear : Theme.hairline, lineWidth: 1)
            )
            if !isUser { Spacer(minLength: 40) }
        }
    }

    private var composer: some View {
        VStack(spacing: 8) {
            if store.currentFormula != nil {
                HStack(spacing: 8) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { attachFormula.toggle() }
                    } label: {
                        Label(
                            attachFormula ? S.aiFormulaAttached(language) : S.aiAttachFormula(language),
                            systemImage: attachFormula ? "checkmark.circle.fill" : "paperclip"
                        )
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(attachFormula ? Theme.ink : Theme.secondaryText)
                        .padding(.horizontal, 12)
                        .frame(height: 30)
                        .background(attachFormula ? Theme.gold.opacity(0.9) : Theme.surface, in: .capsule)
                        .overlay(Capsule().strokeBorder(attachFormula ? Color.clear : Theme.hairline, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    Spacer(minLength: 0)
                }
            }

            HStack(spacing: 10) {
                TextField(S.aiPlaceholder(language), text: $draft, axis: .vertical)
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1...5)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(Theme.surface, in: .rect(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Theme.hairline, lineWidth: 1))
                    .focused($isFocused)
                    .disabled(quotaReached)

                Button {
                    Task { await send() }
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.ink)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(canSend ? Theme.gold : Theme.goldSoft))
                }
                .buttonStyle(.plain)
                .disabled(!canSend)
                .accessibilityLabel(S.send(language))
            }

            if quotaReached {
                Text(S.aiLimitReached(language))
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.danger)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, Theme.margin)
        .padding(.vertical, 10)
        .background(Theme.canvas)
        .overlay(alignment: .top) { MiyarDivider() }
    }

    private var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSending && !quotaReached
    }

    // MARK: Actions

    private func prepare() {
        if let conversationID {
            activeID = conversationID
        } else if activeID == nil {
            activeID = store.aiConversations.first?.id ?? store.newAIConversation().id
        }
    }

    private func formulaContext() -> AIFormulaContext? {
        guard attachFormula, let formula = store.currentFormula else { return nil }
        return AIFormulaContext(
            name: formula.name,
            concentration: formula.concentration.rawValue,
            bottleSizeML: formula.bottleSizeML,
            totalPercent: formula.totalPercent,
            balanceScore: formula.balanceScore,
            lines: formula.ingredients.map { item in
                "\(item.nameEn.isEmpty ? item.nameAr : item.nameEn) — \(String(format: "%.1f", item.percent))% (\(item.stage.rawValue))"
            },
            selectedMaterials: store.savedMaterialIDs.sorted()
        )
    }

    private func send() async {
        guard let id = activeID, canSend else { return }
        let text = Validation.sanitize(draft, limit: 2000)
        let context = formulaContext()

        store.append(
            AIMessage(role: .user, text: text, hasFormulaContext: context != nil),
            to: id
        )
        draft = ""
        errorText = nil
        flash = nil
        isSending = true
        isFocused = false

        do {
            let history = store.aiConversation(id)?.messages ?? []
            let reply = try await AIService.reply(history: history, context: context, language: language)
            store.append(AIMessage(role: .assistant, text: reply), to: id)
            store.consumeAIQuota()
            attachFormula = false
        } catch let error as AIServiceError {
            errorText = error.message
        } catch {
            errorText = S.aiError
        }
        isSending = false
    }
}

// MARK: - History

/// Stored assistant conversations.
struct AIHistoryView: View {
    @Environment(AppStore.self) private var store
    @State private var openConversation: UUID?

    private var language: AppLanguage { store.language }

    var body: some View {
        MiyarScreen(title: S.aiHistory(language)) {
            ScrollView {
                LazyVStack(spacing: 12) {
                    if store.aiConversations.isEmpty {
                        MiyarEmptyState(symbol: "clock.arrow.circlepath", title: S.aiHistory(language), message: S.aiSubtitle(language))
                            .padding(.top, 30)
                    } else {
                        ForEach(store.aiConversations) { conversation in
                            Button {
                                openConversation = conversation.id
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 14))
                                        .foregroundStyle(Theme.gold)
                                        .frame(width: 32, height: 32)
                                        .background(Circle().fill(Theme.goldSoft))
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(conversation.title)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundStyle(Theme.ink)
                                            .lineLimit(1)
                                        Text("\(conversation.messages.count) · \(conversation.updatedAt.relativeText(language))")
                                            .font(.system(size: 12))
                                            .foregroundStyle(Theme.secondaryText)
                                    }
                                    Spacer(minLength: 0)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .miyarCard(padding: 13, radius: Theme.tileRadius)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(S.delete(language), systemImage: "trash", role: .destructive) {
                                    store.deleteAIConversation(conversation.id)
                                }
                            }
                        }
                    }
                }
                .padding(Theme.margin)
                .padding(.bottom, 26)
            }
        }
        .navigationDestination(item: $openConversation) { id in
            AIAssistantView(conversationID: id)
        }
    }
}
