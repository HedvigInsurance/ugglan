import Flow
import UIKit

public enum HomeSectionStyle {
    case horizontal
    case vertical
    case header
}

public struct HomeSection {
    public init(
        title: String,
        style: HomeSectionStyle,
        children: [HomeChild]
    ) {
        self.title = title
        self.style = style
        self.children = children
    }

    public var title: String
    public var style: HomeSectionStyle
    public var children: [HomeChild]
}

public struct HomeChild {
    public init(
        title: String,
        icon: UIImage,
        handler: @escaping (UIViewController) -> Disposable
    ) {
        self.title = title
        self.icon = icon
        self.handler = handler
    }

    public var title: String
    public var icon: UIImage
    public var handler: (UIViewController) -> Disposable
}
