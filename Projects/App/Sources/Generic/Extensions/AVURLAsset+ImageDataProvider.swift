import AVFoundation
import Foundation
import Kingfisher

extension AVURLAsset: ImageDataProvider {
	enum ImageDataProviderError: Error { case failedToRetrieveData }

	public var cacheKey: String { url.absoluteString }

	public func data(handler: @escaping (Result<Data, Error>) -> Void) {
		thumbnailImage.onValue(on: .background) { image in
			guard let data = image.pngData() else {
				handler(.failure(ImageDataProviderError.failedToRetrieveData))
				return
			}
			handler(.success(data))
		}
	}
}
