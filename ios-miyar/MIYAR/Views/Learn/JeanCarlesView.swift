import SwiftUI

/// Step-by-step Jean Carles training plus the saved pairwise experiments.
struct JeanCarlesView: View {
    @Environment(AppStore.self) private var store

    /// Which saved experiments the list shows.
    enum Filter: String, Hashable, CaseIterable, Identifiable {
        case all, unfinished, completed
        var id: String { rawValue }

        func label(_ language: AppLanguage) -> String {
            switch self {
            case .all: S.allExperiments(language)
            case .unfinished: S.unfinished(language)
            case .completed: S.completed(language)
            }
        }
    }

    @State private var editingExperiment: JeanCarlesExperiment?
    @State private var filter: Filter = .all

    private var language: AppLanguage { store.language }

    private var visibleExperiments: [JeanCarlesExperiment] {
        switch filter {
        case .all: store.experiments
        case .unfinished: store.unfinishedExperiments
        case .completed: store.completedExperiments
        }
    }

    var body: some View {
        MiyarScreen(title: S.jeanCarles(language), showsLanguageToggle: true) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    Text(S.jeanCarlesIntro(language))
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    progressCard

                    SectionHeader(title: S.steps(language))
                    ForEach(SeedJeanCarles.steps) { step in
                        StepCard(step: step) {
                            editingExperiment = newExperiment(step: step.id)
                        }
                    }

                    SectionHeader(title: S.experiments(language))

                    HStack(spacing: 8) {
                        ForEach(Filter.allCases) { option in
                            MiyarChip(title: option.label(language), isSelected: filter == option) {
                                filter = option
                            }
                        }
                        Spacer(minLength: 0)
                    }

                    if visibleExperiments.isEmpty {
                        MiyarEmptyState(
                            symbol: "testtube.2",
                            title: S.emptyExperiments(language),
                            message: S.emptyExperimentsHint(language),
                            actionTitle: S.newExperiment(language)
                        ) {
                            editingExperiment = newExperiment(step: 1)
                        }
                        .miyarCard(padding: 6)
                    } else {
                        ForEach(visibleExperiments) { experiment in
                            ExperimentCard(
                                experiment: experiment,
                                onOpen: { editingExperiment = experiment },
                                onToggleComplete: { store.toggleExperimentComplete(experiment.id) },
                                onDelete: { store.deleteExperiment(experiment.id) }
                            )
                        }
                    }
                }
                .padding(Theme.margin)
                .padding(.bottom, 26)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    editingExperiment = newExperiment(step: 1)
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel(S.newExperiment(language))
            }
        }
        .sheet(item: $editingExperiment) { experiment in
            ExperimentSheet(experiment: experiment)
        }
    }

    private var progressCard: some View {
        let total = SeedJeanCarles.steps.count
        let done = store.completedSteps.count
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(S.steps(language)).miyarSectionHeader()
                Spacer()
                Text("\(done)/\(total)")
                    .font(.miyarMono(13, weight: .medium))
                    .foregroundStyle(Theme.gold)
            }
            MiyarProgressBar(value: total == 0 ? 0 : Double(done) / Double(total))
            HStack(spacing: 10) {
                Text("\(store.completedExperiments.count) \(S.completed(language))")
                if !store.unfinishedExperiments.isEmpty {
                    Text("·")
                    Text("\(store.unfinishedExperiments.count) \(S.unfinished(language))")
                }
            }
            .font(.system(size: 12))
            .foregroundStyle(Theme.secondaryText)
        }
        .miyarCard(padding: 16)
    }

    private func newExperiment(step: Int) -> JeanCarlesExperiment {
        let first = SeedMaterials.all.first
        let second = SeedMaterials.all.dropFirst().first
        return JeanCarlesExperiment(
            stepNumber: step,
            materialAID: first?.id ?? "",
            materialBID: second?.id ?? "",
            materialAName: LText(first?.nameAr ?? "", first?.nameEn ?? ""),
            materialBName: LText(second?.nameAr ?? "", second?.nameEn ?? "")
        )
    }
}

// MARK: - Step card

private struct StepCard: View {
    @Environment(AppStore.self) private var store
    let step: JeanCarlesStep
    let onStart: () -> Void

    @State private var isExpanded = false

