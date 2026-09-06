import Foundation

nonisolated enum ListingCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case fullBottle
    case used
    case sample
    case decant
    case oil
    case rawMaterial
    case emptyBottle

    var id: String { rawValue }

    var label: LText {
        switch self {
        case .fullBottle: S.catFullBottle
        case .used: S.catUsed
        case .sample: S.catSample
        case .decant: S.catDecant
        case .oil: S.catOil
        case .rawMaterial: S.catRaw
        case .emptyBottle: S.catEmpty
        }
    }

    var symbol: String {
        switch self {
        case .fullBottle: "waterbottle"
        case .used: "clock.arrow.circlepath"
        case .sample: "eyedropper"
        case .decant: "testtube.2"
        case .oil: "drop"
        case .rawMaterial: "leaf"
        case .emptyBottle: "cube.transparent"
        }
    }
}

nonisolated enum ListingCondition: String, Codable, CaseIterable, Identifiable, Sendable {
    case new
    case likeNew
    case used
    case vintage

    var id: String { rawValue }

    var label: LText {
        switch self {
        case .new: S.condNew
        case .likeNew: S.condLikeNew
        case .used: S.condUsed
        case .vintage: S.condVintage
        }
    }
}

nonisolated enum ListingType: String, Codable, CaseIterable, Identifiable, Sendable {
    case sale
    case exchange
    case both

    var id: String { rawValue }

    var label: LText {
        switch self {
        case .sale: S.forSale
        case .exchange: S.forExchange
        case .both: S.both
        }
    }

    var allowsSale: Bool { self != .exchange }
    var allowsExchange: Bool { self != .sale }
}

nonisolated enum DeliveryOption: String, Codable, CaseIterable, Identifiable, Sendable {
    case shipping
    case meetup
    case authenticated

    var id: String { rawValue }

    var label: LText {
        switch self {
        case .shipping: S.delShipping
        case .meetup: S.delMeetup
        case .authenticated: S.delAuthenticated
        }
    }

    /// Additional fee in USD.
    var feeUSD: Double {
        switch self {
        case .shipping: 8
        case .meetup: 0
        case .authenticated: 12
        }
    }
}

/// A marketplace listing. Demo listings are generic; user listings are created in-app.
nonisolated struct Listing: Codable, Identifiable, Hashable, Sendable {
    var id: UUID = UUID()
    var titleAr: String
    var titleEn: String
    var category: ListingCategory
    var type: ListingType
    var condition: ListingCondition
    var sizeML: Double
    /// Remaining content as a percentage, 0–100.
    var remainingPercent: Double
    /// Asking price in USD; converted for display.
    var priceUSD: Double
    var locationAr: String
    var locationEn: String
    var deliveryOptions: [DeliveryOption]
    var descriptionAr: String
    var descriptionEn: String
    var sellerID: String
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    /// Seeded colour index driving the generated bottle artwork.
    var artworkSeed: Int = 0
    /// Locally captured photo identifiers (file names in the app's images folder).
    var photoIDs: [String] = []
    var isOwnedByCurrentUser: Bool = false

    func title(_ language: AppLanguage) -> String { language == .ar ? titleAr : titleEn }
    func location(_ language: AppLanguage) -> String { language == .ar ? locationAr : locationEn }
    func details(_ language: AppLanguage) -> String { language == .ar ? descriptionAr : descriptionEn }

    func matches(_ query: String) -> Bool {
        guard !query.isEmpty else { return true }
        return [titleAr, titleEn, descriptionAr, descriptionEn, locationAr, locationEn]
            .contains { $0.localizedStandardContains(query) }
    }
}

/// A perfume the user is looking for; matched against new listings.
nonisolated struct WantedAlert: Codable, Identifiable, Hashable, Sendable {
    var id: UUID = UUID()
    var keyword: String
    var category: ListingCategory?
    var maxPriceUSD: Double?
    var createdAt: Date = Date()
}

/// An item in the user's personal perfume collection, usable in exchange offers.
nonisolated struct CollectionItem: Codable, Identifiable, Hashable, Sendable {
    var id: UUID = UUID()
    var nameAr: String
    var nameEn: String
    var sizeML: Double
    var remainingPercent: Double
    var condition: ListingCondition
    var estimatedValueUSD: Double
    var artworkSeed: Int = 0
    var photoIDs: [String] = []
    /// Set when the owner published this bottle to the marketplace.
    var listedListingID: UUID?

    func name(_ language: AppLanguage) -> String { language == .ar ? nameAr : nameEn }
}
