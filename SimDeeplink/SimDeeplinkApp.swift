import SwiftUI
import SimctlCore

@main
struct SimDeeplinkApp: App {
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
