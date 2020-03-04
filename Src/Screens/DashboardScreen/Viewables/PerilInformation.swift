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
        containerStackView.axis = .vertical
        bag += containerStackView.applySafeAreaBottomLayoutMargin()
        
        let headerStackView = UIStackView()
        headerStackView.layoutMargins = UIEdgeInsets(top: 24, left: 15, bottom: 0, right: 15)
        headerStackView.isLayoutMarginsRelativeArrangement = true
        headerStackView.axis = .vertical
        headerStackView.alignment = .leading
        containerStackView.addArrangedSubview(headerStackView)
        
        let containerView = UIStackView()
        containerView.spacing = 15
        containerView.axis = .vertical
        containerView.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 24, right: 15)
        containerView.isLayoutMarginsRelativeArrangement = true

        containerStackView.addArrangedSubview(containerView)

        let icon = Icon(icon: self.icon, iconWidth: 60)
        headerStackView.addArrangedSubview(icon)

        let titleLabel = UILabel()
        titleLabel.style = .draggableOverlayTitle
        titleLabel.textAlignment = .left

        bag += titleLabel.setDynamicText(DynamicString(title))

        containerView.addArrangedSubview(titleLabel)

        let body = MarkdownText(textSignal: .static(description), style: .bodyOffBlack)
        bag += containerView.addArranged(body)

        bag += containerStackView.applyPreferredContentSize(on: viewController)

        viewController.view = containerStackView

        return (viewController, Future { _ in
            bag
        })
    }
}
