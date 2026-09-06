import Foundation

/// Standard perfume concentrations with their conventional oil percentage.
nonisolated enum Concentration: String, Codable, CaseIterable, Identifiable, Sendable {
    case parfum
    case edp
    case edt
    case edc
    case custom

    var id: String { rawValue }

    var label: LText {
        switch self {
        case .parfum: S.concParfum
        case .edp: S.concEDP
        case .edt: S.concEDT
        case .edc: S.concEDC
        case .custom: S.concCustom
        }
    }

    var shortLabel: LText {
        switch self {
        case .parfum: LText("باروفان", "Parfum")
        case .edp: LText("EDP", "EDP")
        case .edt: LText("EDT", "EDT")
        case .edc: LText("EDC", "EDC")
        case .custom: LText("مخصص", "Custom")
        }
    }

    /// Default oil share of the finished bottle.
    var defaultPercent: Double {
        switch self {
        case .parfum: 25
        case .edp: 18
        case .edt: 10
        case .edc: 4
        case .custom: 15
        }
    }
}
