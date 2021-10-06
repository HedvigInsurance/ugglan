import AVFoundation
import Flow
import Foundation
import UIKit

extension AVURLAsset {
    enum ThumbnailImageError: Error { case failed }

    var thumbnailImage: Future<UIImage> {
        Future(on: .background) { completion in
            DispatchQueue.global(qos: .background)
                .async {
                    let imgGenerator = AVAssetImageGenerator(asset: self)
                    imgGenerator.appliesPreferredTrackTransform = true

                    guard
                        let cgImage = try? imgGenerator.copyCGImage(
                            at: self.duration,
                            actualTime: nil
                        )
                    else {
                        completion(.failure(ThumbnailImageError.failed))
                        return
                    }

                    completion(.success(UIImage(cgImage: cgImage)))
                }

            return NilDisposer()
        }
    }
}
