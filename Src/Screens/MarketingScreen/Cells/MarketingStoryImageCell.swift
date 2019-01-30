//
//  MarketingStoryImageCell.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-02.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit

class MarketingStoryImageCell: UICollectionViewCell {
    let imageView = UIImageView()
    var cellDidLoad: () -> Void = {}

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }

    func show(marketingStory: MarketingStory) {
        backgroundColor = UIColor.from(
            apollo: marketingStory.backgroundColor
        )

        DispatchQueue.global(qos: .background).async {
            guard let image = marketingStory.imageAsset() else { return }
            DispatchQueue.main.async {
                self.imageView.image = image
                self.cellDidLoad()
            }
        }

        addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
