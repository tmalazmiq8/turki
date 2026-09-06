import SwiftUI

/// The educational book: chapter list with progress and premium locks.
struct BookView: View {
    @Environment(AppStore.self) private var store
    @State private var showPremiumNotice = false

    private var language: AppLanguage { store.language }

    var body: some View {
        MiyarScreen(title: S.book(language), showsLanguageToggle: true) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    cover
                    SectionHeader(title: S.chapters(language))
                    ForEach(SeedBook.chapters) { chapter in
                        chapterRow(chapter)
                    }
                }
                .padding(Theme.margin)
                .padding(.bottom, 26)
            }
        }
        .alert(S.premiumChapter(language), isPresented: $showPremiumNotice) {
            Button(S.done(language), role: .cancel) {}
        } message: {
            Text("\(S.premiumLocked(language))\n\(S.premiumSoon(language))")
        }
    }

    private var cover: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(colors: [Theme.gold.opacity(0.85), Theme.gold.opacity(0.45)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    VStack(spacing: 4) {
                        Text("MIYAR")
                            .font(.system(size: 10, weight: .semibold))
                            .tracking(2)
                            .foregroundStyle(Theme.ink.opacity(0.7))
                        Rectangle().fill(Theme.ink.opacity(0.2)).frame(width: 26, height: 1)
                        Text(S.bookTitle(.ar))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.ink)
                            .multilineTextAlignment(.center)
                    }
                    .padding(6)
                }
                .frame(width: 84, height: 116)

                VStack(alignment: .leading, spacing: 8) {
                    Text(S.bookTitle(language))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                    Text("\(SeedBook.chapters.count) \(S.chapters(language))")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.secondaryText)
                    MiyarProgressBar(value: store.bookProgress)
                    Text("\(Int(store.bookProgress * 100))% \(S.percentRead(language))")
                        .font(.miyarMono(12))
                        .foregroundStyle(Theme.gold)
                }
                Spacer(minLength: 0)
            }

            NavigationLink(value: AppRoute.chapter(store.lastChapterID ?? (SeedBook.chapters.first?.id ?? 1))) {
                Text(store.lastChapterID == nil ? S.startReading(language) : S.continueReading(language))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Theme.gold, in: .rect(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
        .miyarCard(padding: 18)
    }

    @ViewBuilder
    private func chapterRow(_ chapter: BookChapter) -> some View {
        let locked = chapter.isPremium
        let progress = store.progress(for: chapter.id)
        Group {
            if locked {
                Button { showPremiumNotice = true } label: { chapterLabel(chapter, progress: progress, locked: true) }
                    .buttonStyle(.plain)
            } else {
                NavigationLink(value: AppRoute.chapter(chapter.id)) {
                    chapterLabel(chapter, progress: progress, locked: false)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func chapterLabel(_ chapter: BookChapter, progress: Double, locked: Bool) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(locked ? Theme.ink.opacity(0.06) : Theme.goldSoft)
                if locked {
                    Image(systemName: "lock")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.secondaryText)
                } else {
                    Text("\(chapter.id)")
                        .font(.miyarMono(14, weight: .semibold))
                        .foregroundStyle(Theme.gold)
                }
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(chapter.title(store.language))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(locked ? Theme.secondaryText : Theme.ink)
                    .multilineTextAlignment(.leading)
                Text(chapter.subtitle(store.language))
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.secondaryText)
                    .lineLimit(1)
                if progress > 0 && !locked {
                    MiyarProgressBar(value: progress, height: 4)
                }
            }
            Spacer(minLength: 4)
            VStack(alignment: .trailing, spacing: 4) {
                if locked {
                    MiyarTag(title: S.premiumChapter(store.language), symbol: "crown")
                } else {
                    Text("\(chapter.estimatedMinutes)′")
                        .font(.miyarMono(12))
                        .foregroundStyle(Theme.secondaryText)
                }
                if store.bookmarkedChapters.contains(chapter.id) {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Theme.gold)
                }
            }
        }
        .miyarCard(padding: 13, radius: Theme.tileRadius)
    }
}

