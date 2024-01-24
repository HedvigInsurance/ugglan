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

    public var url: URL {
        switch source {
        case .localFile(let url, let thumbnailURL):
            return url
        case .url(let url):
            return url
        }
    }
}

public enum FileSource: Codable, Equatable, Hashable {
    case localFile(url: URL, thumbnailURL: URL?)
    case url(url: URL)
}

public struct FilePickerDto {
    public let id: String
    public let size: Double
    public let mimeType: MimeType
    public let name: String
    public let data: Data
    public let thumbnailData: Data?

    public init(id: String, size: Double, mimeType: MimeType, name: String, data: Data, thumbnailData: Data?) {
        self.id = id
        self.size = size
        self.mimeType = mimeType
        self.name = name
        self.data = data
        self.thumbnailData = thumbnailData
    }
}

extension FilePickerDto {
    public func asFile() -> File? {
        do {
            let dataUrl = FileUploadManager().getPathForData(for: self.id)
            let thumbnailUrl = FileUploadManager().getPathForThumnailData(for: self.id)
            try data.write(to: dataUrl)
            var useThumbnailUrl = false
            if let thumbnailData {
                useThumbnailUrl = true
                try thumbnailData.write(to: thumbnailUrl)
            }
            return File(
                id: id,
                size: size,
                mimeType: mimeType,
                name: name,
                source: .localFile(url: dataUrl, thumbnailURL: useThumbnailUrl ? thumbnailUrl : nil)
            )
        } catch let ex {
            return nil
        }
    }
}
