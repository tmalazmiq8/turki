import SwiftUI

/// Searchable ingredient database with family and stage filters.
struct MaterialsLibraryView: View {
    @Environment(AppStore.self) private var store

    @State private var query = ""
    @State private var family: OlfactoryFamily?
    @State private var stage: NoteStage?
    @State private var savedOnly = false
    @State private var addedMaterial: String?

    private var language: AppLanguage { store.language }

    private var results: [Material] {
        SeedMaterials.all.filter { material in
            let familyMatch = family == nil || material.family == family
            let stageMatch = stage == nil || material.stage == stage
            let savedMatch = !savedOnly || store.isMaterialSaved(material.id)
            return familyMatch && stageMatch && savedMatch && material.matches(query, language: language)
        }
    }

    var body: some View {
        MiyarScreen(title: S.materialsLibrary(language), showsLanguageToggle: true) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14, pinnedViews: []) {
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
                    .padding(.horizontal, -Theme.margin)

                    HStack(spacing: 8) {
                        ForEach(NoteStage.allCases) { option in
                            MiyarChip(title: option.label(language), symbol: option.symbol, isSelected: stage == option) {
                                stage = stage == option ? nil : option
                            }
                        }
                        MiyarChip(title: S.savedOnly(language), symbol: "bookmark", isSelected: savedOnly) {
                            savedOnly.toggle()
                        }
                    }

                    HStack {
                        Text("\(results.count) \(S.materialsCount(language))")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.secondaryText)
                        Spacer()
                    }

                    if let formula = store.currentFormula {
                        Text("\(S.addToFormula(language)): \(formula.name)")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.secondaryText)
                    }

                    if results.isEmpty {
                        MiyarEmptyState(symbol: "leaf", title: S.noResults(language), message: S.noResultsHint(language))
                    } else {
                        ForEach(results) { material in
                            NavigationLink(value: AppRoute.material(material.id)) {
                                MaterialRow(
                                    material: material,
                                    record: store.ifraRecord(for: material.id),
                                    onQuickAdd: store.currentFormula == nil ? nil : { addToCurrentFormula(material) }
                                )
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                if store.currentFormula != nil {
                                    Button(S.addToFormula(language), systemImage: "plus.circle") {
                                        addToCurrentFormula(material)
                                    }
                                }
                                Button(
                                    store.isMaterialSaved(material.id) ? S.saved(language) : S.saveItem(language),
                                    systemImage: store.isMaterialSaved(material.id) ? "bookmark.fill" : "bookmark"
                                ) {
                                    store.toggleMaterialSaved(material.id)
                                }
                            }
                        }
                    }
                }
                .padding(Theme.margin)
                .padding(.bottom, 26)
            }
            .scrollDismissesKeyboard(.immediately)
            .safeAreaInset(edge: .bottom) {
                if let added = addedMaterial {
                    MiyarBanner(text: "\(S.addedToFormula(language)) — \(added)", tone: .success)
                        .padding(.horizontal, Theme.margin)
                        .padding(.bottom, 8)
                }
            }
        }
    }

    /// Adds the material straight into the current formula at a 10% starting share.
    private func addToCurrentFormula(_ material: Material) {
        guard let formula = store.currentFormula else { return }
        store.addMaterial(material, percent: 10, to: formula.id)
        withAnimation { addedMaterial = material.name(language) }
        Task {
            try? await Task.sleep(for: .seconds(1.8))
            withAnimation { addedMaterial = nil }
        }
    }
}

private struct MaterialRow: View {
    @Environment(AppStore.self) private var store
    let material: Material
    let record: IFRARecord
    var onQuickAdd: (() -> Void)?

    var body: some View {
        let language = store.language
        HStack(spacing: 12) {
            Image(systemName: material.family.symbol)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Theme.gold)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Theme.goldSoft))
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(material.name(language))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Theme.ink)
                    if store.isMaterialSaved(material.id) {
                        Image(systemName: "bookmark.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Theme.gold)
                    }
                }
                Text(material.character(language))
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.secondaryText)
                    .lineLimit(1)
            }
            Spacer(minLength: 4)
            VStack(alignment: .trailing, spacing: 4) {
                MiyarTag(title: material.stage.label(language))
                if record.status == .restricted || record.status == .prohibited {
                    IFRAStatusBadge(record: record)
                }
            }
            if let onQuickAdd {
                Button(action: onQuickAdd) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(Theme.goldSoft))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(S.addToFormula(language))
            }
        }
        .miyarCard(padding: 12, radius: Theme.tileRadius)
    }
}

/// Full material page including notes, pairings and the IFRA entry point.
struct MaterialDetailView: View {
    @Environment(AppStore.self) private var store
    let materialID: String

    @State private var notes = ""
    @State private var showIFRA = false
    @State private var showAddToFormula = false
    @State private var addPercent: Double = 10
    @State private var addedFlash = false

    private var language: AppLanguage { store.language }

