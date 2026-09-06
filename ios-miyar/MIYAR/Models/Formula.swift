import Foundation

/// One material line inside a formula.
nonisolated struct FormulaIngredient: Codable, Identifiable, Hashable, Sendable {
    var id: UUID = UUID()
    var materialID: String
    var nameAr: String
    var nameEn: String
    var stage: NoteStage
    /// Share of the oil blend, 0–100.
    var percent: Double
    /// Price per millilitre in USD.
    var pricePerMLUSD: Double
    var density: Double

    func name(_ language: AppLanguage) -> String {
        language == .ar ? nameAr : nameEn
    }
}

/// A saved perfume formula with its bottle parameters and cost inputs.
nonisolated struct Formula: Codable, Identifiable, Hashable, Sendable {
    var id: UUID = UUID()
    var name: String
    var bottleSizeML: Double = 50
    var concentration: Concentration = .edp
    /// Oil share of the finished bottle, 0–100.
    var oilPercent: Double = 18
    var currency: Currency = .sar
    var ingredients: [FormulaIngredient] = []
    /// Cost of the empty bottle and packaging in USD.
    var packagingCostUSD: Double = 1.5
    /// Cost of perfumer's alcohol per millilitre in USD.
    var alcoholPricePerMLUSD: Double = 0.04
    var dropsPerML: Double = 20
    var notes: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    // MARK: - Derived quantities

    var totalPercent: Double { ingredients.reduce(0) { $0 + $1.percent } }

    var percentIsValid: Bool { abs(totalPercent - 100) < 0.05 }

    var oilVolumeML: Double { bottleSizeML * oilPercent / 100 }

    var alcoholVolumeML: Double { max(0, bottleSizeML - oilVolumeML) }

    func volumeML(for ingredient: FormulaIngredient) -> Double {
        oilVolumeML * ingredient.percent / 100
    }

    func drops(for ingredient: FormulaIngredient) -> Double {
        volumeML(for: ingredient) * dropsPerML
    }

    func grams(for ingredient: FormulaIngredient) -> Double {
        volumeML(for: ingredient) * ingredient.density
    }

    func costUSD(for ingredient: FormulaIngredient) -> Double {
        volumeML(for: ingredient) * ingredient.pricePerMLUSD
    }

    var ingredientCostUSD: Double {
        ingredients.reduce(0) { $0 + costUSD(for: $1) }
    }

    var alcoholCostUSD: Double { alcoholVolumeML * alcoholPricePerMLUSD }

    var totalCostUSD: Double { ingredientCostUSD + alcoholCostUSD + packagingCostUSD }

    var costPerMLUSD: Double { bottleSizeML > 0 ? totalCostUSD / bottleSizeML : 0 }

    func ingredients(in stage: NoteStage) -> [FormulaIngredient] {
        ingredients.filter { $0.stage == stage }
    }

    func percent(in stage: NoteStage) -> Double {
        ingredients(in: stage).reduce(0) { $0 + $1.percent }
    }

    /// A 0–1 balance score: how close each stage sits to its recommended range,
    /// combined with how close the total is to 100%.
    var balanceScore: Double {
        guard !ingredients.isEmpty else { return 0 }
        let stageScores = NoteStage.allCases.map { stage -> Double in
            let value = percent(in: stage)
            let range = stage.recommendedRange
            if range.contains(value) { return 1 }
            let distance = value < range.lowerBound
                ? range.lowerBound - value
                : value - range.upperBound
            return max(0, 1 - distance / 30)
        }
        let stageAverage = stageScores.reduce(0, +) / Double(stageScores.count)
        let totalPenalty = min(1, abs(totalPercent - 100) / 50)
        return max(0, min(1, stageAverage * (1 - totalPenalty * 0.5)))
    }

    /// Plain-text export used by the share sheet.
    func exportText(language: AppLanguage) -> String {
        var lines: [String] = []
        lines.append("\(S.appName(language)) — \(name)")
        lines.append("\(S.bottleSize(language)): \(Int(bottleSizeML)) \(S.milliliters(language))")
        lines.append("\(S.concentration(language)): \(concentration.shortLabel(language)) — \(String(format: "%.1f", oilPercent))%")
        lines.append("")
        for stage in NoteStage.allCases {
            let items = ingredients(in: stage)
            guard !items.isEmpty else { continue }
            lines.append("— \(stage.label(language)) —")
            for item in items {
                let ml = String(format: "%.2f", volumeML(for: item))
                let g = String(format: "%.2f", grams(for: item))
                let d = String(format: "%.0f", drops(for: item))
                lines.append("\(item.name(language)): \(String(format: "%.1f", item.percent))% · \(ml) \(S.milliliters(language)) · \(g) \(S.grams(language)) · \(d) \(S.drops(language))")
            }
            lines.append("")
        }
        lines.append("\(S.alcohol(language)): \(String(format: "%.2f", alcoholVolumeML)) \(S.milliliters(language))")
        lines.append("\(S.totalCost(language)): \(currency.formatUSD(totalCostUSD, language: language))")
        lines.append("")
        lines.append(S.ifraNoAutoCompliance(language))
        return lines.joined(separator: "\n")
    }
}
