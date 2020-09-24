import Flow
import FlowFeedback
import Form
import Foundation
import hCore
import UIKit

public enum ButtonType {
    case standard(backgroundColor: UIColor, textColor: UIColor)
    case standardIcon(backgroundColor: UIColor, textColor: UIColor, icon: ButtonIcon)
    case standardSmall(backgroundColor: UIColor, textColor: UIColor)
    case standardOutline(borderColor: UIColor, textColor: UIColor)
    case tinyIcon(backgroundColor: UIColor, textColor: UIColor, icon: ButtonIcon)
    case outline(borderColor: UIColor, textColor: UIColor)
    case pillSemiTransparent(backgroundColor: UIColor, textColor: UIColor)
    case transparent(textColor: UIColor)
    case iconTransparent(textColor: UIColor, icon: ButtonIcon)

    public enum ButtonIcon {
        case left(image: UIImage, width: CGFloat)
        case right(image: UIImage, width: CGFloat)

        var width: CGFloat {
            switch self {
            case let .left(_, width):
                return width
            case let .right(_, width):
                return width
            }
        }

        var image: UIImage {
            switch self {
            case let .left(image, _):
                return image
            case let .right(image, _):
                return image
            }
        }
    }

    var backgroundOpacity: CGFloat {
        switch self {
        case .standard, .standardSmall, .standardIcon, .tinyIcon:
            return 1
        case .outline, .transparent, .standardOutline:
            return 0
        case .pillSemiTransparent:
            return 0.6
        case .iconTransparent:
            return 0.0
        }
    }

    var highlightedBackgroundOpacity: CGFloat {
        switch self {
        case .standard, .standardSmall, .standardIcon, .tinyIcon:
            return 1
        case .outline, .standardOutline:
            return 0.05
        case .pillSemiTransparent:
            return 0.6
        case .iconTransparent:
            return 0.05
        case .transparent:
            return 0
        }
    }

    public var backgroundColor: UIColor {
        switch self {
        case let .standard(backgroundColor, _):
            return backgroundColor
        case let .standardSmall(backgroundColor, _):
            return backgroundColor
        case let .standardIcon(backgroundColor, _, _):
            return backgroundColor
        case let .tinyIcon(backgroundColor, _, _):
            return backgroundColor
        case let .outline(borderColor, _):
            return borderColor
        case let .standardOutline(borderColor, _):
            return borderColor
        case let .pillSemiTransparent(backgroundColor, _):
            return backgroundColor
        case .iconTransparent:
            return .black
        case .transparent:
            return .clear
        }
    }

    var textColor: UIColor {
        switch self {
        case let .standard(_, textColor):
            return textColor
        case let .standardSmall(_, textColor):
            return textColor
        case let .standardIcon(_, textColor, _):
            return textColor
        case let .tinyIcon(_, textColor, _):
            return textColor
        case let .outline(_, textColor):
            return textColor
        case let .standardOutline(_, textColor):
            return textColor
        case let .pillSemiTransparent(_, textColor):
            return textColor
        case let .iconTransparent(textColor, _):
            return textColor
        case let .transparent(textColor):
            return textColor
        }
    }

    public var height: CGFloat {
        switch self {
        case .standard, .standardIcon, .standardOutline:
            return 50
        case .standardSmall:
            return 34
        case .outline:
            return 34
        case .pillSemiTransparent:
            return 30
        case .iconTransparent:
            return 30
        case .tinyIcon:
            return 30
        case .transparent:
            return 30
        }
    }

    var textStyle: TextStyle {
        switch self {
        case .standard, .outline, .standardIcon, .standardOutline:
            return TextStyle.brand(.body(color: .primary(state: .negative))).colored(textColor)
        case .standardSmall:
            return TextStyle.brand(.subHeadline(color: .primary(state: .negative))).colored(textColor)
        case .pillSemiTransparent:
            return TextStyle.brand(.caption1(color: .primary(state: .negative))).colored(textColor)
        case .iconTransparent:
            return TextStyle.brand(.subHeadline(color: .primary(state: .negative))).colored(textColor)
        case .tinyIcon:
            return TextStyle.brand(.caption2(color: .primary(state: .negative))).colored(textColor)
        case .transparent:
            return TextStyle.brand(.caption2(color: .primary(state: .negative))).colored(textColor)
        }
    }

