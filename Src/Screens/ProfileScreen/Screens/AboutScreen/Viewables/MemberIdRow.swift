//
//  MemberIdRow.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-02-15.
//

import Flow
import Form
import Foundation
import Presentation
import Apollo

struct MemberIdRow {
    let client: ApolloClient
    
    init(client: ApolloClient = HedvigApolloClient.shared.client!) {
        self.client = client
    }
}

extension MemberIdRow: Viewable {
    func materialize(events _: SelectableViewableEvents) -> (KeyValueRow, Disposable) {
        let bag = DisposeBag()
        let row = KeyValueRow()
        
        row.keySignal.value = String(.ABOUT_MEMBER_ID_ROW_KEY)
        
        bag += client.fetch(query: MemberIdQuery()).valueSignal.compactMap {
            $0.data?.member.id
        }.bindTo(row.valueSignal)
        
        row.valueStyleSignal.value = .rowTitleDisabled
        
        return (row, bag)
    }
}
