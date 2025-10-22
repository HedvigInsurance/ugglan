import Kingfisher
import SVGKit

public struct SVGImageProcessor: ImageProcessor {
    public init() {}

    public var identifier: String = "com.appidentifier.webpprocessor"
    public func process(item: ImageProcessItem, options _: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case let .image(image):
            return image
        case let .data(data):
            let imsvg = SVGKImage(data: data)
            return imsvg?.uiImage
        }
    }
}
