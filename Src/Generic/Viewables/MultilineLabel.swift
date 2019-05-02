//
//  MultilineLabel.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-21.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation

struct MultilineLabel {
    let styledTextSignal: ReadWriteSignal<StyledText>
    let intrinsicContentSizeSignal: ReadSignal<CGSize>

    private let intrinsicContentSizeReadWriteSignal = ReadWriteSignal<CGSize>(
        CGSize(width: 0, height: 0)
    )

    init(styledText: StyledText) {
        styledTextSignal = ReadWriteSignal(styledText)
        intrinsicContentSizeSignal = intrinsicContentSizeReadWriteSignal.readOnly()
    }

    init(value: DisplayableString, style: TextStyle) {
        self.init(styledText: StyledText(text: value, style: style))
    }
}

extension MultilineLabel: Viewable {
    func materialize(events _: ViewableEvents) -> (UILabel, Disposable) {
        let bag = DisposeBag()

        let label = UILabel()

        bag += styledTextSignal.atOnce().map { styledText -> StyledText in
            styledText.restyled { (textStyle: inout TextStyle) in
                textStyle.numberOfLines = 0
                textStyle.lineBreakMode = .byWordWrapping
            }
        }.bindTo(label, \.styledText)

        bag += label.didLayoutSignal.onValue {
            label.preferredMaxLayoutWidth = label.frame.size.width
            self.intrinsicContentSizeReadWriteSignal.value = label.intrinsicContentSize
        }

        return (label, bag)
    }
}
