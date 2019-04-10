//
//  CharityLogo.swift
//  ugglan
//
//  Created by Gustaf Gunér on 2019-03-21.
//

import Flow
import Foundation
import UIKit

struct CharityLogo {
    let url: String
}

extension CharityLogo: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let view = UIView()
        
        let imageView = UIImageView()
        imageView.imageFromURL(url: url)
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.center.equalToSuperview()
            make.height.lessThanOrEqualTo(100)
        }
        
        return (view, NilDisposer())
    }
}
