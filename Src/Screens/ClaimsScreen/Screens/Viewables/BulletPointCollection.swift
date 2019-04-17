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
        
        let cardContainer = UIView()
        cardContainer.backgroundColor = .white
        cardContainer.layer.cornerRadius = 8
        cardContainer.layer.shadowOffset = CGSize(width: 0, height: 16)
        cardContainer.layer.shadowRadius = 30
        cardContainer.layer.shadowColor = UIColor.black.cgColor
        cardContainer.layer.shadowOpacity = 0.05
        
        view.addArrangedSubview(cardContainer)
        
        let contentView = UIStackView()
        contentView.axis = .vertical
        contentView.alignment = .top
        contentView.spacing = 10
        contentView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        contentView.isLayoutMarginsRelativeArrangement = true
        
        cardContainer.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(40)
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        let titleLabel = UILabel(value: "", style: .blockRowTitle)
        contentView.addArrangedSubview(titleLabel)
        
        let descriptionLabel = MultilineLabel(styledText: StyledText(text: "", style: .blockRowDescription))
        
        return (view, { bulletPointCard in
            let bag = DisposeBag()
            
            bag += contentView.addArangedSubview(descriptionLabel)
            
            titleLabel.text = bulletPointCard.title
            descriptionLabel.styledTextSignal.value = StyledText(
                text: bulletPointCard.description,
                style: .blockRowDescription
            )
            
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
    func materialize(events: ViewableEvents) -> (UITableView, Disposable) {
        let bag = DisposeBag()
        
        let sectionStyle = SectionStyle(
            rowInsets: UIEdgeInsets(
                top: 5,
                left: 20,
                bottom: 5,
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

        
        let tableKit = TableKit<EmptySection, BulletPointCard>(style: style, bag: bag)
        
        let rows = bulletPoints.map {
            BulletPointCard(
                title: $0.title,
                icon: RemoteVectorIcon(URL(string: "https://graphql.dev.hedvigit.com\($0.icon.pdfUrl)")!),
                description: $0.description
            )
        }
        
        bag += tableKit.delegate.willDisplayCell.onValue({ cell, indexPath in
            cell.layer.zPosition = CGFloat(indexPath.row)
        })
        
        tableKit.set(Table(rows: rows), rowIdentifier: { $0.title })
        tableKit.view.backgroundColor = .offWhite
        
        return (tableKit.view, bag)
    }
}
