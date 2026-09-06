import SwiftUI

/// Composer for a new community post.
struct CreatePostView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var kind: PostKind = .discussion
    @State private var title = ""
    @State private var body_ = ""
    @State private var families: Set<OlfactoryFamily> = []
    @State private var attachFormula = false
    @State private var artworkSeed = Int.random(in: 0..<5)
    @State private var photoIDs: [String] = []
    @State private var includeImage = true
    @State private var showPreview = false

    private var language: AppLanguage { store.language }

    private var canPublish: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !body_.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    kindPicker

                    MiyarField(label: S.postTitle(language), text: $title)

                    VStack(alignment: .leading, spacing: 7) {
                        Text(S.postBody(language))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Theme.secondaryText)
                        TextField(S.postBody(language), text: $body_, axis: .vertical)
                            .font(.system(size: 16))
                            .foregroundStyle(Theme.ink)
                            .lineLimit(6...14)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 13)
                            .background(Theme.surface, in: .rect(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Theme.hairline, lineWidth: 1))
                    }

                    photoSection
                    familySection

                    if store.currentFormula != nil {
                        Toggle(isOn: $attachFormula) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(S.aiAttachFormula(language))
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(Theme.ink)
                                Text(store.currentFormula?.name ?? "")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.secondaryText)
                            }
                        }
                        .tint(Theme.gold)
                        .miyarCard(padding: 14)
                    }

                    MiyarBanner(text: S.guidelinesReminder(language), tone: .info)

                    if showPreview {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(S.preview(language)).miyarSectionHeader()
                            PostCard(post: draftPost)
                        }
                    }

                    Button(S.publish(language)) { publish() }
                        .buttonStyle(GoldButtonStyle())
                        .disabled(!canPublish)
                        .opacity(canPublish ? 1 : 0.5)
                }
                .padding(Theme.margin)
                .padding(.bottom, 26)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Theme.canvas.ignoresSafeArea())
            .navigationTitle(S.newPost(language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.canvas, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(S.cancel(language)) { cancel() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(S.preview(language)) {
                        withAnimation(.easeInOut(duration: 0.25)) { showPreview.toggle() }
                    }
                    .disabled(!canPublish)
                }
            }
        }
        .environment(\.layoutDirection, language.layoutDirection)
    }

    private var kindPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(S.selectCommunity(language)).miyarSectionHeader()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(PostKind.allCases) { option in
                        MiyarChip(title: option.label(language), symbol: option.symbol, isSelected: kind == option) {
                            kind = option
                        }
                    }
                }
                .padding(.vertical, 2)
            }
            .scrollClipDisabled()
        }
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            PhotoPickerStrip(photoIDs: $photoIDs, limit: 4, fallbackSeed: artworkSeed)

            if photoIDs.isEmpty {
                HStack(spacing: 10) {
                    ForEach(0..<5, id: \.self) { seed in
                        Button {
                            artworkSeed = seed
                            includeImage = true
                        } label: {
                            BottleArtwork(seed: seed, cornerRadius: 10)
                                .frame(width: 56, height: 56)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(
                                            includeImage && artworkSeed == seed ? Theme.gold : Theme.hairline,
                                            lineWidth: includeImage && artworkSeed == seed ? 2 : 1
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(S.addPhoto(language)) \(seed + 1)")
                    }
                    Spacer(minLength: 0)
                    Button {
                        includeImage.toggle()
                    } label: {
                        Image(systemName: includeImage ? "photo" : "photo.badge.plus")
                            .font(.system(size: 15))
                            .foregroundStyle(Theme.secondaryText)
                            .frame(width: 44, height: 44)
                            .background(Theme.surface, in: .rect(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Theme.hairline, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(S.addPhoto(language))
                }
            }

            Text(S.photosHint(language))
                .font(.system(size: 12))
                .foregroundStyle(Theme.secondaryText)
        }
    }

    private var familySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(S.allFamilies(language)).miyarSectionHeader()
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 106), spacing: 8)], spacing: 8) {
                ForEach(OlfactoryFamily.allCases) { family in
                    MiyarChip(title: family.label(language), isSelected: families.contains(family)) {
                        if families.contains(family) { families.remove(family) } else { families.insert(family) }
                    }
                }
            }
        }
    }

    private var draftPost: Post {
        let cleanTitle = Validation.sanitize(title, limit: 120)
        let cleanBody = Validation.sanitize(body_, limit: 4000)
        var lines: [LText] = []
        if attachFormula, let formula = store.currentFormula {
            lines = formula.ingredients.map { item in
                LText(
                    "\(item.nameAr) — \(String(format: "%.1f", item.percent))%",
                    "\(item.nameEn) — \(String(format: "%.1f", item.percent))%"
                )
            }
        }
        return Post(
            authorID: SeedPeople.currentUserID,
            kind: kind,
            titleAr: cleanTitle,
            titleEn: cleanTitle,
            bodyAr: cleanBody,
            bodyEn: cleanBody,
            families: families.sorted { $0.rawValue < $1.rawValue },
            createdAt: Date(),
            artworkSeed: artworkSeed,
            hasImage: includeImage || !photoIDs.isEmpty,
            photoIDs: photoIDs,
            formulaLines: lines
        )
    }

    private func publish() {
        store.publish(draftPost)
        dismiss()
    }

    /// Cleans up photos that were imported but never published.
    private func cancel() {
        ImageStore.shared.delete(photoIDs)
        dismiss()
    }
}
