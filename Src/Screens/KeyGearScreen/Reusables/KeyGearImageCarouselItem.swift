//
//  KeyGearImageCarouselItem.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-27.
//

import Foundation
import Flow
import Form

struct KeyGearImageCarouselItem {
    let imageUrl: URL
}

extension KeyGearImageCarouselItem: Reusable {
    static func makeAndConfigure() -> (make: UIImageView, configure: (KeyGearImageCarouselItem) -> Disposable) {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        
        return (imageView, { `self` in
            let bag = DisposeBag()
            
            imageView.kf.setImage(with: self.imageUrl, options: [
                .preloadAllAnimationData,
                .transition(.fade(1)),
            ])
            imageView.contentMode = .scaleAspectFill
            
            return bag
        })
    }
}
