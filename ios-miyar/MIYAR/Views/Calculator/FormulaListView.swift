import SwiftUI

/// Calculator tab root: saved formulas plus entry points to the training tools.
struct FormulaListView: View {
    @Environment(AppStore.self) private var store
    @State private var showNewFormula = false
    @State private var newFormulaName = ""
    @State private var pendingDelete: Formula?

    private var language: AppLanguage { store.language }

    var body: some View {
        MiyarScreen {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    header
                    toolsRow
                    if store.formulas.isEmpty {
                        MiyarEmptyState(
                            symbol: "flask",
                            title: S.emptyFormulas(language),
                            message: S.emptyFormulasHint(language),
                            actionTitle: S.newFormula(language)
                        ) { showNewFormula = true }
                        .miyarCard(padding: 6)
                    } else {
                        SectionHeader(title: S.recentFormulas(language))
                        ForEach(store.formulas) { formula in
                            NavigationLink(value: AppRoute.formula(formula.id)) {
                                FormulaRow(formula: formula)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(S.duplicate(language), systemImage: "doc.on.doc") {
                                    store.duplicateFormula(formula.id)
                                }
                                Button(S.setAsCurrent(language), systemImage: "star") {
                                    store.setCurrentFormula(formula.id)
                                }
                                Button(S.delete(language), systemImage: "trash", role: .destructive) {
                                    pendingDelete = formula
                                }
                            }
                        }
                    }
                }
                .padding(Theme.margin)
                .padding(.bottom, 24)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showNewFormula) { NewFormulaSheet(name: $newFormulaName) }
        .alert(S.delete(language), isPresented: Binding(get: { pendingDelete != nil }, set: { if !$0 { pendingDelete = nil } })) {
            Button(S.cancel(language), role: .cancel) { pendingDelete = nil }
            Button(S.delete(language), role: .destructive) {
                if let formula = pendingDelete { store.deleteFormula(formula.id) }
                pendingDelete = nil
            }
        } message: {
            Text(S.deleteFormulaConfirm(language))
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 3) {
                Text(S.calculator(language))
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                Text("\(store.formulas.count) \(language == .ar ? "تركيبة" : "formulas")")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.secondaryText)
            }
            Spacer()
            HStack(spacing: 10) {
                LanguageToggle()
                Button {
                    showNewFormula = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Theme.gold))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(S.newFormula(language))
            }
        }
        .padding(.top, 8)
    }

    private var toolsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                NavigationLink(value: AppRoute.jeanCarles) {
                    toolPill(symbol: "flask", title: S.jeanCarles(language))
                }
                .buttonStyle(.plain)
                NavigationLink(value: AppRoute.materials) {
                    toolPill(symbol: "books.vertical", title: S.materialsLibrary(language))
                }
                .buttonStyle(.plain)
                NavigationLink(value: AppRoute.ifra) {
                    toolPill(symbol: "checkmark.shield", title: S.ifra(language))
                }
                .buttonStyle(.plain)
                NavigationLink(value: AppRoute.assistant) {
                    toolPill(symbol: "sparkles", title: S.aiAssistant(language))
                }
                .buttonStyle(.plain)
            }
        }
        .contentMargins(.horizontal, 0, for: .scrollContent)
    }

    private func toolPill(symbol: String, title: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: symbol).font(.system(size: 13, weight: .medium))
            Text(title).font(.system(size: 13, weight: .medium))
        }
        .foregroundStyle(Theme.ink)
        .padding(.horizontal, 14)
        .frame(height: 38)
        .background(Theme.surface, in: .capsule)
        .overlay(Capsule().strokeBorder(Theme.hairline, lineWidth: 1))
    }
}
