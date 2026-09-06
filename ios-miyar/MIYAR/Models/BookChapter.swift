import Foundation

/// A chapter of the educational book "مصمم العطور".
nonisolated struct BookChapter: Codable, Identifiable, Hashable, Sendable {
    var id: Int
    var title: LText
    var subtitle: LText
    /// Body paragraphs in both languages.
    var paragraphs: [LText]
    var isPremium: Bool

    var estimatedMinutes: Int {
        let words = paragraphs.reduce(0) { $0 + $1.ar.split(separator: " ").count }
        return max(2, words / 90)
    }
}

/// Reading preferences persisted for the book reader.
nonisolated struct ReadingSettings: Codable, Hashable, Sendable {
    enum Mode: String, Codable, CaseIterable, Identifiable, Sendable {
        case day
        case sepia

        var id: String { rawValue }
        var label: LText { self == .day ? S.modeDay : S.modeSepia }
    }

    var fontSize: Double = 18
    var mode: Mode = .day
}
