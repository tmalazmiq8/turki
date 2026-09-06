import Foundation

/// Connection details for the shared Supabase backend.
///
/// The "publishable" key below is the new Supabase API key format — it is
/// designed to be shipped inside client apps (it can only do what Row Level
/// Security policies on the database allow) and is not a secret. The
/// `service_role` key must NEVER be placed here or anywhere in the app.
enum SupabaseConfig {
    static let projectURL = URL(string: "https://wqiqyhrqsazarslozlgr.supabase.co")!
    static let publishableKey = "sb_publishable_0F2tHsFhIxqDd9VVu6syxw_vssDX6kk"
}
