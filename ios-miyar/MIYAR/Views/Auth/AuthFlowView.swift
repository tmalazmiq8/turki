import SwiftUI

/// Welcome, sign in, sign up, reset and email verification in one flow.
struct AuthFlowView: View {
    @Environment(AppStore.self) private var store

    enum Mode: Hashable { case welcome, signIn, signUp, reset, verify }

    @State private var mode: Mode = .welcome
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmation = ""
    @State private var code = ""
    @State private var error: LText?
    @State private var info: LText?
    @State private var showProviderNotice = false
    @State private var isWorking = false

    private var language: AppLanguage { store.language }

    var body: some View {
        ZStack {
            AuthBackground()
            ScrollView {
                VStack(spacing: 22) {
                    header
                    card
                    Text(S.encryptedNotice(language))
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.secondaryText)
                    Text(S.backendLocalNotice(language))
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.secondaryText.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                }
                .padding(.horizontal, 22)
                .padding(.top, 30)
                .padding(.bottom, 40)
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .alert(S.providerNotConfigured(language), isPresented: $showProviderNotice) {
            Button(S.done(language), role: .cancel) {}
        } message: {
            Text(S.providerNotConfiguredBody(language))
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(spacing: 14) {
            HStack {
                Spacer()
                LanguageToggle()
            }
            MiyarWordmark(size: 40)
            Text(S.appTagline(language))
                .font(.system(size: 14))
                .foregroundStyle(Theme.secondaryText)
        }
    }

    @ViewBuilder
    private var card: some View {
        VStack(spacing: 16) {
            switch mode {
            case .welcome: welcomeContent
            case .signIn: signInContent
            case .signUp: signUpContent
            case .reset: resetContent
            case .verify: verifyContent
            }
        }
        .miyarCard(padding: 20)
        .animation(.spring(response: 0.4, dampingFraction: 0.9), value: mode)
    }

    private var welcomeContent: some View {
        VStack(spacing: 14) {
            Text(language == .ar ? "أهلًا بك في معيار" : "Welcome to MIYAR")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Theme.ink)
            Text(language == .ar
                 ? "صمّم عطورك، تعلّم المواد، وتبادل مع مجتمع العطّارين."
                 : "Design your fragrances, learn the materials, and trade with a community of perfumers.")
                .font(.system(size: 14))
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)

            Button(S.createAccount(language)) { switchTo(.signUp) }
                .buttonStyle(GoldButtonStyle())
            Button(S.signIn(language)) { switchTo(.signIn) }
                .buttonStyle(InkButtonStyle())

            providerSection
        }
    }

    private var signInContent: some View {
        VStack(spacing: 14) {
            formTitle(S.signIn(language))
            MiyarField(label: S.email(language), placeholder: "name@example.com", text: $email, keyboard: .emailAddress, contentType: .emailAddress)
            MiyarField(label: S.password(language), text: $password, isSecure: true, contentType: .password)
            messages
            Button(S.signIn(language)) { submitSignIn() }
                .buttonStyle(GoldButtonStyle())
                .disabled(isWorking)
            Button(S.forgotPassword(language)) { switchTo(.reset) }
                .buttonStyle(.plain)
                .font(.system(size: 13))
                .foregroundStyle(Theme.gold)
            providerSection
            secondary(S.createAccount(language)) { switchTo(.signUp) }
        }
    }

    private var signUpContent: some View {
        VStack(spacing: 14) {
            formTitle(S.createAccount(language))
            MiyarField(label: S.fullName(language), text: $name, contentType: .name)
            MiyarField(label: S.email(language), placeholder: "name@example.com", text: $email, keyboard: .emailAddress, contentType: .emailAddress)
            MiyarField(label: S.password(language), text: $password, isSecure: true, contentType: .newPassword)
            MiyarField(label: S.confirmPassword(language), text: $confirmation, isSecure: true, contentType: .newPassword)
            messages
            Button(S.createAccount(language)) { submitSignUp() }
                .buttonStyle(GoldButtonStyle())
                .disabled(isWorking)
            providerSection
            secondary(S.alreadyHaveAccount(language)) { switchTo(.signIn) }
        }
    }

