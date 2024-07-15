import Kingfisher
import SwiftUI
import hCore

public struct FileView: View {
    let file: File
    let onTap: () -> Void
    let processor = DownsamplingImageProcessor(
        size: CGSize(width: 300, height: 300)
    )

    public init(file: File, onTap: @escaping () -> Void) {
        self.file = file
        self.onTap = onTap
    }

    @ViewBuilder
    public var body: some View {
        VStack {
            if file.mimeType.isImage {
                switch file.source {
                case let .localFile(imageUrl, thumbnailUrl):
                    imageFromLocalFile(url: thumbnailUrl ?? imageUrl)
                case .url(let url):
                    imageFromRemote(url: url)
                }
            } else {
                GeometryReader { geometry in
                    VStack(spacing: 4) {
                        Image(uiImage: fileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(hTextColor.Opaque.secondary)
                            .padding(.horizontal, geometry.size.width / 3)
                            .padding(.top, geometry.size.height / 5)

                        hSection {
                            hText(file.name, style: .finePrint)
                                .foregroundColor(hTextColor.Opaque.secondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                        }
                        .sectionContainerStyle(.transparent)
                    }
                }
                .background(hSurfaceColor.Opaque.primary)
            }
        }
        .onTapGesture {
            onTap()
        }
    }

    private var fileImage: UIImage {
        switch file.mimeType {
        case .PDF:
            return hCoreUIAssets.pdf.image
        default:
            return hCoreUIAssets.file.image
        }
    }

    private func imageFromLocalFile(url: URL) -> some View {
        Rectangle().fill(.clear)
            .aspectRatio(1, contentMode: .fill)
            .background(
                KFImage(source: Kingfisher.Source.provider(LocalFileImageDataProvider(fileURL: url, cacheKey: file.id)))
                    .fade(duration: 0.25)
                    .setProcessor(processor)
                    .resizable()
                    .aspectRatio(
                        contentMode: .fill
                    )
            )
    }

    @ViewBuilder
    private func imageFromRemote(url: URL) -> some View {
        if file.mimeType == .GIF {
            Rectangle().fill(.clear)
                .aspectRatio(1, contentMode: .fill)
                .background(
                    KFAnimatedImage(url)
                        .scaledToFit()
                )
        } else {
            Rectangle().fill(.clear)
                .aspectRatio(1, contentMode: .fill)
                .background(
                    KFImage(
                        source: Kingfisher.Source.network(
                            Kingfisher.KF.ImageResource(downloadURL: url, cacheKey: file.id)
                        )
                    )
                    .fade(duration: 0.25)
                    .targetCache(ImageCache.default)
                    .setProcessor(processor)
                    .resizable()
                    .aspectRatio(
                        contentMode: .fill
                    )
                )
        }

    }
}
