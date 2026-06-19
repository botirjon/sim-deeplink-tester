import Foundation

public enum Storage {
    public static var fileURL: URL {
        let base = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("SimDeeplink", isDirectory: true)
        try? FileManager.default.createDirectory(
            at: base,
            withIntermediateDirectories: true
        )
        return base.appendingPathComponent("deeplinks.json")
    }

    public static func load() -> [DeeplinkEntry] {
        guard
            let data = try? Data(contentsOf: fileURL),
            let entries = try? JSONDecoder().decode([DeeplinkEntry].self, from: data)
        else {
            return []
        }
        return entries
    }

    public static func save(_ entries: [DeeplinkEntry]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
