import Foundation

/// One pairwise comparison experiment from the Jean Carles training method.
nonisolated struct JeanCarlesExperiment: Codable, Identifiable, Hashable, Sendable {
    var id: UUID = UUID()
    var stepNumber: Int
    var materialAID: String
    var materialBID: String
    var materialAName: LText
    var materialBName: LText
    /// Parts of A against parts of B, e.g. 9 : 1.
    var partsA: Int = 5
    var partsB: Int = 5
    /// All ratings are 1–5.
    var strength: Int = 3
    var character: Int = 3
    var evaporation: Int = 3
    var harmony: Int = 3
    /// Share of each material in perfumer's alcohol while it is evaluated, 1–100.
    var dilutionPercent: Double = 10
    var notes: String = ""
    /// Unfinished experiments stay in the list as drafts until the perfumer finishes them.
    var isComplete: Bool = false
    var date: Date = Date()
    var updatedAt: Date = Date()

    var ratioLabel: String { "\(partsA) : \(partsB)" }

    var averageRating: Double {
        Double(strength + character + evaporation + harmony) / 4
    }

    var dilutionLabel: String {
        dilutionPercent == dilutionPercent.rounded()
            ? "\(Int(dilutionPercent))%"
            : String(format: "%.1f%%", dilutionPercent)
    }

    // Decoded leniently so experiments saved by earlier versions keep working.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        stepNumber = try container.decodeIfPresent(Int.self, forKey: .stepNumber) ?? 1
        materialAID = try container.decode(String.self, forKey: .materialAID)
        materialBID = try container.decode(String.self, forKey: .materialBID)
        materialAName = try container.decode(LText.self, forKey: .materialAName)
        materialBName = try container.decode(LText.self, forKey: .materialBName)
        partsA = try container.decodeIfPresent(Int.self, forKey: .partsA) ?? 5
        partsB = try container.decodeIfPresent(Int.self, forKey: .partsB) ?? 5
        strength = try container.decodeIfPresent(Int.self, forKey: .strength) ?? 3
        character = try container.decodeIfPresent(Int.self, forKey: .character) ?? 3
        evaporation = try container.decodeIfPresent(Int.self, forKey: .evaporation) ?? 3
        harmony = try container.decodeIfPresent(Int.self, forKey: .harmony) ?? 3
        dilutionPercent = try container.decodeIfPresent(Double.self, forKey: .dilutionPercent) ?? 10
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        isComplete = try container.decodeIfPresent(Bool.self, forKey: .isComplete) ?? true
        date = try container.decodeIfPresent(Date.self, forKey: .date) ?? Date()
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? date
    }

    init(
        id: UUID = UUID(),
        stepNumber: Int,
        materialAID: String,
        materialBID: String,
        materialAName: LText,
        materialBName: LText,
        partsA: Int = 5,
        partsB: Int = 5,
        strength: Int = 3,
        character: Int = 3,
        evaporation: Int = 3,
        harmony: Int = 3,
        dilutionPercent: Double = 10,
        notes: String = "",
        isComplete: Bool = false,
        date: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.stepNumber = stepNumber
        self.materialAID = materialAID
        self.materialBID = materialBID
        self.materialAName = materialAName
        self.materialBName = materialBName
        self.partsA = partsA
        self.partsB = partsB
        self.strength = strength
        self.character = character
        self.evaporation = evaporation
        self.harmony = harmony
        self.dilutionPercent = dilutionPercent
        self.notes = notes
        self.isComplete = isComplete
        self.date = date
        self.updatedAt = updatedAt
    }
}

/// A single training step in the Jean Carles curriculum.
nonisolated struct JeanCarlesStep: Identifiable, Hashable, Sendable {
    let id: Int
    let title: LText
    let summary: LText
    let instructions: [LText]
}
