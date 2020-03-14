//
//  InsuranceDetails.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-04.
//

import Flow
import Form
import Foundation
import UIKit
import Space
import ComponentKit

struct PerilCollection {
    let perilsDataSignal: ReadWriteSignal<PerilCategoryFragment?> = ReadWriteSignal(nil)
    let presentingViewController: UIViewController
    let collectionViewInset: UIEdgeInsets

    init(
        presentingViewController: UIViewController,
        collectionViewInset: UIEdgeInsets = UIEdgeInsets(
            top: 20,
            left: 16,
            bottom: 20,
            right: 16
        )
    ) {
        self.presentingViewController = presentingViewController
        self.collectionViewInset = collectionViewInset
    }
}

extension PerilCollection: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let contentStackView = UIStackView()
        contentStackView.axis = .vertical

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical

        let collectionKit = CollectionKit<EmptySection, Peril>(
            table: Table(),
            layout: flowLayout,
            holdIn: bag
        )

        bag += collectionKit.delegate.sizeForItemAt.set { _ -> CGSize in
            CGSize(
                width: min(85, collectionKit.view.frame.width / 4),
                height: 85
            )
        }

        bag += collectionKit.delegate.willDisplayCell.onValue { _ in
            collectionKit.view.snp.remakeConstraints { make in
                make.leading.equalToSuperview().inset(self.collectionViewInset.left)
                make.trailing.equalToSuperview().inset(self.collectionViewInset.right)
                make.height.equalTo(collectionKit.view.collectionViewLayout.collectionViewContentSize.height)
            }
        }

        collectionKit.view.backgroundColor = .clear

        let collectionViewStack = UIStackView()
        collectionViewStack.edgeInsets = collectionViewInset
        collectionViewStack.addArrangedSubview(collectionKit.view)

        contentStackView.addArrangedSubview(collectionViewStack)

        bag += perilsDataSignal.atOnce().compactMap { $0?.perils }.onValue { perilSignalArray in
            let perilViewableArray = perilSignalArray.filter { $0?.title != nil || $0?.id != nil || $0?.description != nil }.map { peril in
                Peril(title: peril?.title ?? "", id: peril?.id ?? "", description: peril?.description ?? "", presentingViewController: self.presentingViewController)
            }

            collectionKit.set(Table(rows: perilViewableArray), animation: .none, rowIdentifier: { $0.title })

            collectionKit.view.snp.remakeConstraints { make in
                make.width.equalToSuperview().inset(self.collectionViewInset.left + self.collectionViewInset.right)
                // A given height is needed for the cells to render -- the actual height constraint is set in the willDisplayCell method.
                make.height.equalTo(10)
            }
        }

        let divider = Divider(backgroundColor: .primaryBorder)
        bag += contentStackView.addArranged(divider)

        let footerLabel = MultilineLabel(styledText: StyledText(text: String(key: .DASHBOARD_PERIL_FOOTER), style: .perilTitle))
        bag += contentStackView.addArranged(footerLabel) { footerLabelView in
            footerLabelView.textAlignment = .center
            footerLabelView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.height.equalTo(30)
            }
        }

        return (contentStackView, bag)
    }
}
