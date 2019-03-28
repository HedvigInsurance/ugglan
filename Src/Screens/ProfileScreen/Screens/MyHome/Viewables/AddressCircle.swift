//
//  AddressCircle.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-02-12.
//

import Apollo
import Flow
import Foundation
import UIKit

struct AddressCircle {
    let client: ApolloClient

    init(client: ApolloClient = ApolloContainer.shared.client) {
        self.client = client
    }
}

extension AddressCircle: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let containerView = UIView()

        let circleText = DynamicString()

        bag += client.fetch(query: MyHomeQuery()).valueSignal.map({ result -> String in
            if let address = result.data?.insurance.address {
                return address
            }

            return ""
        }).bindTo(circleText)

        let circleLabel = CircleLabel(
            labelText: circleText,
            backgroundColor: .darkPink
        )

        bag += containerView.add(circleLabel)

        containerView.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.height.equalTo(200)
        }

        return (containerView, bag)
    }
}
