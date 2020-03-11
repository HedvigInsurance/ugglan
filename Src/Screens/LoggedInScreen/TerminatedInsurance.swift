//
//  TerminatedInsurance.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-19.
//

import Flow
import Form
import Foundation
import Presentation
import UIKit
import ComponentKit

struct TerminatedInsurance {}

extension TerminatedInsurance: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()

        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.spacing = 20

        let spacing = Spacing(height: 20)
        bag += view.addArranged(spacing)

        let title = MultilineLabel(value: String(key: .INSURANCE_STATUS_TERMINATED_ALERT_TITLE), style: .standaloneLargeTitle)
        bag += view.addArranged(title)

        let description = MultilineLabel(value: String(key: .INSURANCE_STATUS_TERMINATED_ALERT_MESSAGE), style: TextStyle.bodyOffBlack.centerAligned)
        bag += view.addArranged(description)

        let button = Button(
            title: String(key: .INSURANCE_STATUS_TERMINATED_ALERT_CTA),
            type: .standard(backgroundColor: .hedvig(.primaryTintColor), textColor: .hedvig(.white))
        )
        bag += view.addArranged(button)

        bag += button.onTapSignal.onValue { _ in
            let overlay = DraggableOverlay(presentable: FreeTextChat(), adjustsToKeyboard: false)
            viewController.present(overlay)
        }

        bag += viewController.install(view) { scrollView in
            scrollView.backgroundColor = .hedvig(.offWhite)
        }

        return (viewController, bag)
    }
}
