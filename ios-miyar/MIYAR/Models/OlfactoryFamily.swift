import Foundation

/// Olfactory families used across the library, glossary and community tags.
nonisolated enum OlfactoryFamily: String, Codable, CaseIterable, Identifiable, Sendable {
    case citrus
    case floral
    case woody
    case oriental
    case aromatic
    case chypre
    case fougere
    case gourmand
    case musk
    case animalic
    case green
    case aldehydic

    var id: String { rawValue }

    var label: LText {
        switch self {
        case .citrus: LText("حمضية", "Citrus")
        case .floral: LText("زهرية", "Floral")
        case .woody: LText("خشبية", "Woody")
        case .oriental: LText("شرقية", "Oriental")
        case .aromatic: LText("عطرية عشبية", "Aromatic")
        case .chypre: LText("شيبر", "Chypre")
        case .fougere: LText("فوجير", "Fougère")
        case .gourmand: LText("حلوة", "Gourmand")
        case .musk: LText("مسك", "Musk")
        case .animalic: LText("حيوانية", "Animalic")
        case .green: LText("خضراء", "Green")
        case .aldehydic: LText("ألدهيدية", "Aldehydic")
        }
    }

    var symbol: String {
        switch self {
        case .citrus: "circle.hexagongrid"
        case .floral: "camera.macro"
        case .woody: "tree"
        case .oriental: "flame"
        case .aromatic: "leaf"
        case .chypre: "drop.triangle"
        case .fougere: "fern"
        case .gourmand: "birthday.cake"
        case .musk: "cloud"
        case .animalic: "pawprint"
        case .green: "leaf.circle"
        case .aldehydic: "sparkles"
        }
    }
}
