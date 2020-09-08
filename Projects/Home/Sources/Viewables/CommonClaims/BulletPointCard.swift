//
//  BulletPointCard.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-18.
//

import Flow
import Form
import Foundation
import hCoreUI
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
        cardContainer.backgroundColor = .brand(.primaryBackground())
        cardContainer.layer.cornerRadius = 8

        view.addArrangedSubview(cardContainer)

        let contentView = UIStackView()
        contentView.axis = .vertical
        contentView.alignment = .top
        contentView.spacing = 5
        contentView.layoutMargins = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 20)
        contentView.isLayoutMarginsRelativeArrangement = true
        contentView.insetsLayoutMarginsFromSafeArea = false

        cardContainer.addSubview(contentView)

        contentView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(40)
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        let titleLabel = UILabel(value: "", style: .brand(.headline(color: .primary)))
        contentView.addArrangedSubview(titleLabel)

        let descriptionLabel = MultilineLabel(value: "", style: .brand(.body(color: .secondary)))

        return (view, { bulletPointCard in
            let bag = DisposeBag()

            bag += cardContainer.applyShadow { _ -> UIView.ShadowProperties in
                UIView.ShadowProperties(
                    opacity: 0.05,
                    offset: CGSize(width: 0, height: 16),
                    radius: 30,
                    color: .brand(.primaryShadowColor),
                    path: nil
                )
            }

            bag += contentView.addArranged(descriptionLabel)

            titleLabel.value = bulletPointCard.title
            descriptionLabel.valueSignal.value = bulletPointCard.description

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
