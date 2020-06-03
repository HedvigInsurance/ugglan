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

        let containerStackView = UIStackView()
        containerStackView.alignment = .leading
        bag += containerStackView.applySafeAreaBottomLayoutMargin()

        let containerView = UIStackView()
        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 24)
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.axis = .vertical
        containerView.spacing = 15

        containerStackView.addArrangedSubview(containerView)

        let titleLabel = MultilineLabel(value: L10n.profileMyCharityInfoTitle, style: .draggableOverlayTitle)
        bag += containerView.addArranged(titleLabel)

        let body = MarkdownText(textSignal: .static(L10n.profileMyCharityInfoBody), style: .bodyOffBlack)
        bag += containerView.addArranged(body)

        bag += containerStackView.applyPreferredContentSize(on: viewController)

        viewController.view = containerStackView

        return (viewController, Future { _ in
            bag
        })
    }
}
