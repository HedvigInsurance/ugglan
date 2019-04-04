//
//  MarkdownText.swift
//  ugglan
//
//  Created by Gustaf Gunér on 2019-04-04.
//

import Foundation
import Flow
import UIKit
import MarkdownKit

enum MarkdownTextStyle {
    case body
    
    func font() -> UIFont {
        switch self {
        case .body:
            return (HedvigFonts.circularStdBook?.withSize(16))!
        }
    }
    
    func color () -> UIColor {
        switch self {
        case .body:
            return .offBlack
        }
    }
    
    func lineSpacing() -> CGFloat {
        switch self {
        case .body:
            return 4
        }
    }
}

struct MarkdownText {
    let text: String
    let style: MarkdownTextStyle
}

extension MarkdownText: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = UIView()
        
        let bag = DisposeBag()
        
        let markdownParser = MarkdownParser(font: (style.font()), color: style.color())
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = style.lineSpacing()
        
        let attributedString = markdownParser.parse(text)
        
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
        mutableAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, mutableAttributedString.length - 1))
        
        let markdownText = UILabel()
        markdownText.numberOfLines = 0
        markdownText.lineBreakMode = .byWordWrapping
        markdownText.baselineAdjustment = .none
        markdownText.attributedText = mutableAttributedString
        
        bag += markdownText.didLayoutSignal.onValue { _ in
            markdownText.snp.remakeConstraints { make in
                make.width.equalToSuperview()
                make.centerX.equalToSuperview()
            }
        }
        
        view.addSubview(markdownText)
        
        bag += view.didLayoutSignal.onValue { _ in
            view.snp.remakeConstraints { make in
                make.width.equalToSuperview()
                make.height.equalToSuperview()
            }
        }
        
        return (view, bag)
    }
}