/// Reader with font-size control, day/sepia mode and chapter navigation.
struct ChapterReaderView: View {
    @Environment(AppStore.self) private var store
    let chapterID: Int

    @State private var showSettings = false

    private var language: AppLanguage { store.language }
    private var chapter: BookChapter? { SeedBook.chapters.first { $0.id == chapterID } }
    private var index: Int? { SeedBook.chapters.firstIndex { $0.id == chapterID } }

    private var background: Color {
        store.reading.mode == .sepia ? Theme.sepia : Theme.canvas
    }

    var body: some View {
        Group {
            if let chapter {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(S.chapter(language)) \(chapter.id)")
                                .font(.system(size: 12, weight: .semibold))
                                .tracking(1.2)
                                .foregroundStyle(Theme.gold)
                            Text(chapter.title(language))
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(Theme.ink)
                            Text(chapter.subtitle(language))
                                .font(.system(size: 14))
                                .foregroundStyle(Theme.secondaryText)
                        }

                        ForEach(Array(chapter.paragraphs.enumerated()), id: \.offset) { _, paragraph in
                            Text(paragraph(language))
                                .font(.system(size: store.reading.fontSize))
                                .lineSpacing(store.reading.fontSize * 0.55)
                                .foregroundStyle(Theme.ink)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        navigationRow
                    }
                    .padding(Theme.margin)
                    .padding(.bottom, 30)
                }
            } else {
                MiyarEmptyState(symbol: "book.closed", title: S.noResults(language))
            }
        }
        .background(background.ignoresSafeArea())
        .navigationTitle(chapter?.title(language) ?? S.book(language))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(background, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.toggleChapterBookmark(chapterID)
                } label: {
                    Image(systemName: store.bookmarkedChapters.contains(chapterID) ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(Theme.gold)
                }
                .accessibilityLabel(S.bookmark(language))
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "textformat.size").foregroundStyle(Theme.ink)
                }
                .accessibilityLabel(S.fontSize(language))
            }
        }
        .sheet(isPresented: $showSettings) { ReaderSettingsSheet() }
        .onAppear { store.setProgress(1, for: chapterID) }
    }

    private var navigationRow: some View {
        HStack(spacing: 12) {
            if let index, index > 0 {
                let previous = SeedBook.chapters[index - 1]
                NavigationLink(value: AppRoute.chapter(previous.id)) {
                    Text(S.previousChapter(language))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Theme.ink)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Theme.surface, in: .rect(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Theme.hairline, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .disabled(previous.isPremium)
                .opacity(previous.isPremium ? 0.5 : 1)
            }
            if let index, index < SeedBook.chapters.count - 1 {
                let next = SeedBook.chapters[index + 1]
                NavigationLink(value: AppRoute.chapter(next.id)) {
                    Text(next.isPremium ? S.premiumChapter(language) : S.nextChapter(language))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(next.isPremium ? Theme.goldSoft : Theme.gold, in: .rect(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .disabled(next.isPremium)
            }
        }
        .padding(.top, 10)
    }
}

/// Font size and reading mode controls.
struct ReaderSettingsSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var store = store
        let language = store.language
        NavigationStack {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(S.fontSize(language)).miyarSectionHeader()
                    HStack(spacing: 12) {
                        Text("A").font(.system(size: 13)).foregroundStyle(Theme.secondaryText)
                        Slider(value: $store.reading.fontSize, in: 14...26, step: 1).tint(Theme.gold)
                        Text("A").font(.system(size: 22)).foregroundStyle(Theme.secondaryText)
                    }
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text(S.readingMode(language)).miyarSectionHeader()
                    HStack(spacing: 10) {
                        ForEach(ReadingSettings.Mode.allCases) { mode in
                            MiyarChip(title: mode.label(language), isSelected: store.reading.mode == mode) {
                                store.reading.mode = mode
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding(Theme.margin)
            .background(Theme.canvas.ignoresSafeArea())
            .navigationTitle(S.readingMode(language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(S.done(language)) { dismiss() }
                }
            }
        }
        .presentationDetents([.height(280)])
        .environment(\.layoutDirection, language.layoutDirection)
    }
}
