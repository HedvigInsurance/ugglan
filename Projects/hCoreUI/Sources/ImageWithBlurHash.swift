import Foundation
import Kingfisher
import SwiftUI

class ImageLoaderService: ObservableObject {
    @Published var image: UIImage = UIImage()

    func loadImage(url: URL?) {
        guard let url = url else {
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.image = UIImage(data: data) ?? UIImage()
            }
        }
        task.resume()
    }
}

public struct RemoteImage: View {
    var url: URL?
    @ObservedObject var imageLoader = ImageLoaderService()

    public init(
        url: URL?
    ) {
        self.url = url
    }

    public var body: some View {
        Image(uiImage: imageLoader.image)
            .resizable()
            .onAppear {
                imageLoader.loadImage(url: url)
            }
    }
}

extension View {
    public func backgroundImageWithBlurHashFallback(
        imageURL: URL?,
        blurHash: String
    ) -> some View {
        Group {
            if #available(iOS 14, *) {
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
            } else {
                self
                    .background(
                        RemoteImage(url: imageURL)
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
}

public struct ImageWithHashFallBack: View {
    var imageURL: String
    var blurHash: String

    public init(
        imageURL: String,
        blurHash: String
    ) {
        self.imageURL = imageURL
        self.blurHash = blurHash
    }

    public var body: some View {
        if #available(iOS 14, *) {
            KFImage(URL(string: imageURL))
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
        } else {
            RemoteImage(url: URL(string: imageURL))
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
        }
    }
}
