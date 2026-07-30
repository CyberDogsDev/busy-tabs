import Foundation

struct Status: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var color: String
    var sortOrder: Int
    var isActive: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, color
        case sortOrder = "sort_order"
        case isActive = "is_active"
    }
}

struct Member: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var statusId: UUID?
    var note: String?
    var lastSeenAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, note
        case statusId = "status_id"
        case lastSeenAt = "last_seen_at"
        case updatedAt = "updated_at"
    }

    func isStale(now: Date, staleAfter: TimeInterval = Config.staleAfter) -> Bool {
        now.timeIntervalSince(lastSeenAt) > staleAfter
    }
}
