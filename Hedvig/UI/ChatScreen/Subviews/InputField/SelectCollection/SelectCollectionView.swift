//
//  SelectTable.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-16.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import PinLayout
import Tempura
import UIKit

private let cellReuseIdentifier = "SelectCollectionViewCell"

class SelectCollectionView: UICollectionView, View, UICollectionViewDataSource {
    var choices: [MessageBodySingleSelectFragment.Choice?] = [] {
        didSet(oldValue) {
            if oldValue != nil {
                performBatchUpdates({
                    deleteItems(at: oldValue.enumerated().map({ (index, _) -> IndexPath in
                        IndexPath(item: index, section: 0)
                    }))
                    insertItems(at: choices.enumerated().map({ (index, _) -> IndexPath in
                        IndexPath(item: index, section: 0)
                    }))
                }, completion: nil)
            }
        }
    }

    var onSelect: ((_ choice: MessageBodySingleSelectFragment.Choice?) -> Void)?

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return choices.count
    }

    func collectionView(_: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(
            withReuseIdentifier: cellReuseIdentifier,
            for: indexPath
        ) as? SelectCollectionViewCell

        if cell == nil {
            return SelectCollectionViewCell()
        }

        cell!.choice = choices[indexPath.row]
        cell!.onSelect = onSelect
        cell!.update()
        cell!.layoutIfNeeded()

        return cell!
    }

    func setup() {
        dataSource = self
        register(SelectCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)

        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.estimatedItemSize = CGSize(width: 100, height: 60)
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        }
    }

    func style() {
        backgroundColor = UIColor.clear
    }

    func update() {
        DispatchQueue.main.async {
            self.reloadData()
            self.collectionViewLayout.invalidateLayout()
            self.layoutIfNeeded()
        }
    }

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
        style()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pin.width(100%)
        pin.height(60)
    }
}
