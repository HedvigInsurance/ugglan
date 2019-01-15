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

struct NameCircle {
    let client: ApolloClient

    init(client: ApolloClient = HedvigApolloClient.shared.client!) {
        self.client = client
    }
}

extension NameCircle: Viewable {
    func materialize(events _: ViewableEvents) -> (CircleLabel, Disposable) {
        let bag = DisposeBag()

        let nameCircleText = DynamicString()

        bag += client.fetch(query: ProfileQuery()).valueSignal.map({ result -> String in
            if let member = result.data?.member, let firstName = member.firstName, let lastName = member.lastName {
                return "\(firstName) \(lastName)"
            }

            return ""
        }).bindTo(nameCircleText)

        let nameCircle = CircleLabel(
            text: nameCircleText
        )

        return (nameCircle, bag)
    }
}
