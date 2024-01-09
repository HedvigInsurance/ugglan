import Foundation

public struct File: Codable, Equatable, Identifiable, Hashable {
    public let id: String
    public let size: Double
    public let mimeType: MimeType
    public let name: String
    public let source: FileSource

    public init(id: String, size: Double, mimeType: MimeType, name: String, source: FileSource) {
        self.id = id
        self.size = size
        self.mimeType = mimeType
        self.name = name
        self.source = source
    }
}

public enum FileSource: Codable, Equatable, Hashable {
    case localFile(url: URL, thumbnailURL: URL?)
    case url(url: URL)
}
