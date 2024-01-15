import Flow
import Kingfisher
import SwiftUI
import hCore
import hCoreUI

struct ChatFileView: View {
    let file: File

    let processor = DownsamplingImageProcessor(
        size: CGSize(width: 300, height: 300)
    )
    @ViewBuilder
    var body: some View {
        Group {
            if file.mimeType.isImage {
                if file.mimeType == .GIF {
                    KFAnimatedImage(
                        source: Kingfisher.Source.network(
                            Kingfisher.ImageResource(downloadURL: file.url, cacheKey: file.id)
                        )
                    )
                    .targetCache(ImageCache.default)
                    .aspectRatio(
                        contentMode: .fit
                    )
                } else {
                    KFImage(
                        source: getSource()
                    )
                    .fade(duration: 0.25)
                    .placeholder({ progress in
                        ProgressView()
                    })
                    .targetCache(ImageCache.default)
                    .setProcessor(processor)
                    .resizable()
                    .aspectRatio(
                        contentMode: .fit
                    )
                }
            } else {
                HStack {
                    hCoreUIAssets.documentsMultiple.view
                    hText(L10n.chatFileDownload)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12).stroke()
                )
            }
        }
        .onTapGesture {
            showFile()
        }
    }

    func showFile() {
        let disposeBag = DisposeBag()
        if let topVC = UIApplication.shared.getTopViewController() {
            switch file.source {
            case let .localFile(url, _):
                let preview = DocumentPreview(url: url)
                disposeBag += topVC.present(preview.journey)
            case .url(let url):
                let preview = DocumentPreview(url: url)
                disposeBag += topVC.present(preview.journey)
            }
        }
    }

    private func getSource() -> Kingfisher.Source {
        switch file.source {
        case .localFile(let url, _):
            return Kingfisher.Source.provider(LocalFileImageDataProvider(fileURL: url, cacheKey: file.id))
        case .url(let url):
            return Kingfisher.Source.network(
                Kingfisher.ImageResource(downloadURL: url, cacheKey: file.id)
            )
        }
    }
}

#Preview{
    let file: File = .init(
        id: "imageId1",
        size: 22332,
        mimeType: .PNG,
        name: "test-image",
        source: .url(
            url: URL(string: "https://filesamples.com/samples/image/png/sample_640%C3%97426.png")!
        )
    )
    let file2: File = .init(
        id: "imageId1",
        size: 22332,
        mimeType: .GIF,
        name: "test-image",
        source: .url(
            url: URL(string: "https://media4.giphy.com/media/nrXif9YExO9EI/giphy.gif")!
        )
    )

    let file3: File = .init(
        id: "imageId1",
        size: 22332,
        mimeType: .other(type: ""),
        name: "test-image",
        source: .url(
            url: URL(string: "https://media4.giphy.com/media/nrXif9YExO9EI/giphy.gif")!
        )
    )

    return
        VStack {
            ChatFileView(file: file)
            ChatFileView(file: file2)
            ChatFileView(file: file3)
            Spacer()
        }
}
