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
        
        let subView = UIView()
        viewController.view.addSubview(subView)
        subView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        viewController.preferredContentSize = CGSize(width: 0, height: 0)

        let containerStackView = UIStackView()
        bag += containerStackView.applySafeAreaBottomLayoutMargin()
        containerStackView.axis = .vertical
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.layoutMargins = UIEdgeInsets(top: 24, left: 15, bottom: 0, right: 15)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        containerStackView.addArrangedSubview(stackView)

        let containerView = UIStackView()
        containerView.spacing = 15
        containerView.backgroundColor = UIColor.white
        containerView.axis = .vertical
        containerView.alignment = .fill
        containerView.distribution = .fill
        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 24)
        containerView.isLayoutMarginsRelativeArrangement = true

        containerStackView.addArrangedSubview(containerView)

        let icon = Icon(icon: self.icon, iconWidth: 60)
        stackView.addArrangedSubview(icon)
        
        icon.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }

        let titleLabel = UILabel()
        titleLabel.style = .draggableOverlayTitle
        titleLabel.textAlignment = .left

        bag += titleLabel.setDynamicText(DynamicString(title))

        containerView.addArrangedSubview(titleLabel)

        let body = MarkdownText(textSignal: .static(description), style: .bodyOffBlack)
        bag += containerView.addArranged(body)

        bag += containerStackView.applyPreferredContentSize(on: viewController)

        subView.addSubview(containerStackView)
        containerStackView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }

        return (viewController, Future { _ in
            bag
        })
    }
}
