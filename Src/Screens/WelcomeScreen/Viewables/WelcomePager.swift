//
//  WelcomePager.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-28.
//

import Flow
import Form
import Foundation
import Presentation
import UIKit
import Space
import ComponentKit

struct WelcomePager {
    let dataSignal = ReadWriteSignal<WelcomeQuery.Data?>(nil)
    let scrollToNextCallbacker: Callbacker<Void>
    let scrolledToPageIndexCallbacker: Callbacker<Int>
    let scrolledToEndCallbacker: Callbacker<Void>
    let presentingViewController: UIViewController
}

extension WelcomePager: Viewable {
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
                    self.presentingViewController.view.alpha = 1 - position

                    if position == 1 {
                        self.scrolledToEndCallbacker.callAll()
                    }
                }
            }
        }

        bag += dataSignal
            .atOnce()
            .compactMap { $0?.welcome }
            .onValue { welcome in
                var welcomePagerScreens = welcome.map { welcomePost -> PagerScreen in
                    let welcomePagerScreen = WelcomePagerScreen(
                        title: welcomePost.title,
                        paragraph: welcomePost.paragraph,
                        icon: welcomePost.illustration.fragments.iconFragment
                    )

                    return PagerScreen(
                        id: UUID(),
                        content: AnyPresentable(welcomePagerScreen)
                    )
                }

                welcomePagerScreens.append(PagerScreen(id: UUID(), content: AnyPresentable(DummyPagerScreen())))

                pager.dataSignal.value = welcomePagerScreens
            }

        return (view, bag)
    }
}
