//
//  CommonClaimsCollection.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-12.
//

import Foundation
import Flow
import Form
import Apollo
import UIKit
import Presentation

struct CommonClaimsCollection {
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

extension CommonClaimsCollection: Viewable {
    func materialize(events: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionKit = CollectionKit<EmptySection, CommonClaimCard>(
            layout: layout,
            bag: bag
        )
        collectionKit.view.backgroundColor = .offWhite
        collectionKit.view.clipsToBounds = false
        
        bag += collectionKit.delegate.sizeForItemAt.set { _ -> CGSize in
            return CGSize(
                width: collectionKit.view.frame.width / 2,
                height: 140
            )
        }
        
        bag += collectionKit.registerViewForSupplementaryElement { tableIndex -> CommonClaimsHeader in
            return CommonClaimsHeader()
        }
        
        bag += client.fetch(query: CommonClaimsQuery(locale: .svSe)).onValue { result in
            let rows = result.data!.commonClaims.enumerated().map {
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
        }.disposable
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        
        let titleLabel = MultilineLabel(value: "Snabbval", style: .blockRowTitle)
        bag += stackView.addArangedSubview(titleLabel.wrappedIn(UIStackView())) { containerStackView in
            containerStackView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 0)
            containerStackView.isLayoutMarginsRelativeArrangement = true
        }
        
        stackView.addArrangedSubview(collectionKit.view)
        
        bag += collectionKit.view.didLayoutSignal.onValue({ _ in
            collectionKit.view.snp.updateConstraints({ make in
                make.height.equalTo(
                    collectionKit.view.collectionViewLayout.collectionViewContentSize.height
                )
            })
        })
        
        return (stackView, bag)
    }
}
