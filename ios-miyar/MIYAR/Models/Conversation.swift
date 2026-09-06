import Foundation

/// A direct message between the current user and another member.
nonisolated struct ChatMessage: Codable, Identifiable, Hashable, Sendable {
    var id: UUID = UUID()
    var senderID: String
    var bodyAr: String
    var bodyEn: String
    var sentAt: Date
    /// Locally stored image file name, when the message is a photo.
    var photoID: String?
    /// Seeded artwork used for demo image messages.
    var artworkSeed: Int?
    /// Set once the other side has read the message.
    var readAt: Date?

    func body(_ language: AppLanguage) -> String { language == .ar ? bodyAr : bodyEn }

    var isImage: Bool { photoID != nil || artworkSeed != nil }
    var isRead: Bool { readAt != nil }
}

/// A private conversation thread with persistent history.
///
/// Only the two participants can see the thread. On device it lives in the
/// app's protected container; on the server the same shape is guarded by
/// Row Level Security so a row is readable only by its participants.
nonisolated struct Conversation: Codable, Identifiable, Hashable, Sendable {
    var id: UUID = UUID()
    var partnerID: String
    var messages: [ChatMessage] = []
    var isMuted: Bool = false
    var updatedAt: Date = Date()
    /// True while the other member is composing.
    var partnerIsTyping: Bool = false

    var lastMessage: ChatMessage? { messages.last }

    /// Messages received from the partner that the user has not opened yet.
    func unreadCount(currentUserID: String) -> Int {
        messages.filter { $0.senderID != currentUserID && !$0.isRead }.count
    }
}
