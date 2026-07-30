import SwiftUI

struct PanelView: View {
    @EnvironmentObject private var store: TeamStore

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if store.myMemberId == nil {
                FirstRunView()
            } else {
                StatusPicker()
                Divider().overlay(Brand.slate)
                TeamList()
            }
            if let error = store.errorMessage {
                Text(error)
                    .font(.caption2)
                    .foregroundStyle(.red)
                    .lineLimit(2)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
            }
            Divider().overlay(Brand.slate)
            footer
        }
        .frame(width: 280)
        .background(Brand.ink)
        .preferredColorScheme(.dark)
    }

    private var footer: some View {
        HStack {
            Toggle("Launch at login", isOn: Binding(
                get: { store.launchAtLogin },
                set: { store.setLaunchAtLogin($0) }
            ))
            .toggleStyle(.checkbox)
            .font(.caption)
            .foregroundStyle(Brand.cloud)
            Spacer()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .font(.caption)
            .foregroundStyle(Brand.cloud.opacity(0.7))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}
