//
//  CharityLogo.swift
//  ugglan
//
//  Created by Gustaf Gunér on 2019-03-21.
//

import Flow
import Foundation
import UIKit
import ComponentKit

struct CharityLogo {
    let url: URL
}

extension CharityLogo: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let containerView = UIView()
        let bag = DisposeBag()

        let imageView = CachedImage(url: url)

        bag += containerView.add(imageView) { view in
            view.snp.makeConstraints { make in
                make.width.equalToSuperview().multipliedBy(0.8)
                make.center.equalToSuperview()
                make.height.lessThanOrEqualTo(100)
            }
        }

        return (containerView, bag)
    }
}
