import Foundation

enum Config {
    // Baked-in team key. Env vars override for local development.
    private static let defaultURL = "https://mibhuhczpeqeecukwokc.supabase.co"
    private static let defaultAnonKey = "sb_publishable_Gtu3zLmcT6kI-9yxkO9FkQ_kw6ht0F4"

    static let supabaseURL = URL(
        string: ProcessInfo.processInfo.environment["BUSYTABS_SUPABASE_URL"] ?? defaultURL
    )!
    static let supabaseAnonKey =
        ProcessInfo.processInfo.environment["BUSYTABS_SUPABASE_ANON_KEY"] ?? defaultAnonKey

    /// How often each app reports "I'm alive".
    static let heartbeatInterval: TimeInterval = 60
    /// Members not seen within this window render as Offline.
    static let staleAfter: TimeInterval = 180
}
