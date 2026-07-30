import Foundation

enum Config {
    // Baked-in team key. Env vars override for local development.
    private static let defaultURL = "https://YOUR-PROJECT.supabase.co"
    private static let defaultAnonKey = "YOUR-ANON-KEY"

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
