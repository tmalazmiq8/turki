import Foundation
import Observation

/// A pending email verification challenge.
nonisolated struct PendingVerification: Sendable, Hashable {
    var email: String
    /// The display name chosen at sign-up, kept here only until the email is
    /// confirmed and the profile row can be created with it.
    var name: String
}

/// The single source of truth for the whole app.
///
/// Accounts and authentication are handled by Supabase Auth; the rest of the
/// app's data still lives in secure on-device storage for now (see
/// supabase/schema.sql for the shared tables and how to extend this).
@Observable
final class AppStore {
    // MARK: - Preferences
    var language: AppLanguage = .ar { didSet { save() } }

    // MARK: - Accounts
    private(set) var currentUser: UserProfile?
    var pendingVerification: PendingVerification?

    var isSignedIn: Bool { currentUser != nil }

    // MARK: - Perfumery
    private(set) var formulas: [Formula] = []
    private(set) var currentFormulaID: UUID?
    private(set) var savedMaterialIDs: Set<String> = []
    private(set) var materialNotes: [String: String] = [:]
    private(set) var experiments: [JeanCarlesExperiment] = []
    private(set) var completedSteps: Set<Int> = []
    private(set) var glossaryBookmarks: Set<String> = []

    // MARK: - Book
    var reading = ReadingSettings() { didSet { save() } }
    private(set) var chapterProgress: [Int: Double] = [:]
    private(set) var bookmarkedChapters: Set<Int> = []
    private(set) var lastChapterID: Int?
    private(set) var premiumUnlocked = false

    // MARK: - Marketplace
    /// Currency used to display every marketplace price.
    var marketCurrency: Currency = .sar { didSet { save() } }
    private(set) var listings: [Listing] = []
    private(set) var favoriteListingIDs: Set<UUID> = []
    private(set) var wanted: [WantedAlert] = []
    private(set) var collection: [CollectionItem] = []
    private(set) var offers: [ExchangeOffer] = []

    // MARK: - Community
    private(set) var posts: [Post] = []
    private(set) var savedPostIDs: Set<UUID> = []
    private(set) var followingIDs: Set<String> = []
    private(set) var blockedIDs: Set<String> = []
    private(set) var conversations: [Conversation] = []

    // MARK: - Assistant
    private(set) var aiConversations: [AIConversation] = []
    private(set) var aiUsage = AIUsage()
    private(set) var savedAIResponses: [String] = []

    // MARK: - System
    private(set) var notifications: [AppNotification] = []
    private(set) var sessions: [DeviceSession] = []
    private(set) var ifraOverrides: [String: IFRARecord] = [:]
    private(set) var ifraLastSync: Date?

    private let baseIFRA: [String: IFRARecord] = SeedIFRA.defaults(for: SeedMaterials.all)
    private var isLoaded = false

    // MARK: - Lifecycle

    init() {
        let snapshot = Persistence.load()
        apply(snapshot)
        if !snapshot.didSeed { seedDemoContent() }
        isLoaded = true
        // Show the cached profile immediately (including offline), then
        // confirm it against Supabase and refresh the session in the background.
        Task { await bootstrapSession() }
    }

    private func apply(_ s: AppSnapshot) {
        language = s.language
        // Optimistic: a cached session + cached profile means "signed in" for
        // the very first frame. `bootstrapSession()` verifies this right after.
        if SupabaseAuthService.cachedSession() != nil {
            currentUser = s.cachedProfile
        }
        formulas = s.formulas
        currentFormulaID = s.currentFormulaID
        savedMaterialIDs = Set(s.savedMaterialIDs)
        materialNotes = s.materialNotes
        experiments = s.experiments
        completedSteps = Set(s.completedSteps)
        glossaryBookmarks = Set(s.glossaryBookmarks)
        reading = s.reading
        chapterProgress = Dictionary(uniqueKeysWithValues: s.chapterProgress.compactMap { key, value in
            Int(key).map { ($0, value) }
        })
        bookmarkedChapters = Set(s.bookmarkedChapters)
        lastChapterID = s.lastChapterID
        listings = s.listings
        marketCurrency = s.marketCurrency
        favoriteListingIDs = Set(s.favoriteListingIDs)
        wanted = s.wanted
        collection = s.collection
        offers = s.offers
        posts = s.posts
        savedPostIDs = Set(s.savedPostIDs)
        followingIDs = Set(s.followingIDs)
        blockedIDs = Set(s.blockedIDs)
        conversations = s.conversations
        aiConversations = s.aiConversations
        aiUsage = s.aiUsage
        aiUsage.rollIfNeeded()
        savedAIResponses = s.savedAIResponses
        notifications = s.notifications
        sessions = s.sessions
        ifraOverrides = s.ifraOverrides
        ifraLastSync = s.ifraLastSync
    }

