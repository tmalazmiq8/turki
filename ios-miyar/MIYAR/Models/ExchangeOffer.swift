import Foundation

/// One entry in an offer's status history.
nonisolated struct OfferEvent: Codable, Identifiable, Hashable, Sendable {
    var id: UUID = UUID()
    var status: ExchangeOffer.Status
    var note: String = ""
    /// True when the signed-in member performed the action.
    var byCurrentUser: Bool
    var date: Date = Date()
}

/// An exchange proposal made against a marketplace listing.
nonisolated struct ExchangeOffer: Codable, Identifiable, Hashable, Sendable {
    enum Status: String, Codable, Sendable {
        case pending
        case accepted
        case rejected
        case negotiating

        var label: LText {
            switch self {
            case .pending: S.offerPending
            case .accepted: S.offerAccepted
            case .rejected: S.offerRejected
            case .negotiating: S.offerNegotiating
            }
        }

        var symbol: String {
            switch self {
            case .pending: "clock"
            case .accepted: "checkmark.circle"
            case .rejected: "xmark.circle"
            case .negotiating: "bubble.left.and.bubble.right"
            }
        }

        /// Offers in these states can still be answered.
        var isOpen: Bool { self == .pending || self == .negotiating }
    }

    var id: UUID = UUID()
    var listingID: UUID
    var listingTitle: LText
    var listingValueUSD: Double
    var offeredItemID: UUID
    var offeredItemName: LText
    var offeredItemValueUSD: Double
    var offeredItemArtworkSeed: Int
    var offeredItemPhotoIDs: [String] = []
    var message: String
    var delivery: DeliveryOption
    var status: Status = .pending
    var createdAt: Date = Date()
    /// The other side of the trade.
    var counterpartyID: String = ""
    /// True when another member sent this offer to the signed-in user.
    var isIncoming: Bool = false
    /// Appended when either side negotiates.
    var negotiationNotes: [String] = []
    /// Full audit trail: every status change with its note and timestamp.
    var history: [OfferEvent] = []

    /// Positive when the offered item is worth more than the listing.
    var differenceUSD: Double { offeredItemValueUSD - listingValueUSD }

    /// Only the receiving side may accept, reject or negotiate.
    var canRespond: Bool { isIncoming && status.isOpen }
}
