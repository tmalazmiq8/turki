import Foundation

/// Loads published IFRA records from the shared Supabase database.
///
/// Records are data, never code: an administrator edits the `ifra_records`
/// table (Supabase Table Editor, or a future admin tool) and every installed
/// app picks the change up without a new release. The client only ever reads
/// this table — see supabase/schema.sql for the row-level-security policy
/// that enforces that server-side.
nonisolated enum IFRAService {
    enum ServiceError: LocalizedError, Sendable {
        case notConfigured
        case server(Int)

        var message: LText {
            switch self {
            case .notConfigured: S.backendNotConfigured
            case .server: LText("تعذّر جلب السجلات من الخادم.", "Couldn't fetch records from the server.")
            }
        }

        var errorDescription: String? { "ifra-service" }
    }

    /// One row of `public.ifra_records`: the primary key plus the record
    /// itself, stored as-is in the `data` jsonb column.
    private struct Row: Decodable {
        let id: String
        let data: IFRARecord
    }

    private static var endpoint: URL {
        SupabaseConfig.projectURL
            .appendingPathComponent("/rest/v1/ifra_records")
    }

    /// Always true now that IFRA data comes from the app's own Supabase
    /// project rather than an optional external functions URL.
    static var isConfigured: Bool { true }

    static func fetchRecords() async throws -> [IFRARecord] {
        var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "select", value: "*")]
        var request = URLRequest(url: components.url!)
        request.setValue(SupabaseConfig.publishableKey, forHTTPHeaderField: "apikey")
        request.timeoutInterval = 20
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw ServiceError.server(-1) }
        guard http.statusCode == 200 else { throw ServiceError.server(http.statusCode) }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([Row].self, from: data).map(\.data)
    }
}