    private func makeSnapshot() -> AppSnapshot {
        var s = AppSnapshot()
        s.language = language
        s.cachedProfile = currentUser
        s.formulas = formulas
        s.currentFormulaID = currentFormulaID
        s.savedMaterialIDs = Array(savedMaterialIDs)
        s.materialNotes = materialNotes
        s.experiments = experiments
        s.completedSteps = Array(completedSteps)
        s.glossaryBookmarks = Array(glossaryBookmarks)
        s.reading = reading
        s.chapterProgress = Dictionary(uniqueKeysWithValues: chapterProgress.map { (String($0.key), $0.value) })
        s.bookmarkedChapters = Array(bookmarkedChapters)
        s.lastChapterID = lastChapterID
        s.listings = listings
        s.marketCurrency = marketCurrency
        s.favoriteListingIDs = Array(favoriteListingIDs)
        s.wanted = wanted
        s.collection = collection
        s.offers = offers
        s.posts = posts
        s.savedPostIDs = Array(savedPostIDs)
        s.followingIDs = Array(followingIDs)
        s.blockedIDs = Array(blockedIDs)
        s.conversations = conversations
        s.aiConversations = aiConversations
        s.aiUsage = aiUsage
        s.savedAIResponses = savedAIResponses
        s.notifications = notifications
        s.sessions = sessions
        s.ifraOverrides = ifraOverrides
        s.ifraLastSync = ifraLastSync
        s.didSeed = true
        return s
    }

    private func save() {
        guard isLoaded else { return }
        let snapshot = makeSnapshot()
        Task.detached(priority: .utility) {
            Persistence.write(snapshot)
        }
    }

    private func seedDemoContent() {
        listings = SeedMarket.listings
        collection = SeedMarket.collection
        offers = SeedMarket.offers
        posts = SeedCommunity.posts
        conversations = SeedCommunity.conversations
        notifications = SeedCommunity.notifications
        sessions = SeedCommunity.sessions
        // Write the seed immediately so a refresh always has a file to read.
        Persistence.write(makeSnapshot())
    }

    /// Re-reads the persisted store. Backs pull-to-refresh and the retry action;
    /// it becomes the Supabase fetch once the backend is connected.
    func refreshFromStorage() async throws {
        let snapshot = try await Task.detached(priority: .userInitiated) {
            try Persistence.loadThrowing()
        }.value
        let wasLoaded = isLoaded
        isLoaded = false
        apply(snapshot)
        isLoaded = wasLoaded
    }

    // MARK: - Authentication

    /// Creates the account with Supabase Auth and starts the email-verification step.
    /// - Returns: a localized error when the input is not acceptable.
    func signUp(name: String, email: String, password: String, confirmation: String) async -> LText? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmedName.isEmpty { return S.errEmptyName }
        if !Validation.isEmail(trimmedEmail) { return S.errInvalidEmail }
        if password.count < 8 { return S.errShortPassword }
        if password != confirmation { return S.errPasswordMismatch }

