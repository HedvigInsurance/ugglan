import Foundation
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

public struct File: Codable, Equatable, Identifiable, Hashable, Sendable {
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
        case let .url(url, _):
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
        switch source {
        case .data:
            return self
        case .url:
            return nil
        case let .localFile(results):
            if let results, let data = try? await results.itemProvider.getData().data {
                return .init(id: id, size: size, mimeType: mimeType, name: name, source: .data(data: data))
            }
            return nil
        }
    }
}

public enum FileSource: Codable, Equatable, Hashable, Sendable {
    case data(data: Data)
    case url(url: URL, mimeType: MimeType)
    case localFile(results: PHPickerResult?)

    enum Key: CodingKey {
        case rawValue
        case data
        case url
        case mimeType
    }

    enum CodingError: Error {
        case unknownValue
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
        case let .data(data):
            try container.encode(0, forKey: .rawValue)
            try container.encode(data, forKey: .data)

        case let .url(url, mimeType):
            try container.encode(1, forKey: .rawValue)
            try container.encode(url, forKey: .url)
            try container.encode(mimeType, forKey: .mimeType)

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
            let mimeType = try container.decode(MimeType.self, forKey: .mimeType)
            self = .url(url: url, mimeType: mimeType)
        default:
            throw CodingError.unknownValue
        }
    }
}

public extension File {
    init?(from url: URL) {
        guard let data = FileManager.default.contents(atPath: url.relativePath) else { return nil }
        let mimeType = MimeType.findBy(mimeType: url.mimeType)
        if mimeType == .HEIC {
            if let image = UIImage(data: data),
               let data = image.jpegData(compressionQuality: 0.9)
            {
                id = UUID().uuidString
                size = Double(data.count)
                self.mimeType = .JPEG
                name = url.deletingPathExtension().appendingPathExtension(for: UTType.jpeg).lastPathComponent
                source = .data(data: data)
            } else {
                return nil
            }
        } else {
            id = UUID().uuidString
            size = Double(data.count)
            self.mimeType = mimeType
            name = url.lastPathComponent
            source = .data(data: data)
        }
    }
}

@MainActor
public extension NSItemProvider {
    func getData() async throws -> (data: Data, mimeType: MimeType) {
        try await withCheckedThrowingContinuation {
            (inCont: CheckedContinuation<(Data, mimeType: MimeType), Error>) in
            Task { @MainActor in
                if self.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    self.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
                        if let url, let data = FileManager.default.contents(atPath: url.relativePath),
                           let image = UIImage(data: data),
                           let data = image.jpegData(compressionQuality: 0.9)
                        {
                            inCont.resume(returning: (data, MimeType.JPEG))
                        } else if let error {
                            inCont.resume(throwing: error)
                        } else {
                            inCont.resume(throwing: DataProviderError.invalidData)
                        }
                    }
                } else if self.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                    self.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { videoUrl, error in
                        if let videoUrl, let data = FileManager.default.contents(atPath: videoUrl.relativePath),
                           let mimeType = UTType(filenameExtension: videoUrl.pathExtension)?.preferredMIMEType
                        {
                            inCont.resume(returning: (data, MimeType.findBy(mimeType: mimeType)))
                        } else if let error {
                            inCont.resume(throwing: error)
                        } else {
                            inCont.resume(throwing: DataProviderError.invalidData)
                        }
                    }
                } else if self.hasItemConformingToTypeIdentifier(UTType.item.identifier) {
                    self.loadFileRepresentation(forTypeIdentifier: UTType.item.identifier) { itemUrl, error in
                        if let itemUrl, let data = FileManager.default.contents(atPath: itemUrl.relativePath),
                           let mimeType = UTType(filenameExtension: itemUrl.pathExtension)?.preferredMIMEType
                        {
                            inCont.resume(returning: (data, MimeType.findBy(mimeType: mimeType)))
                        } else if let error {
                            inCont.resume(throwing: error)
                        } else {
                            inCont.resume(throwing: DataProviderError.invalidData)
                        }
                    }
                } else {
                    inCont.resume(throwing: DataProviderError.invalidData)
                }
            }
        }
    }

    enum DataProviderError: Error {
        case invalidData
    }
}

@MainActor
public extension NSItemProvider {
    func getFile() async -> File? {
        let name = suggestedName ?? ""
        return await withCheckedContinuation { inCont in
            if self.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                self.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, _ in
                    if let url, let data = FileManager.default.contents(atPath: url.relativePath),
                       let image = UIImage(data: data),
                       let data = image.jpegData(compressionQuality: 0.9)
                    {
                        let file = File(
                            id: UUID().uuidString,
                            size: Double(data.count),
                            mimeType: .JPEG,
                            name: name,
                            source: .data(data: data)
                        )
                        Task { @MainActor in
                            inCont.resume(with: .success(file))
                        }
                    } else {
                        inCont.resume(with: .success(nil))
                    }
                }
            } else if self.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                self.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { videoUrl, _ in
                    if let videoUrl, let data = FileManager.default.contents(atPath: videoUrl.relativePath),
                       let mimeType = UTType(filenameExtension: videoUrl.pathExtension)?.preferredMIMEType
                    {
                        Task {
                            let mimeType = MimeType.findBy(mimeType: mimeType)
                            let file = File(
                                id: UUID().uuidString,
                                size: Double(data.count),
                                mimeType: mimeType,
                                name: name,
                                source: .data(data: data)
                            )
                            Task { @MainActor in
                                inCont.resume(with: .success(file))
                            }
                        }
                    } else {
                        inCont.resume(with: .success(nil))
                    }
                }
            } else if self.hasItemConformingToTypeIdentifier(UTType.item.identifier) {
                self.loadFileRepresentation(forTypeIdentifier: UTType.item.identifier) { itemUrl, _ in
                    if let itemUrl, let data = FileManager.default.contents(atPath: itemUrl.relativePath),
                       let mimeType = UTType(filenameExtension: itemUrl.pathExtension)?.preferredMIMEType
                    {
                        Task {
                            let mimeType = MimeType.findBy(mimeType: mimeType)
                            let file = File(
                                id: UUID().uuidString,
                                size: Double(data.count),
                                mimeType: mimeType,
                                name: name,
                                source: .data(data: data)
                            )
                            Task { @MainActor in
                                inCont.resume(with: .success(file))
                            }
                        }
                    } else {
                        inCont.resume(with: .success(nil))
                    }
                }
            } else {
                inCont.resume(with: .success(nil))
            }
        }
    }
}

extension PHPickerResult: @unchecked @retroactive Sendable {}
