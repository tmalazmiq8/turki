import SwiftUI

/// Personalised landing screen: greeting, live formula, quick actions,
/// recent work and reading progress.
struct HomeView: View {
    @Environment(AppStore.self) private var store
    @State private var showNewFormula = false
    @State private var newFormulaName = ""

    private var language: AppLanguage { store.language }

    private var greeting: LText {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return S.goodMorning
        case 12..<17: return S.goodAfternoon
        default: return S.goodEvening
        }
    }

    var body: some View {
        MiyarScreen {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 22) {
                    headerBar
                    searchButton
                    currentFormulaCard
                    quickActions
                    recentFormulas
                    readingCard
                    assistantCard
                }
                .padding(.horizontal, Theme.margin)
                .padding(.bottom, 28)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showNewFormula) {
            NewFormulaSheet(name: $newFormulaName)
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack(alignment: .center) {
            HStack(spacing: 10) {
                MiyarLogoMark(size: 36)
                VStack(alignment: .leading, spacing: 3) {
                    Text(greeting(language))
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.secondaryText)
                    Text(store.currentUser?.name(language) ?? S.appName(language))
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                }
            }
            Spacer(minLength: 8)
            HStack(spacing: 10) {
                LanguageToggle()
                Link(destination: URL(string: IFRAInfo.materialsSearch) ?? URL(string: IFRAInfo.officialHome)!) {
                    Image(systemName: "checkmark.shield")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Theme.ink)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Theme.surface))
                        .overlay(Circle().strokeBorder(Theme.hairline, lineWidth: 1))
                }
                .accessibilityLabel(S.ifra(language))
                NavigationLink(value: AppRoute.notifications) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(Theme.ink)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Theme.surface))
                            .overlay(Circle().strokeBorder(Theme.hairline, lineWidth: 1))
                        if store.unreadNotifications > 0 {
                            Circle()
                                .fill(Theme.gold)
                                .frame(width: 10, height: 10)
                                .offset(x: -4, y: 4)
                        }
                    }
                }
                .accessibilityLabel(S.notifications(language))
            }
        }
        .padding(.top, 8)
    }

    private var searchButton: some View {
        NavigationLink(value: AppRoute.search) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Theme.secondaryText)
                Text(S.searchEverything(language))
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.secondaryText)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .frame(height: 46)
            .background(Theme.surface, in: .rect(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Theme.hairline, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Current formula

    @ViewBuilder
    private var currentFormulaCard: some View {
        if let formula = store.currentFormula {
            NavigationLink(value: AppRoute.formula(formula.id)) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text(S.currentFormula(language)).miyarSectionHeader()
                        Spacer()
                        MiyarTag(title: formula.concentration.shortLabel(language))
                    }
                    Text(formula.name)
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                        .multilineTextAlignment(.leading)

                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text(String(format: "%.0f", formula.totalPercent))
                            .font(.miyarDisplay(40))
                            .foregroundStyle(Theme.ink)
                        Text("%")
                            .font(.system(size: 17))
                            .foregroundStyle(Theme.secondaryText)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(S.balanced(language))
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.secondaryText)
                            Text("\(Int(formula.balanceScore * 100))%")
                                .font(.miyarMono(15, weight: .semibold))
                                .foregroundStyle(Theme.gold)
                        }
                    }

                    MiyarProgressBar(value: min(1, formula.totalPercent / 100))

                    HStack(spacing: 14) {
                        ForEach(NoteStage.allCases) { stage in
                            VStack(alignment: .leading, spacing: 3) {
                                Text(stage.label(language))
                                    .font(.system(size: 11))
                                    .foregroundStyle(Theme.secondaryText)
                                Text(formula.percent(in: stage).percentText())
                                    .font(.miyarMono(13, weight: .medium))
                                    .foregroundStyle(Theme.ink)
                            }
                            if stage != .base { Spacer() }
                        }
                    }
                }
                .miyarCard(padding: 18)
            }
            .buttonStyle(.plain)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text(S.currentFormula(language)).miyarSectionHeader()
                Text(S.noCurrentFormula(language))
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Theme.ink)
                Button(S.startFirstFormula(language)) { showNewFormula = true }
                    .buttonStyle(GoldButtonStyle())
            }
            .miyarCard(padding: 18)
        }
    }

    // MARK: - Quick actions

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: S.quickActions(language))
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                QuickActionTile(symbol: "plus.circle", title: S.newFormula(language)) { showNewFormula = true }
                NavigationLink(value: AppRoute.materials) {
                    QuickActionTileLabel(symbol: "books.vertical", title: S.materialsLibrary(language))
                }
                .buttonStyle(.plain)
                NavigationLink(value: AppRoute.jeanCarles) {
                    QuickActionTileLabel(symbol: "flask", title: S.jeanCarles(language))
                }
                .buttonStyle(.plain)
                NavigationLink(value: AppRoute.ifra) {
                    QuickActionTileLabel(symbol: "checkmark.shield", title: S.ifra(language))
                }
                .buttonStyle(.plain)
                NavigationLink(value: AppRoute.glossary) {
                    QuickActionTileLabel(symbol: "character.book.closed", title: S.glossary(language))
                }
                .buttonStyle(.plain)
                NavigationLink(value: AppRoute.book) {
                    QuickActionTileLabel(symbol: "book", title: S.book(language))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Recent formulas

    @ViewBuilder
    private var recentFormulas: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: S.recentFormulas(language))
            if store.formulas.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text(S.emptyFormulasHint(language))
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.secondaryText)
                    Button(S.newFormula(language)) { showNewFormula = true }
                        .buttonStyle(InkButtonStyle(fullWidth: false))
                }
                .miyarCard()
            } else {
                VStack(spacing: 10) {
                    ForEach(store.formulas.prefix(3)) { formula in
                        NavigationLink(value: AppRoute.formula(formula.id)) {
                            FormulaRow(formula: formula)
                        }
                        .buttonStyle(.plain)
                    }
                }
                if store.formulas.count > 3 {
                    NavigationLink(value: AppRoute.formulaList) {
                        Text(S.seeAll(language))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Theme.gold)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Reading

    private var readingCard: some View {
        NavigationLink(value: AppRoute.book) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(S.readingProgress(language)).miyarSectionHeader()
                    Spacer()
                    Text("\(Int(store.bookProgress * 100))% \(S.percentRead(language))")
                        .font(.miyarMono(12))
                        .foregroundStyle(Theme.gold)
                }
                Text(S.bookTitle(language))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                MiyarProgressBar(value: store.bookProgress)
                Text(store.lastChapterID == nil ? S.startReading(language) : S.continueReading(language))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.gold)
            }
            .miyarCard(padding: 18)
        }
        .buttonStyle(.plain)
    }

    private var assistantCard: some View {
        NavigationLink(value: AppRoute.assistant) {
            HStack(spacing: 14) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Theme.gold)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Theme.goldSoft))
                VStack(alignment: .leading, spacing: 3) {
                    Text(S.aiAssistant(language))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                    Text(S.aiSubtitle(language))
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.secondaryText)
                }
                Spacer(minLength: 0)
            }
            .miyarCard(padding: 14)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Pieces

