import Foundation
import Security

/// A signed-in session as returned by Supabase Auth.
nonisolated struct SupabaseSession: Codable, Sendable {
    var accessToken: String
    var refreshToken: String
    var userID: String
    var email: String
    var expiresAt: Date
    var needsEmailConfirmation: Bool
}

/// Errors surfaced by calls to Supabase, already mapped to user-facing copy.
nonisolated enum SupabaseAuthError: LocalizedError, Sendable {
    case invalidCredentials
    case emailNotConfirmed
    case weakPassword
    case emailTaken
    case network
    case server(String)

    var message: LText {
        switch self {
        case .invalidCredentials: S.errWrongCredentials
        case .emailNotConfirmed: LText("يرجى تأكيد بريدك الإلكتروني أولًا.", "Please confirm your email first.")
        case .weakPassword: S.errShortPassword
        case .emailTaken: S.errEmailTaken
        case .network: LText("تعذّر الاتصال بالخادم. تحقق من الإنترنت.", "Couldn't reach the server. Check your connection.")
        case .server(let msg): LText(msg, msg)
        }
    }

    var errorDescription: String? { "supabase-auth" }
}

/// Thin wrapper around Supabase's Auth (GoTrue) REST API.
///
/// This talks to the project directly over HTTPS with `URLSession` — no
/// Supabase SDK dependency required. The session (access + refresh token) is
/// cached in the Keychain, device-only, so it survives relaunches without
/// living in the plaintext-adjacent app snapshot.
nonisolated enum SupabaseAuthService {
    private static var base: URL { SupabaseConfig.projectURL }

    // MARK: - Session storage (Keychain)

    private enum SessionStore {
        static let account = "miyar.supabase.session"
        static let service = "com.miyar.app.auth"

        static func save(_ session: SupabaseSession) {
            guard let data = try? JSONEncoder().encode(session) else { return }
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            SecItemDelete(query as CFDictionary)
            var add = query
            add[kSecValueData as String] = data
            add[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            SecItemAdd(add as CFDictionary, nil)
        }

        static func load() -> SupabaseSession? {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
                kSecReturnData as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]
            var result: AnyObject?
            guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
                  let data = result as? Data else { return nil }
            return try? JSONDecoder().decode(SupabaseSession.self, from: data)
        }

        static func clear() {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            SecItemDelete(query as CFDictionary)
        }
    }

    /// The cached session, if any. Does not validate expiry — callers that
    /// need a guaranteed-fresh token should call `refreshedSession()`.
    static func cachedSession() -> SupabaseSession? { SessionStore.load() }

    // MARK: - Requests

    private static func request(path: String, query: [String: String] = [:]) -> URLRequest {
        var components = URLComponents(url: base.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        if !query.isEmpty {
            components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        var request = URLRequest(url: components.url!)
        request.setValue(SupabaseConfig.publishableKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 20
        return request
    }

    private struct TokenResponse: Decodable {
        let access_token: String?
        let refresh_token: String?
        let expires_in: Double?
        let user: UserPayload?
    }

    private struct UserPayload: Decodable {
        let id: String
        let email: String?
        let confirmed_at: String?
        let email_confirmed_at: String?
    }

    private struct ErrorPayload: Decodable {
        let error_description: String?
        let msg: String?
        let error_code: String?
    }

    private static func mappedError(status: Int, data: Data) -> SupabaseAuthError {
        let payload = try? JSONDecoder().decode(ErrorPayload.self, from: data)
        let code = payload?.error_code ?? ""
        let text = (payload?.msg ?? payload?.error_description ?? "").lowercased()
        if code == "email_not_confirmed" || text.contains("confirm") { return .emailNotConfirmed }
        if code == "user_already_exists" || text.contains("already registered") { return .emailTaken }
        if code == "weak_password" || text.contains("password") && status == 422 { return .weakPassword }
        if status == 400 || status == 401 { return .invalidCredentials }
        return .server(payload?.msg ?? payload?.error_description ?? "supabase error \(status)")
    }

    private static func session(from token: TokenResponse) -> SupabaseSession? {
        guard let access = token.access_token, let refresh = token.refresh_token, let user = token.user else { return nil }
        let confirmed = (user.confirmed_at ?? user.email_confirmed_at) != nil
        return SupabaseSession(
            accessToken: access,
            refreshToken: refresh,
            userID: user.id,
            email: user.email ?? "",
            expiresAt: Date().addingTimeInterval(token.expires_in ?? 3600),
            needsEmailConfirmation: !confirmed
        )
    }

    // MARK: - Public API

    /// Creates the account. If the project has "Confirm email" enabled,
    /// Supabase sends a confirmation email and no session is returned yet —
    /// the caller should show a "check your email" state.
    static func signUp(email: String, password: String) async throws -> SupabaseSession {
        var req = request(path: "/auth/v1/signup")
        req.httpMethod = "POST"
        req.httpBody = try JSONSerialization.data(withJSONObject: ["email": email, "password": password])
        let (data, response) = try await send(req)
        guard let http = response as? HTTPURLResponse else { throw SupabaseAuthError.network }
        guard (200...299).contains(http.statusCode) else { throw mappedError(status: http.statusCode, data: data) }
        let token = try JSONDecoder().decode(TokenResponse.self, from: data)
        if let session = session(from: token) {
            SessionStore.save(session)
            return session
        }
        // No token in the response means confirmation is required before a
        // session can be issued. The account exists on the server already.
        let placeholder = SupabaseSession(accessToken: "", refreshToken: "", userID: "", email: email, expiresAt: Date(), needsEmailConfirmation: true)
        return placeholder
    }

    static func signIn(email: String, password: String) async throws -> SupabaseSession {
        var req = request(path: "/auth/v1/token", query: ["grant_type": "password"])
        req.httpMethod = "POST"
        req.httpBody = try JSONSerialization.data(withJSONObject: ["email": email, "password": password])
        let (data, response) = try await send(req)
        guard let http = response as? HTTPURLResponse else { throw SupabaseAuthError.network }
        guard (200...299).contains(http.statusCode) else { throw mappedError(status: http.statusCode, data: data) }
        let token = try JSONDecoder().decode(TokenResponse.self, from: data)
        guard let session = session(from: token) else { throw SupabaseAuthError.invalidCredentials }
        SessionStore.save(session)
        return session
    }

    /// Resends the sign-up confirmation email.
    static func resendConfirmation(email: String) async throws {
        var req = request(path: "/auth/v1/resend")
        req.httpMethod = "POST"
        req.httpBody = try JSONSerialization.data(withJSONObject: ["type": "signup", "email": email])
        let (data, response) = try await send(req)
        guard let http = response as? HTTPURLResponse else { throw SupabaseAuthError.network }
        guard (200...299).contains(http.statusCode) else { throw mappedError(status: http.statusCode, data: data) }
    }

    /// Confirms a sign-up using the OTP code Supabase emailed to the user
    /// (requires the "Confirm signup" email template to include `{{ .Token }}`
    /// — see the setup notes in supabase/schema.sql).
    static func verifySignup(email: String, token: String) async throws -> SupabaseSession {
        var req = request(path: "/auth/v1/verify")
        req.httpMethod = "POST"
        req.httpBody = try JSONSerialization.data(withJSONObject: ["type": "signup", "email": email, "token": token])
        let (data, response) = try await send(req)
        guard let http = response as? HTTPURLResponse else { throw SupabaseAuthError.network }
        guard (200...299).contains(http.statusCode) else { throw mappedError(status: http.statusCode, data: data) }
        let decoded = try JSONDecoder().decode(TokenResponse.self, from: data)
        guard let session = session(from: decoded) else { throw SupabaseAuthError.invalidCredentials }
        SessionStore.save(session)
        return session
    }

    /// Refreshes the cached session if it's missing or close to expiry.
    /// Returns nil when there is no session or the refresh token was rejected
    /// (e.g. revoked, or the user needs to sign in again).
    static func refreshedSession() async -> SupabaseSession? {
        guard let session = cachedSession() else { return nil }
        if session.expiresAt > Date().addingTimeInterval(60) { return session }
        var req = request(path: "/auth/v1/token", query: ["grant_type": "refresh_token"])
        req.httpMethod = "POST"
        req.httpBody = try? JSONSerialization.data(withJSONObject: ["refresh_token": session.refreshToken])
        guard let (data, response) = try? await send(req),
              let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode),
              let decoded = try? JSONDecoder().decode(TokenResponse.self, from: data),
              let refreshed = self.session(from: decoded) else {
            SessionStore.clear()
            return nil
        }
        SessionStore.save(refreshed)
        return refreshed
    }

    /// Sends a password-recovery email containing a reset link.
    static func sendPasswordRecovery(email: String) async throws {
        var req = request(path: "/auth/v1/recover")
        req.httpMethod = "POST"
        req.httpBody = try JSONSerialization.data(withJSONObject: ["email": email])
        let (data, response) = try await send(req)
        guard let http = response as? HTTPURLResponse else { throw SupabaseAuthError.network }
        guard (200...299).contains(http.statusCode) else { throw mappedError(status: http.statusCode, data: data) }
    }

    /// Changes the password for the currently signed-in user.
    static func updatePassword(_ newPassword: String) async throws {
        guard let session = cachedSession() else { throw SupabaseAuthError.invalidCredentials }
        var req = request(path: "/auth/v1/user")
        req.httpMethod = "PUT"
        req.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        req.httpBody = try JSONSerialization.data(withJSONObject: ["password": newPassword])
        let (data, response) = try await send(req)
        guard let http = response as? HTTPURLResponse else { throw SupabaseAuthError.network }
        guard (200...299).contains(http.statusCode) else { throw mappedError(status: http.statusCode, data: data) }
    }

    static func signOut() async {
        if let session = cachedSession() {
            var req = request(path: "/auth/v1/logout")
            req.httpMethod = "POST"
            req.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
            _ = try? await send(req)
        }
        SessionStore.clear()
    }

    static func deleteLocalSession() {
        SessionStore.clear()
    }

    private static func send(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await URLSession.shared.data(for: request)
        } catch {
            throw SupabaseAuthError.network
        }
    }
}
