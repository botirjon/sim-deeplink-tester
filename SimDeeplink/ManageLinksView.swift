import SwiftUI
import SimctlCore

struct ManageLinksView: View {
    @ObservedObject var store: DeeplinkStore
    @State private var selection: DeeplinkEntry.ID?

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detail
        }
    }

    private var sidebar: some View {
        List(selection: $selection) {
            ForEach(store.entries) { entry in
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.name).font(.body)
                    Text(entry.url)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .tag(Optional(entry.id))
            }
            .onMove { source, destination in
                store.move(fromOffsets: source, toOffset: destination)
            }
        }
        .frame(minWidth: 220)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    addNew()
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
    }

    @ViewBuilder
    private var detail: some View {
        if let entry = selectedEntry {
            EditorForm(
                entry: binding(for: entry),
                onSend: { store.send(entry) },
                onDelete: {
                    store.delete(entry)
                    selection = store.entries.first?.id
                }
            )
            .id(entry.id)
            .padding()
            .frame(minWidth: 360)
        } else {
            VStack(spacing: 12) {
                Image(systemName: "link.circle")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("Select a deeplink, or add a new one.")
                    .foregroundStyle(.secondary)
            }
            .frame(minWidth: 360, minHeight: 240)
        }
    }

    private var selectedEntry: DeeplinkEntry? {
        guard let id = selection else { return nil }
        return store.entries.first { $0.id == id }
    }

    private func addNew() {
        let entry = DeeplinkEntry(name: "New deeplink", url: "myapp://", notes: "")
        store.add(entry)
        selection = entry.id
    }

    private func binding(for entry: DeeplinkEntry) -> Binding<DeeplinkEntry> {
        Binding(
            get: {
                store.entries.first { $0.id == entry.id } ?? entry
            },
            set: { newValue in
                store.update(newValue)
            }
        )
    }
}

private struct EditorForm: View {
    @Binding var entry: DeeplinkEntry
    let onSend: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Form {
            Section("Entry") {
                TextField("Name", text: $entry.name)
                TextField("URL", text: $entry.url)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
                TextField("Notes", text: $entry.notes, axis: .vertical)
                    .lineLimit(2...6)
            }

            Section {
                HStack {
                    Button {
                        onSend()
                    } label: {
                        Label("Send to simulator", systemImage: "paperplane.fill")
                    }
                    .keyboardShortcut(.return, modifiers: .command)
                    .buttonStyle(.borderedProminent)

                    Spacer()

                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
}
