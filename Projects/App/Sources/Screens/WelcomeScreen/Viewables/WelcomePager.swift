//
//  WelcomePager.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-28.
//

import Flow
import Form
import Foundation
import hCore
import hGraphQL
import Presentation
import UIKit

struct WelcomePager {
    let dataSignal = ReadWriteSignal<GraphQL.WelcomeQuery.Data?>(nil)
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

        bag += view.addArranged(pager)

        bag += dataSignal
            .atOnce()
            .compactMap { $0?.welcome }
            .onValue { welcome in
                let welcomePagerScreens = welcome.map { welcomePost -> PagerScreen in
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

                pager.dataSignal.value = welcomePagerScreens
            }

        return (view, bag)
    }
}
