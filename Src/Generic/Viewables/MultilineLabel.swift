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
    let usePreferredMaxLayoutWidth: Bool
    let lineHeight: CGFloat?

    private let intrinsicContentSizeReadWriteSignal = ReadWriteSignal<CGSize>(
        CGSize(width: 0, height: 0)
    )

    init(styledText: StyledText, usePreferredMaxLayoutWidth: Bool = true, lineHeight: CGFloat? = nil) {
        styledTextSignal = ReadWriteSignal(styledText)
        intrinsicContentSizeSignal = intrinsicContentSizeReadWriteSignal.readOnly()
        self.usePreferredMaxLayoutWidth = usePreferredMaxLayoutWidth
        self.lineHeight = lineHeight
    }

    init(value: DisplayableString, style: TextStyle, usePreferredMaxLayoutWidth: Bool = true, lineHeight: CGFloat? = nil) {
        self.init(styledText: StyledText(text: value, style: style), usePreferredMaxLayoutWidth: usePreferredMaxLayoutWidth, lineHeight: lineHeight)
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
        
        bag += styledTextSignal.atOnce().onValue { _ in
            if (self.lineHeight != nil) {
                label.setLineHeight(lineHeight: self.lineHeight!)
            }
        }

        bag += label.didLayoutSignal.onValue {
            if self.usePreferredMaxLayoutWidth {
                label.preferredMaxLayoutWidth = label.frame.size.width
            }
            self.intrinsicContentSizeReadWriteSignal.value = label.intrinsicContentSize
        }

        return (label, bag)
    }
}
