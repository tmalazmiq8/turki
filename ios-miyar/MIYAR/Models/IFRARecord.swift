import Foundation

/// Verified-only IFRA safety data for a single material.
///
/// The app NEVER invents a limit: when `maxConcentrationPercent` is `nil`
/// the UI must display "Official limit not verified".
nonisolated struct IFRARecord: Codable, Identifiable, Hashable, Sendable {
    enum Status: String, Codable, Sendable {
        case restricted
        case prohibited
        case specification
        case notListed
        case unverified

        var label: LText {
            switch self {
            case .restricted: S.ifraRestricted
            case .prohibited: S.ifraProhibited
            case .specification: S.ifraSpecified
            case .notListed: S.ifraNotListed
            case .unverified: S.ifraStatusUnverified
            }
        }
    }

    /// Matches `Material.id`.
    var id: String
    /// e.g. "IFRA 51st Amendment" — kept as text exactly as published.
    var amendment: String
    /// e.g. "Category 4 (fine fragrance)".
    var productCategory: LText
    var status: Status
    /// `nil` means no officially verified figure is available for this record.
    var maxConcentrationPercent: Double?
    var sourceURL: String
    var lastUpdated: Date
    /// Free-text note published alongside the record, if any.
    var note: LText?

    /// True only when an official figure has been verified and stored.
    var hasVerifiedLimit: Bool { maxConcentrationPercent != nil }
}

extension IFRARecord {
    /// A record placeholder for materials with no verified data at all.
    static func unverified(id: String) -> IFRARecord {
        IFRARecord(
            id: id,
            amendment: "—",
            productCategory: LText("غير محدد", "Not specified"),
            status: .unverified,
            maxConcentrationPercent: nil,
            sourceURL: IFRAInfo.officialURL,
            lastUpdated: Date(timeIntervalSince1970: 0),
            note: nil
        )
    }
}

nonisolated enum IFRAInfo {
    static let officialURL = "https://ifrafragrance.org/standards"
    static let officialHome = "https://ifrafragrance.org"
    /// IFRA's searchable Standards Library — lists every fragrance material with a published standard.
    static let materialsSearch = "https://ifrafragrance.org/standards-library"
}
