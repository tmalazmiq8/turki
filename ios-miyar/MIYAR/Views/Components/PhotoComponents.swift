import PhotosUI
import SwiftUI

// MARK: - Loading phases

/// Load state shared by every list screen: loading → ready, or failed with retry.
enum LoadPhase: Equatable {
    case loading
    case ready
    case failed
}

/// Skeleton placeholder shown while a screen reads its data.
struct MiyarLoadingList: View {
    var rows: Int = 4
    var height: CGFloat = 96

    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<rows, id: \.self) { _ in
                VStack(alignment: .leading, spacing: 10) {
                    SkeletonBlock(height: height, radius: Theme.tileRadius)
                    SkeletonBlock(height: 12, radius: 6)
                    SkeletonBlock(height: 12, radius: 6).padding(.trailing, 90)
                }
                .miyarCard(padding: 12)
            }
        }
        .accessibilityLabel(S.loadingContent(.en))
    }
}

/// Error state with a retry action, used whenever loading fails.
struct MiyarErrorState: View {
    @Environment(AppStore.self) private var store
    var message: String?
    let retry: () -> Void

    var body: some View {
        let language = store.language
        MiyarEmptyState(
            symbol: "exclamationmark.triangle",
            title: S.loadFailed(language),
            message: message ?? S.loadFailedHint(language),
            actionTitle: S.retry(language),
            action: retry
        )
    }
}

/// "Show more" footer that drives simple pagination.
struct LoadMoreFooter: View {
    @Environment(AppStore.self) private var store
    let remaining: Int
    let action: () -> Void

