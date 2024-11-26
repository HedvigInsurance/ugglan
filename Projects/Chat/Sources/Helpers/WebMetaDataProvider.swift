import Foundation
@preconcurrency import LinkPresentation

@MainActor
class WebMetaDataProvider {
    static let shared = WebMetaDataProvider()
    private init() {}
    private var cache: [URL: WebMetaDataProviderData?] = [:]
    private var failedURLs: [URL] = []
    func data(for url: URL) async throws -> WebMetaDataProviderData? {
        if let data = cache[url] {
            return data
        } else if failedURLs.contains(url) {
            return nil
        } else {
            let data = try await withCheckedThrowingContinuation {
                (inCont: CheckedContinuation<WebMetaDataProviderData, Error>) -> Void in
                let metadataProvider = LPMetadataProvider()
                DispatchQueue.main.async {
                    metadataProvider.startFetchingMetadata(for: url) { [weak self] metadata, error in
                        if let metadata {
                            if #available(iOS 16.0, *) {
                                if let imageProvider = metadata.imageProvider {
                                    let title = metadata.title ?? ""
                                    _ =
                                        imageProvider
                                        .loadDataRepresentation(
                                            for: .image,
                                            completionHandler: { [weak self] data, error in
                                                Task { @MainActor in
                                                    if let data, let image = UIImage(data: data) {
                                                        self?.cache[url] = WebMetaDataProviderData(
                                                            title: title,
                                                            image: image
                                                        )
                                                    } else {
                                                        self?.cache[url] = WebMetaDataProviderData(
                                                            title: title,
                                                            image: nil
                                                        )
                                                    }
                                                    if let data = self?.cache[url], let data = data {
                                                        inCont.resume(returning: data)
                                                    } else {
                                                        inCont.resume(
                                                            throwing: WebMetaDataProviderError.somethingWentWrong(
                                                                url: url
                                                            )
                                                        )
                                                    }
                                                }
                                            }
                                        )
                                } else if let title = metadata.title {
                                    self?.cache[url] = WebMetaDataProviderData(
                                        title: title,
                                        image: nil
                                    )
                                    if let data = self?.cache[url], let data = data {
                                        inCont.resume(returning: data)
                                    } else {
                                        inCont.resume(throwing: WebMetaDataProviderError.somethingWentWrong(url: url))
                                    }
                                } else {
                                    self?.failedURLs.append(url)
                                    inCont.resume(throwing: WebMetaDataProviderError.somethingWentWrong(url: url))
                                }
                            } else {
                                self?.cache[url] = WebMetaDataProviderData(
                                    title: metadata.title ?? "",
                                    image: nil
                                )

                                if let data = self?.cache[url], let data = data {
                                    inCont.resume(returning: data)
                                } else {
                                    inCont.resume(throwing: WebMetaDataProviderError.somethingWentWrong(url: url))
                                }
                            }
                        } else {
                            inCont.resume(throwing: WebMetaDataProviderError.somethingWentWrong(url: url))
                        }

                    }
                }
            }
            return data
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
