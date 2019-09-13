//
//  AVURLAsset+ImageDataProvider.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-13.
//

import Foundation
import AVFoundation
import Kingfisher

extension AVURLAsset: ImageDataProvider {
    enum ImageDataProviderError: Error {
        case failedToRetrieveData
    }
    
    public var cacheKey: String {
        return url.absoluteString
    }
    
    public func data(handler: @escaping (Result<Data, Error>) -> Void) {
        thumbnailImage.onValue(on: .main) { image in
            guard let data = image.pngData() else {
                handler(.failure(ImageDataProviderError.failedToRetrieveData))
                return
            }
            handler(.success(data))
        }
    }
}
