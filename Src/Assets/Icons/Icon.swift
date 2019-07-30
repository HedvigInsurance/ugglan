//
//  Icon.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-11.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import UIKit

class Icon: UIView {
    let image = UIImageView()
    var icon: ImageAsset {
        didSet {
            setup()
        }
    }
    var iconWidth: CGFloat {
        didSet {
            image.snp.remakeConstraints { make in
                make.width.equalTo(iconWidth)
                make.height.equalToSuperview()
                make.center.equalToSuperview()
            }
        }
    }

    init(frame: CGRect = .zero, icon: ImageAsset, iconWidth: CGFloat) {
        self.icon = icon
        self.iconWidth = iconWidth
        super.init(frame: frame)
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: iconWidth, height: iconWidth)
    }

    func setup() {
        image.isUserInteractionEnabled = false
        isUserInteractionEnabled = false

        image.image = icon.image
        addSubview(image)

        image.contentMode = .scaleAspectFit
        
        image.snp.makeConstraints { make in
            make.width.equalTo(iconWidth)
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
}
