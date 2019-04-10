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

struct PerilCollection {
    let perilsDataSignal: ReadWriteSignal<DashboardQuery.Data.Insurance.PerilCategory?> = ReadWriteSignal(nil)
}

extension PerilCollection: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let collectionViewEdgeInset: CGFloat = 16
        
        let contentViewInsets = UIEdgeInsets(
            top: 20,
            left: collectionViewEdgeInset,
            bottom: 20,
            right: collectionViewEdgeInset
        )
        
        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        
        let collectionKit = CollectionKit<EmptySection, Peril>(
            table: Table(),
            layout: flowLayout,
            bag: bag
        )
        
        bag += collectionKit.delegate.sizeForItemAt.set { index -> CGSize in
            return CGSize(width: 50, height: 85)
        }
        
        bag += collectionKit.delegate.willDisplayCell.onValue { _ in
            collectionKit.view.snp.remakeConstraints { make in
                make.width.equalToSuperview().inset(collectionViewEdgeInset * 2)
                make.height.equalTo(collectionKit.view.collectionViewLayout.collectionViewContentSize.height)
            }
        }
        
        collectionKit.view.backgroundColor = .clear
        
        let collectionViewStack = UIStackView()
        collectionViewStack.edgeInsets = contentViewInsets
        collectionViewStack.addArrangedSubview(collectionKit.view)
        
        contentStackView.addArrangedSubview(collectionViewStack)
        
        bag += perilsDataSignal.atOnce().compactMap { $0?.perils }.onValue { perilSignalArray in
            let perilViewableArray = perilSignalArray.map { peril in
                Peril(title: (peril?.title)!, id: (peril?.id)!)
            }
            
            collectionKit.set(Table(rows: perilViewableArray), animation: .none, rowIdentifier: { $0.title })
            
            collectionKit.view.snp.remakeConstraints { make in
                make.width.equalToSuperview().inset(collectionViewEdgeInset * 2)
                // A given height is needed for the cells to render -- the actual height constraint is set in the willDisplayCell method.
                make.height.equalTo(10)
            }
        }
        
        let divider = Divider(backgroundColor: .offWhite)
        bag += contentStackView.addArranged(divider)
        
        let footerLabel = MultilineLabel(styledText: StyledText(text: "Klicka på ikonerna för mer info", style: .perilTitle))
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
