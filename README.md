# SimDeeplink

A small macOS menu-bar app + companion CLI for opening deeplinks on the iOS
simulator. Save your test deeplinks once, then fire them with two clicks (or one
`simdpl` invocation) — no more copy-pasting URLs into `xcrun simctl openurl`.

Built around two products in one SwiftPM package:

| Product       | What it is                                  |
| ------------- | ------------------------------------------- |
| `SimDeeplink` | SwiftUI menu-bar app                        |
| `simdpl`      | CLI replacement for the old zshrc function  |

Both share a common store (`~/Library/Application Support/SimDeeplink/deeplinks.json`),
so links you save in one show up in the other.

## Features

- Menu-bar dropdown of saved deeplinks — one click sends.
- Target picker: send to the default booted device, or pick a specific booted
  simulator from a submenu.
- Manage Links window (⌘,) with a sidebar list and a detail editor.
- `simdpl` CLI with `open` / `list` / `add` / `remove` / `sims`.

## Requirements

- macOS 14 (Sonoma) or later
- Xcode 15+ (only required for building from source)
- A booted iOS simulator

## Running

```bash
# Run the menu-bar app from the repo
swift run SimDeeplink

# Use the CLI
swift run simdpl myapp://product/123
swift run simdpl add onboarding myapp://onboard
swift run simdpl onboarding         # open by saved name
swift run simdpl list
swift run simdpl sims
```

To install the CLI globally:

```bash
swift build -c release
cp .build/release/simdpl /usr/local/bin/simdpl
```

To open the project in Xcode:

```bash
open Package.swift
```

## Layout

```
Sources/
├── SimctlCore/        # shared: DeeplinkEntry, Storage, SimctlClient
├── simdpl/            # CLI (swift-argument-parser)
└── SimDeeplink/       # SwiftUI menu-bar app
```
