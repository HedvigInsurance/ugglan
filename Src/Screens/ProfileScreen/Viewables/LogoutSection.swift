//
//  LogoutSection.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-17.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import Presentation

struct LogoutSection {
    let presentingViewController: UIViewController
}

extension LogoutSection: Viewable {
    func materialize(events _: ViewableEvents) -> (ButtonSection, Disposable) {
        let bag = DisposeBag()

        let logoutButtonSection = ButtonSection(
            text: String(.LOGOUT_BUTTON),
            textStyle: .dangerButton,
            sectionStyle: .sectionPlain,
            selectedBackground: .selectedDanger
        )

        bag += logoutButtonSection.onSelect.onValue({ _ in
            let alert = Alert<Bool>(
                title: String(.LOGOUT_ALERT_TITLE),
                message: nil,
                tintColor: nil,
                actions: [
                    Alert.Action(
                        title: String(.LOGOUT_ALERT_ACTION_CANCEL),
                        style: UIAlertAction.Style.cancel
                    ) { false },
                    Alert.Action(
                        title: String(.LOGOUT_ALERT_ACTION_CONFIRM),
                        style: UIAlertAction.Style.destructive
                    ) { true },
                ]
            )

            bag += self.presentingViewController.present(alert).onValue({ shouldLogout in
                if shouldLogout {
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    appDelegate?.logout()
                }
            })
        })

        return (logoutButtonSection, bag)
    }
}
