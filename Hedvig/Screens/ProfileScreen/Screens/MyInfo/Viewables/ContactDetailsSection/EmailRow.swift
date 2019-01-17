//
//  EmailRow.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-15.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Foundation

struct EmailRow {
    let client: ApolloClient

    init(client: ApolloClient = HedvigApolloClient.shared.client!) {
        self.client = client
    }
}

extension EmailRow: Viewable {
    func materialize(events _: ViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()
        let row = RowView(title: String.translation(.EMAIL_ROW_TITLE), style: .rowTitle)

        let valueLabel = UILabel()
        row.append(valueLabel)

        bag += client.watch(query: MyInfoQuery(), cachePolicy: .returnCacheDataAndFetch).map({ result -> StyledText in
            if let member = result.data?.member, let email = member.email {
                return StyledText(text: email, style: .rowTitle)
            }

            return StyledText(text: String.translation(.EMAIL_ROW_EMPTY), style: .rowTitleDisabled)
        }).bindTo(valueLabel, \.styledText)

        return (row, bag)
    }
}
