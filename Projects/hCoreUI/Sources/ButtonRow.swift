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
import hCore
import Mixpanel
import UIKit

public struct ButtonRow {
    public static var trackingHandler: (_ row: Self) -> Void = { _ in }
    
    public let text: ReadWriteSignal<String>
    public let style: ReadWriteSignal<TextStyle>
    public let isHiddenSignal = ReadWriteSignal<Bool>(false)

    private let onSelectCallbacker = Callbacker<Void>()
    public let onSelect: Signal<Void>

    public init(text: String, style: TextStyle) {
        self.text = ReadWriteSignal(text)
        self.style = ReadWriteSignal(style)
        onSelect = onSelectCallbacker.providedSignal
    }

    public init(text: ReadWriteSignal<String>, style: ReadWriteSignal<TextStyle>) {
        self.text = text
        self.style = style
        onSelect = onSelectCallbacker.providedSignal
    }
}

extension ButtonRow: Viewable {
    public func materialize(events: SelectableViewableEvents) -> (RowView, Disposable) {
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

        bag += events.onSelect.onValue {
            Self.trackingHandler(self)
        }
        
        row.append(label)

        return (row, bag)
    }
}
