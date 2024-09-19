import Kingfisher
import SwiftUI
import hCore
import hCoreUI

struct ChatFileView: View {
    let file: File
    let status: MessageStatus
    @EnvironmentObject var chatNavigationVm: ChatNavigationViewModel

    init(file: File, status: MessageStatus = .draft) {
        self.file = file
        self.status = status
    }
    let processor = DownsamplingImageProcessor(
        size: CGSize(width: 300, height: 300)
    )
    @ViewBuilder
    var body: some View {
        if case .failed = status {
            fileView
        } else {
            fileView
                .onTapGesture {
                    showFile()
                }
        }
    }

    private var fileView: some View {
        Group {
            if file.mimeType.isImage {
                imageView
            } else {
                otherFile
            }
        }
    }

    @ViewBuilder
    var imageView: some View {
        if file.mimeType == .GIF, let url = file.url {
            KFAnimatedImage(
                source: Kingfisher.Source.network(
                    Kingfisher.KF.ImageResource(downloadURL: url, cacheKey: file.id)
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
                    .foregroundColor(hTextColor.Opaque.primary)
                    .environment(\.colorScheme, .light)

            })
            .targetCache(ImageCache.default)
            .setProcessor(processor)
            .resizable()
            .aspectRatio(
                contentMode: .fill
            )
            .frame(width: 140, height: 140)
        }
    }

    var otherFile: some View {
        RoundedRectangle(cornerRadius: .cornerRadiusL)
            .fill(hSurfaceColor.Opaque.primary)
            .frame(width: 140, height: 140)
            .overlay {
                VStack {
                    hText("." + file.mimeType.name, style: .heading2)
                        .foregroundColor(hTextColor.Opaque.primary)

                    // we are missing name so we dont show it
                    // hText(file.name, style: .finePrint)
                    // .foregroundColor(hTextColor.Opaque.secondary)
                }
            }
    }

    func showFile() {
        switch file.source {
        case let .localFile(url, _):
            chatNavigationVm.isFilePresented = .init(url: url)
        case .url(let url):
            chatNavigationVm.isFilePresented = .init(url: url)
        case .data(let data):
            break
        }
    }

    private func getSource() -> Kingfisher.Source {
        switch file.source {
        case .localFile(let url, _):
            return Kingfisher.Source.provider(LocalFileImageDataProvider(fileURL: url, cacheKey: file.id))
        case .url(let url):
            return Kingfisher.Source.network(
                Kingfisher.KF.ImageResource(downloadURL: url, cacheKey: file.id)
            )
        case .data(let data):
            return Kingfisher.Source.provider(InMemoryImageDataProvider(cacheKey: file.id, data: data))
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

public struct InMemoryImageDataProvider: ImageDataProvider {

    public var cacheKey: String
    let data: Data
    /// Provides the data which represents image. Kingfisher uses the data you pass in the
    /// handler to process images and caches it for later use.
    ///
    /// - Parameter handler: The handler you should call when you prepared your data.
    ///                      If the data is loaded successfully, call the handler with
    ///                      a `.success` with the data associated. Otherwise, call it
    ///                      with a `.failure` and pass the error.
    ///
    /// - Note:
    /// If the `handler` is called with a `.failure` with error, a `dataProviderError` of
    /// `ImageSettingErrorReason` will be finally thrown out to you as the `KingfisherError`
    /// from the framework.
    public func data(handler: @escaping (Result<Data, Error>) -> Void) {
        handler(.success(data))
    }

    /// The content URL represents this provider, if exists.
    public var contentURL: URL?

}
