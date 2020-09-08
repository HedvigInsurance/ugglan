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
import hCore
import hGraphQL
import Presentation
import UIKit

struct MemberIdRow {
    @Inject var client: ApolloClient
}

extension MemberIdRow: Viewable {
    func materialize(events _: SelectableViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()

        let row = RowView(title: L10n.aboutMemberIdRowKey, style: .brand(.headline(color: .primary)))

        let valueLabel = UILabel(value: "", style: .brand(.headline(color: .quartenary)))
        row.append(valueLabel)

        bag += valueLabel.copySignal.onValue { _ in
            UIPasteboard.general.value = valueLabel.text
        }

        bag += client.fetch(query: GraphQL.MemberIdQuery()).valueSignal.compactMap {
            $0.member.id
        }.bindTo(valueLabel, \.value)

        return (row, bag)
    }
}
