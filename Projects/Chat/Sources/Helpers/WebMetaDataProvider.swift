@preconcurrency import Foundation
@preconcurrency import LinkPresentation
import UniformTypeIdentifiers

@MainActor
class WebMetaDataProvider {
    static let shared = WebMetaDataProvider()
    private init() {}
    private var cache: [URL: WebMetaDataProviderData?] = [:]
    private var failedURLs: [URL] = []
    @MainActor
    func data(for url: URL) async throws -> WebMetaDataProviderData? {
        if let data = cache[url] {
            return data
        } else if failedURLs.contains(url) {
            return nil
        } else {
            let metadataProvider = LPMetadataProvider()
            do {
                let metadata = try await metadataProvider.startFetchingMetadata(for: url)
                if let imageProvider = metadata.imageProvider {
                    let title = metadata.title ?? ""
                    var image: UIImage?
                    do {
                        let imageFromUrl = try await imageProvider.loadItem(forTypeIdentifier: UTType.image.identifier)
                        if let data = imageFromUrl as? Data {
                            image = UIImage(data: data)
                        }
                    }
                    let returnValue = WebMetaDataProviderData(title: title, image: image)
                    cache[url] = returnValue
                    return returnValue
                } else {
                    throw WebMetaDataProviderError.somethingWentWrong(url: url)
                }
            } catch {
                throw WebMetaDataProviderError.somethingWentWrong(url: url)
            }
        }
    }

    enum WebMetaDataProviderError: Error {
        case somethingWentWrong(url: URL)
    }
}
extension WebMetaDataProvider.WebMetaDataProviderError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .somethingWentWrong(url): return url.absoluteString
        }
    }
}

struct WebMetaDataProviderData: Sendable {
    let title: String
    let image: UIImage?

    init(title: String, image: UIImage?) {
        self.title = title
        self.image = image
    }
}