        do {
            let session = try await SupabaseAuthService.signUp(email: trimmedEmail, password: password)
            if session.needsEmailConfirmation {
                pendingVerification = PendingVerification(email: trimmedEmail, name: trimmedName)
                return nil
            }
            try await finalizeSignIn(session: session, nameForNewProfile: trimmedName)
            return nil
        } catch let error as SupabaseAuthError {
            return error.message
        } catch {
            return SupabaseAuthError.network.message
        }
    }

    func signIn(email: String, password: String) async -> LText? {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !Validation.isEmail(trimmed) { return S.errInvalidEmail }
        do {
            let session = try await SupabaseAuthService.signIn(email: trimmed, password: password)
            if session.needsEmailConfirmation {
                pendingVerification = PendingVerification(email: trimmed, name: "")
                return nil
            }
            try await finalizeSignIn(session: session, nameForNewProfile: nil)
            return nil
        } catch let error as SupabaseAuthError {
            return error.message
        } catch {
            return SupabaseAuthError.network.message
        }
    }

    func confirmVerification(code: String) async -> LText? {
        guard let pending = pendingVerification else { return S.errWrongCode }
        do {
            let session = try await SupabaseAuthService.verifySignup(email: pending.email, token: code.trimmingCharacters(in: .whitespaces))
            try await finalizeSignIn(session: session, nameForNewProfile: pending.name.isEmpty ? nil : pending.name)
            pendingVerification = nil
            return nil
        } catch {
            return S.errWrongCode
        }
    }

    func resendVerification() {
        guard let pending = pendingVerification else { return }
        Task { try? await SupabaseAuthService.resendConfirmation(email: pending.email) }
    }

    /// Sends a real password-recovery email via Supabase. Completing the
    /// reset happens through the link Supabase emails, which is the only
    /// secure way to prove ownership of the address without an active session.
    func resetPassword(email: String) async -> LText? {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !Validation.isEmail(trimmed) { return S.errInvalidEmail }
        do {
            try await SupabaseAuthService.sendPasswordRecovery(email: trimmed)
            return nil
        } catch let error as SupabaseAuthError {
            return error.message
        } catch {
            return SupabaseAuthError.network.message
        }
    }

    func changePassword(current: String, new: String, confirmation: String) async -> LText? {
        guard currentUser != nil else { return S.errWrongCredentials }
        if new.count < 8 { return S.errShortPassword }
        if new != confirmation { return S.errPasswordMismatch }
        // Re-authenticate with the current password first so a stolen unlocked
        // session alone can't be used to lock the real owner out.
        guard let email = SupabaseAuthService.cachedSession()?.email else { return S.errWrongCredentials }
        do {
            _ = try await SupabaseAuthService.signIn(email: email, password: current)
            try await SupabaseAuthService.updatePassword(new)
            return nil
        } catch let error as SupabaseAuthError {
            return error.message
        } catch {
            return SupabaseAuthError.network.message
        }
    }

    func signOut() {
        currentUser = nil
        Task { await SupabaseAuthService.signOut() }
        save()
    }

    /// Permanent deletion — removes everything the account owns locally and
    /// signs out. Deleting the Supabase Auth user itself requires an
    /// elevated (service-role) call, which must run on a server, never from
    /// the app; wire this up to a Supabase Edge Function when one exists.
    func deleteAccount() {
        currentUser = nil
        Task { await SupabaseAuthService.signOut() }
        formulas.removeAll()
        currentFormulaID = nil
        experiments.removeAll()
        offers.removeAll()
        wanted.removeAll()
        listings.removeAll { $0.isOwnedByCurrentUser }
        posts.removeAll { $0.authorID == SeedPeople.currentUserID }
        conversations.removeAll()
        aiConversations.removeAll()
        savedAIResponses.removeAll()
        notifications.removeAll()
        sessions.removeAll()
        save()
    }

    func updateProfile(_ transform: (inout UserProfile) -> Void) {
        guard var user = currentUser else { return }
        transform(&user)
        currentUser = user
        save()
        if let session = SupabaseAuthService.cachedSession() {
            Task.detached(priority: .utility) {
                try? await SupabaseProfileService.upsert(profile: user, session: session)
            }
        }
    }

    /// Fetches (or creates, for a brand-new account) the profile row, then
    /// signs the user into the app. Shared by sign-up, sign-in and the
    /// verification step so all three end up in the same state.
    private func finalizeSignIn(session: SupabaseSession, nameForNewProfile: String?) async throws {
        var profile = try await SupabaseProfileService.fetchOwnProfile(session: session)
        if profile == nil {
            var fresh = SeedPeople.newUser(name: nameForNewProfile ?? session.email, email: session.email)
            fresh.id = session.userID
            fresh.isEmailVerified = true
            try await SupabaseProfileService.upsert(profile: fresh, session: session)
            profile = fresh
        }
        currentUser = profile
        registerCurrentSession()
        save()
    }

    /// Called once at launch to restore a Supabase session, if one exists.
    /// Runs after `apply(_:)` has already shown the cached profile
    /// optimistically, so this only needs to confirm or roll that back.
    func bootstrapSession() async {
        guard let session = await SupabaseAuthService.refreshedSession(), !session.needsEmailConfirmation else {
            if currentUser != nil { currentUser = nil; save() }
            return
        }
        if let profile = try? await SupabaseProfileService.fetchOwnProfile(session: session) {
            currentUser = profile
            registerCurrentSession()
            save()
        } else if currentUser == nil {
            // No cached profile and the row fetch failed (e.g. offline) —
            // leave the user signed out rather than guessing.
            return
        }
    }

    private func registerCurrentSession() {
        if !sessions.contains(where: { $0.isCurrent }) {
            sessions.insert(
                DeviceSession(
                    deviceName: "iPhone",
                    locationAr: currentUser?.locationAr.isEmpty == false ? currentUser!.locationAr : "غير معروف",
                    locationEn: currentUser?.locationEn.isEmpty == false ? currentUser!.locationEn : "Unknown",
                    lastActive: Date(),
                    isCurrent: true
                ),
                at: 0
            )
        }
    }

    func endSession(_ id: UUID) {
        sessions.removeAll { $0.id == id && !$0.isCurrent }
        save()
    }

    // MARK: - Formulas

    var currentFormula: Formula? {
        guard let id = currentFormulaID else { return nil }
        return formulas.first { $0.id == id }
    }

    func formula(_ id: UUID) -> Formula? { formulas.first { $0.id == id } }

    @discardableResult
    func createFormula(name: String) -> Formula {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let formula = Formula(name: trimmed.isEmpty ? S.newFormula(language) : trimmed)
        formulas.insert(formula, at: 0)
        currentFormulaID = formula.id
        save()
        return formula
    }

    func upsert(_ formula: Formula) {
        var updated = formula
        updated.updatedAt = Date()
        if let index = formulas.firstIndex(where: { $0.id == formula.id }) {
            formulas[index] = updated
        } else {
            formulas.insert(updated, at: 0)
        }
        save()
    }

    func deleteFormula(_ id: UUID) {
        formulas.removeAll { $0.id == id }
        if currentFormulaID == id { currentFormulaID = formulas.first?.id }
        save()
    }

    @discardableResult
    func duplicateFormula(_ id: UUID) -> Formula? {
        guard let source = formulas.first(where: { $0.id == id }) else { return nil }
        var copy = source
        copy.id = UUID()
        copy.name = source.name + (language == .ar ? " — نسخة" : " — copy")
        copy.createdAt = Date()
        copy.updatedAt = Date()
        copy.ingredients = source.ingredients.map { item in
            var line = item
            line.id = UUID()
            return line
        }
        formulas.insert(copy, at: 0)
        save()
        return copy
    }

    func setCurrentFormula(_ id: UUID) {
        currentFormulaID = id
        save()
    }

    /// Adds a library material to a formula (the current one by default).
    func addMaterial(_ material: Material, percent: Double, to formulaID: UUID?) {
        let targetID = formulaID ?? currentFormulaID
        guard let targetID, let index = formulas.firstIndex(where: { $0.id == targetID }) else { return }
        let ingredient = FormulaIngredient(
            materialID: material.id,
            nameAr: material.nameAr,
            nameEn: material.nameEn,
            stage: material.stage,
            percent: percent,
            pricePerMLUSD: material.pricePerMLUSD,
            density: material.density
        )
        formulas[index].ingredients.append(ingredient)
        formulas[index].updatedAt = Date()
        save()
    }

    // MARK: - Materials

    func isMaterialSaved(_ id: String) -> Bool { savedMaterialIDs.contains(id) }

    func toggleMaterialSaved(_ id: String) {
        if savedMaterialIDs.contains(id) { savedMaterialIDs.remove(id) } else { savedMaterialIDs.insert(id) }
        save()
    }

    func note(for materialID: String) -> String { materialNotes[materialID] ?? "" }

    func setNote(_ text: String, for materialID: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { materialNotes.removeValue(forKey: materialID) } else { materialNotes[materialID] = trimmed }
        save()
    }

    // MARK: - IFRA

    func ifraRecord(for materialID: String) -> IFRARecord {
        ifraOverrides[materialID] ?? baseIFRA[materialID] ?? .unverified(id: materialID)
    }

    /// Applies an administrator override locally; the same payload shape is what
    /// the server dashboard will push once the backend is connected.
    func applyIFRAOverride(_ record: IFRARecord) {
        ifraOverrides[record.id] = record
        ifraLastSync = Date()
        save()
    }

    func clearIFRAOverride(_ materialID: String) {
        ifraOverrides.removeValue(forKey: materialID)
        save()
    }

    /// Fetches the published record set from the server. Records are data, not
    /// app code, so limits can change without a new app release.
    func refreshIFRAFromServer() async throws {
        let records = try await IFRAService.fetchRecords()
        for record in records { ifraOverrides[record.id] = record }
        ifraLastSync = Date()
        save()
    }

    // MARK: - Jean Carles

    func experiment(_ id: UUID) -> JeanCarlesExperiment? {
        experiments.first { $0.id == id }
    }

    /// Experiments the perfumer saved as drafts and has not finished rating.
    var unfinishedExperiments: [JeanCarlesExperiment] {
        experiments.filter { !$0.isComplete }
    }

    var completedExperiments: [JeanCarlesExperiment] {
        experiments.filter(\.isComplete)
    }

    func experiments(inStep step: Int) -> [JeanCarlesExperiment] {
        experiments.filter { $0.stepNumber == step }
    }

    func addExperiment(_ experiment: JeanCarlesExperiment) {
        experiments.insert(experiment, at: 0)
        save()
    }

    /// Saves an edited experiment, inserting it when it is new.
    func updateExperiment(_ experiment: JeanCarlesExperiment) {
        var updated = experiment
        updated.updatedAt = Date()
        if let index = experiments.firstIndex(where: { $0.id == experiment.id }) {
            experiments[index] = updated
        } else {
            experiments.insert(updated, at: 0)
        }
        save()
    }

    func toggleExperimentComplete(_ id: UUID) {
        guard let index = experiments.firstIndex(where: { $0.id == id }) else { return }
        experiments[index].isComplete.toggle()
        experiments[index].updatedAt = Date()
        save()
    }

    func deleteExperiment(_ id: UUID) {
        experiments.removeAll { $0.id == id }
        save()
    }

    func toggleStepComplete(_ step: Int) {
        if completedSteps.contains(step) { completedSteps.remove(step) } else { completedSteps.insert(step) }
        save()
    }

    // MARK: - Glossary

    func isBookmarked(term id: String) -> Bool { glossaryBookmarks.contains(id) }

    func toggleBookmark(term id: String) {
        if glossaryBookmarks.contains(id) { glossaryBookmarks.remove(id) } else { glossaryBookmarks.insert(id) }
        save()
    }

    // MARK: - Book

    func progress(for chapterID: Int) -> Double { chapterProgress[chapterID] ?? 0 }

    func setProgress(_ value: Double, for chapterID: Int) {
        let clamped = min(1, max(0, value))
        if clamped > progress(for: chapterID) {
            chapterProgress[chapterID] = clamped
        }
        lastChapterID = chapterID
        save()
    }

    func toggleChapterBookmark(_ chapterID: Int) {
        if bookmarkedChapters.contains(chapterID) { bookmarkedChapters.remove(chapterID) } else { bookmarkedChapters.insert(chapterID) }
        save()
    }

    /// Share of the whole book that has been read.
    var bookProgress: Double {
        let chapters = SeedBook.chapters
        guard !chapters.isEmpty else { return 0 }
        let total = chapters.reduce(0.0) { $0 + progress(for: $1.id) }
        return total / Double(chapters.count)
    }

    // MARK: - Marketplace

    func listing(_ id: UUID) -> Listing? { listings.first { $0.id == id } }

    var visibleListings: [Listing] {
        listings.filter { !blockedIDs.contains($0.sellerID) }
    }

    func isFavorite(_ id: UUID) -> Bool { favoriteListingIDs.contains(id) }

    func toggleFavorite(_ id: UUID) {
        if favoriteListingIDs.contains(id) { favoriteListingIDs.remove(id) } else { favoriteListingIDs.insert(id) }
        save()
    }

    @discardableResult
    func publish(_ listing: Listing) -> Listing {
        var new = listing
        new.isOwnedByCurrentUser = true
        new.sellerID = SeedPeople.currentUserID
        new.createdAt = Date()
        new.updatedAt = Date()
        listings.insert(new, at: 0)
        notifyMatchingAlerts(for: new)
        save()
        return new
    }

    /// Saves edits to a listing the signed-in member owns.
    func updateListing(_ listing: Listing) {
        guard let index = listings.firstIndex(where: { $0.id == listing.id }),
              listings[index].isOwnedByCurrentUser else { return }
        var updated = listing
        updated.isOwnedByCurrentUser = true
        updated.sellerID = SeedPeople.currentUserID
        updated.updatedAt = Date()
        listings[index] = updated
        save()
    }

    func deleteListing(_ id: UUID) {
        guard let listing = listings.first(where: { $0.id == id && $0.isOwnedByCurrentUser }) else { return }
        ImageStore.shared.delete(listing.photoIDs)
        listings.removeAll { $0.id == id }
        for index in collection.indices where collection[index].listedListingID == id {
            collection[index].listedListingID = nil
        }
        save()
    }

    var myListings: [Listing] { listings.filter { $0.isOwnedByCurrentUser } }

    func addWanted(_ alert: WantedAlert) {
        wanted.insert(alert, at: 0)
        save()
    }

    func deleteWanted(_ id: UUID) {
        wanted.removeAll { $0.id == id }
        save()
    }

    func matches(for alert: WantedAlert) -> [Listing] {
        visibleListings.filter { listing in
            let keywordMatch = alert.keyword.isEmpty || listing.matches(alert.keyword)
            let categoryMatch = alert.category == nil || listing.category == alert.category
            let priceMatch = alert.maxPriceUSD == nil || listing.priceUSD <= (alert.maxPriceUSD ?? .infinity)
            return keywordMatch && categoryMatch && priceMatch
        }
    }

    private func notifyMatchingAlerts(for listing: Listing) {
        for alert in wanted where matches(for: alert).contains(where: { $0.id == listing.id }) {
            notifications.insert(
                AppNotification(
                    kind: .market,
                    title: LText("إعلان يطابق تنبيهك", "A listing matches your alert"),
                    body: LText(listing.titleAr, listing.titleEn),
                    date: Date()
                ),
                at: 0
            )
        }
    }

    func addToCollection(_ item: CollectionItem) {
        collection.insert(item, at: 0)
        save()
    }

    func updateCollectionItem(_ item: CollectionItem) {
        guard let index = collection.firstIndex(where: { $0.id == item.id }) else { return }
        collection[index] = item
        save()
    }

    func removeFromCollection(_ id: UUID) {
        if let item = collection.first(where: { $0.id == id }) {
            ImageStore.shared.delete(item.photoIDs)
        }
        collection.removeAll { $0.id == id }
        save()
    }

    /// Publishes a bottle from the personal collection and links the two records.
    func listCollectionItem(_ itemID: UUID, as listing: Listing) {
        let published = publish(listing)
        guard let index = collection.firstIndex(where: { $0.id == itemID }) else { return }
        collection[index].listedListingID = published.id
        save()
    }

    /// Offers other members sent to the signed-in user.
    var incomingOffers: [ExchangeOffer] {
        offers.filter { $0.isIncoming && !blockedIDs.contains($0.counterpartyID) }
    }

    /// Offers the signed-in user sent out.
    var outgoingOffers: [ExchangeOffer] {
        offers.filter { !$0.isIncoming }
    }

    func offer(_ id: UUID) -> ExchangeOffer? { offers.first { $0.id == id } }

    func submitOffer(_ offer: ExchangeOffer) {
        var new = offer
        new.status = .pending
        new.history = [OfferEvent(status: .pending, note: offer.message, byCurrentUser: !offer.isIncoming)]
        offers.insert(new, at: 0)
        notifications.insert(
            AppNotification(
                kind: .exchange,
                title: new.isIncoming ? S.offerReceivedEvent : S.offerCreatedEvent,
                body: new.listingTitle,
                date: Date()
            ),
            at: 0
        )
        save()
    }

    /// Records a status change and appends it to the offer's history trail.
    func updateOffer(_ id: UUID, status: ExchangeOffer.Status, note: String? = nil, byCurrentUser: Bool = true) {
        guard let index = offers.firstIndex(where: { $0.id == id }) else { return }
        let trimmed = Validation.sanitize(note ?? "", limit: 600)
        offers[index].status = status
        if !trimmed.isEmpty {
            offers[index].negotiationNotes.append(trimmed)
        }
        offers[index].history.append(OfferEvent(status: status, note: trimmed, byCurrentUser: byCurrentUser))
        notifications.insert(
            AppNotification(
                kind: .exchange,
                title: S.offerUpdated,
                body: offers[index].listingTitle,
                date: Date()
            ),
            at: 0
        )
        save()
    }

    func deleteOffer(_ id: UUID) {
        offers.removeAll { $0.id == id }
        save()
    }

    // MARK: - Community

    func post(_ id: UUID) -> Post? { posts.first { $0.id == id } }

    var visiblePosts: [Post] {
        posts.filter { !blockedIDs.contains($0.authorID) }
    }

    func toggleLike(_ id: UUID) {
        guard let index = posts.firstIndex(where: { $0.id == id }) else { return }
        posts[index].isLiked.toggle()
        posts[index].likeCount += posts[index].isLiked ? 1 : -1
        save()
    }

    func isPostSaved(_ id: UUID) -> Bool { savedPostIDs.contains(id) }

    func toggleSavePost(_ id: UUID) {
        if savedPostIDs.contains(id) { savedPostIDs.remove(id) } else { savedPostIDs.insert(id) }
        save()
    }

    /// Adds a comment, or a reply when `parentID` is supplied.
    func addComment(_ text: String, to postID: UUID, parentID: UUID? = nil) {
        let trimmed = Validation.sanitize(text, limit: 1200)
        guard !trimmed.isEmpty, let index = posts.firstIndex(where: { $0.id == postID }) else { return }
        posts[index].comments.append(
            PostComment(
                authorID: SeedPeople.currentUserID,
                bodyAr: trimmed,
                bodyEn: trimmed,
                createdAt: Date(),
                parentID: parentID
            )
        )
        save()
    }

    func toggleCommentLike(_ commentID: UUID, in postID: UUID) {
        guard let postIndex = posts.firstIndex(where: { $0.id == postID }),
              let commentIndex = posts[postIndex].comments.firstIndex(where: { $0.id == commentID }) else { return }
        posts[postIndex].comments[commentIndex].isLiked.toggle()
        let liked = posts[postIndex].comments[commentIndex].isLiked
        posts[postIndex].comments[commentIndex].likeCount = max(0, posts[postIndex].comments[commentIndex].likeCount + (liked ? 1 : -1))
        save()
    }

    /// Removes one of the user's own comments along with its replies.
    func deleteComment(_ commentID: UUID, in postID: UUID) {
        guard let postIndex = posts.firstIndex(where: { $0.id == postID }),
              let comment = posts[postIndex].comments.first(where: { $0.id == commentID }),
              comment.authorID == SeedPeople.currentUserID else { return }
        posts[postIndex].comments.removeAll { $0.id == commentID || $0.parentID == commentID }
        save()
    }

    func publish(_ post: Post) {
        posts.insert(post, at: 0)
        save()
    }

    func deletePost(_ id: UUID) {
        if let post = posts.first(where: { $0.id == id && $0.authorID == SeedPeople.currentUserID }) {
            ImageStore.shared.delete(post.photoIDs)
        }
        posts.removeAll { $0.id == id && $0.authorID == SeedPeople.currentUserID }
        save()
    }

    var myPosts: [Post] { posts.filter { $0.authorID == SeedPeople.currentUserID } }

    func isFollowing(_ userID: String) -> Bool { followingIDs.contains(userID) }

    func toggleFollow(_ userID: String) {
        if followingIDs.contains(userID) { followingIDs.remove(userID) } else { followingIDs.insert(userID) }
        save()
    }

    func isBlocked(_ userID: String) -> Bool { blockedIDs.contains(userID) }

    func toggleBlock(_ userID: String) {
        if blockedIDs.contains(userID) {
            blockedIDs.remove(userID)
        } else {
            blockedIDs.insert(userID)
            followingIDs.remove(userID)
        }
        save()
    }

    // MARK: - Messaging

    func conversation(_ id: UUID) -> Conversation? { conversations.first { $0.id == id } }

    var sortedConversations: [Conversation] {
        conversations
            .filter { !blockedIDs.contains($0.partnerID) }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    /// Unread messages across every thread the user can still see.
    var unreadMessageCount: Int {
        sortedConversations.reduce(0) { $0 + $1.unreadCount(currentUserID: SeedPeople.currentUserID) }
    }

    /// Returns the existing thread with a member, creating one when needed.
    @discardableResult
    func startConversation(with partnerID: String) -> UUID {
        if let existing = conversations.first(where: { $0.partnerID == partnerID }) { return existing.id }
        let conversation = Conversation(partnerID: partnerID, messages: [], updatedAt: Date())
        conversations.insert(conversation, at: 0)
        save()
        return conversation.id
    }

    /// Sends a text and/or photo message into a private thread.
    func sendMessage(_ text: String, in conversationID: UUID, photoID: String? = nil, artworkSeed: Int? = nil) {
        let trimmed = Validation.sanitize(text, limit: 2000)
        guard !trimmed.isEmpty || photoID != nil || artworkSeed != nil,
              let index = conversations.firstIndex(where: { $0.id == conversationID }),
              !blockedIDs.contains(conversations[index].partnerID) else { return }
        conversations[index].messages.append(
            ChatMessage(
                senderID: SeedPeople.currentUserID,
                bodyAr: trimmed,
                bodyEn: trimmed,
                sentAt: Date(),
                photoID: photoID,
                artworkSeed: artworkSeed
            )
        )
        conversations[index].updatedAt = Date()
        save()
    }

    /// Marks every message received in a thread as read.
    func markConversationRead(_ id: UUID) {
        guard let index = conversations.firstIndex(where: { $0.id == id }) else { return }
        var changed = false
        for messageIndex in conversations[index].messages.indices
        where conversations[index].messages[messageIndex].senderID != SeedPeople.currentUserID
            && conversations[index].messages[messageIndex].readAt == nil {
            conversations[index].messages[messageIndex].readAt = Date()
            changed = true
        }
        if changed { save() }
    }

    /// Applies the partner's read receipt to the user's own messages.
    func markOwnMessagesRead(in id: UUID) {
        guard let index = conversations.firstIndex(where: { $0.id == id }) else { return }
        var changed = false
        for messageIndex in conversations[index].messages.indices
        where conversations[index].messages[messageIndex].senderID == SeedPeople.currentUserID
            && conversations[index].messages[messageIndex].readAt == nil {
            conversations[index].messages[messageIndex].readAt = Date()
            changed = true
        }
        if changed { save() }
    }

    /// Drives the partner's typing indicator. The backend will set this live.
    func setPartnerTyping(_ isTyping: Bool, in id: UUID) {
        guard let index = conversations.firstIndex(where: { $0.id == id }),
              conversations[index].partnerIsTyping != isTyping else { return }
        conversations[index].partnerIsTyping = isTyping
    }

    func toggleMute(_ id: UUID) {
        guard let index = conversations.firstIndex(where: { $0.id == id }) else { return }
        conversations[index].isMuted.toggle()
        save()
    }

    func deleteConversation(_ id: UUID) {
        if let conversation = conversations.first(where: { $0.id == id }) {
            ImageStore.shared.delete(conversation.messages.compactMap(\.photoID))
        }
        conversations.removeAll { $0.id == id }
        save()
    }

    // MARK: - Assistant

    func aiConversation(_ id: UUID) -> AIConversation? { aiConversations.first { $0.id == id } }

    @discardableResult
    func newAIConversation() -> AIConversation {
        let conversation = AIConversation(title: S.aiNewChat(language))
        aiConversations.insert(conversation, at: 0)
        save()
        return conversation
    }

    func append(_ message: AIMessage, to conversationID: UUID) {
        guard let index = aiConversations.firstIndex(where: { $0.id == conversationID }) else { return }
        aiConversations[index].messages.append(message)
        aiConversations[index].updatedAt = Date()
        if message.role == .user, aiConversations[index].messages.count == 1 {
            aiConversations[index].title = String(message.text.prefix(46))
        }
        save()
    }

    func markReported(messageID: UUID, in conversationID: UUID) {
        guard let cIndex = aiConversations.firstIndex(where: { $0.id == conversationID }),
              let mIndex = aiConversations[cIndex].messages.firstIndex(where: { $0.id == messageID }) else { return }
        aiConversations[cIndex].messages[mIndex].isReported = true
        save()
    }

    func deleteAIConversation(_ id: UUID) {
        aiConversations.removeAll { $0.id == id }
        save()
    }

    func saveAIResponse(_ text: String) {
        savedAIResponses.insert(text, at: 0)
        save()
    }

    var aiRemaining: Int {
        var usage = aiUsage
        usage.rollIfNeeded()
        return usage.remaining
    }

    func consumeAIQuota() {
        aiUsage.rollIfNeeded()
        aiUsage.count += 1
        save()
    }

    // MARK: - Notifications

    var unreadNotifications: Int { notifications.filter { !$0.isRead }.count }

    func markNotificationsRead() {
        for index in notifications.indices { notifications[index].isRead = true }
        save()
    }

    func clearNotifications() {
        notifications.removeAll()
        save()
    }
}

/// Small input validators shared by the auth and listing forms.
nonisolated enum Validation {
    static func isEmail(_ value: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return value.range(of: pattern, options: .regularExpression) != nil
    }

    /// Trims and collapses whitespace so user text stays clean in the database.
    static func sanitize(_ value: String, limit: Int = 4000) -> String {
        let collapsed = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "[ \\t]{2,}", with: " ", options: .regularExpression)
        return String(collapsed.prefix(limit))
    }
}
