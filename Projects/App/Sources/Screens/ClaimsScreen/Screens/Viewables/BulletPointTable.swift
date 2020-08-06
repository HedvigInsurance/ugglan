//
//  BulletPointTable.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-17.
//

import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

struct BulletPointTable {
    let bulletPoints: [CommonClaimsQuery.Data.CommonClaim.Layout.AsTitleAndBulletPoints.BulletPoint]
}

extension BulletPointTable: Viewable {
    func materialize(events _: ViewableEvents) -> (UITableView, Disposable) {
        let bag = DisposeBag()

        let sectionStyle = SectionStyle(
            rowInsets: UIEdgeInsets(
                top: 5,
                left: 0,
                bottom: 5,
                right: 0
            ),
            itemSpacing: 0,
            minRowHeight: 10,
            background: .invisible,
            selectedBackground: .invisible,
            header: .none,
            footer: .none
        )

        let dynamicSectionStyle = DynamicSectionStyle { _ in
            sectionStyle
        }

        let style = DynamicTableViewFormStyle(section: dynamicSectionStyle, form: .default)

        let tableKit = TableKit<EmptySection, BulletPointCard>(style: style, holdIn: bag)
        tableKit.view.isScrollEnabled = false

        let rows = bulletPoints.map {
            BulletPointCard(
                title: $0.title,
                icon: RemoteVectorIcon(hCoreUI.IconFragment(unsafeResultMap: $0.icon.fragments.iconFragment.resultMap)),
                description: $0.description
            )
        }

        bag += tableKit.delegate.willDisplayCell.onValue { cell, indexPath in
            cell.layer.zPosition = CGFloat(indexPath.row)
        }

        tableKit.set(Table(rows: rows), rowIdentifier: { $0.title })
        tableKit.view.backgroundColor = .primaryBackground

        return (tableKit.view, bag)
    }
}
