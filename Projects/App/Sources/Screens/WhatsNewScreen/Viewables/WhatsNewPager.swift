//
//  WhatsNewPager.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-12.
//

import Flow
import Form
import Foundation
import hCore
import hGraphQL
import Presentation
import UIKit

struct WhatsNewPager {
    let dataSignal = ReadWriteSignal<GraphQL.WhatsNewQuery.Data?>(nil)
    let scrollToNextCallbacker: Callbacker<Void>
    let scrolledToPageIndexCallbacker: Callbacker<Int>
    let scrolledToEndCallbacker: Callbacker<Void>
}

extension WhatsNewPager: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIStackView()

        let scrollToNextSignal = scrollToNextCallbacker.signal()

        let pager = Pager(
            scrollToNextSignal: scrollToNextSignal,
            scrolledToPageIndexCallbacker: scrolledToPageIndexCallbacker
        )

        bag += view.addArranged(pager) { collectionView in
            bag += collectionView.contentOffsetSignal.onValue { point in
                let slidesScrolledThrough = point.x / collectionView.frame.width + 1
                let amountOfRealSlides = CGFloat(pager.dataSignal.value.count - 1)

                if slidesScrolledThrough > amountOfRealSlides {
                    let position = slidesScrolledThrough - amountOfRealSlides
                    view.viewController?.view.alpha = 1 - position

                    if position == 1 {
                        self.scrolledToEndCallbacker.callAll()
                    }
                }
            }
        }

        bag += dataSignal
            .atOnce()
            .compactMap { $0?.news }
            .onValue { news in
                var newsPagerScreens = news.map { newsPost -> PagerScreen in
                    let whatsNewPagerScreen = WhatsNewPagerScreen(
                        title: newsPost.title,
                        paragraph: newsPost.paragraph,
                        icon: newsPost.illustration.fragments.iconFragment
                    )

                    return PagerScreen(
                        id: UUID(),
                        content: AnyPresentable(whatsNewPagerScreen)
                    )
                }

                newsPagerScreens.append(PagerScreen(id: UUID(), content: AnyPresentable(DummyPagerScreen())))

                pager.dataSignal.value = newsPagerScreens
            }

        return (view, bag)
    }
}
