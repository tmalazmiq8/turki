import Foundation

/// Reads and writes the `public.profiles` table (see supabase/schema.sql)
/// through Supabase's auto-generated REST API (PostgREST).
nonisolated enum SupabaseProfileService {
    private static var restBase: URL { SupabaseConfig.projectURL.appendingPathComponent("/rest/v1/profiles") }

    private struct Row: Codable {
        var id: String
        var name_ar: String
        var name_en: String
        var bio_ar: String
        var bio_en: String
        var location_ar: String
        var location_en: String
        var phone: String
        var avatar_seed: Int
        var photo_url: String?
        var show_profile_publicly: Bool
        var allow_direct_messages: Bool
        var is_verified: Bool
        var rating: Double
        var sales_count: Int
        var follower_count: Int

        var profile: UserProfile {
            var p = UserProfile(
                id: id,
                nameAr: name_ar, nameEn: name_en,
                bioAr: bio_ar, bioEn: bio_en,
                locationAr: location_ar, locationEn: location_en
            )
            p.phone = phone
            p.avatarSeed = avatar_seed
            p.photoID = photo_url
            p.showProfilePublicly = show_profile_publicly
            p.allowDirectMessages = allow_direct_messages
            p.isVerified = is_verified
            p.rating = rating
            p.salesCount = sales_count
            p.followerCount = follower_count
            p.isEmailVerified = true
            return p
        }

        init(profile: UserProfile, email: String) {
            id = profile.id
            name_ar = profile.nameAr
            name_en = profile.nameEn
            bio_ar = profile.bioAr
            bio_en = profile.bioEn
            location_ar = profile.locationAr
            location_en = profile.locationEn
            phone = profile.phone
            avatar_seed = profile.avatarSeed
            photo_url = profile.photoID
            show_profile_publicly = profile.showProfilePublicly
            allow_direct_messages = profile.allowDirectMessages
            is_verified = profile.isVerified
            rating = profile.rating
            sales_count = profile.salesCount
            follower_count = profile.followerCount
        }
    }

    private static func headers(for session: SupabaseSession, extra: [String: String] = [:]) -> [String: String] {
        var h = [
            "apikey": SupabaseConfig.publishableKey,
            "Authorization": "Bearer \(session.accessToken)",
            "Content-Type": "application/json"
        ]
        for (k, v) in extra { h[k] = v }
        return h
    }

    /// Fetches the caller's own profile row, or nil if it doesn't exist yet
    /// (a brand-new account that hasn't had its first profile created).
    static func fetchOwnProfile(session: SupabaseSession) async throws -> UserProfile? {
        var components = URLComponents(url: restBase, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "id", value: "eq.\(session.userID)"),
            URLQueryItem(name: "select", value: "*")
        ]
        var req = URLRequest(url: components.url!)
        headers(for: session).forEach { req.setValue($1, forHTTPHeaderField: $0) }
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else { return nil }
        let rows = try JSONDecoder().decode([Row].self, from: data)
        return rows.first?.profile
    }

    /// Creates or updates the caller's profile row (upsert on primary key).
    static func upsert(profile: UserProfile, session: SupabaseSession) async throws {
        var req = URLRequest(url: restBase)
        req.httpMethod = "POST"
        headers(for: session, extra: ["Prefer": "resolution=merge-duplicates,return=minimal"]).forEach {
            req.setValue($1, forHTTPHeaderField: $0)
        }
        let row = Row(profile: profile, email: session.email)
        req.httpBody = try JSONEncoder().encode(row)
        let (_, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw SupabaseAuthError.network
        }
    }
}