    private var resetContent: some View {
        VStack(spacing: 14) {
            formTitle(S.resetPassword(language))
            Text(S.resetPasswordHint(language))
                .font(.system(size: 13))
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)
            MiyarField(label: S.email(language), placeholder: "name@example.com", text: $email, keyboard: .emailAddress, contentType: .emailAddress)
            messages
            Button(S.resetPassword(language)) { submitReset() }
                .buttonStyle(GoldButtonStyle())
            secondary(S.backToSignIn(language)) { switchTo(.signIn) }
        }
    }

    private var verifyContent: some View {
        VStack(spacing: 14) {
            formTitle(S.emailVerification(language))
            Text(S.emailVerificationSent(language))
                .font(.system(size: 13))
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)
            MiyarField(label: S.verificationCode(language), text: $code, keyboard: .numberPad, contentType: .oneTimeCode)
            messages
            Button(S.verify(language)) { submitVerify() }
                .buttonStyle(GoldButtonStyle())
            secondary(S.resendCode(language)) {
                store.resendVerification()
                info = LText("تم إرسال رمز جديد.", "A new code has been sent.")
            }
        }
    }

    private var providerSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                MiyarDivider()
                Text(S.orDivider(language))
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.secondaryText)
                MiyarDivider()
            }
            providerButton(symbol: "apple.logo", title: S.continueWithApple(language))
            providerButton(symbol: "g.circle", title: S.continueWithGoogle(language))
            Text(S.providerNotConfigured(language))
                .font(.system(size: 11))
                .foregroundStyle(Theme.secondaryText.opacity(0.85))
        }
    }

    private func providerButton(symbol: String, title: String) -> some View {
        Button {
            showProviderNotice = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: symbol).font(.system(size: 16))
                Text(title).font(.system(size: 15, weight: .medium))
            }
            .foregroundStyle(Theme.ink.opacity(0.45))
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(Theme.canvas, in: .rect(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Theme.hairline, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func formTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 19, weight: .semibold))
            .foregroundStyle(Theme.ink)
    }

    private func secondary(_ title: String, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .buttonStyle(.plain)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(Theme.gold)
    }

    @ViewBuilder
    private var messages: some View {
        if let error {
            MiyarBanner(text: error(language), tone: .error)
        } else if let info {
            MiyarBanner(text: info(language), tone: .success)
        }
    }

    // MARK: - Actions

    private func switchTo(_ newMode: Mode) {
        error = nil
        info = nil
        code = ""
        mode = newMode
    }

    private func submitSignIn() {
        error = nil
        info = nil
        isWorking = true
        Task {
            defer { isWorking = false }
            if let failure = await store.signIn(email: email, password: password) {
                error = failure
                return
            }
            if store.pendingVerification != nil {
                mode = .verify
            }
        }
    }

    private func submitSignUp() {
        error = nil
        info = nil
        isWorking = true
        Task {
            defer { isWorking = false }
            if let failure = await store.signUp(name: name, email: email, password: password, confirmation: confirmation) {
                error = failure
                return
            }
            mode = .verify
        }
    }

    private func submitReset() {
        error = nil
        info = nil
        isWorking = true
        Task {
            defer { isWorking = false }
            if let failure = await store.resetPassword(email: email) {
                error = failure
                return
            }
            info = S.resetLinkSent
            mode = .signIn
        }
    }

    private func submitVerify() {
        error = nil
        info = nil
        isWorking = true
        Task {
            defer { isWorking = false }
            if let failure = await store.confirmVerification(code: code) {
                error = failure
            }
        }
    }
}

/// Soft gold halo behind the auth card.
private struct AuthBackground: View {
    var body: some View {
        ZStack {
            Theme.canvas
            RadialGradient(
                colors: [Theme.gold.opacity(0.16), .clear],
                center: .top,
                startRadius: 10,
                endRadius: 420
            )
            RadialGradient(
                colors: [Theme.gold.opacity(0.10), .clear],
                center: .bottomTrailing,
                startRadius: 10,
                endRadius: 320
            )
        }
        .ignoresSafeArea()
    }
}
