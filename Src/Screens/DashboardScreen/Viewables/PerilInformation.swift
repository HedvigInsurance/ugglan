//
//  PerilInformation.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-15.
//

import Apollo
import Flow
import Form
import Presentation
import UIKit

struct PerilInformation {
    let description: String
    let title: String
    let icon: ImageAsset

    init(title: String, description: String, icon: ImageAsset) {
        self.title = title
        self.description = description
        self.icon = icon
    }
}

extension PerilInformation: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.preferredContentSize = CGSize(width: 0, height: 0)

        let containerStackView = UIStackView()
        containerStackView.isLayoutMarginsRelativeArrangement = false

        let containerView = UIStackView()
        containerView.spacing = 10
        containerView.backgroundColor = UIColor.white
        containerView.axis = .vertical
        containerView.alignment = .top
        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 24)
        containerView.isLayoutMarginsRelativeArrangement = true

        containerStackView.addArrangedSubview(containerView)

        let icon = Icon(icon: self.icon, iconWidth: 60)
        containerView.addArrangedSubview(icon)

        icon.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.height.equalTo(60)
        }
        
        let titleLabel = MultilineLabel(value: title, style: TextStyle.standaloneLargeTitle.lineHeight(32.0))
        bag += containerView.addArranged(titleLabel)

        let body = MarkdownText(text: description, style: .bodyOffBlack)
        bag += containerView.addArranged(body)

        bag += containerStackView.didLayoutSignal.map { _ in
            containerStackView.systemLayoutSizeFitting(UIScreen.main.bounds.size)
        }.distinct().bindTo(viewController, \.preferredContentSize)
        
        viewController.view = containerStackView

        return (viewController, Future { _ in
            bag
        })
    }
}
