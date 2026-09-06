import SwiftUI

/// The two supported interface languages. Arabic is the default and drives RTL layout.
enum AppLanguage: String, CaseIterable, Codable, Sendable {
    case ar
    case en

    var layoutDirection: LayoutDirection { self == .ar ? .rightToLeft : .leftToRight }
    var localeIdentifier: String { self == .ar ? "ar" : "en" }
    var shortLabel: String { self == .ar ? "عربي" : "EN" }
    var displayName: String { self == .ar ? "العربية" : "English" }
}

/// A single piece of copy in both languages.
nonisolated struct LText: Sendable, Hashable, Codable {
    let ar: String
    let en: String

    init(_ ar: String, _ en: String) {
        self.ar = ar
        self.en = en
    }

    func callAsFunction(_ language: AppLanguage) -> String {
        language == .ar ? ar : en
    }
}