    public var extraWidthOffset: CGFloat {
        switch self {
        case .standard, .standardIcon, .standardOutline:
            return 50
        case .standardSmall:
            return 35
        case .outline:
            return 35
        case .pillSemiTransparent:
            return 35
        case .iconTransparent:
            return 35
        case .tinyIcon:
            return 20
        case .transparent:
            return 35
        }
    }

    var icon: ButtonIcon? {
        switch self {
        case let .iconTransparent(_, icon):
            return icon
        case let .standardIcon(_, _, icon):
            return icon
        case let .tinyIcon(_, _, icon):
            return icon
        default:
            return nil
        }
    }

    var iconColor: UIColor? {
        switch self {
        case .iconTransparent:
            return textColor
        case .standardIcon:
            return textColor
        case .tinyIcon:
            return textColor
        default:
            return nil
        }
    }

    var iconDistance: CGFloat {
        switch self {
        case .iconTransparent:
            return 7
        case .standardIcon:
            return 4
        case .tinyIcon:
            return 3
        default:
            return 0
        }
    }

    var borderWidth: CGFloat {
        switch self {
        case .outline, .standardOutline:
            return 1
        default:
            return 0
        }
    }

    var borderColor: UIColor {
        switch self {
        case let .outline(borderColor, _):
            return borderColor
        case let .standardOutline(borderColor, _):
            return borderColor
        default:
            return UIColor.clear
        }
    }
}

public struct Button {
    private let onTapReadWriteSignal = ReadWriteSignal<Void>(())

    private let id = UUID()
    public let title: ReadWriteSignal<DisplayableString>
    public let onTapSignal: Signal<Void>
    public let type: ReadWriteSignal<ButtonType>
    public let animate: Bool

    public init(title: DisplayableString, type: ButtonType, animate: Bool = true) {
        self.title = ReadWriteSignal(title)
        onTapSignal = onTapReadWriteSignal.plain()
        self.type = ReadWriteSignal<ButtonType>(type)
        self.animate = animate
    }
}

extension Button: Equatable {
    public static func == (lhs: Button, rhs: Button) -> Bool {
        lhs.id == rhs.id
    }
}

extension Button: Viewable {
    public static var trackingHandler: (_ button: Button) -> Void = { _ in }

    public func materialize(events _: ViewableEvents) -> (UIButton, Disposable) {
        let bag = DisposeBag()

        let styleSignal = ReadWriteSignal<ButtonStyle>(ButtonStyle.default)
        let highlightedStyleSignal = ReadWriteSignal<ButtonStyle>(ButtonStyle.default)

        func updateStyle(buttonType: ButtonType) {
            styleSignal.value = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
                style.buttonType = .custom

                let backgroundColor = buttonType.backgroundColor.withAlphaComponent(buttonType.backgroundOpacity)

                style.states = [
                    .normal: ButtonStateStyle(
                        background: BackgroundStyle(
                            color: backgroundColor,
                            border: BorderStyle(
                                width: buttonType.borderWidth,
                                color: buttonType.borderColor,
                                cornerRadius: 6
                            )
                        ),
                        text: buttonType.textStyle
                    ),
                ]
            }
        }

