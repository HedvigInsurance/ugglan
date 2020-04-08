//
//  Button.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-19.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

//import Firebase
//import FirebaseAnalytics
import Flow
import Form
import Foundation
import UIKit

enum ButtonType {
    case standard(backgroundColor: UIColor, textColor: UIColor)
    case standardIcon(backgroundColor: UIColor, textColor: UIColor, icon: ButtonIcon)
    case standardSmall(backgroundColor: UIColor, textColor: UIColor)
    case standardOutline(borderColor: UIColor, textColor: UIColor)
    case tinyIcon(backgroundColor: UIColor, textColor: UIColor, icon: ButtonIcon)
    case outline(borderColor: UIColor, textColor: UIColor)
    case pillSemiTransparent(backgroundColor: UIColor, textColor: UIColor)
    case transparent(textColor: UIColor)
    case iconTransparent(textColor: UIColor, icon: ButtonIcon)

    enum ButtonIcon {
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

    var backgroundColor: UIColor {
        switch self {
        case let .standard((backgroundColor, _)):
            return backgroundColor
        case let .standardSmall((backgroundColor, _)):
            return backgroundColor
        case let .standardIcon((backgroundColor, _, _)):
            return backgroundColor
        case let .tinyIcon((backgroundColor, _, _)):
            return backgroundColor
        case let .outline((borderColor, _)):
            return borderColor
        case let .standardOutline((borderColor, _)):
            return borderColor
        case let .pillSemiTransparent((backgroundColor, _)):
            return backgroundColor
        case .iconTransparent((_, _)):
            return .purple
        case .transparent:
            return .transparent
        }
    }

    var textColor: UIColor {
        switch self {
        case let .standard((_, textColor)):
            return textColor
        case let .standardSmall((_, textColor)):
            return textColor
        case let .standardIcon((_, textColor, _)):
            return textColor
        case let .tinyIcon((_, textColor, _)):
            return textColor
        case let .outline((_, textColor)):
            return textColor
        case let .standardOutline((_, textColor)):
            return textColor
        case let .pillSemiTransparent((_, textColor)):
            return textColor
        case let .iconTransparent((textColor, _)):
            return textColor
        case let .transparent(textColor):
            return textColor
        }
    }

    var height: CGFloat {
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

    var fontSize: CGFloat {
        switch self {
        case .standard, .standardSmall, .outline, .standardIcon, .standardOutline:
            return 15
        case .pillSemiTransparent:
            return 13
        case .iconTransparent:
            return 14
        case .tinyIcon:
            return 10
        case .transparent:
            return 13
        }
    }

    var extraWidthOffset: CGFloat {
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
        case let .iconTransparent((_, icon)):
            return icon
        case let .standardIcon((_, _, icon)):
            return icon
        case let .tinyIcon((_, _, icon)):
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
        case let .outline((borderColor, _)):
            return borderColor
        case let .standardOutline((borderColor, _)):
            return borderColor
        default:
            return UIColor.clear
        }
    }
}

struct Button {
    private let onTapReadWriteSignal = ReadWriteSignal<Void>(())

    private let id = UUID()
    let title: ReadWriteSignal<String>
    let onTapSignal: Signal<Void>
    let type: ReadWriteSignal<ButtonType>
    let animate: Bool

    init(title: String, type: ButtonType, animate: Bool = true) {
        self.title = ReadWriteSignal(title)
        onTapSignal = onTapReadWriteSignal.plain()
        self.type = ReadWriteSignal<ButtonType>(type)
        self.animate = animate
    }
}

extension Button: Equatable {
    static func == (lhs: Button, rhs: Button) -> Bool {
        lhs.id == rhs.id
    }
}

extension Button: Viewable {
    func materialize(events: ViewableEvents) -> (UIButton, Disposable) {
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
                        text: TextStyle(
                            font: HedvigFonts.favoritStdBook!.withSize(buttonType.fontSize),
                            color: buttonType.textColor
                        )
                    ),
                ]
            }
        }

        func updateHighlightedStyle(buttonType: ButtonType) {
            highlightedStyleSignal.value = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
                style.buttonType = .custom

                let backgroundColor = buttonType.backgroundColor.darkened(amount: 0.05).withAlphaComponent(buttonType.highlightedBackgroundOpacity)
                let textColor = buttonType.textColor

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
                        text: TextStyle(
                            font: HedvigFonts.favoritStdBook!.withSize(buttonType.fontSize),
                            color: textColor
                        )
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

        bag += touchUpInside.withLatestFrom(title.atOnce().plain()).onValue { _, title in
//            if let localizationKey = title.localizationKey?.description {
//                Analytics.logEvent(localizationKey, parameters: [
//                    "context": "Button",
//                ])
//            }
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

        button.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.width.equalTo(button.intrinsicContentSize.width + self.type.value.extraWidthOffset)
            make.height.equalTo(self.type.value.height)
            make.centerX.equalToSuperview()
        }

        return (button, bag)
    }
}
