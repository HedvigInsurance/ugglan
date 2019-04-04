//
//  CharityInformationBody.swift
//  ugglan
//
//  Created by Gustaf Gunér on 2019-04-04.
//

import Foundation
import Flow
import UIKit
import MarkdownKit

struct CharityInformationBody {
    let text: String
}

extension CharityInformationBody: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = UIView()
        
        let bag = DisposeBag()
        
        let body = MarkdownText(text: text, style: .body)
        bag += view.add(body)
        
        bag += view.didLayoutSignal.onValue { _ in
            view.snp.remakeConstraints { make in
                make.width.equalToSuperview().inset(24)
                make.height.equalToSuperview().inset(24)
                make.center.equalToSuperview()
            }
        }
        
        return (view, bag)
    }
}
