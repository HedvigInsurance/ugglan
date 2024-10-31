import Foundation
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

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

    public var url: URL? {
        switch source {
        case .localFile:
            return nil
        case .url(let url):
            return url
        default:
            return nil
        }
    }

    public func getAsDataFromUrl() -> File? {
        guard let url else {
            return nil
        }
        if let data = try? Data(contentsOf: url) {
            return .init(id: id, size: size, mimeType: mimeType, name: name, source: .data(data: data))
        }
        return nil
    }

    public func getAsData() async throws -> File? {
        switch self.source {
        case .data(let data):
            return self
        case .url(let url):
            return nil
        case .localFile(let results):
            if let results {
                let data = try? await withCheckedThrowingContinuation {
                    (inCont: CheckedContinuation<Data?, Error>) -> Void in
                    results.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.item.identifier) {
                        fileUrl,
                        error in
                        if let fileUrl,
                            let pathData = FileManager.default.contents(atPath: fileUrl.relativePath)
                        {
                            inCont.resume(returning: pathData)
                        } else {
                            inCont.resume(returning: nil)
                        }
                    }

                }
                if let data {
                    return .init(id: id, size: size, mimeType: mimeType, name: name, source: .data(data: data))
                }
                return nil

            }
            return nil
        }
    }
}

public enum FileSource: Codable, Equatable, Hashable {
    case data(data: Data)
    case url(url: URL)
    case localFile(results: PHPickerResult?)

    enum Key: CodingKey {
        case rawValue
        case data
        case url
    }

    enum CodingError: Error {
        case unknownValue
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
        case .data(let data):
            try container.encode(0, forKey: .rawValue)
            try container.encode(data, forKey: .data)
        case .url(let url):
            try container.encode(1, forKey: .rawValue)
            try container.encode(url, forKey: .url)
        default:
            throw CodingError.unknownValue
        }
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        switch rawValue {
        case 0:
            let data = try container.decode(Data.self, forKey: .data)
            self = .data(data: data)
        case 1:
            let url = try container.decode(URL.self, forKey: .url)
            self = .url(url: url)
        default:
            throw CodingError.unknownValue
        }

    }

}
extension File {
    public init?(from url: URL) {
        guard let data = FileManager.default.contents(atPath: url.relativePath) else { return nil }
        let mimeType = MimeType.findBy(mimeType: url.mimeType)
        if mimeType == .HEIC {
            if let image = UIImage(data: data),
                let data = image.jpegData(compressionQuality: 0.9)
            {
                self.id = UUID().uuidString
                self.size = Double(data.count)
                self.mimeType = .JPEG
                self.name = url.deletingPathExtension().appendingPathExtension(for: UTType.jpeg).lastPathComponent
                self.source = .data(data: data)
            } else {
                return nil
            }
        } else {
            self.id = UUID().uuidString
            self.size = Double(data.count)
            self.mimeType = mimeType
            self.name = url.lastPathComponent
            self.source = .data(data: data)
        }
    }
}
