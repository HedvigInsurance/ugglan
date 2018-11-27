//
//  StoriesCollectionViewCell.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-22.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Foundation
import PinLayout
import Tempura
import UIKit

class StoriesCollectionViewCell: UICollectionViewCell, View {
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        style()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        clipsToBounds = true

        let image = try? UIImage(
            data: Data(contentsOf:
                URL(string: "https://media.graphcms.com//eIOdieS6Sa25y1wsI3wO")!)
        )

        if image != nil {
            imageView.image = image!
        }

        imageView.contentMode = .scaleAspectFill

        addSubview(imageView)
    }

    func style() {
        backgroundColor = [HedvigColors.purple, HedvigColors.pink, HedvigColors.blackPurple].randomElement()
    }

    func update() {}

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.pin.width(100%)
        imageView.pin.height(100%)
        pin.width(100%)
        pin.height(100%)
    }
}
