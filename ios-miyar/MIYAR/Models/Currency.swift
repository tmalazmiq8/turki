import Foundation

/// Currencies supported by the calculator and the marketplace.
nonisolated enum Currency: String, Codable, CaseIterable, Identifiable, Sendable {
    case kwd = "KWD"
    case sar = "SAR"
    case aed = "AED"
    case qar = "QAR"
    case bhd = "BHD"
    case omr = "OMR"
    case usd = "USD"

    var id: String { rawValue }

    var label: LText {
        switch self {
        case .kwd: LText("دينار كويتي", "Kuwaiti dinar")
        case .sar: LText("ريال سعودي", "Saudi riyal")
        case .aed: LText("درهم إماراتي", "UAE dirham")
        case .qar: LText("ريال قطري", "Qatari riyal")
        case .bhd: LText("دينار بحريني", "Bahraini dinar")
        case .omr: LText("ريال عماني", "Omani rial")
        case .usd: LText("دولار أمريكي", "US dollar")
        }
    }

    var symbol: LText {
        switch self {
        case .kwd: LText("د.ك", "KWD")
        case .sar: LText("ر.س", "SAR")
        case .aed: LText("د.إ", "AED")
        case .qar: LText("ر.ق", "QAR")
        case .bhd: LText("د.ب", "BHD")
        case .omr: LText("ر.ع", "OMR")
        case .usd: LText("$", "$")
        }
    }

    /// Indicative units of this currency per 1 USD. Pegged Gulf rates are stable;
    /// these are display defaults and can be refreshed from the server later.
    var perUSD: Double {
        switch self {
        case .kwd: 0.307
        case .sar: 3.75
        case .aed: 3.6725
        case .qar: 3.64
        case .bhd: 0.376
        case .omr: 0.3845
        case .usd: 1.0
        }
    }

    /// Decimal places conventionally used (three for the Gulf dinar/rial family).
    var fractionDigits: Int {
        switch self {
        case .kwd, .bhd, .omr: 3
        default: 2
        }
    }

    func fromUSD(_ usd: Double) -> Double { usd * perUSD }
    func toUSD(_ amount: Double) -> Double { amount / perUSD }

    /// Formats an amount already expressed in this currency.
    func format(_ amount: Double, language: AppLanguage) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        formatter.locale = Locale(identifier: language == .ar ? "ar" : "en_US")
        let number = formatter.string(from: NSNumber(value: amount)) ?? "0"
        return "\(number) \(symbol(language))"
    }

    /// Formats a USD figure converted into this currency.
    func formatUSD(_ usd: Double, language: AppLanguage) -> String {
        format(fromUSD(usd), language: language)
    }
}
