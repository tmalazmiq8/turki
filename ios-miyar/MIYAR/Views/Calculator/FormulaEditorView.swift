import SwiftUI

/// The formula workbench: bottle parameters, note-stage editor and validation.
struct FormulaEditorView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let formulaID: UUID

    private static let bottlePresets: [Double] = [15, 30, 50, 100]

    @State private var draft: Formula?
    @State private var usesCustomSize = false
    @State private var customSizeText = ""
    @State private var showAddMaterial = false
    @State private var addStage: NoteStage = .top
    @State private var showExport = false
    @State private var showIFRAReview = false
    @State private var savedFlash = false

    private var language: AppLanguage { store.language }

    var body: some View {
        Group {
            if let draft {
                content(draft)
            } else {
                MiyarEmptyState(symbol: "questionmark.folder", title: S.noResults(language))
                    .frame(maxHeight: .infinity)
                    .background(Theme.canvas)
            }
        }
        .background(Theme.canvas.ignoresSafeArea())
        .navigationTitle(draft?.name ?? S.calculator(language))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.canvas, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(S.duplicate(language), systemImage: "doc.on.doc") {
                        if let copy = store.duplicateFormula(formulaID) {
                            draft = copy
                        }
                    }
                    Button(S.setAsCurrent(language), systemImage: "star") { store.setCurrentFormula(formulaID) }
                    Button(S.export(language), systemImage: "square.and.arrow.up") { showExport = true }
                    Button(S.ifraFormulaReview(language), systemImage: "checkmark.shield") { showIFRAReview = true }
                    Divider()
                    Button(S.delete(language), systemImage: "trash", role: .destructive) {
                        store.deleteFormula(formulaID)
                        dismiss()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .onAppear {
            if draft == nil {
                let loaded = store.formula(formulaID)
                draft = loaded
                if let size = loaded?.bottleSizeML {
                    usesCustomSize = !Self.bottlePresets.contains(size)
                    customSizeText = String(format: "%.0f", size)
                }
            }
        }
        .onDisappear { persist() }
        .sheet(isPresented: $showAddMaterial) {
            AddMaterialSheet(stage: addStage) { material, percent in
                draft?.ingredients.append(
                    FormulaIngredient(
                        materialID: material.id,
                        nameAr: material.nameAr,
                        nameEn: material.nameEn,
                        stage: addStage,
                        percent: percent,
                        pricePerMLUSD: material.pricePerMLUSD,
                        density: material.density
                    )
                )
                persist()
            }
        }
        .sheet(isPresented: $showExport) {
            if let draft {
                ExportSheet(text: draft.exportText(language: language))
            }
        }
        .sheet(isPresented: $showIFRAReview) {
            if let draft {
                IFRAFormulaReviewSheet(formula: draft)
            }
        }
    }

    // MARK: - Content

    private func content(_ formula: Formula) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                bottleCard
                totalsCard(formula)
                ForEach(NoteStage.allCases) { stage in
                    stageSection(stage, formula: formula)
                }
                costsCard(formula)
                ifraCard(formula)
                NavigationLink(value: AppRoute.results(formulaID)) {
                    HStack {
                        Text(S.results(language))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Theme.ink)
                        Spacer()
                        Text(formula.currency.formatUSD(formula.totalCostUSD, language: language))
                            .font(.miyarMono(15, weight: .medium))
                            .foregroundStyle(Theme.ink)
                    }
                    .padding(.horizontal, 18)
                    .frame(height: 54)
                    .background(Theme.gold, in: .rect(cornerRadius: 14))
                }
                .buttonStyle(.plain)

                Button(S.save(language)) {
                    persist()
                    withAnimation { savedFlash = true }
                    Task {
                        try? await Task.sleep(for: .seconds(1.6))
                        withAnimation { savedFlash = false }
                    }
                }
                .buttonStyle(InkButtonStyle())

                if savedFlash {
                    MiyarBanner(text: S.formulaSaved(language), tone: .success)
                }
            }
            .padding(Theme.margin)
            .padding(.bottom, 26)
        }
    }

    private var bottleCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(S.bottleSize(language)).miyarSectionHeader()

            HStack(spacing: 8) {
                ForEach(Self.bottlePresets, id: \.self) { size in
                    MiyarChip(
                        title: "\(Int(size))",
                        isSelected: !usesCustomSize && draft?.bottleSizeML == size
                    ) {
                        usesCustomSize = false
                        draft?.bottleSizeML = size
                        persist()
                    }
                }
                Text(S.milliliters(language))
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.secondaryText)
                Spacer(minLength: 0)
            }

            MiyarChip(title: S.customSize(language), symbol: "slider.horizontal.3", isSelected: usesCustomSize) {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                    usesCustomSize.toggle()
                }
                if usesCustomSize {
                    customSizeText = String(format: "%.0f", draft?.bottleSizeML ?? 50)
                }
            }

            if usesCustomSize {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 10) {
                        TextField(S.customSize(language), text: $customSizeText)
                            .keyboardType(.decimalPad)
                            .font(.miyarMono(15, weight: .medium))
                            .foregroundStyle(Theme.ink)
                            .padding(.horizontal, 14)
                            .frame(height: 44)
                            .background(Theme.canvas, in: .rect(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Theme.hairline, lineWidth: 1))
                            .onChange(of: customSizeText) { _, newValue in applyCustomSize(newValue) }
                        Text(S.milliliters(language))
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.secondaryText)
                    }
                    Text(S.customSizeHint(language))
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            MiyarDivider()

            Text(S.concentration(language)).miyarSectionHeader()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Concentration.allCases) { option in
                        MiyarChip(title: option.shortLabel(language), isSelected: draft?.concentration == option) {
                            draft?.concentration = option
                            if option != .custom { draft?.oilPercent = option.defaultPercent }
                            persist()
                        }
                    }
                }
                .padding(.vertical, 2)
            }

            if let draft {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(S.perfumeOil(language))
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.secondaryText)
                        Spacer()
                        Text(draft.oilPercent.percentText())
                            .font(.miyarMono(13, weight: .medium))
                            .foregroundStyle(Theme.ink)
                    }
                    Slider(
                        value: Binding(
                            get: { self.draft?.oilPercent ?? 18 },
                            set: { newValue in
                                self.draft?.oilPercent = newValue
                                self.draft?.concentration = .custom
                            }
                        ),
                        in: 1...40,
                        step: 0.5,
                        onEditingChanged: { editing in if !editing { persist() } }
                    )
                    .tint(Theme.gold)
                    HStack {
                        Text("\(S.perfumeOil(language)) \(String(format: "%.2f", draft.oilVolumeML)) \(S.milliliters(language))")
                        Spacer()
                        Text("\(S.alcohol(language)) \(String(format: "%.2f", draft.alcoholVolumeML)) \(S.milliliters(language))")
                    }
                    .font(.miyarMono(12))
                    .foregroundStyle(Theme.secondaryText)
                }
            }

            MiyarDivider()

            HStack {
                Text(S.currency(language)).miyarSectionHeader()
                Spacer()
                Picker(S.currency(language), selection: Binding(
                    get: { draft?.currency ?? .sar },
                    set: { draft?.currency = $0; persist() }
                )) {
                    ForEach(Currency.allCases) { currency in
                        Text("\(currency.symbol(language)) — \(currency.label(language))").tag(currency)
                    }
                }
                .pickerStyle(.menu)
                .tint(Theme.gold)
            }
        }
        .miyarCard(padding: 18)
    }

    private func totalsCard(_ formula: Formula) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .lastTextBaseline) {
                Text(S.totalPercentage(language)).miyarSectionHeader()
                Spacer()
                Text(formula.totalPercent.percentText())
                    .font(.miyarMono(20, weight: .semibold))
                    .foregroundStyle(formula.percentIsValid ? Theme.gold : Theme.ink)
                    .contentTransition(.numericText())
            }
            MiyarProgressBar(value: min(1, formula.totalPercent / 100))
            if formula.ingredients.isEmpty {
                MiyarBanner(text: S.noIngredients(language), tone: .info)
            } else if formula.percentIsValid {
                MiyarBanner(text: S.percentValid(language), tone: .success)
            } else if formula.totalPercent > 100 {
                MiyarBanner(text: S.percentOver(language), tone: .error)
            } else {
                MiyarBanner(text: S.percentUnder(language), tone: .info)
            }
        }
        .miyarCard(padding: 18)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: formula.totalPercent)
    }

    private func stageSection(_ stage: NoteStage, formula: Formula) -> some View {
        let items = formula.ingredients(in: stage)
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: stage.symbol)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.gold)
                Text(stage.label(language))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                Spacer()
                Text(formula.percent(in: stage).percentText())
                    .font(.miyarMono(13, weight: .medium))
                    .foregroundStyle(Theme.secondaryText)
            }

            if items.isEmpty {
                Text(S.noIngredients(language))
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.secondaryText)
            } else {
                ForEach(items) { item in
                    IngredientRow(
                        item: item,
                        formula: formula,
                        onChange: { newPercent in
                            if let index = draft?.ingredients.firstIndex(where: { $0.id == item.id }) {
                                draft?.ingredients[index].percent = newPercent
                            }
                        },
                        onPriceChange: { newPriceUSD in
                            if let index = draft?.ingredients.firstIndex(where: { $0.id == item.id }) {
                                draft?.ingredients[index].pricePerMLUSD = max(0, newPriceUSD)
                                persist()
                            }
                        },
                        onCommit: { persist() },
                        onDelete: {
                            draft?.ingredients.removeAll { $0.id == item.id }
                            persist()
                        }
                    )
                }
            }

            Button {
                addStage = stage
                showAddMaterial = true
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: "plus")
                    Text(S.addMaterial(language))
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.gold)
            }
            .buttonStyle(.plain)
        }
        .miyarCard(padding: 16)
    }

    // MARK: - Costs

    private func costsCard(_ formula: Formula) -> some View {
        CostsCard(formula: formula) { bottleCostUSD, alcoholPriceUSD, dropsPerML in
            draft?.packagingCostUSD = bottleCostUSD
            draft?.alcoholPricePerMLUSD = alcoholPriceUSD
            draft?.dropsPerML = dropsPerML
            persist()
        }
    }

    // MARK: - IFRA

    private func ifraCard(_ formula: Formula) -> some View {
        let records = formula.ingredients.map { store.ifraRecord(for: $0.materialID) }
        let verified = records.filter(\.hasVerifiedLimit).count
        let flagged = records.filter { $0.status == .restricted || $0.status == .prohibited }.count
        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.shield")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.gold)
                Text(S.ifraSection(language))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                Spacer(minLength: 0)
            }

            if formula.ingredients.isEmpty {
                Text(S.noIngredients(language))
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.secondaryText)
            } else {
                HStack(spacing: 8) {
                    MiyarTag(title: "\(verified)/\(records.count) \(S.ifraMax(language))")
                    if flagged > 0 {
                        MiyarTag(title: "\(flagged) \(S.ifraRestricted(language))", symbol: "exclamationmark.triangle")
                    }
                }
                if verified < records.count {
                    Text(S.ifraUnverified(language))
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.secondaryText)
                }
            }

            Text(S.ifraDisclaimer(language))
                .font(.system(size: 12))
                .foregroundStyle(Theme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            Text(S.ifraNoAutoCompliance(language))
                .font(.system(size: 11))
                .foregroundStyle(Theme.secondaryText.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                Button(S.ifraFormulaReview(language)) { showIFRAReview = true }
                    .buttonStyle(InkButtonStyle(fullWidth: false))
                Link(destination: URL(string: IFRAInfo.materialsSearch) ?? URL(string: IFRAInfo.officialHome)!) {
                    HStack(spacing: 6) {
                        Image(systemName: "globe").font(.system(size: 12, weight: .semibold))
                        Text(S.ifraOfficialSearch(language)).font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(Theme.gold)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .miyarCard(padding: 16)
    }

    // MARK: - Helpers

    private func applyCustomSize(_ text: String) {
        let normalized = text.replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized), value > 0 else { return }
        draft?.bottleSizeML = min(1000, value)
        persist()
    }

    private func persist() {
        guard let draft else { return }
        store.upsert(draft)
    }
}

// MARK: - Costs card

/// Bottle, alcohol and drop-conversion inputs, entered in the formula's currency.
private struct CostsCard: View {
    @Environment(AppStore.self) private var store
    let formula: Formula
    /// Reports bottle cost (USD), alcohol price per ml (USD) and drops per ml.
    let onUpdate: (Double, Double, Double) -> Void

    @State private var bottleText = ""
    @State private var alcoholText = ""
    @State private var dropsText = ""
    @State private var didLoad = false

    var body: some View {
        let language = store.language
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(S.costsSection(language)).miyarSectionHeader()
                Spacer()
                Text(formula.currency.symbol(language))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.gold)
            }

            field(label: S.bottlePackagingCost(language), text: $bottleText, keyboard: .decimalPad)
            field(label: S.alcoholPricePerML(language), text: $alcoholText, keyboard: .decimalPad)
            field(label: S.dropsPerML(language), text: $dropsText, keyboard: .numberPad)

            MiyarDivider()

            HStack {
                Text(S.ingredientCost(language))
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.secondaryText)
                Spacer()
                Text(formula.currency.formatUSD(formula.ingredientCostUSD, language: language))
                    .font(.miyarMono(13, weight: .medium))
                    .foregroundStyle(Theme.ink)
            }
            HStack {
                Text(S.totalCost(language))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                Spacer()
                Text(formula.currency.formatUSD(formula.totalCostUSD, language: language))
                    .font(.miyarMono(15, weight: .semibold))
                    .foregroundStyle(Theme.gold)
                    .contentTransition(.numericText())
            }

            Text(S.costsHint(language))
                .font(.system(size: 11))
                .foregroundStyle(Theme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .miyarCard(padding: 16)
        .onAppear { if !didLoad { load(); didLoad = true } }
        .onChange(of: formula.currency) { _, _ in load() }
    }

    private func field(label: String, text: Binding<String>, keyboard: UIKeyboardType) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(Theme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            TextField("0", text: text)
                .keyboardType(keyboard)
                .multilineTextAlignment(.center)
                .font(.miyarMono(14, weight: .medium))
                .foregroundStyle(Theme.ink)
                .frame(width: 96, height: 40)
                .background(Theme.canvas, in: .rect(cornerRadius: 11))
                .overlay(RoundedRectangle(cornerRadius: 11).strokeBorder(Theme.hairline, lineWidth: 1))
                .onChange(of: text.wrappedValue) { _, _ in commit() }
        }
    }

    private func load() {
        let currency = formula.currency
        bottleText = trimmed(currency.fromUSD(formula.packagingCostUSD), digits: currency.fractionDigits)
        alcoholText = trimmed(currency.fromUSD(formula.alcoholPricePerMLUSD), digits: 3)
        dropsText = String(format: "%.0f", formula.dropsPerML)
    }

    private func commit() {
        let currency = formula.currency
        let bottle = parse(bottleText) ?? currency.fromUSD(formula.packagingCostUSD)
        let alcohol = parse(alcoholText) ?? currency.fromUSD(formula.alcoholPricePerMLUSD)
        let drops = parse(dropsText) ?? formula.dropsPerML
        onUpdate(
            currency.toUSD(max(0, bottle)),
            currency.toUSD(max(0, alcohol)),
            min(100, max(1, drops))
        )
    }

    private func parse(_ text: String) -> Double? {
        Double(text.replacingOccurrences(of: ",", with: "."))
    }

    private func trimmed(_ value: Double, digits: Int) -> String {
        String(format: "%.\(digits)f", value)
    }
}

