import Foundation

/// Errors surfaced by the assistant, already mapped to user-facing copy.
nonisolated enum AIServiceError: LocalizedError, Sendable {
    case notConfigured
    case unauthorized
    case rateLimited
    case server(Int)
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .notConfigured: "backend-not-configured"
        default: "assistant-unavailable"
        }
    }

    /// Localized text for the chat error bubble.
    var message: LText {
        switch self {
        case .notConfigured: S.backendNotConfigured
        case .rateLimited: LText("طلبات كثيرة. انتظر لحظة ثم أعد المحاولة.", "Too many requests. Wait a moment and try again.")
        default: S.aiError
        }
    }
}

/// Structured context attached to an analysis request.
nonisolated struct AIFormulaContext: Sendable {
    var name: String
    var concentration: String
    var bottleSizeML: Double
    var totalPercent: Double
    var balanceScore: Double
    var lines: [String]
    var selectedMaterials: [String]

    func summary(language: AppLanguage) -> String {
        var parts: [String] = []
        parts.append("FORMULA: \(name)")
        parts.append("CONCENTRATION: \(concentration)")
        parts.append("BOTTLE: \(Int(bottleSizeML)) ml")
        parts.append("TOTAL: \(String(format: "%.1f", totalPercent))%")
        parts.append("BALANCE_SCORE: \(String(format: "%.2f", balanceScore))")
        parts.append("INGREDIENTS:")
        parts.append(contentsOf: lines.map { "- \($0)" })
        if !selectedMaterials.isEmpty {
            parts.append("SELECTED_MATERIALS: " + selectedMaterials.joined(separator: ", "))
        }
        parts.append("LANGUAGE: \(language.rawValue)")
        return parts.joined(separator: "\n")
    }
}

/// Talks to the model through Rork's server-side proxy.
///
/// No provider API key exists in the app: the request is authenticated with the
/// project's build-injected toolkit token and the proxy holds the real secrets.
/// Swapping in a Supabase Edge Function later means changing `endpoint` only.
nonisolated enum AIService {
    private static let model = "anthropic/claude-haiku-4.5"

    private static var endpoint: URL? {
        let base = Config.EXPO_PUBLIC_TOOLKIT_URL.trimmingCharacters(in: .whitespaces)
        guard !base.isEmpty else { return nil }
        return URL(string: "\(base)/v2/vercel/v1/chat/completions")
    }

    private static func systemPrompt(language: AppLanguage) -> String {
        """
        You are MIYAR's perfumery assistant for an Arabic-first fragrance design app.
        Reply in \(language == .ar ? "Arabic" : "English") using the same register the user writes in.
        You explain raw materials, olfactory families, fragrance structure, Jean Carles
        pairwise training, maceration and formula balance in a clear, teacherly way.

        Hard rules:
        - Everything you say is educational. Never state or imply that a formula, a
          material or a concentration is safe, approved, certified, or IFRA-compliant.
        - Never invent an IFRA maximum concentration, amendment number or restriction.
          If asked for a limit, say the official figure must be checked on
          ifrafragrance.org and in the supplier's documentation.
        - Never give medical, dermatological or regulatory advice.
        - Be concise: short paragraphs, plain sentences, no markdown tables.
        - When a formula is attached, comment on structure, stage balance, likely
          performance and educational improvements — with percentages as suggestions only.
        """
    }

    private struct ChatResponse: Decodable {
        struct Choice: Decodable {
            struct Message: Decodable { let content: String? }
            let message: Message
        }
        let choices: [Choice]
    }

    /// Sends the conversation and returns the assistant's reply text.
    static func reply(
        history: [AIMessage],
        context: AIFormulaContext?,
        language: AppLanguage
    ) async throws -> String {
        guard let endpoint else { throw AIServiceError.notConfigured }

        var payload: [[String: String]] = [
            ["role": "system", "content": systemPrompt(language: language)]
        ]
        if let context {
            payload.append([
                "role": "system",
                "content": "The user attached this formula as context:\n" + context.summary(language: language)
            ])
        }
        // Only the tail of the thread is sent to keep requests small and fast.
        for message in history.suffix(12) {
            payload.append(["role": message.role.rawValue, "content": message.text])
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 45
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let token = Config.EXPO_PUBLIC_RORK_TOOLKIT_SECRET_KEY
        if !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "model": model,
            "messages": payload,
            "temperature": 0.6
        ])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw AIServiceError.server(-1) }
        switch http.statusCode {
        case 200: break
        case 401, 403: throw AIServiceError.unauthorized
        case 429: throw AIServiceError.rateLimited
        default: throw AIServiceError.server(http.statusCode)
        }

        let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
        let text = decoded.choices.first?.message.content?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else { throw AIServiceError.emptyResponse }
        return text
    }
}
