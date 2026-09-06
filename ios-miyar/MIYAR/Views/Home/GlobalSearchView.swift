import SwiftUI

/// One search field across materials, formulas, glossary, listings and posts.
struct GlobalSearchView: View {
    @Environment(AppStore.self) private var store
    @State private var query = ""

    private var language: AppLanguage { store.language }

    private var materials: [Material] {
        guard !query.isEmpty else { return [] }
        return SeedMaterials.all.filter { $0.matches(query, language: language) }.prefix(6).map { $0 }
    }

    private var terms: [GlossaryTerm] {
        guard !query.isEmpty else { return [] }
        return SeedGlossary.all.filter { $0.matches(query) }.prefix(5).map { $0 }
    }

    private var formulas: [Formula] {
        guard !query.isEmpty else { return [] }
        return store.formulas.filter { $0.name.localizedStandardContains(query) }
    }

    private var listings: [Listing] {
        guard !query.isEmpty else { return [] }
        return store.visibleListings.filter { $0.matches(query) }.prefix(5).map { $0 }
    }

    private var posts: [Post] {
        guard !query.isEmpty else { return [] }
        return store.visiblePosts.filter { $0.matches(query) }.prefix(5).map { $0 }
    }

    private var isEmpty: Bool {
        materials.isEmpty && terms.isEmpty && formulas.isEmpty && listings.isEmpty && posts.isEmpty
    }

    var body: some View {
        MiyarScreen(title: S.search(language)) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    MiyarSearchField(placeholder: S.searchEverything(language), text: $query)

                    if query.isEmpty {
                        MiyarEmptyState(
                            symbol: "magnifyingglass",
                            title: S.searchEverything(language),
                            message: S.glossaryIntro(language)
                        )
                    } else if isEmpty {
                        MiyarEmptyState(symbol: "questionmark.circle", title: S.noResults(language), message: S.noResultsHint(language))
                    } else {
                        section(S.materialsLibrary(language), isEmpty: materials.isEmpty) {
                            ForEach(materials) { material in
                                NavigationLink(value: AppRoute.material(material.id)) {
                                    resultRow(symbol: material.family.symbol, title: material.name(language), subtitle: material.family.label(language))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        section(S.recentFormulas(language), isEmpty: formulas.isEmpty) {
                            ForEach(formulas) { formula in
                                NavigationLink(value: AppRoute.formula(formula.id)) {
                                    resultRow(symbol: "slider.horizontal.3", title: formula.name, subtitle: formula.totalPercent.percentText())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        section(S.glossary(language), isEmpty: terms.isEmpty) {
                            ForEach(terms) { term in
                                NavigationLink(value: AppRoute.glossaryTerm(term.id)) {
                                    resultRow(symbol: "character.book.closed", title: term.term(language), subtitle: term.category.label(language))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        section(S.marketplace(language), isEmpty: listings.isEmpty) {
                            ForEach(listings) { listing in
                                NavigationLink(value: AppRoute.listing(listing.id)) {
                                    resultRow(symbol: listing.category.symbol, title: listing.title(language), subtitle: listing.location(language))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        section(S.community(language), isEmpty: posts.isEmpty) {
                            ForEach(posts) { post in
                                NavigationLink(value: AppRoute.post(post.id)) {
                                    resultRow(symbol: post.kind.symbol, title: post.title(language), subtitle: post.kind.label(language))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(Theme.margin)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.immediately)
        }
    }

    @ViewBuilder
    private func section<Content: View>(_ title: String, isEmpty: Bool, @ViewBuilder content: () -> Content) -> some View {
        if !isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(title: title)
                VStack(spacing: 8) { content() }
            }
        }
    }

    private func resultRow(symbol: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.gold)
                .frame(width: 34, height: 34)
                .background(Circle().fill(Theme.goldSoft))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.secondaryText)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .miyarCard(padding: 12, radius: Theme.tileRadius)
    }
}
