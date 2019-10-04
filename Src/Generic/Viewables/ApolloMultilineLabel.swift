//
//  ApolloMultilineLabel.swift
//  test
//
//  Created by Sam Pettersson on 2019-10-03.
//

import Foundation
import Apollo
import Flow
import UIKit
import Form

struct ApolloMultilineLabel<Query: GraphQLQuery> {
    let query: Query
    let client: ApolloClient
    let mapDataAndStyle: (_ data: Query.Data) -> StyledText
    
    init(
        query: Query,
        client: ApolloClient = ApolloContainer.shared.client,
        mapDataAndStyle: @escaping (_ data: Query.Data) -> StyledText
    ) {
        self.query = query
        self.mapDataAndStyle = mapDataAndStyle
        self.client = client
    }
}

extension ApolloMultilineLabel: Viewable {
    func materialize(events: ViewableEvents) -> (MultilineLabel, Disposable) {
        let bag = DisposeBag()
        let multilineLabel = MultilineLabel(value: "", style: TextStyle.body)
        
        bag += client
            .watch(query: query)
            .compactMap { $0.data }
            .map { self.mapDataAndStyle($0) }
            .bindTo(multilineLabel.styledTextSignal)
        
        return (multilineLabel, bag)
    }
}
