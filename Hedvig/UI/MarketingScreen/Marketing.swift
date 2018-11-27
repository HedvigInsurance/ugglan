//  Marketing.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-25.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Presentation
import SnapKit
import UIKit

struct Marketing {
    struct Layouting {
        static func storiesCollectionView(
            _ storiesCollectionView: StoriesCollectionView,
            _ containerView: UIView
        ) {
            storiesCollectionView.snp.makeConstraints { make in
                make.width.equalTo(containerView.safeAreaLayoutGuide.snp.width).inset(10)
                make.center.equalTo(containerView.safeAreaLayoutGuide.snp.center)
                make.height.equalTo(containerView.safeAreaLayoutGuide.snp.height)
            }
        }

        static func newMemberButtonView(
            _ newMemberButtonView: NewMemberButtonView,
            _ storiesCollectionView: StoriesCollectionView
        ) {
            newMemberButtonView.snp.makeConstraints { make in
                make.width.equalTo(storiesCollectionView.snp.width).multipliedBy(0.5).inset(15)
                make.height.equalTo(40)
                make.right.equalTo(storiesCollectionView.snp.right).inset(15)
                make.bottom.equalTo(storiesCollectionView.snp.bottom).inset(15)
            }
        }

        static func existingMemberButtonView(
            _ existingMemberButtonView: ExistingMemberButtonView,
            _ storiesCollectionView: StoriesCollectionView
        ) {
            existingMemberButtonView.snp.makeConstraints { make in
                make.width.equalTo(storiesCollectionView.snp.width).multipliedBy(0.5).inset(15)
                make.height.equalTo(40)
                make.left.equalTo(storiesCollectionView.snp.left).inset(15)
                make.bottom.equalTo(storiesCollectionView.snp.bottom).inset(15)
            }
        }
    }
}

extension Marketing: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()

        let bag = DisposeBag()

        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        viewController.view = containerView

        let storiesCollectionView = StoriesCollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        containerView.addSubview(storiesCollectionView)
        Layouting.storiesCollectionView(storiesCollectionView, containerView)

        let newMemberButtonView = NewMemberButtonView()
        containerView.addSubview(newMemberButtonView)
        Layouting.newMemberButtonView(newMemberButtonView, storiesCollectionView)

        let existingMemberButtonView = ExistingMemberButtonView()
        containerView.addSubview(existingMemberButtonView)
        Layouting.existingMemberButtonView(existingMemberButtonView, storiesCollectionView)

        return (viewController, bag)
    }
}
