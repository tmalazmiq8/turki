import SwiftUI

/// Builds an exchange proposal from an item in the user's collection.
struct ExchangeOfferView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let listing: Listing

    @State private var selected: CollectionItem?
    @State private var message = ""
    @State private var delivery: DeliveryOption = .shipping
    @State private var error: LText?

    private var language: AppLanguage { store.language }
    private var currency: Currency { store.marketCurrency }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    theirItemCard
                    yourItemCard
                    if let selected { differenceCard(selected) }

                    VStack(alignment: .leading, spacing: 10) {
                        Text(S.delivery(language)).miyarSectionHeader()
                        HStack(spacing: 8) {
                            ForEach(listing.deliveryOptions) { option in
                                MiyarChip(title: option.label(language), isSelected: delivery == option) {
                                    delivery = option
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .miyarCard(padding: 16)

                    MiyarField(label: S.messageToSeller(language), text: $message, lineLimit: 3...6)

                    if let error {
                        MiyarBanner(text: error(language), tone: .error)
                    }

                    Button(S.submitOffer(language)) { submit() }
                        .buttonStyle(GoldButtonStyle())
                }
                .padding(Theme.margin)
                .padding(.bottom, 26)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Theme.canvas.ignoresSafeArea())
            .navigationTitle(S.exchangeOffer(language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(S.cancel(language)) { dismiss() }
                }
            }
        }
        .environment(\.layoutDirection, language.layoutDirection)
        .onAppear {
            if delivery != .shipping, let first = listing.deliveryOptions.first { delivery = first }
            if !listing.deliveryOptions.contains(delivery), let first = listing.deliveryOptions.first { delivery = first }
        }
    }

    private var theirItemCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(S.theirItem(language)).miyarSectionHeader()
            HStack(spacing: 12) {
                StoredPhotoView(photoID: listing.photoIDs.first, fallbackSeed: listing.artworkSeed, cornerRadius: 10)
                    .frame(width: 62, height: 62)
                VStack(alignment: .leading, spacing: 3) {
                    Text(listing.title(language))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Theme.ink)
                        .lineLimit(2)
                    Text(currency.formatUSD(listing.priceUSD, language: language))
                        .font(.miyarMono(13, weight: .medium))
                        .foregroundStyle(Theme.gold)
                }
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .miyarCard(padding: 16)
    }

    private var yourItemCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(S.selectYourItem(language)).miyarSectionHeader()
            if store.collection.isEmpty {
                Text(S.myCollection(language))
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.secondaryText)
                NavigationLink(value: AppRoute.collection) {
                    Text(S.addToCollection(language))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.gold)
                }
                .buttonStyle(.plain)
            } else {
                ForEach(store.collection) { item in
                    Button {
                        selected = item
                    } label: {
                        HStack(spacing: 12) {
                            StoredPhotoView(photoID: item.photoIDs.first, fallbackSeed: item.artworkSeed, cornerRadius: 10)
                                .frame(width: 52, height: 52)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.name(language))
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Theme.ink)
                                    .lineLimit(1)
                                Text("\(Int(item.sizeML)) \(S.milliliters(language)) · \(item.remainingPercent.percentText())")
                                    .font(.miyarMono(11))
                                    .foregroundStyle(Theme.secondaryText)
                            }
                            Spacer(minLength: 0)
                            Text(currency.formatUSD(item.estimatedValueUSD, language: language))
                                .font(.miyarMono(12))
                                .foregroundStyle(Theme.secondaryText)
                            Image(systemName: selected?.id == item.id ? "largecircle.fill.circle" : "circle")
                                .foregroundStyle(selected?.id == item.id ? Theme.gold : Theme.secondaryText)
                        }
                        .padding(10)
                        .background(Theme.canvas, in: .rect(cornerRadius: 12))
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .miyarCard(padding: 16)
    }

    private func differenceCard(_ item: CollectionItem) -> some View {
        let difference = item.estimatedValueUSD - listing.priceUSD
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(S.theirValue(language)).font(.system(size: 13)).foregroundStyle(Theme.secondaryText)
                Spacer()
                Text(currency.formatUSD(listing.priceUSD, language: language))
                    .font(.miyarMono(13)).foregroundStyle(Theme.ink)
            }
            HStack {
                Text(S.yourValue(language)).font(.system(size: 13)).foregroundStyle(Theme.secondaryText)
                Spacer()
                Text(currency.formatUSD(item.estimatedValueUSD, language: language))
                    .font(.miyarMono(13)).foregroundStyle(Theme.ink)
            }
            MiyarDivider()
            HStack {
                Text(S.difference(language)).font(.system(size: 14, weight: .medium)).foregroundStyle(Theme.ink)
                Spacer()
                Text(abs(difference) < 0.01
                     ? S.evenTrade(language)
                     : "\(currency.formatUSD(abs(difference), language: language)) \(difference > 0 ? S.inTheirFavor(language) : S.inYourFavor(language))")
                    .font(.miyarMono(13, weight: .medium))
                    .foregroundStyle(Theme.gold)
                    .multilineTextAlignment(.trailing)
            }
        }
        .miyarCard(padding: 16)
    }

    private func submit() {
        guard let selected else { error = S.errRequiredField; return }
        let offer = ExchangeOffer(
            listingID: listing.id,
            listingTitle: LText(listing.titleAr, listing.titleEn),
            listingValueUSD: listing.priceUSD,
            offeredItemID: selected.id,
            offeredItemName: LText(selected.nameAr, selected.nameEn),
            offeredItemValueUSD: selected.estimatedValueUSD,
            offeredItemArtworkSeed: selected.artworkSeed,
            offeredItemPhotoIDs: selected.photoIDs,
            message: Validation.sanitize(message, limit: 600),
            delivery: delivery,
            counterpartyID: listing.sellerID,
            isIncoming: false
        )
        store.submitOffer(offer)
        let conversationID = store.startConversation(with: listing.sellerID)
        store.sendMessage(
            language == .ar
                ? "عرض تبادل: \(selected.nameAr) مقابل \(listing.titleAr)"
                : "Exchange offer: \(selected.nameEn) for \(listing.titleEn)",
            in: conversationID
        )
        dismiss()
    }
}
