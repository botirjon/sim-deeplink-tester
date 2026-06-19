import SwiftUI
import SimctlCore

struct MenuBarContent: View {
    @ObservedObject var store: DeeplinkStore
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        if store.entries.isEmpty {
            Text("No deeplinks saved")
            Button("Add your first deeplink…") {
                openManageWindow()
            }
        } else {
            ForEach(store.entries) { entry in
                Button(entry.name) {
                    store.send(entry)
                }
            }
        }

        Divider()

        Menu("Target: \(store.targetLabel)") {
            Button("Default (booted)") {
                store.selectedSimUDID = nil
            }
            if !store.bootedSims.isEmpty {
                Divider()
                ForEach(store.bootedSims) { sim in
                    Button("\(sim.name) — \(sim.runtime)") {
                        store.selectedSimUDID = sim.udid
                    }
                }
            }
            Divider()
            Button("Refresh booted sims") {
                store.refreshSims()
            }
        }

        if let err = store.lastError {
            Divider()
            Text("Error: \(err)")
        } else if let sent = store.lastSent {
            Divider()
            Text("Last sent: \(sent)")
        }

        Divider()

        Button("Manage Links…") {
            openManageWindow()
        }
        .keyboardShortcut(",", modifiers: .command)

        Button("Quit SimDeeplink") {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: .command)
    }

    private func openManageWindow() {
        openWindow(id: "manage")
        NSApp.activate(ignoringOtherApps: true)
    }
}
