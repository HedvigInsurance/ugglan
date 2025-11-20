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
            .placeholder { _ in
                ProgressView()
                    .foregroundColor(hTextColor.Opaque.primary)
                    .environment(\.colorScheme, .light)
            }
            .targetCache(ImageCache.default)
            .setProcessor(processor)
            .resizable()
            .aspectRatio(
                contentMode: .fill
            )
            .frame(width: 140, height: 140)
            .contentShape(Rectangle())
        }
    }

    var otherFile: some View {
        RoundedRectangle(cornerRadius: .cornerRadiusL)
            .fill(hSurfaceColor.Opaque.primary)
            .frame(width: 140, height: 140)
            .overlay {
                VStack {
                    if !file.name.isEmpty {
                        hText(file.name, style: .finePrint)
                            .foregroundColor(hTextColor.Opaque.secondary)
                            .padding(.padding8)
                    } else {
                        hText("." + file.mimeType.name, style: .heading2)
                            .foregroundColor(hTextColor.Opaque.primary)
                    }
                }
            }
    }

    func showFile() {
        switch file.source {
        case let .localFile(results):
            if let results {
                Task {
                    do {
                        let data = try await results.itemProvider.getData()
                        chatNavigationVm.isFilePresented = .data(
                            data: data.data,
                            name: file.name,
                            mimeType: data.mimeType
                        )
                    } catch _ {}
                }
            }
        case let .url(url, mimeType):
            chatNavigationVm.isFilePresented = .url(url: url, name: file.name, mimeType: mimeType)
        case let .data(data):
            chatNavigationVm.isFilePresented = .data(data: data, name: file.name, mimeType: file.mimeType)
        }
    }

    private func getSource() -> Kingfisher.Source {
        switch file.source {
        case let .localFile(results):
            return Kingfisher.Source.provider(
                hPHPickerResultImageDataProvider(cacheKey: file.id, pickerResult: results!)
            )
        case let .url(url, _):
            return Kingfisher.Source.network(
                Kingfisher.KF.ImageResource(downloadURL: url, cacheKey: file.id)
            )
        case let .data(data):
            return Kingfisher.Source.provider(InMemoryImageDataProvider(cacheKey: file.id, data: data))
        }
    }
}

#Preview {
    let file: File = .init(
        id: "imageId1",
        size: 22332,
        mimeType: .PNG,
        name: "test-image",
        source: .url(
            url: URL(string: "https://filesamples.com/samples/image/png/sample_640%C3%97426.png")!,
            mimeType: .PNG
        )
    )
    let file2: File = .init(
        id: "imageId1",
        size: 22332,
        mimeType: .GIF,
        name: "test-image",
        source: .url(
            url: URL(string: "https://media4.giphy.com/media/nrXif9YExO9EI/giphy.gif")!,
            mimeType: .GIF
        )
    )

    let file3: File = .init(
        id: "imageId1",
        size: 22332,
        mimeType: .other(type: ""),
        name: "test-image",
        source: .url(
            url: URL(string: "https://media4.giphy.com/media/nrXif9YExO9EI/giphy.gif")!,
            mimeType: .GIF
        )
    )

    return VStack {
        ChatFileView(file: file)
        ChatFileView(file: file2)
        ChatFileView(file: file3)
        Spacer()
    }
}
