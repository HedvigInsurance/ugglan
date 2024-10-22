import Kingfisher
import PhotosUI
import SwiftUI
import hCore

public struct FileView: View {
    let file: File
    let imageDataProvider: ImageDataProvider?
    let onTap: () -> Void
    let processor = DownsamplingImageProcessor(
        size: CGSize(width: 300, height: 300)
    )

    public init(file: File, onTap: @escaping () -> Void) {
        self.file = file
        self.onTap = onTap
        switch file.source {
        case let .localFile(results):
            self.imageDataProvider = hPHPickerResultImageDataProvider(cacheKey: file.id, pickerResult: results!)
        case .url:
            self.imageDataProvider = nil
        case let .data(data):
            self.imageDataProvider = nil
        }
    }

    @ViewBuilder
    public var body: some View {
        VStack {
            if file.mimeType.isImage {
                switch file.source {
                case let .localFile(url):
                    imageFromLocalFile(results: url!)
                case .url(let url):
                    imageFromRemote(url: url)
                case let .data(data):
                    if let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(
                                contentMode: .fill
                            )
                    }
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

    private func imageFromLocalFile(results: PHPickerResult) -> some View {
        Rectangle().fill(.clear)
            .aspectRatio(1, contentMode: .fill)
            .background(
                KFImage(source: Kingfisher.Source.provider(imageDataProvider!))
                    .fade(duration: 0.25)
                    //                    .setProcessor(processor)
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

public struct hPHPickerResultImageDataProvider: ImageDataProvider {

    /// The possible error might be caused by the `PHPickerResultImageDataProvider`.
    /// - invalidImage: The retrieved image is invalid.
    public enum PHPickerResultImageDataProviderError: Error {
        /// An error happens during picking up image through the item provider of `PHPickerResult`.
        case pickerProviderError(any Error)
        /// The retrieved image is invalid.
        case invalidImage
    }

    /// The picker result bound to `self`.
    public let pickerResult: PHPickerResult

    /// The content type of the image.
    public let contentType: UTType

    private var internalKey: String {
        pickerResult.assetIdentifier ?? UUID().uuidString
    }

    public var cacheKey: String

    /// Creates an image data provider from a given `PHPickerResult`.
    /// - Parameters:
    ///  - pickerResult: The picker result to provide image data.
    ///  - contentType: The content type of the image. Default is `UTType.image`.
    public init(cacheKey: String, pickerResult: PHPickerResult, contentType: UTType = UTType.image) {
        self.cacheKey = cacheKey
        self.pickerResult = pickerResult
        self.contentType = contentType
    }

    public func data(handler: @escaping @Sendable (Result<Data, any Error>) -> Void) {
        pickerResult.itemProvider.loadDataRepresentation(forTypeIdentifier: contentType.identifier) { data, error in
            if let error {
                handler(.failure(PHPickerResultImageDataProviderError.pickerProviderError(error)))
                return
            }

            guard let data else {
                handler(.failure(PHPickerResultImageDataProviderError.invalidImage))
                return
            }

            handler(.success(data))
        }
    }
}
