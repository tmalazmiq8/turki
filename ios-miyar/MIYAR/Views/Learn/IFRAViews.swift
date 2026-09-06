import SwiftUI

// MARK: - Section

/// Dedicated safety section: disclaimer, official source, per-material records.
struct IFRASectionView: View {
    @Environment(AppStore.self) private var store
    @State private var query = ""
    @State private var restrictedOnly = false
    @State private var syncError: LText?
    @State private var isSyncing = false

    private var language: AppLanguage { store.language }

    private var materials: [Material] {
        SeedMaterials.all.filter { material in
            let record = store.ifraRecord(for: material.id)
            let statusMatch = !restrictedOnly || record.status == .restricted || record.status == .prohibited
            return statusMatch && material.matches(query, language: language)
        }
    }

    var body: some View {
        MiyarScreen(title: S.ifra(language)) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    IFRADisclaimerCard()

                    Link(destination: URL(string: IFRAInfo.materialsSearch) ?? URL(string: IFRAInfo.officialHome)!) {
                        HStack(spacing: 10) {
                            Image(systemName: "globe")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Theme.gold)
                            Text(S.ifraOfficialSearch(language))
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Theme.ink)
                            Spacer(minLength: 0)
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Theme.secondaryText)
                        }
                        .miyarCard(padding: 14)
                    }

                    NavigationLink(value: AppRoute.ifraAdmin) {
                        HStack(spacing: 10) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Theme.gold)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(S.ifraAdmin(language))
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(Theme.ink)
                                Text(S.ifraAdminHint(language))
                                    .font(.system(size: 11))
                                    .foregroundStyle(Theme.secondaryText)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer(minLength: 0)
                        }
                        .miyarCard(padding: 14)
                    }
                    .buttonStyle(.plain)

                    Button {
                        Task { await sync() }
                    } label: {
                        HStack(spacing: 8) {
                            if isSyncing {
                                ProgressView().controlSize(.small).tint(Theme.ink)
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                            Text(S.ifraFetchRemote(language))
                        }
                    }
                    .buttonStyle(InkButtonStyle())
                    .disabled(isSyncing)

                    if let syncError {
                        MiyarBanner(text: syncError(language), tone: .error)
                    }
                    if let last = store.ifraLastSync {
                        Text("\(S.ifraLastUpdated(language)): \(last.shortDate(language))")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.secondaryText)
                    }

                    MiyarSearchField(placeholder: S.search(language), text: $query)
                    MiyarChip(title: S.ifraMaterialsWithLimits(language), isSelected: restrictedOnly) {
                        restrictedOnly.toggle()
                    }

                    if materials.isEmpty {
                        MiyarEmptyState(symbol: "magnifyingglass", title: S.noResults(language), message: S.noResultsHint(language))
                    } else {
                        ForEach(materials) { material in
                            NavigationLink(value: AppRoute.material(material.id)) {
                                IFRAMaterialRow(material: material, record: store.ifraRecord(for: material.id))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(Theme.margin)
                .padding(.bottom, 26)
            }
        }
    }

    private func sync() async {
        isSyncing = true
        syncError = nil
        do {
            try await store.refreshIFRAFromServer()
        } catch let error as IFRAService.ServiceError {
            syncError = error.message
        } catch {
            syncError = LText("تعذّر الاتصال بالخادم.", "Couldn't reach the server.")
        }
        isSyncing = false
    }
}

// MARK: - Shared pieces

/// The mandatory guidance disclaimer, shown wherever IFRA data appears.
struct IFRADisclaimerCard: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        let language = store.language
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.shield")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.gold)
                Text(S.ifraSection(language))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.ink)
            }
            Text(S.ifraDisclaimer(language))
                .font(.system(size: 13))
                .foregroundStyle(Theme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            Text(S.ifraNoAutoCompliance(language))
                .font(.system(size: 12))
                .foregroundStyle(Theme.secondaryText.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .miyarCard(padding: 16)
    }
}

struct IFRAStatusBadge: View {
    @Environment(AppStore.self) private var store
    let record: IFRARecord

    private var tone: Color {
        switch record.status {
        case .prohibited: Theme.danger
        case .restricted: Theme.gold
        default: Theme.secondaryText
        }
    }

    var body: some View {
        Text(record.status.label(store.language))
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(tone)
            .padding(.horizontal, 10)
            .frame(height: 24)
            .background(tone.opacity(0.12), in: .capsule)
    }
}

private struct IFRAMaterialRow: View {
    @Environment(AppStore.self) private var store
    let material: Material
    let record: IFRARecord

    var body: some View {
        let language = store.language
        HStack(spacing: 12) {
            Image(systemName: material.family.symbol)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.gold)
                .frame(width: 34, height: 34)
                .background(Circle().fill(Theme.goldSoft))
            VStack(alignment: .leading, spacing: 3) {
                Text(material.name(language))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Theme.ink)
                Text(record.hasVerifiedLimit
                     ? "\(S.ifraMax(language)): \((record.maxConcentrationPercent ?? 0).percentText())"
                     : S.ifraUnverified(language))
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.secondaryText)
                    .lineLimit(1)
            }
            Spacer(minLength: 4)
            IFRAStatusBadge(record: record)
        }
        .miyarCard(padding: 12, radius: Theme.tileRadius)
    }
}

