import ArgumentParser
import Foundation
import SimctlCore

@main
struct SimDpl: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "simdpl",
        abstract: "Open a deeplink on an iOS simulator.",
        discussion: """
            Examples:
              simdpl myapp://product/123
              simdpl open onboarding         # by saved name
              simdpl add onboarding myapp://onboard
              simdpl list
              simdpl sims
            """,
        subcommands: [Open.self, List.self, Add.self, Remove.self, Sims.self],
        defaultSubcommand: Open.self
    )
}

extension SimDpl {
    struct Open: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Open a URL (or a saved entry by name) on a booted simulator."
        )

        @Argument(help: "A URL, or the name of a saved deeplink.")
        var urlOrName: String

        @Option(name: .shortAndLong, help: "Simulator UDID. Defaults to the booted device.")
        var device: String?

        func run() throws {
            let saved = Storage.load().first { $0.name == urlOrName }
            let url = saved?.url ?? urlOrName
            try SimctlClient.openURL(url, target: device)
            FileHandle.standardOutput.write(Data("✓ opened \(url)\n".utf8))
        }
    }

    struct List: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "List saved deeplinks.")

        func run() {
            let entries = Storage.load()
            if entries.isEmpty {
                print("(no saved deeplinks — add one with `simdpl add <name> <url>`)")
                return
            }
            let nameWidth = entries.map { $0.name.count }.max() ?? 0
            for entry in entries {
                let padded = entry.name.padding(toLength: nameWidth, withPad: " ", startingAt: 0)
                print("\(padded)  \(entry.url)")
            }
        }
    }

    struct Add: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Save a deeplink under a name.")

        @Argument(help: "A short identifier you'll use to open it later.")
        var name: String

        @Argument(help: "The deeplink URL.")
        var url: String

        func run() {
            var entries = Storage.load()
            entries.removeAll { $0.name == name }
            entries.append(DeeplinkEntry(name: name, url: url))
            Storage.save(entries)
            print("✓ saved '\(name)'")
        }
    }

    struct Remove: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Remove a saved deeplink by name.")

        @Argument var name: String

        func run() {
            var entries = Storage.load()
            let before = entries.count
            entries.removeAll { $0.name == name }
            Storage.save(entries)
            print(entries.count < before ? "✓ removed '\(name)'" : "no entry named '\(name)'")
        }
    }

    struct Sims: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "List booted simulators.")

        func run() throws {
            let sims = try SimctlClient.bootedSimulators()
            if sims.isEmpty {
                print("(no booted simulators)")
                return
            }
            for sim in sims {
                print("\(sim.udid)  \(sim.name)  (\(sim.runtime))")
            }
        }
    }
}
