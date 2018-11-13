//
//  Icon.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-11.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import Tempura
import UIKit

class Icon: UIView, View {
    let image = UIImageView()
    let iconName: String!
    let iconWidth: CGFloat!

    init(frame: CGRect, iconName: String!, iconWidth: CGFloat!) {
        self.iconName = iconName
        self.iconWidth = iconWidth
        super.init(frame: frame)

        setup()
        style()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        image.isUserInteractionEnabled = false
        isUserInteractionEnabled = false

        if let icon = UIImage(named: iconName) {
            image.image = icon
            addSubview(image)
        }
    }

    func style() {}

    func update() {}

    override func layoutSubviews() {
        super.layoutSubviews()
        image.pin.width(iconWidth).aspectRatio()
        pin.center()
        pin.size(of: image)
    }
}
