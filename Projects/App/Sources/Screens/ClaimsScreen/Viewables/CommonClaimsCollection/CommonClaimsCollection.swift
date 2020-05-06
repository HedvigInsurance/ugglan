//
//  CommonClaimsCollection.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-12.
//

import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit

struct CommonClaimsCollection {
    @Inject var client: ApolloClient
    let presentingViewController: UIViewController

    init(
        presentingViewController: UIViewController
    ) {
        self.presentingViewController = presentingViewController
    }
}

extension CommonClaimsCollection: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 5

        let collectionKit = CollectionKit<EmptySection, CommonClaimCard>(
            layout: layout,
            holdIn: bag
        )
        collectionKit.view.clipsToBounds = false
        collectionKit.view.backgroundColor = .primaryBackground

        bag += collectionKit.delegate.sizeForItemAt.set { _ -> CGSize in
            CGSize(
                width: min(190, (collectionKit.view.frame.width / 2) - 10),
                height: 140
            )
        }

        bag += collectionKit.delegate.willDisplayCell.onValue { cell, indexPath in
            cell.layer.zPosition = CGFloat(indexPath.row)
        }

        func fetchData() {
            bag += client.fetch(
                query: CommonClaimsQuery(
                    locale: Localization.Locale.currentLocale.asGraphQLLocale()
                )
            )
            .valueSignal
            .compactMap { $0.data?.commonClaims }
            .onValue { commonClaims in
                let rows = commonClaims.enumerated().map {
                    CommonClaimCard(
                        data: $0.element,
                        index: TableIndex(section: 0, row: $0.offset),
                        presentingViewController: self.presentingViewController
                    )
                }

                collectionKit.set(
                    Table(rows: rows),
                    rowIdentifier: { $0.data.title }
                )
            }
        }

        fetchData()

        bag += NotificationCenter.default.signal(forName: .localeSwitched).onValue { _ in
            fetchData()
        }

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 20, right: 15)
        stackView.isLayoutMarginsRelativeArrangement = true

        let titleLabel = MultilineLabel(value: L10n.claimsQuickChoiceHeader, style: .blockRowTitle)
        bag += stackView.addArranged(titleLabel.wrappedIn(UIStackView())) { containerStackView in
            containerStackView.layoutMargins = UIEdgeInsets(horizontalInset: 0, verticalInset: 0)
            containerStackView.isLayoutMarginsRelativeArrangement = true
        }

        stackView.addArrangedSubview(collectionKit.view)

        bag += collectionKit.view.didLayoutSignal.onValue { _ in
            collectionKit.view.snp.updateConstraints { make in
                make.height.equalTo(
                    collectionKit.view.collectionViewLayout.collectionViewContentSize.height
                )
            }
        }

        return (stackView, bag)
    }
}
