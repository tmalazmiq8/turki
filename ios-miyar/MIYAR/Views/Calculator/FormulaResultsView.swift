import SwiftUI

/// Quantities and full cost breakdown for a formula.
struct FormulaResultsView: View {
    @Environment(AppStore.self) private var store
    let formulaID: UUID

    @State private var showExport = false
    @State private var showIFRAReview = false

    private var language: AppLanguage { store.language }

    var body: some View {
        Group {
            if let formula = store.formula(formulaID) {
                content(formula)
            } else {
                MiyarEmptyState(symbol: "questionmark.folder", title: S.noResults(language))
            }
        }
        .background(Theme.canvas.ignoresSafeArea())
        .navigationTitle(S.results(language))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.canvas, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showExport = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel(S.export(language))
            }
        }
        .sheet(isPresented: $showExport) {
            if let formula = store.formula(formulaID) {
                ExportSheet(text: formula.exportText(language: language))
            }
        }
        .sheet(isPresented: $showIFRAReview) {
            if let formula = store.formula(formulaID) {
                IFRAFormulaReviewSheet(formula: formula)
            }
        }
    }

    private func content(_ formula: Formula) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                summaryCard(formula)
                quantitiesCard(formula)
                costCard(formula)

                Button {
                    showIFRAReview = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.shield")
                        Text(S.ifraFormulaReview(language))
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Theme.ink)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Theme.surface, in: .rect(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Theme.gold.opacity(0.5), lineWidth: 1))
                }
                .buttonStyle(.plain)

                MiyarBanner(text: S.ifraNoAutoCompliance(language), tone: .info)
            }
            .padding(Theme.margin)
            .padding(.bottom, 26)
        }
    }

    private func summaryCard(_ formula: Formula) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(formula.name)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Theme.ink)
            HStack(spacing: 10) {
                MiyarTag(title: "\(Int(formula.bottleSizeML)) \(S.milliliters(language))")
                MiyarTag(title: formula.concentration.shortLabel(language))
                MiyarTag(title: formula.oilPercent.percentText())
            }
            MiyarDivider()
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(S.balanced(language))
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.secondaryText)
                    Text("\(Int(formula.balanceScore * 100))%")
                        .font(.miyarDisplay(30))
                        .foregroundStyle(Theme.ink)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text(S.totalPercentage(language))
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.secondaryText)
                    Text(formula.totalPercent.percentText())
                        .font(.miyarDisplay(30))
                        .foregroundStyle(formula.percentIsValid ? Theme.gold : Theme.danger)
                }
            }
            MiyarProgressBar(value: formula.balanceScore)
        }
        .miyarCard(padding: 18)
    }

    private func quantitiesCard(_ formula: Formula) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(S.results(language)).miyarSectionHeader()
            ForEach(NoteStage.allCases) { stage in
                let items = formula.ingredients(in: stage)
                if !items.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(stage.label(language))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.gold)
                        ForEach(items) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Text(item.name(language))
                                        .font(.system(size: 14))
                                        .foregroundStyle(Theme.ink)
                                        .lineLimit(1)
                                    Spacer(minLength: 6)
                                    Text(item.percent.percentText())
                                        .font(.miyarMono(13, weight: .semibold))
                                        .foregroundStyle(Theme.gold)
                                }
                                HStack(spacing: 8) {
                                    quantity(String(format: "%.2f", formula.volumeML(for: item)), S.milliliters(language))
                                    quantity(String(format: "%.2f", formula.grams(for: item)), S.grams(language))
                                    quantity(String(format: "%.0f", formula.drops(for: item)), S.drops(language))
                                    Spacer(minLength: 4)
                                    Text(formula.currency.formatUSD(formula.costUSD(for: item), language: language))
                                        .font(.miyarMono(12, weight: .medium))
                                        .foregroundStyle(Theme.secondaryText)
                                }
                            }
                        }
                    }
                }
            }
            MiyarDivider()
            HStack {
                Text(S.alcohol(language)).font(.system(size: 14)).foregroundStyle(Theme.ink)
                Spacer()
                Text("\(String(format: "%.2f", formula.alcoholVolumeML)) \(S.milliliters(language))")
                    .font(.miyarMono(13, weight: .medium))
                    .foregroundStyle(Theme.ink)
            }
            HStack {
                Text(S.dropsPerML(language)).font(.system(size: 13)).foregroundStyle(Theme.secondaryText)
                Spacer()
                Text(String(format: "%.0f", formula.dropsPerML))
                    .font(.miyarMono(13))
                    .foregroundStyle(Theme.secondaryText)
            }
        }
        .miyarCard(padding: 18)
    }

    private func costCard(_ formula: Formula) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(S.totalCost(language)).miyarSectionHeader()
            costRow(S.ingredientCost(language), formula.currency.formatUSD(formula.ingredientCostUSD, language: language))
            costRow(S.alcoholCost(language), formula.currency.formatUSD(formula.alcoholCostUSD, language: language))
            costRow(S.packagingCost(language), formula.currency.formatUSD(formula.packagingCostUSD, language: language))
            MiyarDivider()
            HStack {
                Text(S.totalCost(language))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                Spacer()
                Text(formula.currency.formatUSD(formula.totalCostUSD, language: language))
                    .font(.miyarMono(18, weight: .semibold))
                    .foregroundStyle(Theme.gold)
            }
            HStack {
                Text(S.costPerML(language))
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.secondaryText)
                Spacer()
                Text(formula.currency.formatUSD(formula.costPerMLUSD, language: language))
                    .font(.miyarMono(13))
                    .foregroundStyle(Theme.secondaryText)
            }
        }
        .miyarCard(padding: 18)
    }

    private func quantity(_ value: String, _ unit: String) -> some View {
        HStack(spacing: 3) {
            Text(value).font(.miyarMono(12, weight: .medium)).foregroundStyle(Theme.ink)
            Text(unit).font(.system(size: 10)).foregroundStyle(Theme.secondaryText)
        }
    }

    private func costRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).font(.system(size: 14)).foregroundStyle(Theme.ink)
            Spacer()
            Text(value).font(.miyarMono(13, weight: .medium)).foregroundStyle(Theme.ink)
        }
    }
}
