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
            
            bag += self.client.fetch(query: MarketingStoriesQuery()).onValue { result in
                guard let data = result.data else { return }
                let rows = data.marketingStories.map({ (marketingStoryData) -> MarketingStory in
                    MarketingStory(apollo: marketingStoryData!)
                })
                
                let rowsSignal = ReadWriteSignal<[MarketingStory]>(rows)
                
                bag += rows.mapToFuture({ marketingStory in
                    marketingStory.cacheData()
                }).onValue({ _ in
                    let stories = Stories(
                        marketingStories: rowsSignal.readOnly(),
                        resultCallbacker: resultCallbacker
                    )
                    bag += containerView.add(stories)
                })
            }
            
            return bag
        })
    }
}