    var body: some View {
        let language = store.language
        let isDone = store.completedSteps.contains(step.id)
        let stepExperiments = store.experiments(inStep: step.id)
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { isExpanded.toggle() }
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(isDone ? Theme.gold : Theme.goldSoft)
                        if isDone {
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Theme.ink)
                        } else {
                            Text("\(step.id)")
                                .font(.miyarMono(14, weight: .semibold))
                                .foregroundStyle(Theme.gold)
                        }
                    }
                    .frame(width: 38, height: 38)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(step.title(language))
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Theme.ink)
                            .multilineTextAlignment(.leading)
                        Text(step.summary(language))
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.secondaryText)
                            .multilineTextAlignment(.leading)
                            .lineLimit(isExpanded ? nil : 2)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Theme.secondaryText)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(step.instructions.enumerated()), id: \.offset) { index, line in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(index + 1)")
                                .font(.miyarMono(11, weight: .semibold))
                                .foregroundStyle(Theme.gold)
                                .frame(width: 18, height: 18)
                                .background(Circle().fill(Theme.goldSoft))
                            Text(line(language))
                                .font(.system(size: 13))
                                .foregroundStyle(Theme.ink)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    if !stepExperiments.isEmpty {
                        Text("\(S.stepExperiments(language)): \(stepExperiments.count)")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.secondaryText)
                            .padding(.top, 2)
                    }

                    HStack(spacing: 10) {
                        Button(S.startStep(language), action: onStart)
                            .buttonStyle(GoldButtonStyle(fullWidth: false))
                        Button(isDone ? S.completed(language) : S.markComplete(language)) {
                            store.toggleStepComplete(step.id)
                        }
                        .buttonStyle(InkButtonStyle(fullWidth: false))
                    }
                    .padding(.top, 4)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .miyarCard(padding: 14)
    }
}

// MARK: - Experiment card

private struct ExperimentCard: View {
    @Environment(AppStore.self) private var store
    let experiment: JeanCarlesExperiment
    let onOpen: () -> Void
    let onToggleComplete: () -> Void
    let onDelete: () -> Void

    var body: some View {
        let language = store.language
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text("\(experiment.materialAName(language)) · \(experiment.materialBName(language))")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Theme.ink)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 4)
                    Text(experiment.ratioLabel)
                        .font(.miyarMono(12, weight: .medium))
                        .foregroundStyle(Theme.gold)
                }

                HStack(spacing: 8) {
                    MiyarTag(title: "\(S.stepLabel(language)) \(experiment.stepNumber)")
                    MiyarTag(title: "\(S.dilution(language)) \(experiment.dilutionLabel)")
                    statusTag
                }

                HStack(spacing: 14) {
                    rating(S.strength(language), experiment.strength)
                    rating(S.character(language), experiment.character)
                    rating(S.evaporation(language), experiment.evaporation)
                    rating(S.harmony(language), experiment.harmony)
                }

                if !experiment.notes.isEmpty {
                    Text(experiment.notes)
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }

                HStack {
                    Text(experiment.date.shortDate(language))
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.secondaryText)
                    Spacer()
                    Text(experiment.isComplete ? S.editExperiment(language) : S.resumeExperiment(language))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.gold)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .miyarCard(padding: 14)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(
                experiment.isComplete ? S.reopenExperiment(language) : S.markExperimentDone(language),
                systemImage: experiment.isComplete ? "arrow.uturn.backward" : "checkmark.circle"
            ) {
                onToggleComplete()
            }
            Button(S.delete(language), systemImage: "trash", role: .destructive, action: onDelete)
        }
    }

    private var statusTag: some View {
        let language = store.language
        let done = experiment.isComplete
        return Text(done ? S.completed(language) : S.unfinished(language))
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(done ? Theme.gold : Theme.secondaryText)
            .padding(.horizontal, 10)
            .frame(height: 26)
            .background((done ? Theme.gold : Theme.secondaryText).opacity(0.12), in: .capsule)
    }

    private func rating(_ title: String, _ value: Int) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 10))
                .foregroundStyle(Theme.secondaryText)
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { step in
                    Circle()
                        .fill(step <= value ? Theme.gold : Theme.ink.opacity(0.12))
                        .frame(width: 5, height: 5)
                }
            }
        }
    }
}

// MARK: - Experiment sheet

