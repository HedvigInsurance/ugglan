//
//  CharityInformation.swift
//  ugglan
//
//  Created by Gustaf Gunér on 2019-03-28.
//

import Apollo
import Flow
import Form
import hCore
import hCoreUI
import Presentation
import UIKit

struct CharityInformation {}

extension CharityInformation: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.title = L10n.profileMyCharityInfoTitle

        let containerView = UIStackView()
        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 24)
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.axis = .vertical
        containerView.spacing = 15

        let body = MarkdownText(textSignal: .static(L10n.profileMyCharityInfoBody), style: .brand(.body(color: .primary)))
        bag += containerView.addArranged(body)

        bag += viewController.install(containerView)

        return (viewController, Future { _ in
            bag
        })
    }
}
