import SwiftUI

/// Password, sessions, privacy switches and the two-step account deletion.
struct SecurityView: View {
    @Environment(AppStore.self) private var store

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmation = ""
    @State private var error: LText?
    @State private var flash: LText?

    @State private var deleteStage = 0
    @State private var deleteConfirmationText = ""

    private var language: AppLanguage { store.language }

    var body: some View {
        MiyarScreen(title: S.security(language)) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    MiyarBanner(text: S.encryptedNotice(language), tone: .info)

                    passwordCard
                    privacyCard
                    sessionsCard
                    deletionCard
                }
                .padding(Theme.margin)
                .padding(.bottom, 26)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    // MARK: Password

    private var passwordCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(S.changePassword(language)).miyarSectionHeader()
            MiyarField(label: S.currentPassword(language), text: $currentPassword, isSecure: true, contentType: .password)
            MiyarField(label: S.newPassword(language), text: $newPassword, isSecure: true, contentType: .newPassword)
            MiyarField(label: S.confirmPassword(language), text: $confirmation, isSecure: true, contentType: .newPassword)

            if let error {
                MiyarBanner(text: error(language), tone: .error)
            }
            if let flash {
                MiyarBanner(text: flash(language), tone: .success)
            }

            Button(S.save(language)) {
                Task {
                    if let issue = await store.changePassword(current: currentPassword, new: newPassword, confirmation: confirmation) {
                        error = issue
                        flash = nil
                    } else {
                        error = nil
                        withAnimation { flash = S.passwordChanged }
                        currentPassword = ""
                        newPassword = ""
                        confirmation = ""
                    }
                }
            }
            .buttonStyle(GoldButtonStyle())
            .disabled(currentPassword.isEmpty || newPassword.isEmpty)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .miyarCard(padding: 16)
    }

    // MARK: Privacy

    private var privacyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(S.privacy(language)).miyarSectionHeader()

            Toggle(isOn: Binding(
                get: { store.currentUser?.showProfilePublicly ?? true },
                set: { value in store.updateProfile { $0.showProfilePublicly = value } }
            )) {
                Text(S.showProfilePublicly(language))
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.ink)
            }
            .tint(Theme.gold)

            MiyarDivider()

            Toggle(isOn: Binding(
                get: { store.currentUser?.allowDirectMessages ?? true },
                set: { value in store.updateProfile { $0.allowDirectMessages = value } }
            )) {
                Text(S.allowDirectMessages(language))
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.ink)
            }
            .tint(Theme.gold)

            MiyarDivider()

            NavigationLink(value: AppRoute.blocked) {
                MiyarRowLabel(symbol: "hand.raised", title: S.blockedUsers(language), trailingText: "\(store.blockedIDs.count)")
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .miyarCard(padding: 16)
    }

    // MARK: Sessions

    private var sessionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(S.activeSessions(language)).miyarSectionHeader()
            ForEach(store.sessions) { session in
                HStack(spacing: 12) {
                    Image(systemName: session.isCurrent ? "iphone.gen3" : "desktopcomputer")
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.gold)
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(Theme.goldSoft))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(session.deviceName + (session.isCurrent ? " · \(S.thisDevice(language))" : ""))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Theme.ink)
                        Text("\(session.location(language)) · \(session.lastActive.relativeText(language))")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.secondaryText)
                    }
                    Spacer(minLength: 6)
                    if !session.isCurrent {
                        Button(S.signOutSession(language)) { store.endSession(session.id) }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Theme.danger)
                            .buttonStyle(.plain)
                    }
                }
                if session.id != store.sessions.last?.id { MiyarDivider() }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .miyarCard(padding: 16)
    }

    // MARK: Deletion

    private var deletionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(S.deleteAccount(language)).miyarSectionHeader()
            Text(S.deleteAccountHint(language))
                .font(.system(size: 13))
                .foregroundStyle(Theme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            if deleteStage == 0 {
                Button(S.deleteAccount(language)) {
                    withAnimation(.easeInOut(duration: 0.25)) { deleteStage = 1 }
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.danger)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(Theme.danger.opacity(0.08), in: .rect(cornerRadius: 14))
                .buttonStyle(.plain)
            } else {
                Text(deleteStage == 1 ? S.deleteStepOne(language) : S.deleteStepTwo(language))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.danger)
                Text(S.deleteWarning(language))
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                if deleteStage == 1 {
                    HStack(spacing: 10) {
                        Button(S.cancel(language)) {
                            withAnimation { deleteStage = 0 }
                        }
                        .buttonStyle(InkButtonStyle())
                        Button(S.deleteContinue(language)) {
                            withAnimation(.easeInOut(duration: 0.25)) { deleteStage = 2 }
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.danger)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Theme.danger.opacity(0.1), in: .rect(cornerRadius: 14))
                        .buttonStyle(.plain)
                    }
                } else {
                    MiyarField(label: S.deleteTypeToConfirm(language), text: $deleteConfirmationText)
                    HStack(spacing: 10) {
                        Button(S.cancel(language)) {
                            deleteConfirmationText = ""
                            withAnimation { deleteStage = 0 }
                        }
                        .buttonStyle(InkButtonStyle())
                        Button(S.deleteFinal(language)) {
                            store.deleteAccount()
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Theme.danger.opacity(isDeleteConfirmed ? 1 : 0.35), in: .rect(cornerRadius: 14))
                        .buttonStyle(.plain)
                        .disabled(!isDeleteConfirmed)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .miyarCard(padding: 16)
    }

    private var isDeleteConfirmed: Bool {
        let typed = deleteConfirmationText.trimmingCharacters(in: .whitespacesAndNewlines)
        return typed == S.deleteConfirmWord(.ar) || typed.uppercased() == S.deleteConfirmWord(.en)
    }
}
