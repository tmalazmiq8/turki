import SwiftUI

/// The three stages of a fragrance pyramid.
nonisolated enum NoteStage: String, Codable, CaseIterable, Identifiable, Sendable {
    case top
    case heart
    case base

    var id: String { rawValue }

    var label: LText {
        switch self {
        case .top: S.topNotes
        case .heart: S.heartNotes
        case .base: S.baseNotes
        }
    }

    var symbol: String {
        switch self {
        case .top: "sun.max"
        case .heart: "heart"
        case .base: "mountain.2"
        }
    }

    /// Recommended share of the oil blend, used for balance scoring.
    var recommendedRange: ClosedRange<Double> {
        switch self {
        case .top: 15...30
        case .heart: 30...50
        case .base: 25...50
        }
    }
}