/// The full record for one material, opened from material and formula screens.
struct IFRADetailSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let materialID: String
    let materialName: String

    var body: some View {
        let language = store.language
        let record = store.ifraRecord(for: materialID)
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(materialName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Theme.ink)

                    VStack(spacing: 0) {
                        detailRow(S.ifraStatus(language)) { IFRAStatusBadge(record: record) }
                        MiyarDivider()
                        detailRow(S.ifraMax(language)) {
                            Text(record.hasVerifiedLimit
                                 ? (record.maxConcentrationPercent ?? 0).percentText()
                                 : S.ifraUnverified(language))
                                .font(.system(size: 14, weight: record.hasVerifiedLimit ? .semibold : .regular))
                                .foregroundStyle(record.hasVerifiedLimit ? Theme.ink : Theme.secondaryText)
                                .multilineTextAlignment(.trailing)
                        }
                        MiyarDivider()
                        detailRow(S.ifraAmendment(language)) {
                            Text(record.amendment)
                                .font(.system(size: 14))
                                .foregroundStyle(Theme.ink)
                        }
                        MiyarDivider()
                        detailRow(S.ifraCategory(language)) {
                            Text(record.productCategory(language))
                                .font(.system(size: 14))
                                .foregroundStyle(Theme.ink)
                                .multilineTextAlignment(.trailing)
                        }
                        MiyarDivider()
                        detailRow(S.ifraLastUpdated(language)) {
                            Text(record.lastUpdated.timeIntervalSince1970 == 0 ? "—" : record.lastUpdated.shortDate(language))
                                .font(.system(size: 14))
                                .foregroundStyle(Theme.ink)
                        }
                    }
                    .miyarCard(padding: 14)

                    if let note = record.note {
                        Text(note(language))
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                            .miyarCard(padding: 14)
                    }

                    IFRADisclaimerCard()

                    Link(destination: URL(string: record.sourceURL) ?? URL(string: IFRAInfo.officialHome)!) {
                        HStack(spacing: 8) {
                            Image(systemName: "link")
                            Text(S.ifraSource(language))
                            Spacer(minLength: 0)
                            Image(systemName: "arrow.up.right").font(.system(size: 11, weight: .semibold))
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Theme.ink)
                        .miyarCard(padding: 14)
                    }
                }
                .padding(Theme.margin)
                .padding(.bottom, 24)
            }
            .background(Theme.canvas.ignoresSafeArea())
            .navigationTitle(S.ifra(language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(S.close(language)) { dismiss() }
                }
            }
        }
        .environment(\.layoutDirection, language.layoutDirection)
    }

    private func detailRow<Trailing: View>(_ title: String, @ViewBuilder trailing: () -> Trailing) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(Theme.secondaryText)
            Spacer(minLength: 10)
            trailing()
        }
        .padding(.vertical, 11)
    }
}

/// Safety review across every material used in a formula.
struct IFRAFormulaReviewSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let formula: Formula

    @State private var openMaterial: String?

    var body: some View {
        let language = store.language
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    IFRADisclaimerCard()

                    if formula.ingredients.isEmpty {
                        MiyarEmptyState(symbol: "tray", title: S.noIngredients(language))
                    } else {
                        VStack(spacing: 10) {
                            ForEach(formula.ingredients) { item in
                                let record = store.ifraRecord(for: item.materialID)
                                Button {
                                    openMaterial = item.materialID
                                } label: {
                                    HStack(spacing: 10) {
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(item.name(language))
                                                .font(.system(size: 15, weight: .medium))
                                                .foregroundStyle(Theme.ink)
                                            Text("\(S.percentOfBlend(language)): \(item.percent.percentText())")
                                                .font(.system(size: 12))
                                                .foregroundStyle(Theme.secondaryText)
                                            Text(record.hasVerifiedLimit
                                                 ? "\(S.ifraMax(language)): \((record.maxConcentrationPercent ?? 0).percentText())"
                                                 : S.ifraUnverified(language))
                                                .font(.system(size: 12))
                                                .foregroundStyle(record.hasVerifiedLimit ? Theme.ink : Theme.secondaryText)
                                        }
                                        Spacer(minLength: 4)
                                        IFRAStatusBadge(record: record)
                                    }
                                    .miyarCard(padding: 13, radius: Theme.tileRadius)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(Theme.margin)
                .padding(.bottom, 24)
            }
            .background(Theme.canvas.ignoresSafeArea())
            .navigationTitle(S.ifraFormulaReview(language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(S.close(language)) { dismiss() }
                }
            }
            .sheet(item: Binding(
                get: { openMaterial.map(IdentifiedString.init) },
                set: { openMaterial = $0?.value }
            )) { wrapper in
                IFRADetailSheet(
                    materialID: wrapper.value,
                    materialName: SeedMaterials.byID(wrapper.value)?.name(language) ?? wrapper.value
                )
            }
        }
        .environment(\.layoutDirection, language.layoutDirection)
    }
}

