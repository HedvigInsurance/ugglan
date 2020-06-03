//
//  ButtonSection.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-27.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import hCore
import UIKit

struct ButtonSection {
    let text: ReadWriteSignal<String>
    let isHiddenSignal = ReadWriteSignal<Bool>(false)
    let style: Style

    enum Style {
        case normal, danger
    }

    private let onSelectCallbacker = Callbacker<Void>()
    let onSelect: Signal<Void>

    init(
        text: String,
        style: Style
    ) {
        self.text = ReadWriteSignal(text)
        self.style = style
        onSelect = onSelectCallbacker.signal()
    }
}

extension ButtonSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let section = SectionView(headerView: nil, footerView: nil)

        bag += isHiddenSignal.bindTo(section, \.isHidden)

        section.dynamicStyle = DynamicSectionStyle { trait -> SectionStyle in
            let lightStyle = SectionStyle.sectionPlainLight.restyled { (style: inout SectionStyle) in
                style.background = .standardLightRoundedBorder

                if self.style == .normal {
                    style.selectedBackground = .selectedRoundedBorder
                } else {
                    style.selectedBackground = .selectedDangerRoundedBorder
                }
            }

            let darkStyle = SectionStyle.sectionPlainDark.restyled { (style: inout SectionStyle) in
                style.background = .standardDarkRoundedBorder

                if self.style == .normal {
                    style.selectedBackground = .selectedRoundedBorder
                } else {
                    style.selectedBackground = .selectedDangerRoundedBorder
                }
            }

            return trait.userInterfaceStyle == .dark ? darkStyle : lightStyle
        }

        let buttonRow = ButtonRow(
            text: "",
            style: style == .normal ? .normalButton : .dangerButton
        )

        bag += text.atOnce().bindTo(buttonRow.text)

        bag += buttonRow.onSelect.lazyBindTo(callbacker: onSelectCallbacker)

        bag += section.append(buttonRow)

        return (section, bag)
    }
}
