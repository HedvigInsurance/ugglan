import Kingfisher
import SwiftUI

extension View {
    public func backgroundImageWithBlurHashFallback(
        imageURL: URL?,
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

public struct ImageWithHashFallBack: ViewModifier {
    var imageURL: URL?
    var blurHash: String

    public init(
        imageURL: URL?,
        blurHash: String
    ) {
        self.imageURL = imageURL
        self.blurHash = blurHash
    }

    public func body(content: Content) -> some View {
        if #available(iOS 14, *) {
            content
                .background(
                    KFImage(imageURL)
                        .fade(duration: 0.25)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.all)
                        .background(
                            Image(
                                uiImage: UIImage(
                                    blurHash: blurHash,
                                    size: .init(width: 32, height: 32)
                                ) ?? UIImage()
                            )
                            .resizable()
                        )
                )

        } else {
            content
                .background(
                    RemoteImage(url: imageURL)
                        .aspectRatio(contentMode: .fill)
                        .background(
                            Image(
                                uiImage: UIImage(
                                    blurHash: blurHash,
                                    size: .init(width: 32, height: 32)
                                ) ?? UIImage()
                            )
                            .resizable()
                        )
                )

        }
    }
}
