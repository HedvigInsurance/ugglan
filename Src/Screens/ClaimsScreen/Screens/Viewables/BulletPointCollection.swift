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
    let icon: RemoteVectorIcon
    let description: String
    
    static func makeAndConfigure() -> (make: UIView, configure: (BulletPointCard) -> Disposable) {
        let view = UIStackView()
        view.axis = .vertical
        view.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        view.isLayoutMarginsRelativeArrangement = true
        
        let cardContainer = UIView()
        cardContainer.backgroundColor = .white
        cardContainer.layer.cornerRadius = 8
        cardContainer.layer.shadowOffset = CGSize(width: 0, height: 16)
        cardContainer.layer.shadowRadius = 30
        cardContainer.layer.shadowColor = UIColor.black.cgColor
        cardContainer.layer.shadowOpacity = 0.05
        
        view.addArrangedSubview(cardContainer)
        
        cardContainer.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
        }
        
        let contentView = UIStackView()
        contentView.axis = .vertical
        contentView.alignment = .top
        
        cardContainer.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(40)
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        let titleLabel = UILabel(value: "", style: .blockRowTitle)
        contentView.addArrangedSubview(titleLabel)
        
        let descriptionLabel = UILabel(value: "", style: .blockRowDescription)
        contentView.addArrangedSubview(descriptionLabel)
        
        return (view, { bulletPointCard in
            let bag = DisposeBag()
            
            titleLabel.text = bulletPointCard.title
            descriptionLabel.text = bulletPointCard.description
            
            bag += cardContainer.add(bulletPointCard.icon) { iconView in
                iconView.snp.makeConstraints({ make in
                    make.width.height.equalTo(20)
                    make.top.equalTo(15)
                    make.left.equalTo(15)
                })
            }
            
            return bag
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
        
        let rows = bulletPoints.map {
            BulletPointCard(
                title: $0.title,
                icon: RemoteVectorIcon(URL(string: "https://graphql.dev.hedvigit.com\($0.icon.pdfUrl)")!),
                description: $0.description
            )
        }
        
        collectionKit.set(Table(rows: rows), rowIdentifier: { $0.title })
        collectionKit.view.backgroundColor = .offWhite
        
        return (collectionKit.view, bag)
    }
}
