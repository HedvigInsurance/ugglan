//
//  NameCircle.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-14.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Foundation
import UIKit

struct NameCircle {
    let client: ApolloClient

    init(client: ApolloClient = ApolloContainer.shared.client) {
        self.client = client
    }
}

extension NameCircle: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let containerView = UIView()

        let nameCircleText = DynamicString()

        bag += client.fetch(query: ProfileQuery()).valueSignal.map { result -> String in
            if let member = result.data?.member, let firstName = member.firstName, let lastName = member.lastName {
                return "\(firstName) \(lastName)"
            }

            return ""
        }.bindTo(nameCircleText)

        let nameCircle = CircleLabel(
            labelText: nameCircleText,
            backgroundColor: UIColor(dynamic: { trait -> UIColor in
                 trait.userInterfaceStyle == .dark ? .secondaryBackground : .purple
            })
        )

        bag += containerView.add(nameCircle)

        containerView.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.height.equalTo(200)
        }

        return (containerView, bag)
    }
}
