import Foundation

/// Bundled IFRA records.
///
/// IMPORTANT: no numeric limit is ever invented here. Records ship with
/// `maxConcentrationPercent == nil`, which the UI renders as
/// "Official limit not verified". Verified figures are supplied later by the
/// server (see `IFRAService`) or entered by an administrator, never guessed.
nonisolated enum SeedIFRA {
    /// Materials that are widely documented as being covered by an IFRA standard.
    /// The *existence* of a standard is recorded; the *value* is left unverified.
    private static let restrictedIDs: Set<String> = [
        "oakmoss", "coumarin", "cinnamon", "citral", "lemon", "bergamot", "galbanum", "ylang", "rose", "jasmine"
    ]

    static func defaults(for materials: [Material]) -> [String: IFRARecord] {
        var records: [String: IFRARecord] = [:]
        for material in materials {
            let isRestricted = restrictedIDs.contains(material.id)
            records[material.id] = IFRARecord(
                id: material.id,
                amendment: isRestricted ? "IFRA Standards — latest amendment" : "—",
                productCategory: isRestricted
                    ? LText("يُرجى تحديد الفئة من المعيار الرسمي", "Determine the category from the official standard")
                    : LText("غير محدد", "Not specified"),
                status: isRestricted ? .restricted : .unverified,
                maxConcentrationPercent: nil,
                sourceURL: IFRAInfo.officialURL,
                lastUpdated: Date(timeIntervalSince1970: 0),
                note: isRestricted
                    ? LText(
                        "هذه المادة مشمولة بمعيار IFRA. لم يتم التحقق من الرقم الرسمي داخل التطبيق — راجع أحدث معيار وشهادة المورد.",
                        "This material is covered by an IFRA standard. The official figure has not been verified in-app — check the latest standard and the supplier's certificate."
                      )
                    : nil
            )
        }
        return records
    }
}
