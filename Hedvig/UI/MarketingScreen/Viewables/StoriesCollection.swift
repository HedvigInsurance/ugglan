//
//  StoriesCollection.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-30.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Foundation
import SnapKit
import UIKit

struct StoriesCollection {
    let client: ApolloClient
    let containerView: UIView
}

extension StoriesCollection: Viewable {
    func materialize() -> (UIView, Disposable) {
        let bag = DisposeBag()

        let view = UIView()

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        let collectionKit = CollectionKit<EmptySection, MarketingStory>(
            table: Table(),
            layout: flowLayout,
            bag: bag
        )

        collectionKit.view.backgroundColor = HedvigColors.white
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

        view.addSubview(collectionKit.view)
        collectionKit.view.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }

        let memberActionButtons = MemberActionButtons(collectionKit: collectionKit)
        bag += view.add(memberActionButtons)

        let skipToNextButton = SkipToNextButton(collectionKit: collectionKit)
        bag += view.add(skipToNextButton)

        let skipToPreviousButton = SkipToPreviousButton(collectionKit: collectionKit)
        bag += view.add(skipToPreviousButton)

        return (view, bag)
    }

    func makeConstraints(make: ConstraintMaker) {
        make.width.equalTo(containerView.safeAreaLayoutGuide.snp.width).inset(10)
        make.top.equalTo(containerView.safeAreaLayoutGuide.snp.top)
        make.centerX.equalTo(containerView.safeAreaLayoutGuide.snp.centerX)

        if containerView.safeAreaInsets.bottom > 0 {
            make.height.equalTo(containerView.safeAreaLayoutGuide.snp.height)
        } else {
            make.height.equalTo(containerView.safeAreaLayoutGuide.snp.height).inset(5)
        }
    }
}
