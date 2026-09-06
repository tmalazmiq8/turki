import SwiftUI

/// Bilingual perfumery terminology with categories and bookmarks.
struct GlossaryView: View {
    @Environment(AppStore.self) private var store

    @State private var query = ""
    @State private var category: GlossaryTerm.Category?
    @State private var bookmarksOnly = false

    private var language: AppLanguage { store.language }

    private var results: [GlossaryTerm] {
        SeedGlossary.all.filter { term in
            let categoryMatch = category == nil || term.category == category
            let bookmarkMatch = !bookmarksOnly || store.isBookmarked(term: term.id)
            return categoryMatch && bookmarkMatch && term.matches(query)
        }
    }

    var body: some View {
        MiyarScreen(title: S.glossary(language), showsLanguageToggle: true) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    Text(S.glossaryIntro(language))
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.secondaryText)

                    MiyarSearchField(placeholder: S.search(language), text: $query)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            MiyarChip(title: S.catAll(language), isSelected: category == nil) { category = nil }
                            ForEach(GlossaryTerm.Category.allCases) { option in
                                MiyarChip(title: option.label(language), isSelected: category == option) {
                                    category = category == option ? nil : option
                                }
                            }
                            MiyarChip(title: S.bookmarksOnly(language), symbol: "bookmark", isSelected: bookmarksOnly) {
                                bookmarksOnly.toggle()
                            }
                        }
                        .padding(.horizontal, Theme.margin)
                    }
                    .padding(.horizontal, -Theme.margin)

                    if results.isEmpty {
                        MiyarEmptyState(symbol: "character.book.closed", title: S.noResults(language), message: S.noResultsHint(language))
                    } else {
                        ForEach(results) { term in
                            NavigationLink(value: AppRoute.glossaryTerm(term.id)) {
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(term.term(language))
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundStyle(Theme.ink)
                                        Text(language == .ar ? term.termEn : term.termAr)
                                            .font(.system(size: 12))
                                            .foregroundStyle(Theme.secondaryText)
                                    }
                                    Spacer(minLength: 4)
                                    if store.isBookmarked(term: term.id) {
                                        Image(systemName: "bookmark.fill")
                                            .font(.system(size: 11))
                                            .foregroundStyle(Theme.gold)
                                    }
                                    MiyarTag(title: term.category.label(language))
                                }
                                .miyarCard(padding: 13, radius: Theme.tileRadius)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(Theme.margin)
                .padding(.bottom, 26)
            }
            .scrollDismissesKeyboard(.immediately)
        }
    }
}

/// A single glossary entry with its example and related terms.
struct GlossaryTermView: View {
    @Environment(AppStore.self) private var store
    let termID: String

    private var language: AppLanguage { store.language }

    var body: some View {
        Group {
            if let term = SeedGlossary.byID(termID) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(term.termAr)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(Theme.ink)
                            Text(term.termEn)
                                .font(.system(size: 14))
                                .foregroundStyle(Theme.secondaryText)
                            MiyarTag(title: term.category.label(language))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .miyarCard(padding: 18)

                        block(S.definition(language), term.definition(language))
                        block(S.example(language), term.example(language))

                        let related = term.related.compactMap { SeedGlossary.byID($0) }
                        if !related.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(S.relatedTerms(language)).miyarSectionHeader()
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 8)], spacing: 8) {
                                    ForEach(related) { item in
                                        NavigationLink(value: AppRoute.glossaryTerm(item.id)) {
                                            Text(item.term(language))
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundStyle(Theme.ink)
                                                .frame(maxWidth: .infinity, minHeight: 36)
                                                .background(Theme.canvas, in: .rect(cornerRadius: 10))
                                                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Theme.hairline, lineWidth: 1))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .miyarCard(padding: 16)
                        }
                    }
                    .padding(Theme.margin)
                    .padding(.bottom, 26)
                }
            } else {
                MiyarEmptyState(symbol: "questionmark.folder", title: S.noResults(language))
            }
        }
        .background(Theme.canvas.ignoresSafeArea())
        .navigationTitle(SeedGlossary.byID(termID)?.term(language) ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.canvas, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.toggleBookmark(term: termID)
                } label: {
                    Image(systemName: store.isBookmarked(term: termID) ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(Theme.gold)
                }
                .accessibilityLabel(store.isBookmarked(term: termID) ? S.bookmarked(language) : S.bookmark(language))
            }
        }
    }

    private func block(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).miyarSectionHeader()
            Text(body)
                .font(.system(size: 15))
                .foregroundStyle(Theme.ink)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .miyarCard(padding: 16)
    }
}