        func updateHighlightedStyle(buttonType: ButtonType) {
            highlightedStyleSignal.value = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
                style.buttonType = .custom

                let backgroundColor: UIColor
                if buttonType.backgroundColor.isLight() {
                    backgroundColor = buttonType.backgroundColor.darkened(amount: 0.05).withAlphaComponent(buttonType.highlightedBackgroundOpacity)
                } else {
                    backgroundColor = buttonType.backgroundColor.lighter(amount: 0.10).withAlphaComponent(buttonType.highlightedBackgroundOpacity)
                }

                style.states = [
                    .normal: ButtonStateStyle(
                        background: BackgroundStyle(
                            color: backgroundColor,
                            border: BorderStyle(
                                width: buttonType.borderWidth,
                                color: buttonType.borderColor,
                                cornerRadius: 6
                            )
                        ),
                        text: buttonType.textStyle
                    ),
                ]
            }
        }

        bag += type.atOnce().onValue { buttonType in
            updateStyle(buttonType: buttonType)
        }

        bag += type.atOnce().onValue { buttonType in
            updateHighlightedStyle(buttonType: buttonType)
        }

        let button = UIButton(title: "", style: styleSignal.value)

        bag += button.traitCollectionSignal.onValue { _ in
            updateStyle(buttonType: self.type.value)
            updateHighlightedStyle(buttonType: self.type.value)
        }

        bag += styleSignal
            .atOnce()
            .compactMap { $0 }
            .bindTo(
                transition: button,
                style: TransitionStyle.crossDissolve(duration: 0.25),
                button,
                \.style
            )

        button.adjustsImageWhenHighlighted = false

        let iconImageView = UIImageView()
        button.addSubview(iconImageView)

        bag += type.atOnce().onValue { type in
            if let icon = type.icon {
                iconImageView.isHidden = false
                iconImageView.image = icon.image.withRenderingMode(.alwaysTemplate)

                if let iconColor = type.iconColor {
                    iconImageView.tintColor = iconColor
                }

                iconImageView.contentMode = .scaleAspectFit

                let iconDistance = type.iconDistance

                switch icon {
                case .left:
                    button.titleEdgeInsets = UIEdgeInsets(
                        top: 0,
                        left: icon.width + iconDistance,
                        bottom: 0,
                        right: 0
                    )
                case .right:
                    button.titleEdgeInsets = UIEdgeInsets(
                        top: 0,
                        left: 0,
                        bottom: 0,
                        right: icon.width + iconDistance
                    )
                }

                button.addSubview(iconImageView)

                iconImageView.snp.makeConstraints { make in
                    switch icon {
                    case .left:
                        make.left.equalTo(type.extraWidthOffset / 2)
                    case .right:
                        make.right.equalTo(-type.extraWidthOffset / 2)
                    }

                    make.centerY.equalToSuperview()
                    make.height.equalTo(type.height)
                    make.width.equalTo(icon.width)
                }
            } else {
                iconImageView.isHidden = true
            }
        }

        bag += title.atOnce().withLatestFrom(type).onValueDisposePrevious { title, type in
            let innerBag = DisposeBag()

            button.setTitle(title)

            let iconWidth = type.icon != nil ? (type.icon?.width ?? 0) + type.iconDistance : 0

            innerBag += button.didLayoutSignal.take(first: 1).onValue { _ in
                button.snp.updateConstraints { make in
                    make.width.equalTo(
                        button.intrinsicContentSize.width + type.extraWidthOffset + iconWidth
                    )
                }
            }

            return innerBag
        }

        bag += button.signal(for: .touchDown).filter { self.animate }
            .withLatestFrom(highlightedStyleSignal.atOnce().plain())
            .map { _, highlightedStyleSignalValue -> ButtonStyle in
                highlightedStyleSignalValue
            }.bindTo(
                transition: button,
                style: TransitionStyle.crossDissolve(duration: 0.25),
                button,
                \.style
            )

        let touchUpInside = button.signal(for: .touchUpInside)
        bag += touchUpInside.feedback(type: .impactLight)

        bag += touchUpInside.map { _ -> Void in
            ()
        }.bindTo(onTapReadWriteSignal)

        bag += touchUpInside.filter { self.animate }
            .withLatestFrom(styleSignal.atOnce().plain())
            .map { _, styleSignalValue -> ButtonStyle in
                styleSignalValue
            }.delay(by: 0.1).bindTo(
                transition: button,
                style: TransitionStyle.crossDissolve(duration: 0.25),
                button,
                \.style
            )

        bag += touchUpInside.onValue { _ in
            Button.trackingHandler(self)
        }

        bag += merge(
            button.signal(for: .touchUpOutside),
            button.signal(for: .touchCancel)
        ).filter { self.animate }
            .withLatestFrom(styleSignal.atOnce().plain())
            .map { _, styleSignalValue -> ButtonStyle in
                styleSignalValue
            }.bindTo(
                transition: button,
                style: TransitionStyle.crossDissolve(duration: 0.25),
                button,
                \.style
            )

        button.snp.makeConstraints { make in
            make.width.equalTo(0)
            make.height.equalTo(0)
        }

        bag += button.didLayoutSignal.take(first: 1).onValue { _ in
            let type = self.type.value
            let iconWidth = type.icon != nil ? (type.icon?.width ?? 0) + type.iconDistance : 0

            button.snp.updateConstraints { make in
                make.width.equalTo(button.intrinsicContentSize.width + self.type.value.extraWidthOffset + iconWidth)
                make.height.equalTo(self.type.value.height)
            }
            button.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
            }
        }

        return (button, bag)
    }
}