/// Lets a plain string drive `sheet(item:)`.
struct IdentifiedString: Identifiable, Hashable {
    let value: String
    var id: String { value }
}

// MARK: - Admin

/// Administrator entry point: edits the local override that mirrors the payload
/// the server dashboard publishes.
struct IFRAAdminView: View {
    @Environment(AppStore.self) private var store

    @State private var materialID: String = SeedMaterials.all.first?.id ?? ""
    @State private var amendment = ""
    @State private var categoryAr = ""
    @State private var categoryEn = ""
    @State private var status: IFRARecord.Status = .unverified
    @State private var hasLimit = false
    @State private var limitText = ""
    @State private var sourceURL = IFRAInfo.officialURL
    @State private var feedback: LText?

    private var language: AppLanguage { store.language }

    var body: some View {
        MiyarScreen(title: S.ifraAdmin(language)) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    MiyarBanner(text: S.ifraAdminHint(language), tone: .info)

                    VStack(alignment: .leading, spacing: 14) {
                        Picker(S.materialsLibrary(language), selection: $materialID) {
                            ForEach(SeedMaterials.all) { material in
                                Text(material.name(language)).tag(material.id)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(Theme.gold)

                        MiyarField(label: S.ifraAmendment(language), placeholder: "IFRA 51st Amendment", text: $amendment)
                        MiyarField(label: "\(S.ifraCategory(language)) — عربي", text: $categoryAr)
                        MiyarField(label: "\(S.ifraCategory(language)) — EN", text: $categoryEn)

                        VStack(alignment: .leading, spacing: 7) {
                            Text(S.ifraStatus(language))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Theme.secondaryText)
                            Picker(S.ifraStatus(language), selection: $status) {
                                Text(S.ifraRestricted(language)).tag(IFRARecord.Status.restricted)
                                Text(S.ifraProhibited(language)).tag(IFRARecord.Status.prohibited)
                                Text(S.ifraSpecified(language)).tag(IFRARecord.Status.specification)
                                Text(S.ifraNotListed(language)).tag(IFRARecord.Status.notListed)
                                Text(S.ifraStatusUnverified(language)).tag(IFRARecord.Status.unverified)
                            }
                            .pickerStyle(.segmented)
                        }

                        Toggle(isOn: $hasLimit) {
                            Text(S.ifraMax(language))
                                .font(.system(size: 14))
                                .foregroundStyle(Theme.ink)
                        }
                        .tint(Theme.gold)

                        if hasLimit {
                            MiyarField(label: S.ifraMax(language), placeholder: "0.5", text: $limitText, keyboard: .decimalPad)
                        } else {
                            Text(S.ifraUnverified(language))
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.secondaryText)
                        }

                        MiyarField(label: S.ifraSource(language), text: $sourceURL, keyboard: .URL)
                    }
                    .miyarCard(padding: 16)

                    if let feedback {
                        MiyarBanner(text: feedback(language), tone: .success)
                    }

                    Button(S.saveChanges(language)) { apply() }
                        .buttonStyle(GoldButtonStyle())

                    if store.ifraOverrides[materialID] != nil {
                        Button(S.delete(language)) {
                            store.clearIFRAOverride(materialID)
                            feedback = S.ifraRecordsUpdated
                        }
                        .buttonStyle(InkButtonStyle())
                    }

                    IFRADisclaimerCard()
                }
                .padding(Theme.margin)
                .padding(.bottom, 26)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .onAppear(perform: loadCurrent)
        .onChange(of: materialID) { _, _ in loadCurrent() }
    }

    private func loadCurrent() {
        let record = store.ifraRecord(for: materialID)
        amendment = record.amendment == "—" ? "" : record.amendment
        categoryAr = record.productCategory.ar
        categoryEn = record.productCategory.en
        status = record.status
        hasLimit = record.hasVerifiedLimit
        limitText = record.maxConcentrationPercent.map { String($0) } ?? ""
        sourceURL = record.sourceURL
    }

    private func apply() {
        // A limit is stored only when the administrator supplies a real figure.
        let limit: Double? = hasLimit ? Double(limitText.replacingOccurrences(of: ",", with: ".")) : nil
        let record = IFRARecord(
            id: materialID,
            amendment: amendment.trimmingCharacters(in: .whitespaces).isEmpty ? "—" : amendment,
            productCategory: LText(
                categoryAr.isEmpty ? "غير محدد" : categoryAr,
                categoryEn.isEmpty ? "Not specified" : categoryEn
            ),
            status: status,
            maxConcentrationPercent: limit,
            sourceURL: sourceURL.isEmpty ? IFRAInfo.officialURL : sourceURL,
            lastUpdated: Date(),
            note: nil
        )
        store.applyIFRAOverride(record)
        feedback = S.ifraRecordsUpdated
    }
}
