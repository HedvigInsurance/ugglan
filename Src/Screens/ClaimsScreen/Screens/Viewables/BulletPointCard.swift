//
//  BulletPointCard.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-18.
//

import Flow
import Form
import Foundation
import UIKit

struct BulletPointCard {
    let title: String
    let icon: RemoteVectorIcon
    let description: String
}

extension BulletPointCard: Reusable {
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
        contentView.spacing = 5
        contentView.layoutMargins = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 20)
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

            bag += contentView.addArranged(descriptionLabel)

            print("PRESENT")
            titleLabel.text = bulletPointCard.title
            descriptionLabel.styledTextSignal.value = StyledText(
                text: bulletPointCard.description,
                style: .blockRowDescription
            )

            bag += cardContainer.add(bulletPointCard.icon) { iconView in
                iconView.snp.makeConstraints { make in
                    make.width.height.equalTo(20)
                    make.top.equalTo(21)
                    make.left.equalTo(15)
                }
            }

            return bag
        })
    }
}
