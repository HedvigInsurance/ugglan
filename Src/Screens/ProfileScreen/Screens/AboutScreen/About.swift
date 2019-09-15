//
//  About.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-16.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Presentation
import UIKit

struct About {
    let client: ApolloClient
    let state: State

    enum State {
        case onboarding, loggedIn
    }

    init(state: State, client: ApolloClient = ApolloContainer.shared.client) {
        self.state = state
        self.client = client
    }
}

extension About: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = String(key: .ABOUT_SCREEN_TITLE)

        let bag = DisposeBag()

        let form = FormView()

        if state == .onboarding {
            let loginSection = form.appendSection(
                headerView: nil,
                footerView: nil,
                style: .sectionPlain
            )

            let loginRow = ButtonRow(
                text: String(key: .SETTINGS_LOGIN_ROW),
                style: .normalButton
            )
            bag += loginSection.append(loginRow)

            bag += loginRow.onSelect.onValue { _ in
                viewController.present(DraggableOverlay(presentable: BankIDLogin(), presentationOptions: [.defaults]))
            }

            bag += form.append(Spacing(height: 20))
        }

        let versionSection = form.appendSection(
            headerView: nil,
            footerView: nil,
            style: .sectionPlain
        )

        let versionRow = VersionRow()
        bag += versionSection.append(versionRow)

        let memberIdRow = MemberIdRow()
        bag += versionSection.append(memberIdRow)

        if state == .loggedIn {
            let activatePushNotificationsRow = ButtonRow(
                text: "Aktivera pushnotiser",
                style: .normalButton
            )
            bag += versionSection.append(activatePushNotificationsRow)

            bag += activatePushNotificationsRow.onSelect.onValueDisposePrevious { _ in
                let register = PushNotificationsRegister(
                    title: String(key: .PUSH_NOTIFICATIONS_ALERT_TITLE),
                    message: "",
                    forceAsk: true
                )
                return viewController.present(register).disposable
            }

            let showWhatsNew = ButtonRow(
                text: "Visa intro",
                style: .normalButton
            )
            bag += versionSection.append(showWhatsNew)

            bag += showWhatsNew.onSelect.onValue { _ in
                bag += self.client
                    .watch(query: WhatsNewQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale(), sinceVersion: "0.0.0"))
                    .compactMap { $0.data }
                    .filter { $0.news.count > 0 }
                    .onValue { data in
                        let whatsNew = WhatsNew(data: data)
                        viewController.present(whatsNew, options: [.prefersNavigationBarHidden(true)])
                    }
            }
        }

        bag += form.append(Spacing(height: 20))

        let licensesSection = form.appendSection(
            headerView: nil,
            footerView: nil,
            style: .sectionPlain
        )

        let licensesRow = LicensesRow(
            presentingViewController: viewController
        )

        bag += licensesSection.append(licensesRow) { row in
            bag += viewController.registerForPreviewing(
                sourceView: row.viewRepresentation,
                previewable: licensesRow
            )
        }

        bag += form.append(Spacing(height: 15))

        let year = Calendar.current.component(.year, from: Date())

        let footerView = UILabel(value: "© Hedvig AB - \(year)", style: .sectionHeader)
        footerView.textAlignment = .center

        form.append(footerView)

        bag += viewController.install(form)

        return (viewController, bag)
    }
}
