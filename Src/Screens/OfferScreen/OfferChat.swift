//
//  OfferChat.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-05.
//

import Apollo
import Flow
import Foundation
import Presentation
import UIKit

struct OfferChat {
    let client: ApolloClient

    init(client: ApolloClient = ApolloContainer.shared.client) {
        self.client = client
    }
}

extension OfferChat: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()
        let (viewController, future) = Chat().materialize()

        bag += client.perform(mutation: OfferClosedMutation()).disposable

        return (viewController, Future { completion in
            bag += future.onResult { result in
                completion(result)
            }

            return bag
        })
    }
}
