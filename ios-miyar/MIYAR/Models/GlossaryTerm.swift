import Foundation

/// A perfumery term with accurate Arabic and English wording.
nonisolated struct GlossaryTerm: Codable, Identifiable, Hashable, Sendable {
    enum Category: String, Codable, CaseIterable, Identifiable, Sendable {
        case structure
        case materials
        case technique
        case families
        case business

        var id: String { rawValue }

        var label: LText {
            switch self {
            case .structure: LText("البنية", "Structure")
            case .materials: LText("المواد", "Materials")
            case .technique: LText("التقنية", "Technique")
            case .families: LText("العائلات", "Families")
            case .business: LText("السوق", "Business")
            }
        }
    }

    var id: String
    var termAr: String
    var termEn: String
    var definition: LText
    var example: LText
    var category: Category
    /// Ids of related terms.
    var related: [String]

    func term(_ language: AppLanguage) -> String {
        language == .ar ? termAr : termEn
    }

    func matches(_ query: String) -> Bool {
        guard !query.isEmpty else { return true }
        return [termAr, termEn, definition.ar, definition.en]
            .contains { $0.localizedStandardContains(query) }
    }
}
