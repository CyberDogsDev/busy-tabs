import Foundation
import ServiceManagement
import Supabase

@MainActor
final class TeamStore: ObservableObject {
    @Published private(set) var statuses: [Status] = []
    @Published private(set) var members: [Member] = []
    /// UI clock; refreshed periodically so staleness re-evaluates without new data.
    @Published private(set) var now = Date()
    @Published private(set) var myMemberId: UUID?
    @Published var errorMessage: String?
    @Published var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled

    private let client: SupabaseClient
    private static let myMemberIdKey = "myMemberId"

    init() {
        client = SupabaseClient(
            supabaseURL: Config.supabaseURL,
            supabaseKey: Config.supabaseAnonKey
        )
        if let stored = UserDefaults.standard.string(forKey: Self.myMemberIdKey) {
            myMemberId = UUID(uuidString: stored)
        }
        Task { await run() }
        Task { await heartbeatLoop() }
        Task { await clockLoop() }
    }

    // MARK: - Derived state

    var me: Member? { members.first { $0.id == myMemberId } }

    var activeStatuses: [Status] {
        statuses.filter(\.isActive).sorted { $0.sortOrder < $1.sortOrder }
    }

    func status(for member: Member) -> Status? {
        guard let sid = member.statusId else { return nil }
        return statuses.first { $0.id == sid }
    }

    var myStatusColorHex: String? {
        guard let me else { return nil }
        return status(for: me)?.color
    }

    /// Fresh members first (by name), stale members dimmed at the bottom.
    var sortedTeam: [Member] {
        members.sorted { a, b in
            let aStale = a.isStale(now: now)
            let bStale = b.isStale(now: now)
            if aStale != bStale { return !aStale }
            return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
        }
    }

    // MARK: - Lifecycle

    private func run() async {
        await refetchAll()
        await subscribeRealtime()
    }

    private func subscribeRealtime() async {
        let channel = client.realtimeV2.channel("busy-tabs")
        let memberChanges = channel.postgresChange(AnyAction.self, schema: "public", table: "members")
        let statusChanges = channel.postgresChange(AnyAction.self, schema: "public", table: "statuses")

        do {
            try await channel.subscribeWithError()
        } catch {
            // Heartbeat refetch keeps us eventually consistent even without realtime.
            errorMessage = "Live updates unavailable: \(error.localizedDescription)"
        }

        Task { [weak self] in
            for await _ in memberChanges { await self?.refetchMembers() }
        }
        Task { [weak self] in
            for await _ in statusChanges { await self?.refetchStatuses() }
        }
    }

    private func heartbeatLoop() async {
        while !Task.isCancelled {
            await heartbeat()
            try? await Task.sleep(nanoseconds: UInt64(Config.heartbeatInterval * 1_000_000_000))
        }
    }

    private func clockLoop() async {
        while !Task.isCancelled {
            now = Date()
            try? await Task.sleep(nanoseconds: 30_000_000_000)
        }
    }

    private func heartbeat() async {
        guard let myMemberId else { return }
        struct Payload: Encodable {
            let lastSeenAt: Date
            enum CodingKeys: String, CodingKey { case lastSeenAt = "last_seen_at" }
        }
        do {
            try await client.from("members")
                .update(Payload(lastSeenAt: Date()))
                .eq("id", value: myMemberId.uuidString)
                .execute()
            errorMessage = nil
        } catch {
            errorMessage = "Can't reach server: \(error.localizedDescription)"
        }
        // Self-heals missed realtime events (sleep/wake, dropped socket).
        await refetchAll()
    }

    // MARK: - Data

    func refetchAll() async {
        await refetchStatuses()
        await refetchMembers()
    }

    private func refetchStatuses() async {
        do {
            statuses = try await client.from("statuses")
                .select()
                .order("sort_order")
                .execute()
                .value
        } catch {
            errorMessage = "Can't load statuses: \(error.localizedDescription)"
        }
    }

    private func refetchMembers() async {
        do {
            members = try await client.from("members")
                .select()
                .order("name")
                .execute()
                .value
        } catch {
            errorMessage = "Can't load team: \(error.localizedDescription)"
        }
    }

    // MARK: - Actions

    /// First run: adopt an existing row with this name (reinstall case) or create one.
    func join(name: String) async {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        struct NewMember: Encodable {
            let name: String
        }
        do {
            let existing: [Member] = try await client.from("members")
                .select()
                .eq("name", value: trimmed)
                .execute()
                .value
            let member: Member
            if let found = existing.first {
                member = found
            } else {
                member = try await client.from("members")
                    .insert(NewMember(name: trimmed))
                    .select()
                    .single()
                    .execute()
                    .value
            }
            myMemberId = member.id
            UserDefaults.standard.set(member.id.uuidString, forKey: Self.myMemberIdKey)
            errorMessage = nil
            await heartbeat()
        } catch {
            errorMessage = "Couldn't join: \(error.localizedDescription)"
        }
    }

    func setStatus(_ status: Status) async {
        guard let myMemberId else { return }
        struct Payload: Encodable {
            let statusId: UUID
            let updatedAt: Date
            enum CodingKeys: String, CodingKey {
                case statusId = "status_id"
                case updatedAt = "updated_at"
            }
        }
        // Optimistic: recolor the menu bar dot immediately.
        if let i = members.firstIndex(where: { $0.id == myMemberId }) {
            members[i].statusId = status.id
        }
        do {
            try await client.from("members")
                .update(Payload(statusId: status.id, updatedAt: Date()))
                .eq("id", value: myMemberId.uuidString)
                .execute()
            errorMessage = nil
        } catch {
            errorMessage = "Couldn't set status: \(error.localizedDescription)"
            await refetchMembers()
        }
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            launchAtLogin = SMAppService.mainApp.status == .enabled
        } catch {
            launchAtLogin = SMAppService.mainApp.status == .enabled
            errorMessage = "Launch at login failed: \(error.localizedDescription)"
        }
    }
}
