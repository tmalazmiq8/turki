import Foundation

/// A perfumery raw material entry in the library.
nonisolated struct Material: Codable, Identifiable, Hashable, Sendable {
    var id: String
    var nameAr: String
    var nameEn: String
    var family: OlfactoryFamily
    var stage: NoteStage
    var origin: LText
    var character: LText
    var evaporation: LText
    var typicalUse: LText
    /// Material ids this one is traditionally paired with.
    var pairings: [String]
    /// Intensity from 1 (soft) to 3 (powerful).
    var intensity: Int
    /// Indicative cost per millilitre in USD, used as the calculator default.
    var pricePerMLUSD: Double
    /// Density used to convert millilitres into grams.
    var density: Double

    func name(_ language: AppLanguage) -> String {
        language == .ar ? nameAr : nameEn
    }

    /// Matches a free-text query against both languages and the family.
    func matches(_ query: String, language: AppLanguage) -> Bool {
        guard !query.isEmpty else { return true }
        let haystack = [nameAr, nameEn, family.label.ar, family.label.en, character.ar, character.en]
        return haystack.contains { $0.localizedStandardContains(query) }
    }
}
