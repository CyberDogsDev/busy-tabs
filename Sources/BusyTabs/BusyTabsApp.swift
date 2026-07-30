import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Menu-bar-only: no Dock icon even when run outside a bundle (swift run).
        NSApp.setActivationPolicy(.accessory)
    }
}

@main
struct BusyTabsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store = TeamStore()

    var body: some Scene {
        MenuBarExtra {
            PanelView()
                .environmentObject(store)
        } label: {
            Image(nsImage: StatusIconRenderer.image(hex: store.myStatusColorHex))
        }
        .menuBarExtraStyle(.window)
    }
}
