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

struct MarkdownText {
    let text: String
}

extension MarkdownText: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = UIView()
        
        let bag = DisposeBag()
        
        let markdownParser = MarkdownParser()
        
        let markdownText = UILabel()
        markdownText.numberOfLines = 0
        markdownText.lineBreakMode = .byWordWrapping
        markdownText.baselineAdjustment = .none
        markdownText.attributedText = markdownParser.parse(text)
        
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
