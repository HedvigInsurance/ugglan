//
//  Marketing+Layouting.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-28.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit

extension Marketing {
    struct Layouting {
        static func collectionView(
            _ collectionView: UICollectionView,
            _ containterView: UIView
        ) {
            collectionView.snp.makeConstraints { make in
                make.width.equalTo(containterView.safeAreaLayoutGuide.snp.width).inset(10)
                make.center.equalTo(containterView.safeAreaLayoutGuide.snp.center)
                make.height.equalTo(containterView.safeAreaLayoutGuide.snp.height)
            }
        }

        static func newMemberButtonView(
            _ newMemberButtonView: NewMemberButtonView,
            _ collectionView: UICollectionView
        ) {
            newMemberButtonView.snp.makeConstraints { make in
                make.width.equalTo(collectionView.snp.width).multipliedBy(0.5).inset(10)
                make.height.equalTo(40)
                make.right.equalTo(collectionView.snp.right).inset(15)
                make.bottom.equalTo(collectionView.snp.bottom).inset(15)
            }
        }

        static func existingMemberButtonView(
            _ existingMemberButtonView: ExistingMemberButtonView,
            _ collectionView: UICollectionView
        ) {
            existingMemberButtonView.snp.makeConstraints { make in
                make.width.equalTo(collectionView.snp.width).multipliedBy(0.5).inset(10)
                make.height.equalTo(40)
                make.left.equalTo(collectionView.snp.left).inset(15)
                make.bottom.equalTo(collectionView.snp.bottom).inset(15)
            }
        }

        static func skipToPreviousButton(
            _ skipToPreviousButton: UIButton,
            _ collectionView: UICollectionView
        ) {
            skipToPreviousButton.snp.makeConstraints { make in
                make.width.equalTo(50)
                make.height.equalTo(collectionView.snp.height).inset(30)
                make.top.equalTo(collectionView.snp.top)
                make.left.equalTo(collectionView.snp.left)
            }
        }

        static func skipToNextButton(
            _ skipToNextButton: UIButton,
            _ collectionView: UICollectionView
        ) {
            skipToNextButton.snp.makeConstraints { make in
                make.width.equalTo(50)
                make.height.equalTo(collectionView.snp.height).inset(30)
                make.top.equalTo(collectionView.snp.top)
                make.right.equalTo(collectionView.snp.right)
            }
        }
    }
}
