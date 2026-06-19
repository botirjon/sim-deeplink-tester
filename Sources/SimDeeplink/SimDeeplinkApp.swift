import SwiftUI
import SimctlCore

@main
struct SimDeeplinkApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store = DeeplinkStore()

    var body: some Scene {
        MenuBarExtra("SimDeeplink", systemImage: "link") {
            MenuBarContent(store: store)
        }
        .menuBarExtraStyle(.menu)

        Window("Manage Deeplinks", id: "manage") {
            ManageLinksView(store: store)
                .frame(minWidth: 560, minHeight: 360)
        }
        .windowResizability(.contentSize)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Menu-bar only — no Dock icon, no auto-opened windows.
        NSApp.setActivationPolicy(.accessory)
        for window in NSApp.windows where window.identifier?.rawValue != "menu-bar" {
            window.close()
        }
    }
}
