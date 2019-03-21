//
//  Button.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-19.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import FirebaseAnalytics
import Flow
import Form
import Foundation
import UIKit

enum ButtonType {
    case standard(backgroundColor: HedvigColor, textColor: HedvigColor)
    case pillTransparent(backgroundColor: HedvigColor, textColor: HedvigColor)
    case information(textColor: HedvigColor, icon: ImageAsset?)

    func backgroundOpacity() -> CGFloat {
        switch self {
        case .standard:
            return 1
        case .pillTransparent:
            return 0.6
        default:
            return 0.0
        }
    }

    func backgroundColor() -> HedvigColor {
        switch self {
        case let .standard((backgroundColor, _)):
            return backgroundColor
        case let .pillTransparent((backgroundColor, _)):
            return backgroundColor
        default:
            return .purple
        }
    }

    func textColor() -> HedvigColor {
        switch self {
        case let .standard((_, textColor)):
            return textColor
        case let .pillTransparent((_, textColor)):
            return textColor
        case let .information((textColor, _)):
            return textColor
        }
    }

    func height() -> CGFloat {
        switch self {
        case .standard:
            return 50
        case .pillTransparent:
            return 30
        case .information:
            return 30
        }
    }

    func fontSize() -> CGFloat {
        switch self {
        case .standard:
            return 15
        case .pillTransparent:
            return 13
        case .information:
            return 14
        }
    }

    func extraWidthOffset() -> CGFloat {
        switch self {
        case .standard:
            return 50
        case .pillTransparent:
            return 35
        case .information:
            return 35
        }
    }
    
    func icon() -> ImageAsset? {
        switch self {
        case let .information((_, icon)):
            return icon
        default:
            return nil
        }
    }
    
    func iconDistance() -> CGFloat {
        switch self {
        case .information((_, _)):
            return 7
        default:
            return 0
        }
    }
}

struct Button {
    private let onTapReadWriteSignal = ReadWriteSignal<Void>(())

    let title: ReadSignal<String>
    let onTapSignal: Signal<Void>
    let type: ButtonType

    init(title: String, type: ButtonType) {
        self.title = ReadWriteSignal(title).readOnly()
        onTapSignal = onTapReadWriteSignal.plain()
        self.type = type
    }
}

extension Button: Viewable {
    func materialize(events: ViewableEvents) -> (UIButton, Disposable) {
        let bag = DisposeBag()

        let style = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
            style.buttonType = .custom

            let backgroundColor = UIColor.from(
                apollo: self.type.backgroundColor()
            ).withAlphaComponent(self.type.backgroundOpacity())
            let textColor = UIColor.from(apollo: self.type.textColor())

            style.states = [
                .normal: ButtonStateStyle(
                    background: BackgroundStyle(
                        color: backgroundColor,
                        border: BorderStyle(
                            width: 0,
                            color: UIColor.clear,
                            cornerRadius: self.type.height() / 2,
                            borderEdges: UIRectEdge()
                        )
                    ),
                    text: TextStyle(
                        font: HedvigFonts.circularStdBook!.withSize(self.type.fontSize()),
                        color: textColor
                    )
                ),
            ]
        }

        let highlightedStyle = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
            style.buttonType = .custom

            let backgroundColor = UIColor.from(
                apollo: self.type.backgroundColor()
            ).darkened(amount: 0.05).withAlphaComponent(self.type.backgroundOpacity())
            let textColor = UIColor.from(apollo: self.type.textColor())

            style.states = [
                .normal: ButtonStateStyle(
                    background: BackgroundStyle(
                        color: backgroundColor,
                        border: BorderStyle(
                            width: 0,
                            color: UIColor.clear,
                            cornerRadius: self.type.height() / 2,
                            borderEdges: UIRectEdge()
                        )
                    ),
                    text: TextStyle(
                        font: HedvigFonts.circularStdBook!.withSize(self.type.fontSize()),
                        color: textColor
                    )
                ),
            ]
        }

        let button = UIButton(title: "", style: style)
        button.adjustsImageWhenHighlighted = false
        
        if let icon = self.type.icon() {
            button.setImage(icon.image, for: [])
            
            let iconDistance = self.type.iconDistance()
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: iconDistance)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: iconDistance, bottom: 0, right: 0)
        }

        bag += title.atOnce().onValue { title in
            button.setTitle(title)
        }

        bag += button.signal(for: .touchDown).map({ _ -> ButtonStyle in
            highlightedStyle
        }).bindTo(
            transition: button,
            style: TransitionStyle.crossDissolve(duration: 0.25),
            button,
            \.style
        )

        let touchUpInside = button.signal(for: .touchUpInside)
        bag += touchUpInside.feedback(type: .impactLight)

        bag += touchUpInside.map({ _ -> Void in
            ()
        }).bindTo(onTapReadWriteSignal)

        bag += touchUpInside.map({ _ -> ButtonStyle in
            style
        }).delay(by: 0.1).bindTo(
            transition: button,
            style: TransitionStyle.crossDissolve(duration: 0.25),
            button,
            \.style
        )

        bag += touchUpInside.flatMapLatest { _ -> ReadSignal<String> in
            self.title.atOnce()
        }.onValue { title in
            if let localizationKey = title.localizationKey?.toString() {
                Analytics.logEvent("button_tap_\(localizationKey)", parameters: nil)
            }
        }

        bag += merge(
            button.signal(for: .touchUpOutside),
            button.signal(for: .touchCancel)
        ).map({ _ -> ButtonStyle in
            style
        }).bindTo(
            transition: button,
            style: TransitionStyle.crossDissolve(duration: 0.25),
            button,
            \.style
        )

        button.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.width.equalTo(button.intrinsicContentSize.width + self.type.extraWidthOffset())
            make.height.equalTo(self.type.height())
            make.centerX.equalToSuperview()
        }

        return (button, bag)
    }
}
