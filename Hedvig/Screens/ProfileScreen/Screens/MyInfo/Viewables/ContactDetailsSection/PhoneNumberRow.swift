//
//  PhoneNumberRow.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-14.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Foundation

struct PhoneNumberRow {
    let client: ApolloClient

    init(client: ApolloClient = HedvigApolloClient.shared.client!) {
        self.client = client
    }
}

extension PhoneNumberRow: Viewable {
    func materialize(events _: ViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()
        let row = RowView(title: String.translation(.PHONE_NUMBER_ROW_TITLE), style: .rowTitle)

        let valueLabel = UILabel()
        row.append(valueLabel)

        bag += client.watch(
            query: MyInfoQuery(),
            cachePolicy: .returnCacheDataAndFetch
        ).map { $0.data?.member.phoneNumber }.map { phoneNumber -> StyledText in
            if let phoneNumber = phoneNumber {
                return StyledText(text: phoneNumber, style: .rowTitle)
            }

            return StyledText(text: String.translation(.PHONE_NUMBER_ROW_EMPTY), style: .rowTitleDisabled)
        }.bindTo(valueLabel, \.styledText)

        return (row, bag)
    }
}
