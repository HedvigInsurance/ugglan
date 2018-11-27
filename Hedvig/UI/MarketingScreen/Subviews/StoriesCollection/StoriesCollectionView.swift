//
//  StoriesCollectionView.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-22.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Foundation
import PinLayout
import Tempura
import UIKit

private let cellReuseIdentifier = "storiesCollectionViewCell"

class StoriesCollectionView: UICollectionView, View, UICollectionViewDataSource {
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
        style()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        isPagingEnabled = true
        dataSource = self
        register(StoriesCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        bounces = false
        showsHorizontalScrollIndicator = false

        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }

    func style() {
        backgroundColor = HedvigColors.black
        layer.cornerRadius = 10
    }

    func update() {}

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return 10
    }

    func collectionView(_: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(
            withReuseIdentifier: cellReuseIdentifier,
            for: indexPath
        ) as? StoriesCollectionViewCell

        if cell == nil {
            return StoriesCollectionViewCell()
        }

        return cell!
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: bounds.width, height: bounds.height)
        }
    }
}
