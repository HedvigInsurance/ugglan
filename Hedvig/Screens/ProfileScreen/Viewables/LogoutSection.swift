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
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()

        let dangerSectionPlain = DynamicSectionStyle { _ -> SectionStyle in
            SectionStyle(
                rowInsets: SectionStyle.sectionPlain.rowInsets,
                itemSpacing: SectionStyle.sectionPlain.itemSpacing,
                minRowHeight: SectionStyle.sectionPlain.minRowHeight,
                background: SectionStyle.sectionPlain.background,
                selectedBackground: .selectedDanger,
                header: SectionStyle.sectionPlain.header,
                footer: SectionStyle.sectionPlain.footer
            )
        }

        let section = SectionView(
            header: nil,
            footer: nil,
            style: dangerSectionPlain
        )

        let logoutButton = ButtonRow(
            text: String.translation(.LOGOUT_BUTTON),
            style: .dangerButton
        )
        bag += section.append(logoutButton)

        bag += logoutButton.onSelect.onValue({ _ in
            let alert = Alert<Bool>(
                title: String.translation(.LOGOUT_ALERT_TITLE),
                message: nil,
                tintColor: nil,
                actions: [
                    Alert.Action(
                        title: String.translation(.LOGOUT_ALERT_ACTION_CANCEL),
                        style: UIAlertAction.Style.cancel
                    ) { false },
                    Alert.Action(
                        title: String.translation(.LOGOUT_ALERT_ACTION_CONFIRM),
                        style: UIAlertAction.Style.destructive
                    ) { true }
                ]
            )

            bag += self.presentingViewController.present(alert).onValue({ shouldLogout in
                if shouldLogout {
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    appDelegate?.logout()
                }
            })
        })

        return (section, bag)
    }
}