    var body: some View {
        let language = store.language
        Button(action: action) {
            HStack(spacing: 8) {
                Text(S.loadMore(language))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                Text("\(remaining)")
                    .font(.miyarMono(12, weight: .semibold))
                    .foregroundStyle(Theme.secondaryText)
            }
            .frame(maxWidth: .infinity, minHeight: 46)
            .background(Theme.surface, in: .capsule)
            .overlay(Capsule().strokeBorder(Theme.hairline, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Stored photos

/// Renders a photo saved by `ImageStore`, falling back to the bottle artwork.
struct StoredPhotoView: View {
    let photoID: String?
    var fallbackSeed: Int = 0
    var cornerRadius: CGFloat = Theme.tileRadius

    @State private var image: UIImage?
    @State private var didLoad = false

    var body: some View {
        Group {
            if let image {
                Color(.secondarySystemBackground)
                    .overlay {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .allowsHitTesting(false)
                    }
                    .clipShape(.rect(cornerRadius: cornerRadius))
            } else if photoID != nil && !didLoad {
                SkeletonBlock(height: 0, radius: cornerRadius)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                BottleArtwork(seed: fallbackSeed, cornerRadius: cornerRadius)
            }
        }
        .task(id: photoID) {
            guard let photoID else {
                image = nil
                didLoad = true
                return
            }
            let loaded = await Task.detached(priority: .userInitiated) {
                ImageStore.shared.image(for: photoID)
            }.value
            image = loaded
            didLoad = true
        }
    }
}

/// Swipeable gallery for a listing or post; shows artwork when there are no photos.
struct PhotoPager: View {
    let photoIDs: [String]
    var fallbackSeed: Int = 0
    var height: CGFloat = 240
    var cornerRadius: CGFloat = Theme.cardRadius

    @State private var index = 0

    var body: some View {
        Group {
            if photoIDs.isEmpty {
                BottleArtwork(seed: fallbackSeed, cornerRadius: cornerRadius)
                    .frame(height: height)
            } else {
                TabView(selection: $index) {
                    ForEach(Array(photoIDs.enumerated()), id: \.element) { position, id in
                        StoredPhotoView(photoID: id, fallbackSeed: fallbackSeed, cornerRadius: cornerRadius)
                            .tag(position)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: photoIDs.count > 1 ? .always : .never))
                .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                .frame(height: height)
                .clipShape(.rect(cornerRadius: cornerRadius))
            }
        }
    }
}

// MARK: - Picker

/// Multi-photo picker that stores images on device and returns their identifiers.
struct PhotoPickerStrip: View {
    @Environment(AppStore.self) private var store

    @Binding var photoIDs: [String]
    var limit: Int = 6
    var fallbackSeed: Int = 0

    @State private var selection: [PhotosPickerItem] = []
    @State private var isImporting = false
    @State private var failed = false

    private var language: AppLanguage { store.language }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(S.addPhotos(language)).miyarSectionHeader()
                Spacer(minLength: 6)
                Text("\(photoIDs.count)/\(limit) \(S.photosCount(language))")
                    .font(.miyarMono(11))
                    .foregroundStyle(Theme.secondaryText)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    PhotosPicker(
                        selection: $selection,
                        maxSelectionCount: max(1, limit - photoIDs.count),
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        VStack(spacing: 5) {
                            Image(systemName: isImporting ? "arrow.triangle.2.circlepath" : "plus")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Theme.gold)
                            Text(S.addPhotos(language))
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(Theme.secondaryText)
                        }
                        .frame(width: 84, height: 84)
                        .background(Theme.goldSoft, in: .rect(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Theme.gold.opacity(0.35), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                        )
                    }
                    .disabled(photoIDs.count >= limit || isImporting)
                    .opacity(photoIDs.count >= limit ? 0.5 : 1)

                    ForEach(photoIDs, id: \.self) { id in
                        StoredPhotoView(photoID: id, fallbackSeed: fallbackSeed, cornerRadius: 12)
                            .frame(width: 84, height: 84)
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    remove(id)
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(Theme.ink)
                                        .frame(width: 22, height: 22)
                                        .background(Circle().fill(Theme.surface.opacity(0.95)))
                                }
                                .buttonStyle(.plain)
                                .padding(5)
                                .accessibilityLabel(S.removePhoto(language))
                            }
                    }
                }
                .padding(.vertical, 2)
            }
            .scrollClipDisabled()

            if photoIDs.count >= limit {
                Text(S.photoLimitReached(language))
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.secondaryText)
            }
            if failed {
                MiyarBanner(text: S.photoFailed(language), tone: .error)
            }
        }
        .onChange(of: selection) { _, items in
            guard !items.isEmpty else { return }
            Task { await importPhotos(items) }
        }
    }

    private func importPhotos(_ items: [PhotosPickerItem]) async {
        isImporting = true
        failed = false
        var added: [String] = []
        for item in items where photoIDs.count + added.count < limit {
            do {
                guard let data = try await item.loadTransferable(type: Data.self) else {
                    failed = true
                    continue
                }
                let identifier = await Task.detached(priority: .userInitiated) {
                    ImageStore.shared.store(data: data)
                }.value
                if let identifier { added.append(identifier) } else { failed = true }
            } catch {
                failed = true
            }
        }
        photoIDs.append(contentsOf: added)
        selection = []
        isImporting = false
    }

    private func remove(_ id: String) {
        photoIDs.removeAll { $0 == id }
        ImageStore.shared.delete(id)
    }
}

/// Single-shot picker used by the chat composer.
struct ChatPhotoPicker: View {
    @Environment(AppStore.self) private var store
    let onPicked: (String) -> Void

    @State private var item: PhotosPickerItem?
    @State private var isImporting = false

    var body: some View {
        PhotosPicker(selection: $item, matching: .images, photoLibrary: .shared()) {
            Image(systemName: isImporting ? "arrow.triangle.2.circlepath" : "photo")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Theme.secondaryText)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Theme.surface))
                .overlay(Circle().strokeBorder(Theme.hairline, lineWidth: 1))
        }
        .disabled(isImporting)
        .accessibilityLabel(S.addPhoto(store.language))
        .onChange(of: item) { _, newValue in
            guard let newValue else { return }
            Task {
                isImporting = true
                defer { isImporting = false; item = nil }
                guard let data = try? await newValue.loadTransferable(type: Data.self) else { return }
                let identifier = await Task.detached(priority: .userInitiated) {
                    ImageStore.shared.store(data: data)
                }.value
                if let identifier { onPicked(identifier) }
            }
        }
    }
}