// MARK: - Material cost sheet

/// Adjusts one ingredient's price per millilitre in the formula's currency.
struct MaterialCostSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let item: FormulaIngredient
    let formula: Formula
    let onSave: (Double) -> Void

    @State private var priceText = ""
    @State private var didLoad = false

    var body: some View {
        let language = store.language
        let currency = formula.currency
        let entered = Double(priceText.replacingOccurrences(of: ",", with: ".")) ?? currency.fromUSD(item.pricePerMLUSD)
        let volume = formula.volumeML(for: item)
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(item.name(language))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Theme.ink)
                        Text(S.materialCostHint(language))
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .miyarCard(padding: 16)

                    VStack(alignment: .leading, spacing: 14) {
                        MiyarField(
                            label: "\(S.pricePerML(language)) — \(currency.symbol(language))",
                            placeholder: "0",
                            text: $priceText,
                            keyboard: .decimalPad
                        )
                        MiyarDivider()
                        row(S.quantities(language), "\(String(format: "%.2f", volume)) \(S.milliliters(language))")
                        row(S.grams(language), String(format: "%.2f", formula.grams(for: item)))
                        row(S.drops(language), String(format: "%.0f", formula.drops(for: item)))
                        MiyarDivider()
                        HStack {
                            Text(S.cost(language))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Theme.ink)
                            Spacer()
                            Text(currency.format(max(0, entered) * volume, language: language))
                                .font(.miyarMono(16, weight: .semibold))
                                .foregroundStyle(Theme.gold)
                                .contentTransition(.numericText())
                        }
                    }
                    .miyarCard(padding: 16)

                    Button(S.save(language)) {
                        onSave(currency.toUSD(max(0, entered)))
                        dismiss()
                    }
                    .buttonStyle(GoldButtonStyle())
                }
                .padding(Theme.margin)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Theme.canvas.ignoresSafeArea())
            .navigationTitle(S.materialCost(language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(S.cancel(language)) { dismiss() }
                }
            }
        }
        .environment(\.layoutDirection, language.layoutDirection)
        .onAppear {
            guard !didLoad else { return }
            priceText = String(format: "%.3f", currency.fromUSD(item.pricePerMLUSD))
            didLoad = true
        }
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).font(.system(size: 13)).foregroundStyle(Theme.secondaryText)
            Spacer()
            Text(value).font(.miyarMono(13, weight: .medium)).foregroundStyle(Theme.ink)
        }
    }
}

