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

enum MarketingResult {
    case login, onboard
}

extension Marketing: Presentable {
    func materialize() -> (UIViewController, Future<MarketingResult>) {
        let viewController = UIViewController()

        let bag = DisposeBag()

        let containerView = UIView()
        containerView.backgroundColor = HedvigColors.white
        viewController.view = containerView

        return (viewController, Future { completion in
            let resultCallbacker = Callbacker<MarketingResult>()
            bag += resultCallbacker.signal().onValue({ marketingResult in
                completion(.success(marketingResult))
            })

            let endScreenCallbacker = Callbacker<Void>()
            let pausedCallbacker = Callbacker<Bool>()

            bag += endScreenCallbacker.signal().onValue({ _ in
                pausedCallbacker.callAll(with: true)

                let marketingEnd = MarketingEnd()
                let marketingEndPresentation = Presentation(
                    marketingEnd,
                    style: .modally(
                        presentationStyle: .overCurrentContext,
                        transitionStyle: .crossDissolve,
                        capturesStatusBarAppearance: true
                    ),
                    options: [.defaults, .prefersNavigationBarHidden(true)]
                )
                bag += viewController.present(marketingEndPresentation)
            })

            let rowsSignal = ReadWriteSignal<[MarketingStory]>([])

            let stories = Stories(
                marketingStories: rowsSignal.readOnly(),
                resultCallbacker: resultCallbacker,
                pausedCallbacker: pausedCallbacker,
                endScreenCallbacker: endScreenCallbacker
            )
            bag += containerView.add(stories)

            let loadingIndicator = LoadingIndicator(showAfter: 2)
            let loadingIndicatorBag = DisposeBag()
            bag += loadingIndicatorBag

            loadingIndicatorBag += containerView.add(loadingIndicator)

            bag += self.client.fetch(query: MarketingStoriesQuery()).onValue { result in
                guard let data = result.data else { return }
                let rows = data.marketingStories.map({ (marketingStoryData) -> MarketingStory in
                    MarketingStory(apollo: marketingStoryData!)
                })

                loadingIndicatorBag.dispose()

                rowsSignal.value = rows
            }

            return Disposer {
                bag += Signal(after: 1).onValue({ _ in
                    bag.dispose()
                })
            }
        })
    }
}
