import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct CommonClaimsCollection { @Inject var client: ApolloClient }

extension CommonClaimsCollection: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 5

        let collectionKit = CollectionKit<EmptySection, CommonClaimCard>(layout: layout, holdIn: bag)
        collectionKit.view.clipsToBounds = false
        collectionKit.view.backgroundColor = .clear

        bag += collectionKit.delegate.sizeForItemAt.set { _ -> CGSize in
            CGSize(width: min(190, (collectionKit.view.frame.width / 2) - 10), height: 140)
        }

        bag += collectionKit.view.signal(for: \.bounds).delay(by: 0.25)
            .onValue { _ in collectionKit.view.reloadData() }

        bag += collectionKit.delegate.willDisplayCell.onValue { cell, indexPath in
            cell.layer.zPosition = CGFloat(indexPath.row)
        }

        func fetchData() {
            bag +=
                client.fetch(
                    query: GraphQL.CommonClaimsQuery(
                        locale: Localization.Locale.currentLocale.asGraphQLLocale()
                    )
                )
                .valueSignal
                .onValue { data in
                    let rows = data.commonClaims.enumerated()
                        .map {
                            CommonClaimCard(
                                data: $0.element,
                                index: TableIndex(section: 0, row: $0.offset)
                            )
                        }

                    collectionKit.set(Table(rows: rows), rowIdentifier: { $0.data.title })
                }
        }

        fetchData()

        let stackView = UIStackView()
        stackView.axis = .vertical

        let titleLabel = MultilineLabel(
            value: L10n.claimsQuickChoiceHeader,
            style: .brand(.title3(color: .primary))
        )
        bag += stackView.addArranged(titleLabel.wrappedIn(UIStackView())) { containerStackView in
            containerStackView.layoutMargins = UIEdgeInsets(horizontalInset: 8, verticalInset: 8)
            containerStackView.isLayoutMarginsRelativeArrangement = true
        }

        stackView.addArrangedSubview(collectionKit.view)

        collectionKit.view.snp.updateConstraints { make in make.height.equalTo(140) }

        bag += collectionKit.view.signal(for: \.contentSize)
            .onValue { _ in
                collectionKit.view.snp.updateConstraints { make in
                    make.height.equalTo(
                        collectionKit.view.collectionViewLayout.collectionViewContentSize.height
                    )
                }
            }

        return (stackView, bag)
    }
}
