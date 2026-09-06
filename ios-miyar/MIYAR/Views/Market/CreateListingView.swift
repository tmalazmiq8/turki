import SwiftUI

/// Publishes a new listing, edits an existing one, or offers a bottle from the
/// personal collection for sale or exchange.
struct CreateListingView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    /// Set when editing a published listing.
    var editing: Listing?
    /// Set when the listing is created from a collection bottle.
    var collectionItem: CollectionItem?

    @State private var titleAr = ""
    @State private var titleEn = ""
    @State private var category: ListingCategory = .fullBottle
    @State private var type: ListingType = .sale
    @State private var condition: ListingCondition = .new
    @State private var sizeText = "50"
    @State private var remaining: Double = 100
    @State private var priceText = ""
    @State private var currency: Currency = .sar
    @State private var location = ""
    @State private var delivery: Set<DeliveryOption> = [.shipping]
    @State private var details = ""
    @State private var artworkSeed = Int.random(in: 0..<5)
    @State private var photoIDs: [String] = []
    @State private var error: LText?
    @State private var didPrepare = false

    private var language: AppLanguage { store.language }

    private var isEditing: Bool { editing != nil }

    private var screenTitle: String {
        if isEditing { return S.editListing(language) }
        if collectionItem != nil { return S.sellOrExchangeItem(language) }
        return S.newListing(language)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    photoCard
                    MiyarField(label: "\(S.productName(language)) — عربي", text: $titleAr)
                    MiyarField(label: "\(S.productName(language)) — EN", text: $titleEn)

                    pickerCard(S.category(language)) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 108), spacing: 8)], spacing: 8) {
                            ForEach(ListingCategory.allCases) { option in
                                MiyarChip(title: option.label(language), isSelected: category == option) {
                                    category = option
                                }
                            }
                        }
                    }

                    pickerCard(S.listingType(language)) {
                        HStack(spacing: 8) {
                            ForEach(ListingType.allCases) { option in
                                MiyarChip(title: option.label(language), isSelected: type == option) { type = option }
                            }
                        }
                    }

                    pickerCard(S.condition(language)) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                            ForEach(ListingCondition.allCases) { option in
                                MiyarChip(title: option.label(language), isSelected: condition == option) { condition = option }
                            }
                        }
                    }

                    HStack(spacing: 12) {
                        MiyarField(label: "\(S.size(language)) (\(S.milliliters(language)))", text: $sizeText, keyboard: .decimalPad)
                        MiyarField(label: S.price(language), text: $priceText, keyboard: .decimalPad)
                    }

                    pickerCard(S.currency(language)) {
                        Picker(S.currency(language), selection: $currency) {
                            ForEach(Currency.allCases) { option in
                                Text("\(option.symbol(language)) — \(option.label(language))").tag(option)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(Theme.gold)
                    }

                    pickerCard("\(S.remaining(language)) — \(remaining.percentText())") {
                        Slider(value: $remaining, in: 0...100, step: 5).tint(Theme.gold)
                    }

                    MiyarField(label: S.location(language), text: $location)

                    pickerCard(S.delivery(language)) {
                        VStack(spacing: 8) {
                            ForEach(DeliveryOption.allCases) { option in
                                Button {
                                    if delivery.contains(option) { delivery.remove(option) } else { delivery.insert(option) }
                                } label: {
                                    HStack {
                                        Image(systemName: delivery.contains(option) ? "checkmark.square.fill" : "square")
                                            .foregroundStyle(delivery.contains(option) ? Theme.gold : Theme.secondaryText)
                                        Text(option.label(language))
                                            .font(.system(size: 14))
                                            .foregroundStyle(Theme.ink)
                                        Spacer(minLength: 0)
                                    }
                                    .contentShape(.rect)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    MiyarField(label: S.description(language), text: $details, lineLimit: 4...8)

                    if let error {
                        MiyarBanner(text: error(language), tone: .error)
                    }

                    Button(isEditing ? S.saveListing(language) : S.publishListing(language)) { submit() }
                        .buttonStyle(GoldButtonStyle())

                    Text(S.guidelinesReminder(language))
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.secondaryText)
                }
                .padding(Theme.margin)
                .padding(.bottom, 26)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Theme.canvas.ignoresSafeArea())
            .navigationTitle(screenTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(S.cancel(language)) { dismiss() }
                }
            }
        }
        .environment(\.layoutDirection, language.layoutDirection)
        .onAppear(perform: prepare)
    }

    /// Fills the form from the edited listing or the chosen collection bottle.
    private func prepare() {
        guard !didPrepare else { return }
        didPrepare = true
        currency = store.marketCurrency

        if let editing {
            titleAr = editing.titleAr
            titleEn = editing.titleEn
            category = editing.category
            type = editing.type
            condition = editing.condition
            sizeText = String(format: "%g", editing.sizeML)
            remaining = editing.remainingPercent
            priceText = editing.priceUSD > 0
                ? String(format: "%.\(currency.fractionDigits)f", currency.fromUSD(editing.priceUSD))
                : ""
            location = editing.locationAr
            delivery = Set(editing.deliveryOptions)
            details = editing.descriptionAr
            artworkSeed = editing.artworkSeed
            photoIDs = editing.photoIDs
            return
        }

        if let collectionItem {
            titleAr = collectionItem.nameAr
            titleEn = collectionItem.nameEn
            category = collectionItem.remainingPercent < 100 ? .used : .fullBottle
            type = .both
            condition = collectionItem.condition
            sizeText = String(format: "%g", collectionItem.sizeML)
            remaining = collectionItem.remainingPercent
            if collectionItem.estimatedValueUSD > 0 {
                priceText = String(format: "%.\(currency.fractionDigits)f", currency.fromUSD(collectionItem.estimatedValueUSD))
            }
            location = store.currentUser?.locationAr ?? ""
            artworkSeed = collectionItem.artworkSeed
            photoIDs = collectionItem.photoIDs
        } else {
            location = store.currentUser?.locationAr ?? ""
        }
    }

    private var photoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            PhotoPickerStrip(photoIDs: $photoIDs, fallbackSeed: artworkSeed)

            if photoIDs.isEmpty {
                BottleArtwork(seed: artworkSeed)
                    .frame(height: 130)
                HStack(spacing: 8) {
                    ForEach(0..<5, id: \.self) { seed in
                        Button {
                            artworkSeed = seed
                        } label: {
                            BottleArtwork(seed: seed, cornerRadius: 8)
                                .frame(width: 46, height: 46)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(artworkSeed == seed ? Theme.gold : Theme.hairline, lineWidth: artworkSeed == seed ? 2 : 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(S.addPhoto(language)) \(seed + 1)")
                    }
                }
            } else {
                PhotoPager(photoIDs: photoIDs, fallbackSeed: artworkSeed, height: 190)
            }

            Text(S.photosHint(language))
                .font(.system(size: 11))
                .foregroundStyle(Theme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .miyarCard(padding: 16)
    }

    private func pickerCard<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).miyarSectionHeader()
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .miyarCard(padding: 16)
    }

    private func submit() {
        let ar = Validation.sanitize(titleAr, limit: 90)
        let en = Validation.sanitize(titleEn.isEmpty ? titleAr : titleEn, limit: 90)
        guard !ar.isEmpty else { error = S.errRequiredField; return }
        guard let size = Double(sizeText.replacingOccurrences(of: ",", with: ".")), size > 0 else {
            error = S.errRequiredField
            return
        }
        let enteredPrice = Double(priceText.replacingOccurrences(of: ",", with: ".")) ?? 0
        if type != .exchange && enteredPrice <= 0 {
            error = S.errRequiredField
            return
        }
        guard !delivery.isEmpty else { error = S.errRequiredField; return }

        var listing = Listing(
            titleAr: ar,
            titleEn: en,
            category: category,
            type: type,
            condition: condition,
            sizeML: size,
            remainingPercent: remaining,
            priceUSD: currency.toUSD(enteredPrice),
            locationAr: Validation.sanitize(location, limit: 80),
            locationEn: Validation.sanitize(location, limit: 80),
            deliveryOptions: DeliveryOption.allCases.filter { delivery.contains($0) },
            descriptionAr: Validation.sanitize(details, limit: 1200),
            descriptionEn: Validation.sanitize(details, limit: 1200),
            sellerID: SeedPeople.currentUserID,
            artworkSeed: artworkSeed,
            photoIDs: photoIDs
        )

        if let editing {
            listing.id = editing.id
            listing.createdAt = editing.createdAt
            store.updateListing(listing)
        } else if let collectionItem {
            store.listCollectionItem(collectionItem.id, as: listing)
        } else {
            store.publish(listing)
        }
        dismiss()
    }
}