struct QuickActionTileLabel: View {
    let symbol: String
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Theme.gold)
                .frame(width: 38, height: 38)
                .background(Circle().fill(Theme.goldSoft))
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .topLeading)
        .miyarCard(padding: 14, radius: Theme.tileRadius)
    }
}

struct QuickActionTile: View {
    let symbol: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            QuickActionTileLabel(symbol: symbol, title: title)
        }
        .buttonStyle(.plain)
    }
}

struct FormulaRow: View {
    @Environment(AppStore.self) private var store
    let formula: Formula

    var body: some View {
        let language = store.language
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Theme.goldSoft)
                Text("\(Int(formula.balanceScore * 100))")
                    .font(.miyarMono(13, weight: .semibold))
                    .foregroundStyle(Theme.gold)
            }
            .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 3) {
                Text(formula.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)
                Text("\(Int(formula.bottleSizeML)) \(S.milliliters(language)) · \(formula.concentration.shortLabel(language)) · \(formula.ingredients.count) \(S.materialsCount(language))")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.secondaryText)
                    .lineLimit(1)
            }
            Spacer(minLength: 4)
            Text(formula.totalPercent.percentText())
                .font(.miyarMono(13, weight: .medium))
                .foregroundStyle(formula.percentIsValid ? Theme.gold : Theme.secondaryText)
        }
        .miyarCard(padding: 12, radius: Theme.tileRadius)
    }
}

/// Sheet used everywhere a new formula can be started.
struct NewFormulaSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Binding var name: String

    var body: some View {
        let language = store.language
        NavigationStack {
            VStack(spacing: 18) {
                MiyarField(label: S.formulaName(language), placeholder: S.newFormula(language), text: $name)
                Button(S.save(language)) {
                    store.createFormula(name: name)
                    name = ""
                    dismiss()
                }
                .buttonStyle(GoldButtonStyle())
                Spacer()
            }
            .padding(Theme.margin)
            .background(Theme.canvas.ignoresSafeArea())
            .navigationTitle(S.newFormula(language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(S.cancel(language)) { dismiss() }
                }
            }
        }
        .presentationDetents([.height(240)])
        .environment(\.layoutDirection, language.layoutDirection)
    }
}
