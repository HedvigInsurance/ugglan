//
//  ButtonRow.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-16.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Firebase
import FirebaseAnalytics
import Flow
import Form
import Foundation
import UIKit
import Common
import ComponentKit

struct ButtonRow {
    let text: ReadWriteSignal<String>
    let style: ReadWriteSignal<TextStyle>
    let isHiddenSignal = ReadWriteSignal<Bool>(false)

    private let onSelectCallbacker = Callbacker<Void>()
    let onSelect: Signal<Void>

    init(text: String, style: TextStyle) {
        self.text = ReadWriteSignal(text)
        self.style = ReadWriteSignal(style)
        onSelect = onSelectCallbacker.signal()
    }

    init(text: ReadWriteSignal<String>, style: ReadWriteSignal<TextStyle>) {
        self.text = text
        self.style = style
        onSelect = onSelectCallbacker.signal()
    }
}

extension ButtonRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()
        let row = RowView()
        row.alignment = .center

        bag += isHiddenSignal.atOnce().bindTo(row, \.isHidden)

        bag += events.onSelect.lazyBindTo(callbacker: onSelectCallbacker)

        let label = UILabel()

        bag += style.atOnce().map { textStyle -> TextStyle in
            textStyle.restyled { (style: inout TextStyle) in
                style.alignment = .center
            }
        }.map { textStyle -> StyledText in
            StyledText(text: label.text ?? "", style: textStyle)
        }.bindTo(label, \.styledText)
        bag += text.atOnce().bindTo(label, \.text)

        label.snp.makeConstraints { make in
            make.height.equalTo(20)
        }

        bag += events.onSelect.withLatestFrom(text.atOnce().plain()).onValue { _, title in
            if let localizationKey = title.localizationKey?.description {
                Analytics.logEvent(localizationKey, parameters: [
                    "context": "ButtonRow",
                ])
            }
        }

        row.append(label)

        return (row, bag)
    }
}
