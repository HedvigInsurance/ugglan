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
import UIKit

struct ButtonSection {
    let text: ReadWriteSignal<String>
    let textStyle: ReadWriteSignal<TextStyle>
    let sectionStyle: ReadWriteSignal<SectionStyle>
    let selectedBackground: ReadWriteSignal<SectionStyle.Background>

    private let onSelectCallbacker = Callbacker<Void>()
    let onSelect: Signal<Void>

    init(
        text: String,
        textStyle: TextStyle,
        sectionStyle: SectionStyle,
        selectedBackground: SectionStyle.Background
    ) {
        self.text = ReadWriteSignal(text)
        self.textStyle = ReadWriteSignal(textStyle)
        self.sectionStyle = ReadWriteSignal(sectionStyle)
        self.selectedBackground = ReadWriteSignal(selectedBackground)
        onSelect = onSelectCallbacker.signal()
    }
}

extension ButtonSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let section = SectionView(headerView: nil, footerView: nil)

        bag += sectionStyle.atOnce().withLatestFrom(selectedBackground.atOnce()).onValue({ sectionStyle, _ in
            section.dynamicStyle = DynamicSectionStyle { _ -> SectionStyle in
                sectionStyle.restyled({ (style: inout SectionStyle) in
                    style.selectedBackground = .selectedDanger
                })
            }
        })

        let buttonRow = ButtonRow(text: text, style: textStyle)
        bag += buttonRow.onSelect.lazyBindTo(callbacker: onSelectCallbacker)

        bag += section.append(buttonRow)

        return (section, bag)
    }
}