/// Records or edits a pairwise comparison: dilution, ratio and the four ratings.
struct ExperimentSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let experiment: JeanCarlesExperiment

    @State private var stepNumber = 1
    @State private var materialA = ""
    @State private var materialB = ""
    @State private var partsA = 5
    @State private var partsB = 5
    @State private var dilution: Double = 10
    @State private var strength = 3
    @State private var character = 3
    @State private var evaporation = 3
    @State private var harmony = 3
    @State private var notes = ""
    @State private var didLoad = false

    private var language: AppLanguage { store.language }

    private var isValid: Bool { materialA != materialB }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    stepCard
                    materialPicker(S.materialA(language), selection: $materialA)
                    materialPicker(S.materialB(language), selection: $materialB)

                    if !isValid {
                        MiyarBanner(text: S.differentMaterials(language), tone: .error)
                    }

                    dilutionCard
                    ratioCard

                    VStack(alignment: .leading, spacing: 14) {
                        ratingRow(S.strength(language), value: $strength)
                        ratingRow(S.character(language), value: $character)
                        ratingRow(S.evaporation(language), value: $evaporation)
                        ratingRow(S.harmony(language), value: $harmony)
                    }
                    .miyarCard(padding: 16)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(S.experimentNotes(language)).miyarSectionHeader()
                        TextField(S.experimentNotes(language), text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.ink)
                            .padding(12)
                            .background(Theme.canvas, in: .rect(cornerRadius: 12))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .miyarCard(padding: 16)

                    VStack(spacing: 10) {
                        Button(S.saveComplete(language)) { save(complete: true) }
                            .buttonStyle(GoldButtonStyle())
                            .disabled(!isValid)
                        Button(S.saveDraft(language)) { save(complete: false) }
                            .buttonStyle(InkButtonStyle())
                            .disabled(!isValid)
                    }

                    IFRADisclaimerCard()
                }
                .padding(Theme.margin)
                .padding(.bottom, 26)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Theme.canvas.ignoresSafeArea())
            .navigationTitle(store.experiment(experiment.id) == nil ? S.newExperiment(language) : S.editExperiment(language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(S.cancel(language)) { dismiss() }
                }
            }
        }
        .environment(\.layoutDirection, language.layoutDirection)
        .onAppear(perform: load)
    }

    private var stepCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(S.stepLabel(language)).miyarSectionHeader()
            Picker(S.stepLabel(language), selection: $stepNumber) {
                ForEach(SeedJeanCarles.steps) { step in
                    Text("\(step.id) — \(step.title(language))").tag(step.id)
                }
            }
            .pickerStyle(.menu)
            .tint(Theme.gold)
            if let step = SeedJeanCarles.step(stepNumber) {
                Text(step.summary(language))
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .miyarCard(padding: 16)
    }

    private var dilutionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(S.dilution(language)).miyarSectionHeader()
                Spacer()
                Text(dilution.percentText())
                    .font(.miyarMono(14, weight: .semibold))
                    .foregroundStyle(Theme.gold)
                    .contentTransition(.numericText())
            }
            HStack(spacing: 8) {
                ForEach([1.0, 5.0, 10.0, 20.0, 100.0], id: \.self) { preset in
                    MiyarChip(title: preset.percentText(), isSelected: dilution == preset) {
                        dilution = preset
                    }
                }
            }
            Slider(value: $dilution, in: 1...100, step: 1).tint(Theme.gold)
            Text(S.dilutionHint(language))
                .font(.system(size: 11))
                .foregroundStyle(Theme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .miyarCard(padding: 16)
    }

    private var ratioCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(S.ratio(language)).miyarSectionHeader()
                Spacer()
                Text("\(partsA) : \(partsB)")
                    .font(.miyarMono(14, weight: .semibold))
                    .foregroundStyle(Theme.gold)
            }
            HStack(spacing: 12) {
                Stepper("\(partsA)", value: $partsA, in: 1...9).tint(Theme.gold)
                Text(":").foregroundStyle(Theme.secondaryText)
                Stepper("\(partsB)", value: $partsB, in: 1...9).tint(Theme.gold)
            }
            .font(.miyarMono(14))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .miyarCard(padding: 16)
    }

    private func materialPicker(_ title: String, selection: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).miyarSectionHeader()
            Picker(title, selection: selection) {
                ForEach(SeedMaterials.all) { material in
                    Text(material.name(language)).tag(material.id)
                }
            }
            .pickerStyle(.menu)
            .tint(Theme.gold)
            if let material = SeedMaterials.byID(selection.wrappedValue) {
                Text("\(material.family.label(language)) · \(material.stage.label(language))")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .miyarCard(padding: 16)
    }

    private func ratingRow(_ title: String, value: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.ink)
                Spacer()
                Text("\(value.wrappedValue)/5")
                    .font(.miyarMono(12))
                    .foregroundStyle(Theme.secondaryText)
            }
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { step in
                    Button {
                        value.wrappedValue = step
                    } label: {
                        Circle()
                            .fill(step <= value.wrappedValue ? Theme.gold : Theme.ink.opacity(0.08))
                            .frame(height: 26)
                            .overlay(
                                Text("\(step)")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(step <= value.wrappedValue ? Theme.ink : Theme.secondaryText)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func load() {
        guard !didLoad else { return }
        stepNumber = experiment.stepNumber
        materialA = experiment.materialAID
        materialB = experiment.materialBID
        partsA = experiment.partsA
        partsB = experiment.partsB
        dilution = experiment.dilutionPercent
        strength = experiment.strength
        character = experiment.character
        evaporation = experiment.evaporation
        harmony = experiment.harmony
        notes = experiment.notes
        didLoad = true
    }

    private func save(complete: Bool) {
        guard let a = SeedMaterials.byID(materialA), let b = SeedMaterials.byID(materialB), a.id != b.id else { return }
        var updated = experiment
        updated.stepNumber = stepNumber
        updated.materialAID = a.id
        updated.materialBID = b.id
        updated.materialAName = LText(a.nameAr, a.nameEn)
        updated.materialBName = LText(b.nameAr, b.nameEn)
        updated.partsA = partsA
        updated.partsB = partsB
        updated.dilutionPercent = dilution
        updated.strength = strength
        updated.character = character
        updated.evaporation = evaporation
        updated.harmony = harmony
        updated.notes = Validation.sanitize(notes, limit: 600)
        updated.isComplete = complete
        store.updateExperiment(updated)
        dismiss()
    }
}
