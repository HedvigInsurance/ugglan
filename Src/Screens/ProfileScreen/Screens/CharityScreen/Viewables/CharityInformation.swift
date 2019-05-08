//
//  CharityInformation.swift
//  ugglan
//
//  Created by Gustaf Gunér on 2019-03-28.
//

import Apollo
import Flow
import Form
import Presentation
import UIKit

struct CharityInformation {}

extension CharityInformation: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        
        let containerStackView = UIStackView()
        containerStackView.isLayoutMarginsRelativeArrangement = false
        containerStackView.alignment = .leading
        
        let containerView = UIStackView()
        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 24)
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.axis = .vertical
        containerView.spacing = 10

        containerStackView.addArrangedSubview(containerView)

        let titleLabel = MultilineLabel(value: String(key: .PROFILE_MY_CHARITY_INFO_TITLE), style: .standaloneLargeTitle)
        bag += containerView.addArranged(titleLabel)

        let body = MarkdownText(text: String(key: .PROFILE_MY_CHARITY_INFO_BODY), style: .bodyOffBlack)
        bag += containerView.addArranged(body)

        bag += containerStackView.didLayoutSignal.map {
            containerStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        }.distinct().bindTo(viewController, \.preferredContentSize)

        viewController.view = containerStackView

        return (viewController, Future { _ in
            bag
        })
    }
}
