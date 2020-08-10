//
//  MultilineLabel.swift
//  Core
//
//  Created by Sam Pettersson on 2020-05-08.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import hCore
import UIKit

public struct MultilineLabel {
    public let styledTextSignal: ReadWriteSignal<StyledText>
    public let intrinsicContentSizeSignal: ReadSignal<CGSize>
    public let usePreferredMaxLayoutWidth: Bool

    public var valueSignal: ReadWriteSignal<DisplayableString> {
        styledTextSignal.map { $0.text }.writable { value in
            self.styledTextSignal.value = StyledText(text: value, style: self.styledTextSignal.value.style)
        }
    }

    private let intrinsicContentSizeReadWriteSignal = ReadWriteSignal<CGSize>(
        CGSize(width: 0, height: 0)
    )

    public init(styledText: StyledText, usePreferredMaxLayoutWidth: Bool = true) {
        styledTextSignal = ReadWriteSignal(styledText)
        intrinsicContentSizeSignal = intrinsicContentSizeReadWriteSignal.readOnly()
        self.usePreferredMaxLayoutWidth = usePreferredMaxLayoutWidth
    }

    public init(value: DisplayableString, style: TextStyle, usePreferredMaxLayoutWidth: Bool = true) {
        self.init(styledText: StyledText(text: value, style: style), usePreferredMaxLayoutWidth: usePreferredMaxLayoutWidth)
    }
}

extension UILabel {
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font ?? UIFont.systemFont(ofSize: 0)], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height / charSize))
        return linesRoundedUp
    }
}

extension MultilineLabel: Viewable {
    public func materialize(events _: ViewableEvents) -> (UILabel, Disposable) {
        let bag = DisposeBag()

        let label = UILabel()

        bag += styledTextSignal.atOnce().map { styledText -> StyledText in
            styledText.restyled { (textStyle: inout TextStyle) in
                textStyle.numberOfLines = 0
                textStyle.lineBreakMode = .byWordWrapping
            }
        }.bindTo(label, \.styledText)

        bag += label.didLayoutSignal.onValue {
            if label.calculateMaxLines() > 1 {
                label.styledText = label.styledText.restyled { (style: inout TextStyle) in
                    style.lineHeight = style.font.lineHeight * 1.4
                }
            }

            if self.usePreferredMaxLayoutWidth {
                label.preferredMaxLayoutWidth = label.frame.size.width
            }
            self.intrinsicContentSizeReadWriteSignal.value = label.intrinsicContentSize
        }

        return (label, bag)
    }
}
