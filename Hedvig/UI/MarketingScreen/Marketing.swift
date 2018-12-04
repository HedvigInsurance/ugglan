//  Marketing.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-25.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Presentation
import SnapKit
import UIKit

struct Marketing {
    let client: ApolloClient
}

extension Marketing: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()

        let bag = DisposeBag()

        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        viewController.view = containerView

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        let collectionKit = CollectionKit<EmptySection, MarketingStory>(
            table: Table(),
            layout: flowLayout,
            bag: bag
        )

        collectionKit.view.isPagingEnabled = true
        collectionKit.view.bounces = false
        collectionKit.view.showsHorizontalScrollIndicator = false
        collectionKit.view.layer.cornerRadius = 10
        collectionKit.view.isPrefetchingEnabled = true

        bag += collectionKit.delegate.sizeForItemAt.set({ (_) -> CGSize in
            collectionKit.view.frame.size
        })

        bag += client.fetch(query: MarketingStoriesQuery()).onValue { result in
            guard let data = result.data else { return }
            let rows = data.marketingStories.map({ (marketingStoryData) -> MarketingStory in
                MarketingStory(apollo: marketingStoryData!)
            })

            collectionKit.set(Table(rows: rows))
        }

        containerView.addSubview(collectionKit.view)
        Layouting.collectionView(collectionKit.view, containerView)

        let newMemberButtonView = NewMemberButtonView()
        containerView.addSubview(newMemberButtonView)
        Layouting.newMemberButtonView(newMemberButtonView, collectionKit.view)

        let existingMemberButtonView = ExistingMemberButtonView()
        containerView.addSubview(existingMemberButtonView)
        Layouting.existingMemberButtonView(existingMemberButtonView, collectionKit.view)

        let skipToPreviousButton = UIButton(title: "Tidigare", style: .invisible)
        containerView.addSubview(skipToPreviousButton)
        Layouting.skipToPreviousButton(skipToPreviousButton, collectionKit.view)

        bag += skipToPreviousButton.onValue {
            let currentIndex = Int(collectionKit.view.contentOffset.x / collectionKit.view.frame.size.width)
            let newIndexPath = IndexPath(row: currentIndex - 1, section: 0)

            if newIndexPath.row >= 0 {
                collectionKit.view.scrollToItem(at: newIndexPath, at: .left, animated: true)
            }
        }

        let skipToNextButton = UIButton(title: "Nästa", style: .invisible)
        containerView.addSubview(skipToNextButton)
        Layouting.skipToNextButton(skipToNextButton, collectionKit.view)

        bag += skipToNextButton.onValue {
            let currentIndex = Int(collectionKit.view.contentOffset.x / collectionKit.view.frame.size.width)
            let newIndexPath = IndexPath(row: currentIndex + 1, section: 0)
            let numberOfItems = collectionKit.dataSource.collectionView(
                collectionKit.view,
                numberOfItemsInSection: 0
            )

            if numberOfItems > newIndexPath.row {
                collectionKit.view.scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: true)
            }
        }

        return (viewController, bag)
    }
}
