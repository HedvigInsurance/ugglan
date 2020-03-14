//
//  MemberIdRow.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-02-15.
//

import Apollo
import Flow
import Form
import Foundation
import Presentation

struct MemberIdRow {
    @Inject var client: ApolloClient
}

extension MemberIdRow: Viewable {
    func materialize(events _: SelectableViewableEvents) -> (KeyValueRow, Disposable) {
        let bag = DisposeBag()
        let row = KeyValueRow()

        row.keySignal.value = String(key: .ABOUT_MEMBER_ID_ROW_KEY)

        bag += client.fetch(query: MemberIdQuery()).valueSignal.compactMap {
            $0.data?.member.id
        }.bindTo(row.valueSignal)

        row.valueStyleSignal.value = .rowTitleDisabled

        return (row, bag)
    }
}