// MARK: - Ingredient row

private struct IngredientRow: View {
    @Environment(AppStore.self) private var store
    let item: FormulaIngredient
    let formula: Formula
    let onChange: (Double) -> Void
    let onPriceChange: (Double) -> Void
    let onCommit: () -> Void
    let onDelete: () -> Void

    @State private var showIFRA = false
    @State private var showCost = false

    var body: some View {
        let language = store.language
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(item.name(language))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Theme.ink)
                Spacer(minLength: 4)
                Text(item.percent.percentText())
                    .font(.miyarMono(14, weight: .semibold))
                    .foregroundStyle(Theme.gold)
                    .contentTransition(.numericText())
            }

            HStack(spacing: 12) {
                Button {
                    onChange(max(0, item.percent - 0.5))
                    onCommit()
                } label: {
                    stepperGlyph("minus")
                }
                .buttonStyle(.plain)

                Slider(
                    value: Binding(get: { item.percent }, set: { onChange($0) }),
                    in: 0...100,
                    step: 0.5,
                    onEditingChanged: { editing in if !editing { onCommit() } }
                )
                .tint(Theme.gold)

                Button {
                    onChange(min(100, item.percent + 0.5))
                    onCommit()
                } label: {
                    stepperGlyph("plus")
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 10) {
                metric(String(format: "%.2f", formula.volumeML(for: item)), S.milliliters(language))
                metric(String(format: "%.2f", formula.grams(for: item)), S.grams(language))
                metric(String(format: "%.0f", formula.drops(for: item)), S.drops(language))
                Spacer(minLength: 0)
            }

            HStack(spacing: 10) {
                Button {
                    showCost = true
                } label: {
                    HStack(spacing: 4) {
                        Text(formula.currency.formatUSD(formula.costUSD(for: item), language: language))
                            .font(.miyarMono(12, weight: .medium))
                            .foregroundStyle(Theme.ink)
                        Image(systemName: "pencil")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(Theme.secondaryText)
                    }
                    .padding(.horizontal, 10)
                    .frame(height: 26)
                    .background(Theme.surface, in: .capsule)
                    .overlay(Capsule().strokeBorder(Theme.hairline, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(S.materialCost(language))

                Spacer(minLength: 0)
                Button {
                    showIFRA = true
                } label: {
                    Text(S.ifraShort(language))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                        .padding(.horizontal, 10)
                        .frame(height: 26)
                        .background(Theme.goldSoft, in: .capsule)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(S.ifra(language))

                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.danger)
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(S.delete(language))
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Theme.canvas, in: .rect(cornerRadius: Theme.tileRadius))
        .sheet(isPresented: $showIFRA) {
            IFRADetailSheet(materialID: item.materialID, materialName: item.name(language))
        }
        .sheet(isPresented: $showCost) {
            MaterialCostSheet(item: item, formula: formula, onSave: onPriceChange)
        }
    }

    private func stepperGlyph(_ symbol: String) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(Theme.ink)
            .frame(width: 30, height: 30)
            .background(Circle().fill(Theme.surface))
            .overlay(Circle().strokeBorder(Theme.hairline, lineWidth: 1))
    }

    private func metric(_ value: String, _ unit: String) -> some View {
        HStack(spacing: 3) {
            Text(value).font(.miyarMono(12, weight: .medium)).foregroundStyle(Theme.ink)
            Text(unit).font(.system(size: 11)).foregroundStyle(Theme.secondaryText)
        }
    }
}

// MARK: - Export

struct ExportSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let text: String

    var body: some View {
        let language = store.language
        NavigationStack {
            ScrollView {
                Text(text)
                    .font(.miyarMono(13))
                    .foregroundStyle(Theme.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                    .miyarCard()
                    .padding(Theme.margin)
            }
            .background(Theme.canvas.ignoresSafeArea())
            .navigationTitle(S.exportedText(language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(S.close(language)) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: text) { Image(systemName: "square.and.arrow.up") }
                }
            }
        }
        .environment(\.layoutDirection, language.layoutDirection)
    }
}
