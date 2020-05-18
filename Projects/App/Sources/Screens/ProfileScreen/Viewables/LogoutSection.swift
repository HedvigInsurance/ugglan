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
import UIKit

struct LogoutSection {
    let presentingViewController: UIViewController
}

extension LogoutSection: Viewable {
    func materialize(events _: ViewableEvents) -> (ButtonSection, Disposable) {
        let bag = DisposeBag()

        let logoutButtonSection = ButtonSection(
            text: L10n.logoutButton,
            style: .danger
        )

        bag += logoutButtonSection.onSelect.onValue { _ in
            let alert = Alert<Bool>(
                title: L10n.logoutAlertTitle,
                message: nil,
                tintColor: nil,
                actions: [
                    Alert.Action(
                        title: L10n.logoutAlertActionCancel,
                        style: UIAlertAction.Style.cancel
                    ) { false },
                    Alert.Action(
                        title: L10n.logoutAlertActionConfirm,
                        style: UIAlertAction.Style.destructive
                    ) { true },
                ]
            )

            bag += self.presentingViewController.present(alert).onValue { shouldLogout in
                if shouldLogout {
                    ApplicationState.preserveState(.marketPicker)
                    UIApplication.shared.appDelegate.logout()
                }
            }
        }

        return (logoutButtonSection, bag)
    }
}
