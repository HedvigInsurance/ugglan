//
//  Charity.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-21.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Foundation
import Presentation

struct Charity {
    let client: ApolloClient

    init(client: ApolloClient = HedvigApolloClient.shared.client!) {
        self.client = client
    }
}

public func += (disposeBag: DisposeBag, disposableArray: [Disposable]) {
    disposableArray.forEach { disposeBag.add($0) }
}

extension Charity: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        viewController.title = "Fisken"

        let tableHeaderContainer = UIView()

        let charityHeader = CharityHeader()
        bag += tableHeaderContainer.add(charityHeader)

        let table = Table<EmptySection, CharityOption>(rows: [])

        let sectionStyle = SectionStyle(
            rowInsets: UIEdgeInsets(
                top: 10,
                left: 20,
                bottom: 10,
                right: 20
            ),
            itemSpacing: 0,
            minRowHeight: 1,
            background: .invisible,
            selectedBackground: .invisible,
            header: .none,
            footer: .none
        )

        let dynamicSectionStyle = DynamicSectionStyle { _ in
            return sectionStyle
        }

        let style = DynamicTableViewFormStyle(section: dynamicSectionStyle, form: .default)

        let tableKit = TableKit<EmptySection, CharityOption>(
            table: table,
            style: style,
            bag: bag,
            headerForSection: { _, _ in
                let (view, charityBag) = charityHeader.materialize(
                    events: ViewableEvents(wasAddedCallbacker: Callbacker())
                )
                bag += charityBag
                return view
            }
        )

        bag += tableKit.delegate.willDisplayCell.onValue({ cell, indexPath in
            cell.layer.zPosition = CGFloat(indexPath.row)
        })

        let rows = ReadWriteSignal<[CharityOption]>([])

        bag += rows.atOnce().onValueDisposePrevious { charityOptions -> Disposable? in
            let innerBag = bag.innerBag()

            innerBag += charityOptions.map({ charityOption -> Disposable in
                charityOption.onSelectSignal.onValueDisposePrevious { _ in
                    self.client.perform(
                        mutation: SelectCharityMutation(id: charityOption.id)
                    ).disposable
                }
            })

            return innerBag
        }

        bag += rows.atOnce().onValue { charityOptions in
            tableKit.set(Table(rows: charityOptions), animation: .fade, rowIdentifier: { $0.title })
        }

        bag += client.watch(
            query: CharityOptionsQuery()
        ).compactMap {
            $0.data?.cashbackOptions.compactMap { $0 }
        }.onValue { cashbackOptions in
            let charityOptions = cashbackOptions.map { cashbackOption in
                CharityOption(
                    id: cashbackOption.id ?? "",
                    name: cashbackOption.name ?? "",
                    title: cashbackOption.title ?? "",
                    description: cashbackOption.description ?? "",
                    paragraph: cashbackOption.paragraph ?? ""
                )
            }

            rows.value = charityOptions
        }

        bag += viewController.install(tableKit)

        return (viewController, bag)
    }
}
