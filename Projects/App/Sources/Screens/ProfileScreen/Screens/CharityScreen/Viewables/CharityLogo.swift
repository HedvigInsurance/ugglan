//
//  CharityLogo.swift
//  ugglan
//
//  Created by Gustaf Gunér on 2019-03-21.
//

import Flow
import Foundation
import hCore
import UIKit

struct CharityLogo {
    let url: URL
}

extension CharityLogo: Viewable {
    func materialize(events _: ViewableEvents) -> (UIImageView, Disposable) {
        let bag = DisposeBag()

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.kf.setImage(with: url)
        
        imageView.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        
        return (imageView, bag)
    }
}
