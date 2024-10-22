import Foundation
import SwiftUI
import UniformTypeIdentifiers
import PhotosUI

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
    
}//
//
//public struct FilePickerDto {
//    public let id: String
//    public let size: Double
//    public let mimeType: MimeType
//    public let name: String
//    public let data: Data
//    public let thumbnailData: Data?
//
//    public init(id: String, size: Double, mimeType: MimeType, name: String, data: Data, thumbnailData: Data?) {
//        self.id = id
//        self.size = size
//        self.mimeType = mimeType
//        self.name = name
//        self.data = data
//        self.thumbnailData = thumbnailData
//    }
//}
//
//extension FilePickerDto {
//    public func asFile() -> File? {
//        do {
//            let dataUrl = FileUploadManager().getPathForData(for: self.id)
//            let thumbnailUrl = FileUploadManager().getPathForThumnailData(for: self.id)
//            try data.write(to: dataUrl)
//            var useThumbnailUrl = false
//            if let thumbnailData {
//                useThumbnailUrl = true
//                try thumbnailData.write(to: thumbnailUrl)
//            }
//            return File(
//                id: id,
//                size: size,
//                mimeType: mimeType,
//                name: name,
//                source: .localFile(url: dataUrl, thumbnailURL: useThumbnailUrl ? thumbnailUrl : nil)
//            )
//        } catch _ {
//            return nil
//        }
//    }
//}

extension File {
    public init?(from url: URL) {
        guard let data = FileManager.default.contents(atPath: url.relativePath) else { return nil }
        let mimeType = MimeType.findBy(mimeType: url.mimeType)
        if mimeType == .HEIC {
            if let image = UIImage(data: data),
                let data = image.jpegData(compressionQuality: 0.9),
                let thumbnailData = image.jpegData(compressionQuality: 0.1)
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
