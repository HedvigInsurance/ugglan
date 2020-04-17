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
    func materialize(events _: SelectableViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()

        let row = RowView(title: String(key: .ABOUT_MEMBER_ID_ROW_KEY), style: .rowTitle)

        let valueLabel = UILabel(value: "", style: .rowTitleDisabled)
        row.append(valueLabel)
        
        bag += valueLabel.copySignal.onValue { _ in
            UIPasteboard.general.value = valueLabel.text
        }
        
        bag += client.fetch(query: MemberIdQuery()).valueSignal.compactMap {
            $0.data?.member.id
        }.bindTo(valueLabel, \.value)

        return (row, bag)
    }
}
