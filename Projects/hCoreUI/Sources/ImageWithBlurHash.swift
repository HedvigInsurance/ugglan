import Foundation
import Kingfisher
import SwiftUI

class ImageLoaderService: ObservableObject {
    @Published var image: UIImage = UIImage()

    func loadImage(url: URL) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.image = UIImage(data: data) ?? UIImage()
            }
        }
        task.resume()
    }
}

struct RemoteImage: View {
    var url: URL
    @ObservedObject var imageLoader = ImageLoaderService()

    var body: some View {
        Image(uiImage: imageLoader.image)
            .resizable()
            .onAppear {
                imageLoader.loadImage(url: url)
            }
    }
}

extension View {
    public func backgroundImageWithBlurHashFallback(
        imageURL: URL,
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