    var body: some View {
        Group {
            if let material = SeedMaterials.byID(materialID) {
                content(material)
            } else {
                MiyarEmptyState(symbol: "questionmark.folder", title: S.noResults(language))
            }
        }
        .background(Theme.canvas.ignoresSafeArea())
        .navigationTitle(SeedMaterials.byID(materialID)?.name(language) ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.canvas, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.toggleMaterialSaved(materialID)
                } label: {
                    Image(systemName: store.isMaterialSaved(materialID) ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(Theme.gold)
                }
                .accessibilityLabel(store.isMaterialSaved(materialID) ? S.saved(language) : S.saveItem(language))
            }
        }
        .onAppear { notes = store.note(for: materialID) }
        .sheet(isPresented: $showIFRA) {
            IFRADetailSheet(materialID: materialID, materialName: SeedMaterials.byID(materialID)?.name(language) ?? "")
        }
    }

    private func content(_ material: Material) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header(material)
                factsCard(material)
                pairingsCard(material)
                ifraCard(material)
                notesCard
                addToFormulaCard(material)
            }
            .padding(Theme.margin)
            .padding(.bottom, 26)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func header(_ material: Material) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: material.family.symbol)
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(Theme.gold)
                    .frame(width: 52, height: 52)
                    .background(Circle().fill(Theme.goldSoft))
                VStack(alignment: .leading, spacing: 3) {
                    Text(material.nameAr)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                    Text(material.nameEn)
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.secondaryText)
                }
                Spacer(minLength: 0)
            }
            HStack(spacing: 8) {
                MiyarTag(title: material.family.label(language), symbol: material.family.symbol)
                MiyarTag(title: material.stage.label(language), symbol: material.stage.symbol)
                MiyarTag(title: String(repeating: "◆", count: material.intensity))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .miyarCard(padding: 18)
    }

    private func factsCard(_ material: Material) -> some View {
        VStack(spacing: 0) {
            factRow(S.origin(language), material.origin(language))
            MiyarDivider()
            factRow(S.characterLabel(language), material.character(language))
            MiyarDivider()
            factRow(S.evaporationLabel(language), material.evaporation(language))
            MiyarDivider()
            factRow(S.typicalUse(language), material.typicalUse(language))
            MiyarDivider()
            factRow(S.pricePerML(language), Currency.usd.format(material.pricePerMLUSD, language: language))
        }
        .miyarCard(padding: 14)
    }

    private func factRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(Theme.secondaryText)
                .frame(width: 92, alignment: .leading)
            Text(value)
                .font(.system(size: 14))
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 11)
    }

    @ViewBuilder
    private func pairingsCard(_ material: Material) -> some View {
        let pairings = material.pairings.compactMap { SeedMaterials.byID($0) }
        if !pairings.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text(S.pairings(language)).miyarSectionHeader()
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 8)], spacing: 8) {
                    ForEach(pairings) { pair in
                        NavigationLink(value: AppRoute.material(pair.id)) {
                            Text(pair.name(language))
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

    private func ifraCard(_ material: Material) -> some View {
        let record = store.ifraRecord(for: material.id)
        return Button {
            showIFRA = true
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.shield")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.gold)
                    Text(S.ifra(language))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                    Spacer(minLength: 0)
                    IFRAStatusBadge(record: record)
                }
                Text(record.hasVerifiedLimit
                     ? "\(S.ifraMax(language)): \((record.maxConcentrationPercent ?? 0).percentText())"
                     : S.ifraUnverified(language))
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.secondaryText)
                Text(S.ifraDisclaimer(language))
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.secondaryText.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .miyarCard(padding: 16)
        }
        .buttonStyle(.plain)
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(S.materialNotes(language)).miyarSectionHeader()
            TextField(S.materialNotes(language), text: $notes, axis: .vertical)
                .lineLimit(3...7)
                .font(.system(size: 14))
                .foregroundStyle(Theme.ink)
                .padding(12)
                .background(Theme.canvas, in: .rect(cornerRadius: 12))
                .onChange(of: notes) { _, newValue in
                    store.setNote(newValue, for: materialID)
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .miyarCard(padding: 16)
    }

    private func addToFormulaCard(_ material: Material) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(S.addToFormula(language)).miyarSectionHeader()
            if let formula = store.currentFormula {
                Text(formula.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.ink)
                HStack {
                    Text(S.percentOfBlend(language))
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.secondaryText)
                    Spacer()
                    Text(addPercent.percentText())
                        .font(.miyarMono(14, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                }
                Slider(value: $addPercent, in: 0.5...60, step: 0.5).tint(Theme.gold)
                Button(S.addToFormula(language)) {
                    store.addMaterial(material, percent: addPercent, to: formula.id)
                    withAnimation { addedFlash = true }
                    Task {
                        try? await Task.sleep(for: .seconds(1.6))
                        withAnimation { addedFlash = false }
                    }
                }
                .buttonStyle(GoldButtonStyle())
                if addedFlash {
                    MiyarBanner(text: S.addedToFormula(language), tone: .success)
                }
            } else {
                Text(S.noCurrentFormula(language))
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.secondaryText)
                Button(S.startFirstFormula(language)) { showAddToFormula = true }
                    .buttonStyle(InkButtonStyle())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .miyarCard(padding: 16)
        .sheet(isPresented: $showAddToFormula) {
            NewFormulaSheet(name: .constant(""))
        }
    }
}
