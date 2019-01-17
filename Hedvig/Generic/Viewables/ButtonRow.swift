//
//  ButtonRow.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-16.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import UIKit

struct ButtonRow {
    let text: ReadWriteSignal<String>
    let style: ReadWriteSignal<TextStyle>

    private let onSelectCallbacker = Callbacker<Void>()
    let onSelect: Signal<Void>

    init(text: String, style: TextStyle) {
        self.text = ReadWriteSignal(text)
        self.style = ReadWriteSignal(style)
        onSelect = onSelectCallbacker.signal()
    }
}

extension ButtonRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()
        let row = RowView()
        row.alignment = .center

        bag += events.onSelect.lazyBindTo(callbacker: onSelectCallbacker)

        let label = UILabel()

        bag += style.atOnce().map({ textStyle -> TextStyle in
            textStyle.restyled({ (style: inout TextStyle) in
                style.alignment = .center
            })
        }).map({ textStyle -> StyledText in
            StyledText(text: label.text ?? "", style: textStyle)
        }).bindTo(label, \.styledText)
        bag += text.atOnce().bindTo(label, \.text)

        bag += label.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.height.equalTo(20)
        }

        row.append(label)

        return (row, bag)
    }
}
