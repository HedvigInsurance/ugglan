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
import Core

struct AddressCircle {
    @Inject var client: ApolloClient
}

extension AddressCircle: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let containerView = UIView()

        let circleText = DynamicString()

        bag += client.fetch(query: MyHomeQuery()).valueSignal.map { result -> String in
            if let address = result.data?.insurance.address {
                return address
            }

            return ""
        }.bindTo(circleText)

        let circleLabel = CircleLabel(
            labelText: circleText,
            backgroundColor: UIColor(dynamic: { trait -> UIColor in
                trait.userInterfaceStyle == .dark ? .secondaryBackground : .darkPink
            })
        )

        bag += containerView.add(circleLabel)

        containerView.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.height.equalTo(200)
        }

        return (containerView, bag)
    }
}
