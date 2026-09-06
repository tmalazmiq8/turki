import SwiftUI

/// Edits the signed-in member's public profile.
struct EditProfileView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var nameAr = ""
    @State private var nameEn = ""
    @State private var bioAr = ""
    @State private var bioEn = ""
    @State private var locationAr = ""
    @State private var locationEn = ""
    @State private var phone = ""
    @State private var avatarSeed = 0
    @State private var didLoad = false
    @State private var flash: LText?
    @State private var error: LText?

    private var language: AppLanguage { store.language }

    private var previewProfile: UserProfile {
        var profile = store.currentUser ?? SeedPeople.newUser(name: nameAr, email: "")
        profile.nameAr = nameAr.isEmpty ? profile.nameAr : nameAr
        profile.nameEn = nameEn.isEmpty ? nameEn : nameEn
        profile.avatarSeed = avatarSeed
        return profile
    }

    var body: some View {
        MiyarScreen(title: S.editProfile(language)) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(spacing: 12) {
                        AvatarCircle(profile: previewProfile, size: 84)
                        Text(S.changePhoto(language))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Theme.secondaryText)
                        HStack(spacing: 10) {
                            ForEach(0..<7, id: \.self) { seed in
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { avatarSeed = seed }
                                } label: {
                                    Circle()
                                        .fill(Theme.goldSoft)
                                        .frame(width: 30, height: 30)
                                        .overlay(
                                            Circle().strokeBorder(
                                                avatarSeed == seed ? Theme.gold : Theme.hairline,
                                                lineWidth: avatarSeed == seed ? 2 : 1
                                            )
                                        )
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("\(S.changePhoto(language)) \(seed + 1)")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .miyarCard(padding: 18)

                    if let error {
                        MiyarBanner(text: error(language), tone: .error)
                    }
                    if let flash {
                        MiyarBanner(text: flash(language), tone: .success)
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        MiyarField(label: "\(S.fullName(language)) — عربي", text: $nameAr)
                        MiyarField(label: "\(S.fullName(language)) — English", text: $nameEn)
                        MiyarField(label: "\(S.bio(language)) — عربي", text: $bioAr, lineLimit: 2...5)
                        MiyarField(label: "\(S.bio(language)) — English", text: $bioEn, lineLimit: 2...5)
                        MiyarField(label: "\(S.location(language)) — عربي", text: $locationAr)
                        MiyarField(label: "\(S.location(language)) — English", text: $locationEn)
                        MiyarField(label: S.phone(language), text: $phone, keyboard: .phonePad, contentType: .telephoneNumber)
                    }
                    .miyarCard(padding: 16)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(S.email(language)).miyarSectionHeader()
                        Text(store.currentUser?.email ?? "")
                            .font(.system(size: 15))
                            .foregroundStyle(Theme.ink)
                        Text(store.currentUser?.isEmailVerified == true ? S.verified(language) : S.notVerified(language))
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.secondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .miyarCard(padding: 16)

                    Button(S.saveChanges(language)) { save() }
                        .buttonStyle(GoldButtonStyle())
                }
                .padding(Theme.margin)
                .padding(.bottom, 26)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .onAppear(perform: load)
    }

    private func load() {
        guard !didLoad, let profile = store.currentUser else { return }
        nameAr = profile.nameAr
        nameEn = profile.nameEn
        bioAr = profile.bioAr
        bioEn = profile.bioEn
        locationAr = profile.locationAr
        locationEn = profile.locationEn
        phone = profile.phone
        avatarSeed = profile.avatarSeed
        didLoad = true
    }

    private func save() {
        let trimmedAr = Validation.sanitize(nameAr, limit: 60)
        let trimmedEn = Validation.sanitize(nameEn, limit: 60)
        guard !trimmedAr.isEmpty || !trimmedEn.isEmpty else {
            error = S.errEmptyName
            flash = nil
            return
        }
        store.updateProfile { profile in
            profile.nameAr = trimmedAr.isEmpty ? trimmedEn : trimmedAr
            profile.nameEn = trimmedEn.isEmpty ? trimmedAr : trimmedEn
            profile.bioAr = Validation.sanitize(bioAr, limit: 240)
            profile.bioEn = Validation.sanitize(bioEn, limit: 240)
            profile.locationAr = Validation.sanitize(locationAr, limit: 80)
            profile.locationEn = Validation.sanitize(locationEn, limit: 80)
            profile.phone = Validation.sanitize(phone, limit: 24)
            profile.avatarSeed = avatarSeed
        }
        error = nil
        withAnimation { flash = S.profileSaved }
    }
}
