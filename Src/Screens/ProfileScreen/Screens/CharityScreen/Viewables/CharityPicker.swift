//
//  CharityPicker.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-23.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Foundation
import UIKit

struct CharityPicker {
    let client: ApolloClient
    let presentingViewController: UIViewController

    init(
        client: ApolloClient = ApolloContainer.shared.client,
        presentingViewController: UIViewController
    ) {
        self.client = client
        self.presentingViewController = presentingViewController
    }
}

extension CharityPicker: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Future<CharityOption>) {
        let bag = DisposeBag()
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
            sectionStyle
        }

        let style = DynamicTableViewFormStyle(section: dynamicSectionStyle, form: .default)

        let tableKit = TableKit<EmptySection, CharityOption>(
            table: table,
            style: style,
            bag: bag,
            headerForSection: { _, _ in
                let headerStackView = UIStackView()
                headerStackView.edgeInsets = UIEdgeInsets(horizontalInset: 20, verticalInset: 0)
                headerStackView.isLayoutMarginsRelativeArrangement = true

                let label = UILabel(
                    value: String(.CHARITY_OPTIONS_HEADER_TITLE),
                    style: .sectionHeader
                )

                headerStackView.addArrangedSubview(label)

                return headerStackView
            },
            footerForSection: { _, _ in
                let footerStackView = UIStackView()
                footerStackView.edgeInsets = UIEdgeInsets(horizontalInset: 20, verticalInset: 30)
                footerStackView.isLayoutMarginsRelativeArrangement = true
                
                let charityInformationButton = CharityInformationButton(presentingViewController: self.presentingViewController)
                bag += footerStackView.addArangedSubview(charityInformationButton)
                
                return footerStackView
            }
        )

        let charityHeader = CharityHeader()
        bag += tableKit.view.addTableHeaderView(charityHeader)

        bag += tableKit.delegate.willDisplayCell.onValue({ cell, indexPath in
            cell.layer.zPosition = CGFloat(indexPath.row)
        })

        let rows = ReadWriteSignal<[CharityOption]>([])

        bag += rows.atOnce().onValue { charityOptions in
            tableKit.set(Table(rows: charityOptions), animation: .none, rowIdentifier: { $0.title })
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

        return (tableKit.view, Future { completion in
            bag += rows.atOnce().onValueDisposePrevious { charityOptions -> Disposable? in
                let innerBag = bag.innerBag()

                innerBag += charityOptions.map({ charityOption -> Disposable in
                    charityOption.onSelectSignal.onValueDisposePrevious { buttonView in
                        let dismissCallbacker = Callbacker<Void>()

                        let bubbleLoading = BubbleLoading(
                            originatingView: buttonView,
                            dismissSignal: dismissCallbacker.signal()
                        )

                        self.presentingViewController.present(
                            bubbleLoading,
                            style: .modally(
                                presentationStyle: .overFullScreen,
                                transitionStyle: .none,
                                capturesStatusBarAppearance: true
                            ),
                            options: [.unanimated]
                        )

                        bag += bubbleLoading.dismissSignal.delay(by: 0.2).onValue({ _ in
                            completion(.success(charityOption))
                        })

                        return self.client.perform(
                            mutation: SelectCharityMutation(id: charityOption.id)
                        ).onValue({ _ in
                            dismissCallbacker.callAll()
                        }).disposable
                    }
                })

                return innerBag
            }

            return bag
        })
    }
}
