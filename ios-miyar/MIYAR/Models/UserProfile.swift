import Foundation

/// A community member — either the signed-in user or another member.
nonisolated struct UserProfile: Codable, Identifiable, Hashable, Sendable {
    var id: String
    var nameAr: String
    var nameEn: String
    var bioAr: String
    var bioEn: String
    var locationAr: String
    var locationEn: String
    var email: String = ""
    var phone: String = ""
    var isVerified: Bool = false
    var rating: Double = 0
    var salesCount: Int = 0
    var followerCount: Int = 0
    /// Index into the avatar gradient palette.
    var avatarSeed: Int = 0
    /// Local file name of a chosen profile photo.
    var photoID: String?
    var showProfilePublicly: Bool = true
    var allowDirectMessages: Bool = true
    var isEmailVerified: Bool = false

    func name(_ language: AppLanguage) -> String { language == .ar ? nameAr : nameEn }
    func bio(_ language: AppLanguage) -> String { language == .ar ? bioAr : bioEn }
    func location(_ language: AppLanguage) -> String { language == .ar ? locationAr : locationEn }

    var initials: String {
        let source = nameEn.isEmpty ? nameAr : nameEn
        return String(source.prefix(1)).uppercased()
    }
}

/// A signed-in device session shown in the security screen.
nonisolated struct DeviceSession: Codable, Identifiable, Hashable, Sendable {
    var id: UUID = UUID()
    var deviceName: String
    var locationAr: String
    var locationEn: String
    var lastActive: Date
    var isCurrent: Bool

    func location(_ language: AppLanguage) -> String { language == .ar ? locationAr : locationEn }
}

/// An in-app notification entry.
nonisolated struct AppNotification: Codable, Identifiable, Hashable, Sendable {
    enum Kind: String, Codable, Sendable {
        case market
        case community
        case exchange
        case system

        var symbol: String {
            switch self {
            case .market: "bag"
            case .community: "bubble.left"
            case .exchange: "arrow.left.arrow.right"
            case .system: "bell"
            }
        }
    }

    var id: UUID = UUID()
    var kind: Kind
    var title: LText
    var body: LText
    var date: Date
    var isRead: Bool = false
}
