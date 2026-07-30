import SwiftUI

struct StatusPicker: View {
    @EnvironmentObject private var store: TeamStore

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("MY STATUS")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Brand.cloud.opacity(0.5))
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .padding(.bottom, 4)

            ForEach(store.activeStatuses) { status in
                StatusRow(status: status, isCurrent: status.id == store.me?.statusId)
            }
        }
        .padding(.bottom, 8)
    }
}

private struct StatusRow: View {
    @EnvironmentObject private var store: TeamStore
    let status: Status
    let isCurrent: Bool
    @State private var hovering = false

    var body: some View {
        Button {
            Task { await store.setStatus(status) }
        } label: {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color(hex: status.color))
                    .frame(width: 10, height: 10)
                Text(status.name)
                    .font(.system(size: 13))
                    .foregroundStyle(.white)
                Spacer()
                if isCurrent {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Brand.viceCyan)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .contentShape(Rectangle())
            .background(hovering ? Brand.viceCyan.opacity(0.12) : .clear)
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
    }
}
