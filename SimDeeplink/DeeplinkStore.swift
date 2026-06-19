import Foundation
import SimctlCore

@MainActor
final class DeeplinkStore: ObservableObject {
    @Published var entries: [DeeplinkEntry]
    @Published var bootedSims: [Simulator] = []
    @Published var selectedSimUDID: String?  // nil == "booted" (default)
    @Published var lastError: String?
    @Published var lastSent: String?

    init() {
        self.entries = Storage.load()
        refreshSims()
    }

    // MARK: - Persistence

    private func save() {
        Storage.save(entries)
    }

    func add(_ entry: DeeplinkEntry) {
        entries.append(entry)
        save()
    }

    func update(_ entry: DeeplinkEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(_ entry: DeeplinkEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        entries.move(fromOffsets: source, toOffset: destination)
        save()
    }

    // MARK: - Actions

    func send(_ entry: DeeplinkEntry) {
        do {
            try SimctlClient.openURL(entry.url, target: selectedSimUDID)
            lastError = nil
            lastSent = entry.name
        } catch {
            lastError = error.localizedDescription
        }
    }

    func refreshSims() {
        do {
            bootedSims = try SimctlClient.bootedSimulators()
            if let sel = selectedSimUDID,
               !bootedSims.contains(where: { $0.udid == sel }) {
                selectedSimUDID = nil
            }
        } catch {
            bootedSims = []
            selectedSimUDID = nil
        }
    }

    var targetLabel: String {
        if let udid = selectedSimUDID,
           let sim = bootedSims.first(where: { $0.udid == udid }) {
            return sim.name
        }
        return "booted (default)"
    }
}
