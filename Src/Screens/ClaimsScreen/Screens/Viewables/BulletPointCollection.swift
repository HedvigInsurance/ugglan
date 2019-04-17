//
//  BulletPointCollection.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-17.
//

import Foundation
import Flow
import UIKit
import Form

struct BulletPointCard: Reusable {
    let title: String
    
    static func makeAndConfigure() -> (make: UIView, configure: (BulletPointCard) -> Disposable) {
        let view = UIStackView()
        view.axis = .vertical
        view.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        view.isLayoutMarginsRelativeArrangement = true
        
        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        contentView.layer.shadowOffset = CGSize(width: 0, height: 16)
        contentView.layer.shadowRadius = 30
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.05
        
        view.addArrangedSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
        }
        
        return (view, { bulletPointCard in
            
            return NilDisposer()
        })
    }
}

struct BulletPointCollection {
    let bulletPoints: [CommonClaimsQuery.Data.CommonClaim.Layout.AsTitleAndBulletPoints.BulletPoint]
}

extension BulletPointCollection: Viewable {
    func materialize(events: ViewableEvents) -> (UICollectionView, Disposable) {
        let bag = DisposeBag()
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        let collectionKit = CollectionKit<EmptySection, BulletPointCard>(layout: layout, bag: bag)
        
        bag += collectionKit.delegate.sizeForItemAt.set { _ -> CGSize in
            return CGSize(width: UIScreen.main.bounds.width, height: 150)
        }
                
        collectionKit.set(Table(rows: bulletPoints.map { BulletPointCard(title: $0.title) }), rowIdentifier: { $0.title })
        collectionKit.view.backgroundColor = .offWhite
        
        return (collectionKit.view, bag)
    }
}
