import SwiftUI

/// Product page: photos, facts, seller, and buy / exchange / contact actions.
struct ListingDetailView: View {
    @Environment(AppStore.self) private var store
    let listingID: UUID

    @State private var showExchange = false
    @State private var showEdit = false
    @State private var showReport = false
    @State private var showDeleteConfirm = false
    @State private var flash: LText?
    @State private var openChat: UUID?

    private var language: AppLanguage { store.language }

    private var currency: Currency { store.marketCurrency }

    var body: some View {
        Group {
            if let listing = store.listing(listingID) {
                content(listing)
            } else {
                MiyarEmptyState(symbol: "bag", title: S.noResults(language), message: S.noResultsHint(language))
            }
        }
        .background(Theme.canvas.ignoresSafeArea())
        .navigationTitle(store.listing(listingID)?.title(language) ?? S.marketplace(language))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.canvas, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if let listing = store.listing(listingID), listing.isOwnedByCurrentUser {
                        Button(S.editListing(language), systemImage: "pencil") { showEdit = true }
                        Button(S.delete(language), systemImage: "trash", role: .destructive) {
                            showDeleteConfirm = true
                        }
                    } else {
                        Button(S.report(language), systemImage: "flag") { showReport = true }
                        if let listing = store.listing(listingID) {
                            Button(store.isBlocked(listing.sellerID) ? S.unblock(language) : S.block(language), systemImage: "hand.raised") {
                                store.toggleBlock(listing.sellerID)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel(S.moderation(language))
            }
        }
        .alert(S.report(language), isPresented: $showReport) {
            Button(S.cancel(language), role: .cancel) {}
            Button(S.report(language)) { flash = S.reportSubmitted }
        } message: {
            Text(S.guidelinesReminder(language))
        }
        .alert(S.delete(language), isPresented: $showDeleteConfirm) {
            Button(S.cancel(language), role: .cancel) {}
            Button(S.delete(language), role: .destructive) { store.deleteListing(listingID) }
        } message: {
            Text(S.deleteListingConfirm(language))
        }
        .sheet(isPresented: $showEdit) {
            if let listing = store.listing(listingID) {
                CreateListingView(editing: listing)
            }
        }
        .sheet(isPresented: $showExchange) {
            if let listing = store.listing(listingID) {
                ExchangeOfferView(listing: listing)
            }
        }
        .navigationDestination(item: $openChat) { id in
            ChatView(conversationID: id)
        }
    }

    private func content(_ listing: Listing) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                PhotoPager(photoIDs: listing.photoIDs, fallbackSeed: listing.artworkSeed, height: 240)
                    .overlay(alignment: .topTrailing) {
                        Button {
                            store.toggleFavorite(listing.id)
                        } label: {
                            Image(systemName: store.isFavorite(listing.id) ? "heart.fill" : "heart")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(store.isFavorite(listing.id) ? Theme.gold : Theme.ink.opacity(0.6))
                                .frame(width: 40, height: 40)
                                .background(Circle().fill(Theme.surface.opacity(0.92)))
                        }
                        .buttonStyle(.plain)
                        .padding(12)
                        .accessibilityLabel(S.favorites(language))
                    }

                VStack(alignment: .leading, spacing: 10) {
                    Text(listing.title(language))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                    HStack(spacing: 8) {
                        MiyarTag(title: listing.category.label(language), symbol: listing.category.symbol)
                        MiyarTag(title: listing.type.label(language))
                        MiyarTag(title: listing.condition.label(language))
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(priceText(listing))
                            .font(.miyarMono(22, weight: .semibold))
                            .foregroundStyle(Theme.ink)
                        Spacer()
                        Text(listing.createdAt.relativeText(language))
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.secondaryText)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .miyarCard(padding: 18)

                factsCard(listing)
                descriptionCard(listing)
                sellerCard(listing)
                actions(listing)

                if let flash {
                    MiyarBanner(text: flash(language), tone: .success)
                }
            }
            .padding(Theme.margin)
            .padding(.bottom, 26)
        }
    }

    private func priceText(_ listing: Listing) -> String {
        listing.type == .exchange ? S.forExchange(language) : currency.formatUSD(listing.priceUSD, language: language)
    }

    private func factsCard(_ listing: Listing) -> some View {
        VStack(spacing: 0) {
            factRow(S.size(language), "\(Int(listing.sizeML)) \(S.milliliters(language))")
            MiyarDivider()
            factRow(S.remaining(language), listing.remainingPercent.percentText())
            MiyarDivider()
            factRow(S.condition(language), listing.condition.label(language))
            MiyarDivider()
            factRow(S.location(language), listing.location(language))
            MiyarDivider()
            VStack(alignment: .leading, spacing: 8) {
                Text(S.delivery(language))
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.secondaryText)
                ForEach(listing.deliveryOptions) { option in
                    HStack(spacing: 8) {
                        Image(systemName: "shippingbox")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.gold)
                        Text(option.label(language))
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.ink)
                        Spacer(minLength: 0)
                        if option.feeUSD > 0 {
                            Text(currency.formatUSD(option.feeUSD, language: language))
                                .font(.miyarMono(11))
                                .foregroundStyle(Theme.secondaryText)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 11)
        }
        .miyarCard(padding: 14)
    }

    private func factRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).font(.system(size: 13)).foregroundStyle(Theme.secondaryText)
            Spacer(minLength: 10)
            Text(value).font(.system(size: 14, weight: .medium)).foregroundStyle(Theme.ink)
        }
        .padding(.vertical, 11)
    }

    private func descriptionCard(_ listing: Listing) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(S.description(language)).miyarSectionHeader()
            Text(listing.details(language).isEmpty ? S.noResultsHint(language) : listing.details(language))
                .font(.system(size: 14))
                .foregroundStyle(Theme.ink)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .miyarCard(padding: 16)
    }

    @ViewBuilder
    private func sellerCard(_ listing: Listing) -> some View {
        if let seller = SeedPeople.byID(listing.sellerID) ?? store.currentUser {
            NavigationLink(value: AppRoute.seller(seller.id)) {
                HStack(spacing: 12) {
                    AvatarCircle(profile: seller, size: 46)
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 5) {
                            Text(seller.name(language))
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Theme.ink)
                            if seller.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Theme.gold)
                            }
                        }
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill").font(.system(size: 9)).foregroundStyle(Theme.gold)
                            Text(String(format: "%.1f", seller.rating))
                                .font(.miyarMono(11))
                                .foregroundStyle(Theme.secondaryText)
                            Text("· \(seller.salesCount) \(S.sales(language))")
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.secondaryText)
                        }
                    }
                    Spacer(minLength: 0)
                    Text(S.sellerProfile(language))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.gold)
                }
                .miyarCard(padding: 14)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private func actions(_ listing: Listing) -> some View {
        VStack(spacing: 10) {
            if listing.isOwnedByCurrentUser {
                MiyarBanner(text: LText("هذا إعلانك.", "This is your own listing.")(language), tone: .info)
                Button(S.editListing(language)) { showEdit = true }
                    .buttonStyle(GoldButtonStyle())
                Button(S.delete(language)) { showDeleteConfirm = true }
                    .buttonStyle(InkButtonStyle())
            } else if store.isBlocked(listing.sellerID) {
                MiyarBanner(text: S.blockedNotice(language), tone: .error)
                Button(S.unblock(language)) { store.toggleBlock(listing.sellerID) }
                    .buttonStyle(InkButtonStyle())
            } else {
                if listing.type.allowsSale {
                    Button(S.buyNow(language)) {
                        let id = store.startConversation(with: listing.sellerID)
                        store.sendMessage(
                            language == .ar
                                ? "أرغب بشراء: \(listing.titleAr)"
                                : "I'd like to buy: \(listing.titleEn)",
                            in: id
                        )
                        flash = S.purchaseRequested
                    }
                    .buttonStyle(GoldButtonStyle())
                }
                if listing.type.allowsExchange {
                    Button(S.offerExchange(language)) { showExchange = true }
                        .buttonStyle(InkButtonStyle())
                }
                Button(S.contactSeller(language)) {
                    openChat = store.startConversation(with: listing.sellerID)
                }
                .buttonStyle(InkButtonStyle())
            }
        }
    }
}
