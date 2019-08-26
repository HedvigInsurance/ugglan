//
//  Button.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-19.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Firebase
import FirebaseAnalytics
import Flow
import Form
import Foundation
import UIKit

enum ButtonType {
    case standard(backgroundColor: HedvigColor, textColor: HedvigColor)
    case standardIcon(backgroundColor: HedvigColor, textColor: HedvigColor, icon: ButtonIcon)
    case standardSmall(backgroundColor: HedvigColor, textColor: HedvigColor)
    case tinyIcon(backgroundColor: HedvigColor, textColor: HedvigColor, icon: ButtonIcon)
    case outline(borderColor: HedvigColor, textColor: HedvigColor)
    case pillTransparent(backgroundColor: HedvigColor, textColor: HedvigColor)
    case iconTransparent(textColor: HedvigColor, icon: ButtonIcon)

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
        case .outline:
            return 0
        case .pillTransparent:
            return 0.6
        case .iconTransparent:
            return 0.0
        }
    }

    var highlightedBackgroundOpacity: CGFloat {
        switch self {
        case .standard, .standardSmall, .standardIcon, .tinyIcon:
            return 1
        case .outline:
            return 0.05
        case .pillTransparent:
            return 0.6
        case .iconTransparent:
            return 0.05
        }
    }

    var backgroundColor: HedvigColor {
        switch self {
        case let .standard((backgroundColor, _)):
            return backgroundColor
        case let .standardSmall((backgroundColor, _)):
            return backgroundColor
        case let .standardIcon((backgroundColor, _, _)):
            return backgroundColor
        case let .tinyIcon((backgroundColor, _, _)):
            return backgroundColor
        case .outline((_, _)):
            return .purple
        case let .pillTransparent((backgroundColor, _)):
            return backgroundColor
        case .iconTransparent((_, _)):
            return .purple
        }
    }

    var textColor: HedvigColor {
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
        case let .pillTransparent((_, textColor)):
            return textColor
        case let .iconTransparent((textColor, _)):
            return textColor
        }
    }

    var height: CGFloat {
        switch self {
        case .standard, .standardIcon:
            return 50
        case .standardSmall:
            return 34
        case .outline:
            return 34
        case .pillTransparent:
            return 30
        case .iconTransparent:
            return 30
        case .tinyIcon:
            return 30
        }
    }

    var fontSize: CGFloat {
        switch self {
        case .standard, .standardSmall, .outline, .standardIcon:
            return 15
        case .pillTransparent:
            return 13
        case .iconTransparent:
            return 14
        case .tinyIcon:
            return 10
        }
    }

    var extraWidthOffset: CGFloat {
        switch self {
        case .standard, .standardIcon:
            return 50
        case .standardSmall:
            return 35
        case .outline:
            return 35
        case .pillTransparent:
            return 35
        case .iconTransparent:
            return 35
        case .tinyIcon:
            return 20
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

    var iconColor: HedvigColor? {
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
        case .outline:
            return 1
        default:
            return 0
        }
    }

    var borderColor: UIColor {
        switch self {
        case let .outline((borderColor, _)):
            return UIColor.from(apollo: borderColor)
        default:
            return UIColor.clear
        }
    }
}

struct Button {
    private let onTapReadWriteSignal = ReadWriteSignal<Void>(())

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

extension Button: Viewable {
    func materialize(events: ViewableEvents) -> (UIButton, Disposable) {
        let bag = DisposeBag()

        let styleSignal = ReadWriteSignal<ButtonStyle>(ButtonStyle.default)
        let highlightedStyleSignal = ReadWriteSignal<ButtonStyle>(ButtonStyle.default)

        bag += type.atOnce().onValue { buttonType in
            styleSignal.value = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
                style.buttonType = .custom

                let backgroundColor = UIColor.from(
                    apollo: buttonType.backgroundColor
                ).withAlphaComponent(buttonType.backgroundOpacity)
                let textColor = UIColor.from(apollo: buttonType.textColor)

                style.states = [
                    .normal: ButtonStateStyle(
                        background: BackgroundStyle(
                            color: backgroundColor,
                            border: BorderStyle(
                                width: buttonType.borderWidth,
                                color: buttonType.borderColor,
                                cornerRadius: buttonType.height / 2
                            )
                        ),
                        text: TextStyle(
                            font: HedvigFonts.circularStdBook!.withSize(buttonType.fontSize),
                            color: textColor
                        )
                    ),
                ]
            }
        }

        bag += type.atOnce().onValue { buttonType in
            highlightedStyleSignal.value = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
                style.buttonType = .custom

                let backgroundColor = UIColor.from(
                    apollo: buttonType.backgroundColor
                ).darkened(amount: 0.05).withAlphaComponent(buttonType.highlightedBackgroundOpacity)
                let textColor = UIColor.from(apollo: buttonType.textColor)

                style.states = [
                    .normal: ButtonStateStyle(
                        background: BackgroundStyle(
                            color: backgroundColor,
                            border: BorderStyle(
                                width: buttonType.borderWidth,
                                color: buttonType.borderColor,
                                cornerRadius: buttonType.height / 2
                            )
                        ),
                        text: TextStyle(
                            font: HedvigFonts.circularStdBook!.withSize(buttonType.fontSize),
                            color: textColor
                        )
                    ),
                ]
            }
        }

        let button = UIButton(title: "", style: styleSignal.value)

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

        bag += type.atOnce().onValue({ type in
            if let icon = type.icon {
                iconImageView.isHidden = false
                iconImageView.image = icon.image.withRenderingMode(.alwaysTemplate)

                if let iconColor = type.iconColor {
                    iconImageView.tintColor = UIColor.from(apollo: iconColor)
                }

                iconImageView.contentMode = .scaleAspectFit

                let iconDistance = type.iconDistance

                button.addSubview(iconImageView)

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
        })

        bag += title.atOnce().withLatestFrom(type).onValueDisposePrevious { title, type in
            let innerBag = DisposeBag()

            button.setTitle(title)

            let iconWidth = type.icon != nil ? (type.icon?.width ?? 0) + type.iconDistance : 0

            innerBag += button.didLayoutSignal.onValue { _ in
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
            .map({ _, highlightedStyleSignalValue -> ButtonStyle in
                highlightedStyleSignalValue
            }).bindTo(
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
            if let localizationKey = title.localizationKey?.description {
                Analytics.logEvent("tap_\(localizationKey)", parameters: nil)
            }
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
