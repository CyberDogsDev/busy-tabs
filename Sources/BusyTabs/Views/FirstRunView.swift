import SwiftUI

struct FirstRunView: View {
    @EnvironmentObject private var store: TeamStore
    @State private var name = ""
    @State private var joining = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Welcome to Busy Tabs")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
            Text("Enter your name so the team can see your status.")
                .font(.system(size: 12))
                .foregroundStyle(Brand.cloud.opacity(0.7))
            TextField("Your name", text: $name)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .foregroundStyle(.white)
                .tint(Brand.viceCyan)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(RoundedRectangle(cornerRadius: 6).fill(Brand.slate))
                .onSubmit { join() }
            Button(action: join) {
                if joining {
                    ProgressView().controlSize(.small)
                } else {
                    Text("Join team")
                        .frame(maxWidth: .infinity)
                }
            }
            .keyboardShortcut(.defaultAction)
            .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || joining)
            .tint(Brand.viceCyan)
        }
        .padding(12)
    }

    private func join() {
        guard !joining else { return }
        joining = true
        Task {
            await store.join(name: name)
            joining = false
        }
    }
}
