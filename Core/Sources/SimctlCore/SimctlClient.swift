import Foundation

public struct Simulator: Identifiable, Hashable {
    public let udid: String
    public let name: String
    public let runtime: String
    public var id: String { udid }

    public init(udid: String, name: String, runtime: String) {
        self.udid = udid
        self.name = name
        self.runtime = runtime
    }
}

public enum SimctlError: Error, LocalizedError {
    case invalidURL(String)
    case commandFailed(String)
    case decodingFailed(String)

    public var errorDescription: String? {
        switch self {
        case .invalidURL(let s): return "Invalid URL: \(s)"
        case .commandFailed(let m): return "simctl failed: \(m)"
        case .decodingFailed(let m): return "Could not parse simctl output: \(m)"
        }
    }
}

public enum SimctlClient {
    /// Returns all booted simulators reported by `xcrun simctl list devices booted --json`.
    public static func bootedSimulators() throws -> [Simulator] {
        let output = try run(["simctl", "list", "devices", "booted", "--json"])

        struct Root: Decodable { let devices: [String: [Device]] }
        struct Device: Decodable {
            let udid: String
            let name: String
            let state: String
        }

        guard let data = output.data(using: .utf8) else {
            throw SimctlError.decodingFailed("not utf8")
        }
        let decoded: Root
        do {
            decoded = try JSONDecoder().decode(Root.self, from: data)
        } catch {
            throw SimctlError.decodingFailed("\(error)")
        }

        var sims: [Simulator] = []
        for (runtimeKey, devices) in decoded.devices {
            for device in devices where device.state == "Booted" {
                sims.append(
                    Simulator(
                        udid: device.udid,
                        name: device.name,
                        runtime: prettyRuntime(runtimeKey)
                    )
                )
            }
        }
        return sims.sorted { $0.name < $1.name }
    }

    /// Opens `url` on the device with the given UDID, or on the default booted device when nil.
    public static func openURL(_ url: String, target: String? = nil) throws {
        guard URL(string: url) != nil else { throw SimctlError.invalidURL(url) }
        let device = target ?? "booted"
        _ = try run(["simctl", "openurl", device, url])
    }

    @discardableResult
    private static func run(_ args: [String]) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = args

        let stdout = Pipe()
        let stderr = Pipe()
        process.standardOutput = stdout
        process.standardError = stderr

        do {
            try process.run()
        } catch {
            throw SimctlError.commandFailed("could not launch xcrun: \(error.localizedDescription)")
        }
        process.waitUntilExit()

        let outData = stdout.fileHandleForReading.readDataToEndOfFile()
        let errData = stderr.fileHandleForReading.readDataToEndOfFile()

        if process.terminationStatus != 0 {
            let err = String(data: errData, encoding: .utf8) ?? "unknown error"
            throw SimctlError.commandFailed(err.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        return String(data: outData, encoding: .utf8) ?? ""
    }

    /// "com.apple.CoreSimulator.SimRuntime.iOS-17-2" -> "iOS 17.2"
    private static func prettyRuntime(_ raw: String) -> String {
        let tail = raw.components(separatedBy: ".").last ?? raw
        // Split into OS name and version digits.
        let parts = tail.split(separator: "-", maxSplits: 1, omittingEmptySubsequences: true)
        guard parts.count == 2 else {
            return tail.replacingOccurrences(of: "-", with: " ")
        }
        let os = String(parts[0])
        let version = String(parts[1]).replacingOccurrences(of: "-", with: ".")
        return "\(os) \(version)"
    }
}
