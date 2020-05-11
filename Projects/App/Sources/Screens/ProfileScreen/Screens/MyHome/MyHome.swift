//
//  MyResidence.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-02-12.
//

import Apollo
import Flow
import Form
import Presentation
import UIKit
import Core
import Core

struct MyHome {
    @Inject var client: ApolloClient

    init(
    ) {}
}

extension MyHome: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.title = L10n.myHomeTitle

        let form = FormView()
        bag += viewController.install(form)

        let addressCircle = AddressCircle()
        bag += form.prepend(addressCircle)

        let rowTitle = UILabel(value: L10n.myHomeSectionTitle, style: .rowTitle)

        bag += form.append(InsuranceSummarySection(headerView: rowTitle))

        bag += form.append(Spacing(height: 20))

        let buttonSection = ButtonSection(
            text: L10n.myHomeChangeInfoButton,
            style: .normal
        )
        bag += form.append(buttonSection)

        bag += buttonSection.onSelect.onValue {
            let alert = Alert<Bool>(
                title: L10n.myHomeChangeAlertTitle,
                message: L10n.myHomeChangeAlertMessage,
                actions: [
                    Alert.Action(title: L10n.myHomeChangeAlertActionCancel) { false },
                    Alert.Action(title: L10n.myHomeChangeAlertActionConfirm) { true },
                ]
            )

            viewController.present(alert).onValue { shouldContinue in
                if shouldContinue {
                    viewController.present(
                        FreeTextChat().withCloseButton,
                        style: .modally(
                            presentationStyle: .pageSheet,
                            transitionStyle: nil,
                            capturesStatusBarAppearance: true
                        )
                    )
                }
            }
        }

        return (viewController, bag)
    }
}
