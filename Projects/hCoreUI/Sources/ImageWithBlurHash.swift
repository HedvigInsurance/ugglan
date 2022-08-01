import Kingfisher
import SwiftUI

extension View {
    public func backgroundImageWithBlurHashFallback(
        imageURL: URL,
        blurHash: String
    ) -> some View {
        Group {
            self.background(
                KFImage(imageURL)
                    .fade(duration: 0.25)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            )
            .background(
                Image(
                    uiImage: UIImage(
                        blurHash: blurHash,
                        size: .init(width: 32, height: 32)
                    ) ?? UIImage()
                )
                .resizable()
            )
        }
    }
}
