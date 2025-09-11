@preconcurrency import Foundation
@preconcurrency import LinkPresentation
import SwiftUI
import UniformTypeIdentifiers
import hCoreUI

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
                    var image: Image?
                    do {
                        let imageFromUrl = try await imageProvider.loadItem(forTypeIdentifier: UTType.image.identifier)
                        if let data = imageFromUrl as? Data {
                            if let uiImage = UIImage(data: data) {
                                image = Image(uiImage: uiImage)
                            }
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

@MainActor
struct WebMetaDataProviderData: Sendable {
    let title: String
    let image: Image

    init(title: String, image: Image? = hCoreUIAssets.helipadOutlined.view) {
        self.title = title
        self.image = image ?? hCoreUIAssets.helipadOutlined.view
    }
}

extension LPLinkMetadata: @unchecked @retroactive Sendable {}
