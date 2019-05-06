//
//  MarkdownText.swift
//  ugglan
//
//  Created by Gustaf Gunér on 2019-04-04.
//

import Flow
import Form
import Foundation
import MarkdownKit
import UIKit

struct MarkdownText {
    let text: String
    let style: TextStyle
}

extension MarkdownText: Viewable {
    func materialize(events _: ViewableEvents) -> (UILabel, Disposable) {
        let bag = DisposeBag()

        let markdownParser = MarkdownParser(font: style.font, color: style.color)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = style.lineSpacing

        let attributedString = markdownParser.parse(text)

        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
        mutableAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, mutableAttributedString.length - 1))

        let markdownText = UILabel()
        markdownText.numberOfLines = 0
        markdownText.lineBreakMode = .byWordWrapping
        markdownText.baselineAdjustment = .none
        markdownText.attributedText = mutableAttributedString
        
        bag += markdownText.didLayoutSignal.onValue { _ in
            markdownText.preferredMaxLayoutWidth = markdownText.frame.size.width
        }

        return (markdownText, bag)
    }
}
