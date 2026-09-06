import Foundation
import CryptoKit
import Security

/// Generates and retrieves the symmetric key that encrypts the on-device
/// snapshot, storing it in the iOS Keychain rather than in a file or
/// UserDefaults. The Keychain entry is device-only (no iCloud sync) and
/// protected so it's only readable after the device has been unlocked once
/// since boot, which keeps the key out of unencrypted backups of the app's
/// sandbox.
private nonisolated enum SnapshotKeyStore {
    private static let account = "miyar.snapshot.key"
    private static let service = "com.miyar.app.storage"

    static func key() -> SymmetricKey {
        if let existing = read() { return existing }
        let fresh = SymmetricKey(size: .bits256)
        save(fresh)
        return fresh
    }

    private static func query(extra: [String: Any] = [:]) -> [String: Any] {
        var base: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        for (k, v) in extra { base[k] = v }
        return base
    }

    private static func read() -> SymmetricKey? {
        var result: AnyObject?
        let status = SecItemCopyMatching(query(extra: [
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]) as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return SymmetricKey(data: data)
    }

    private static func save(_ key: SymmetricKey) {
        let data = key.withUnsafeBytes { Data($0) }
        SecItemDelete(query() as CFDictionary)
        var addQuery = query()
        addQuery[kSecValueData as String] = data
        addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        SecItemAdd(addQuery as CFDictionary, nil)
    }
}

/// Everything the app keeps on device between launches.
nonisolated struct AppSnapshot: Codable, Sendable {
    var language: AppLanguage = .ar
    /// A local, offline-friendly copy of the signed-in user's profile. The
    /// source of truth is the `profiles` table in Supabase; this only lets
    /// the UI show something immediately on launch before the network
    /// round-trip finishes (or while offline).
    var cachedProfile: UserProfile?
    var formulas: [Formula] = []
    var currentFormulaID: UUID?

    var savedMaterialIDs: [String] = []
    var materialNotes: [String: String] = [:]

    var experiments: [JeanCarlesExperiment] = []
    var completedSteps: [Int] = []

    var glossaryBookmarks: [String] = []

    var reading = ReadingSettings()
    var chapterProgress: [String: Double] = [:]
    var bookmarkedChapters: [Int] = []
    var lastChapterID: Int?

    var listings: [Listing] = []
    var marketCurrency: Currency = .sar
    var favoriteListingIDs: [UUID] = []
    var wanted: [WantedAlert] = []
    var collection: [CollectionItem] = []
    var offers: [ExchangeOffer] = []

    var posts: [Post] = []
    var savedPostIDs: [UUID] = []
    var followingIDs: [String] = []
    var blockedIDs: [String] = []

    var conversations: [Conversation] = []

    var aiConversations: [AIConversation] = []
    var aiUsage = AIUsage()
    var savedAIResponses: [String] = []

    var notifications: [AppNotification] = []
    var sessions: [DeviceSession] = []

    var ifraOverrides: [String: IFRARecord] = [:]
    var ifraLastSync: Date?

    var didSeed = false
}

nonisolated enum PersistenceError: Error {
    case unavailable
}

/// Reads and writes the snapshot as JSON inside the app's Application Support folder.
nonisolated enum Persistence {
    private static let fileName = "miyar-state.json"

    private static var fileURL: URL? {
        guard let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        if !FileManager.default.fileExists(atPath: base.path) {
            try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        }
        return base.appendingPathComponent(fileName)
    }

    /// Decrypts a file's contents with the Keychain-backed key. Returns nil
    /// on any failure (missing file, wrong key, corrupted data) so callers
    /// can fall back to a fresh snapshot instead of crashing.
    private static func decryptedData(at url: URL) -> Data? {
        guard let sealed = try? Data(contentsOf: url) else { return nil }
        guard let box = try? AES.GCM.SealedBox(combined: sealed) else { return nil }
        return try? AES.GCM.open(box, using: SnapshotKeyStore.key())
    }

    static func load() -> AppSnapshot {
        guard let url = fileURL, let data = decryptedData(at: url) else { return AppSnapshot() }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode(AppSnapshot.self, from: data)
        } catch {
            // A schema change should never trap the user in a broken state.
            return AppSnapshot()
        }
    }

    /// Strict read used by pull-to-refresh so a real failure can surface a retry.
    static func loadThrowing() throws -> AppSnapshot {
        guard let url = fileURL else { throw PersistenceError.unavailable }
        guard let data = decryptedData(at: url) else { throw PersistenceError.unavailable }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(AppSnapshot.self, from: data)
    }

    static func write(_ snapshot: AppSnapshot) {
        guard let url = fileURL else { return }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(snapshot) else { return }
        guard let sealed = try? AES.GCM.seal(data, using: SnapshotKeyStore.key()) else { return }
        guard let combined = sealed.combined else { return }
        try? combined.write(to: url, options: .atomic)
        try? FileManager.default.setAttributes([.protectionKey: FileProtectionType.completeUnlessOpen], ofItemAtPath: url.path)
    }

    static func reset() {
        guard let url = fileURL else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
