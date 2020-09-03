//
//  ApolloMultilineLabel.swift
//  test
//
//  Created by Sam Pettersson on 2019-10-03.
//

import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

struct ApolloMultilineLabel<Query: GraphQLQuery> {
    let query: Query
    @Inject private var client: ApolloClient
    let mapDataAndStyle: (_ data: Query.Data) -> StyledText

    init(
        query: Query,
        mapDataAndStyle: @escaping (_ data: Query.Data) -> StyledText
    ) {
        self.query = query
        self.mapDataAndStyle = mapDataAndStyle
    }
}

extension ApolloMultilineLabel: Viewable {
    func materialize(events _: ViewableEvents) -> (MultilineLabel, Disposable) {
        let bag = DisposeBag()
        let multilineLabel = MultilineLabel(value: "", style: TextStyle.body)

        bag += client
            .watch(query: query)
            .map { self.mapDataAndStyle($0) }
            .bindTo(multilineLabel.styledTextSignal)

        return (multilineLabel, bag)
    }
}
