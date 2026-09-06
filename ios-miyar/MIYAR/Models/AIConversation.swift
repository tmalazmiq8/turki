import Foundation

/// One turn in an assistant conversation.
nonisolated struct AIMessage: Codable, Identifiable, Hashable, Sendable {
    enum Role: String, Codable, Sendable {
        case user
        case assistant
    }

    var id: UUID = UUID()
    var role: Role
    var text: String
    var createdAt: Date = Date()
    /// True when the user attached formula context to this turn.
    var hasFormulaContext: Bool = false
    var isReported: Bool = false
}

/// A stored assistant conversation with its own title.
nonisolated struct AIConversation: Codable, Identifiable, Hashable, Sendable {
    var id: UUID = UUID()
    var title: String
    var messages: [AIMessage] = []
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}

/// Tracks the assistant's daily question allowance.
nonisolated struct AIUsage: Codable, Hashable, Sendable {
    var day: Date = Calendar.current.startOfDay(for: Date())
    var count: Int = 0

    static let dailyLimit = 25

    var remaining: Int { max(0, Self.dailyLimit - count) }

    /// Resets the counter when the calendar day changes.
    mutating func rollIfNeeded(now: Date = Date()) {
        let today = Calendar.current.startOfDay(for: now)
        if today != day {
            day = today
            count = 0
        }
    }
}
