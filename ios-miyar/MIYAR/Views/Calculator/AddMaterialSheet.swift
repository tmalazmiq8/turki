import SwiftUI

/// Picks a library material and its share of the blend.
struct AddMaterialSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let stage: NoteStage
    let onAdd: (Material, Double) -> Void

    @State private var query = ""
    @State private var family: OlfactoryFamily?
    @State private var selected: Material?
    @State private var percent: Double = 10

    private var language: AppLanguage { store.language }

    private var results: [Material] {
        SeedMaterials.all.filter { material in
            let stageMatch = material.stage == stage || !query.isEmpty
            let familyMatch = family == nil || material.family == family
            return stageMatch && familyMatch && material.matches(query, language: language)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    MiyarSearchField(placeholder: S.search(language), text: $query)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            MiyarChip(title: S.allFamilies(language), isSelected: family == nil) { family = nil }
                            ForEach(OlfactoryFamily.allCases) { option in
                                MiyarChip(title: option.label(language), symbol: option.symbol, isSelected: family == option) {
                                    family = family == option ? nil : option
                                }
                            }
                        }
                        .padding(.horizontal, Theme.margin)
                    }
                    .contentMargins(.horizontal, 0, for: .scrollContent)
                    .padding(.horizontal, -Theme.margin)
                }
                .padding(.horizontal, Theme.margin)
                .padding(.bottom, 12)

                if results.isEmpty {
                    MiyarEmptyState(symbol: "magnifyingglass", title: S.noResults(language), message: S.noResultsHint(language))
                    Spacer()
                } else {
                    List {
                        ForEach(results) { material in
                            Button {
                                selected = material
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: material.family.symbol)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(Theme.gold)
                                        .frame(width: 32, height: 32)
                                        .background(Circle().fill(Theme.goldSoft))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(material.name(language))
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundStyle(Theme.ink)
                                        Text("\(material.family.label(language)) · \(material.stage.label(language))")
                                            .font(.system(size: 12))
                                            .foregroundStyle(Theme.secondaryText)
                                    }
                                    Spacer(minLength: 0)
                                    if selected?.id == material.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Theme.gold)
                                    }
                                }
                                .contentShape(.rect)
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(Theme.canvas)
                            .listRowSeparatorTint(Theme.hairline)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .scrollDismissesKeyboard(.immediately)
                }

                if let selected {
                    VStack(spacing: 12) {
                        HStack {
                            Text(S.percentOfBlend(language))
                                .font(.system(size: 13))
                                .foregroundStyle(Theme.secondaryText)
                            Spacer()
                            Text(percent.percentText())
                                .font(.miyarMono(15, weight: .semibold))
                                .foregroundStyle(Theme.ink)
                        }
                        Slider(value: $percent, in: 0.5...60, step: 0.5).tint(Theme.gold)
                        Button("\(S.addToFormula(language)) — \(selected.name(language))") {
                            onAdd(selected, percent)
                            dismiss()
                        }
                        .buttonStyle(GoldButtonStyle())
                    }
                    .padding(Theme.margin)
                    .background(Theme.surface)
                    .overlay(alignment: .top) { MiyarDivider() }
                }
            }
            .background(Theme.canvas.ignoresSafeArea())
            .navigationTitle("\(S.addMaterial(language)) — \(stage.label(language))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(S.cancel(language)) { dismiss() }
                }
            }
        }
        .environment(\.layoutDirection, language.layoutDirection)
    }
}
