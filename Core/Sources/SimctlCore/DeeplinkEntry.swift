import Foundation

public struct DeeplinkEntry: Codable, Identifiable, Hashable {
    public var id: UUID
    public var name: String
    public var url: String
    public var notes: String

    public init(id: UUID = UUID(), name: String, url: String, notes: String = "") {
        self.id = id
        self.name = name
        self.url = url
        self.notes = notes
    }
}
