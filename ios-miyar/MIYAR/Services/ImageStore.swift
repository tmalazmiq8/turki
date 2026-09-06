import UIKit

/// On-device photo storage for listings, posts, messages and profiles.
///
/// Images are written to the app's Application Support folder (protected by
/// the system data-protection class) and referenced everywhere by a short
/// identifier, so a photo can move to remote storage later without touching
/// any model or view.
nonisolated final class ImageStore: @unchecked Sendable {
    static let shared = ImageStore()

    private let cache = NSCache<NSString, UIImage>()
    private let maxDimension: CGFloat = 1600
    private let compression: CGFloat = 0.82

    private init() {
        cache.countLimit = 80
    }

    private var folderURL: URL? {
        guard let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        let folder = base.appendingPathComponent("images", isDirectory: true)
        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder
    }

    /// Only IDs this store minted itself (a bare UUID) are ever turned into a
    /// path — this keeps a tampered `photo_url` synced down from another
    /// account (e.g. containing "../") from resolving outside the images
    /// folder.
    private func url(for id: String) -> URL? {
        guard UUID(uuidString: id) != nil else { return nil }
        return folderURL?.appendingPathComponent(id).appendingPathExtension("jpg")
    }

    /// Downsizes and stores raw picker data.
    /// - Returns: the identifier to persist in the model, or `nil` on failure.
    func store(data: Data) -> String? {
        guard let image = UIImage(data: data) else { return nil }
        return store(image: image)
    }

    func store(image: UIImage) -> String? {
        let resized = downsample(image)
        guard let data = resized.jpegData(compressionQuality: compression) else { return nil }
        let id = UUID().uuidString
        guard let url = url(for: id) else { return nil }
        do {
            try data.write(to: url, options: [.atomic, .completeFileProtection])
            cache.setObject(resized, forKey: id as NSString)
            return id
        } catch {
            return nil
        }
    }

    /// Cached read; returns `nil` when the file is missing.
    func image(for id: String) -> UIImage? {
        if let cached = cache.object(forKey: id as NSString) { return cached }
        guard let url = url(for: id),
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else { return nil }
        cache.setObject(image, forKey: id as NSString)
        return image
    }

    func delete(_ id: String) {
        cache.removeObject(forKey: id as NSString)
        guard let url = url(for: id) else { return }
        try? FileManager.default.removeItem(at: url)
    }

    func delete(_ ids: [String]) {
        for id in ids { delete(id) }
    }

    private func downsample(_ image: UIImage) -> UIImage {
        let longest = max(image.size.width, image.size.height)
        guard longest > maxDimension else { return image }
        let scale = maxDimension / longest
        let target = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: target)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: target))
        }
    }
}
