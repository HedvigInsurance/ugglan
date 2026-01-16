import Kingfisher
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers
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
                case let .localFile(url):
                    imageFromLocalFile(results: url!)
                case let .url(url, _):
                    imageFromRemote(url: url)
                case let .data(data):
                    Rectangle().fill(.clear)
                        .aspectRatio(1, contentMode: .fill)
                        .background(
                            KFImage(
                                source: Kingfisher.Source.provider(
                                    InMemoryImageDataProvider(cacheKey: file.id, data: data)
                                )
                            )
                            .fade(duration: 0.25)
                            .setProcessor(processor)
                            .resizable()
                            .aspectRatio(
                                contentMode: .fill
                            )
                            .accessibilityHidden(true)
                        )
                }
            } else {
                GeometryReader { geometry in
                    VStack(spacing: .padding4) {
                        fileImage
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
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(file.name)
    }

    private var fileImage: Image {
        switch file.mimeType {
        case .PDF:
            return hCoreUIAssets.pdf.view
        default:
            return hCoreUIAssets.file.view
        }
    }

    private func imageFromLocalFile(results: PHPickerResult) -> some View {
        Rectangle().fill(.clear)
            .aspectRatio(1, contentMode: .fill)
            .background(
                KFImage(
                    source: Kingfisher.Source.provider(
                        hPHPickerResultImageDataProvider(cacheKey: file.id, pickerResult: results)
                    )
                )
                .fade(duration: 0.25)
                .setProcessor(processor)
                .resizable()
                .aspectRatio(
                    contentMode: .fill
                )
                .accessibilityHidden(true)
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
                        .accessibilityHidden(true)
                )
        } else {
            Rectangle().fill(.clear)
                .scaledToFill()
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
                    .accessibilityHidden(true)
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
        Task {
            do {
                let results = try await pickerResult.itemProvider.getData()
                handler(.success(results.data))
            } catch {
                handler(.failure(PHPickerResultImageDataProviderError.pickerProviderError(error)))
            }
        }
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
    ///
    public init(cacheKey: String, data: Data, contentURL: URL? = nil) {
        self.cacheKey = cacheKey
        self.data = data
        self.contentURL = contentURL
    }

    public func data(handler: @escaping (Result<Data, Error>) -> Void) {
        handler(.success(data))
    }

    /// The content URL represents this provider, if exists.
    public var contentURL: URL?
}
