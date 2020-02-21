//
//  KeyGearImageCarouselItem.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-27.
//

import Flow
import Form
import Foundation
import Kingfisher

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
                .keepCurrentImageWhileLoading,
                .cacheOriginalImage,
                .processor(DownsamplingImageProcessor(size: imageView.frame.size)),
                .scaleFactor(UIScreen.main.scale),
                .backgroundDecode,
                .transition(.fade(0.25)),
            ])
            imageView.contentMode = .scaleAspectFill

            return bag
        })
    }
}
