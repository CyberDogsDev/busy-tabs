import SwiftUI

struct TeamList: View {
    @EnvironmentObject private var store: TeamStore

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("TEAM")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Brand.cloud.opacity(0.5))
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .padding(.bottom, 4)

            if store.sortedTeam.isEmpty {
                Text("No teammates yet")
                    .font(.system(size: 12))
                    .foregroundStyle(Brand.cloud.opacity(0.5))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
            }

            ForEach(store.sortedTeam) { member in
                MemberRow(member: member)
            }
        }
        .padding(.bottom, 8)
    }
}

private struct MemberRow: View {
    @EnvironmentObject private var store: TeamStore
    let member: Member

    var body: some View {
        let stale = member.isStale(now: store.now)
        let status = store.status(for: member)
        let colorHex = stale ? Brand.offlineGray : (status?.color ?? Brand.offlineGray)
        let statusName = stale ? "Offline" : (status?.name ?? "—")
        let isMe = member.id == store.myMemberId

        HStack(spacing: 8) {
            Circle()
                .fill(Color(hex: colorHex))
                .frame(width: 10, height: 10)
            Text(member.name + (isMe ? " (you)" : ""))
                .font(.system(size: 13, weight: isMe ? .medium : .regular))
                .foregroundStyle(.white)
                .lineLimit(1)
            Spacer()
            Text(statusName)
                .font(.system(size: 11))
                .foregroundStyle(Brand.cloud.opacity(0.6))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .opacity(stale ? 0.45 : 1)
    }
}
