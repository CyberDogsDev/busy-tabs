import Foundation
import Testing

@testable import BusyTabs

private func member(lastSeen: Date) -> Member {
    Member(
        id: UUID(),
        name: "Test",
        statusId: nil,
        note: nil,
        lastSeenAt: lastSeen,
        updatedAt: lastSeen
    )
}

@Suite struct StalenessTests {
    @Test func freshMemberIsNotStale() {
        let now = Date()
        #expect(!member(lastSeen: now.addingTimeInterval(-60)).isStale(now: now))
    }

    @Test func memberJustInsideWindowIsNotStale() {
        let now = Date()
        #expect(!member(lastSeen: now.addingTimeInterval(-179)).isStale(now: now))
    }

    @Test func memberBeyondWindowIsStale() {
        let now = Date()
        #expect(member(lastSeen: now.addingTimeInterval(-181)).isStale(now: now))
    }

    @Test func customWindow() {
        let now = Date()
        let m = member(lastSeen: now.addingTimeInterval(-30))
        #expect(m.isStale(now: now, staleAfter: 10))
        #expect(!m.isStale(now: now, staleAfter: 60))
    }
}

@Suite struct ModelDecodingTests {
    private var decoder: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: string) { return date }
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: string) { return date }
            throw DecodingError.dataCorruptedError(
                in: container, debugDescription: "Bad date: \(string)")
        }
        return d
    }

    @Test func decodesStatusRow() throws {
        let json = """
            {"id":"9E3B62E7-8E7A-4A0B-B9B0-111111111111","name":"Available","color":"#34C759","sort_order":1,"is_active":true}
            """.data(using: .utf8)!
        let status = try decoder.decode(Status.self, from: json)
        #expect(status.name == "Available")
        #expect(status.color == "#34C759")
        #expect(status.sortOrder == 1)
        #expect(status.isActive)
    }

    @Test func decodesMemberRowWithSupabaseTimestamps() throws {
        let json = """
            {"id":"9E3B62E7-8E7A-4A0B-B9B0-222222222222","name":"Chase","status_id":"9E3B62E7-8E7A-4A0B-B9B0-111111111111","note":null,"last_seen_at":"2026-07-30T18:22:10.123456+00:00","updated_at":"2026-07-30T18:22:10+00:00"}
            """.data(using: .utf8)!
        let m = try decoder.decode(Member.self, from: json)
        #expect(m.name == "Chase")
        #expect(m.statusId != nil)
        #expect(m.note == nil)
    }

    @Test func decodesMemberWithNullStatus() throws {
        let json = """
            {"id":"9E3B62E7-8E7A-4A0B-B9B0-333333333333","name":"New Hire","status_id":null,"note":null,"last_seen_at":"2026-07-30T18:22:10+00:00","updated_at":"2026-07-30T18:22:10+00:00"}
            """.data(using: .utf8)!
        let m = try decoder.decode(Member.self, from: json)
        #expect(m.statusId == nil)
    }
}

@Suite struct ColorHexTests {
    @Test func parsesHexWithHash() throws {
        let c = try #require(ColorHex.components("#FF0000"))
        #expect(abs(c.r - 1) < 0.001)
        #expect(abs(c.g) < 0.001)
        #expect(abs(c.b) < 0.001)
    }

    @Test func parsesHexWithoutHash() {
        #expect(ColorHex.components("34C759") != nil)
    }

    @Test func rejectsGarbage() {
        #expect(ColorHex.components("not-a-color") == nil)
        #expect(ColorHex.components("#FFF") == nil)
        #expect(ColorHex.components("") == nil)
    }
}
