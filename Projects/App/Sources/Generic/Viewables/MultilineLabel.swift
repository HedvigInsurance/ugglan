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
import UIKit


struct MultilineLabel {
    let styledTextSignal: ReadWriteSignal<StyledText>
    let intrinsicContentSizeSignal: ReadSignal<CGSize>
    let usePreferredMaxLayoutWidth: Bool

    private let intrinsicContentSizeReadWriteSignal = ReadWriteSignal<CGSize>(
        CGSize(width: 0, height: 0)
    )

    init(styledText: StyledText, usePreferredMaxLayoutWidth: Bool = true) {
        styledTextSignal = ReadWriteSignal(styledText)
        intrinsicContentSizeSignal = intrinsicContentSizeReadWriteSignal.readOnly()
        self.usePreferredMaxLayoutWidth = usePreferredMaxLayoutWidth
    }

    init(value: DisplayableString, style: TextStyle, usePreferredMaxLayoutWidth: Bool = true) {
        self.init(styledText: StyledText(text: value, style: style), usePreferredMaxLayoutWidth: usePreferredMaxLayoutWidth)
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
            if self.usePreferredMaxLayoutWidth {
                label.preferredMaxLayoutWidth = label.frame.size.width
            }
            self.intrinsicContentSizeReadWriteSignal.value = label.intrinsicContentSize
        }

        return (label, bag)
    }
}
