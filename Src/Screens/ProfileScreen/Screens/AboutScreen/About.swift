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
import SwiftUI
import UIKit
import Space
import Common

struct About {
    @Inject var client: ApolloClient
    let state: State

    enum State {
        case onboarding, loggedIn
    }

    init(state: State) {
        self.state = state
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
        bag += versionSection.append(versionRow) { versionRowView in
            let tapGestureRecongnizer = UITapGestureRecognizer()
            tapGestureRecongnizer.numberOfTapsRequired = 2

            versionRowView.viewRepresentation.addGestureRecognizer(tapGestureRecongnizer)

            bag += tapGestureRecongnizer.signal(forState: .recognized).onValue { _ in
                if #available(iOS 13, *) {
                    viewController.present(UIHostingController(rootView: Debug()), style: .modally(), options: [])
                }
            }
        }

        let memberIdRow = MemberIdRow()
        bag += versionSection.append(memberIdRow)

        if state == .loggedIn {
            let activatePushNotificationsRow = ButtonRow(
                text: String(key: .ABOUT_PUSH_ROW),
                style: .normalButton
            )

            bag += versionSection.append(activatePushNotificationsRow)

            let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications

            if !isRegisteredForRemoteNotifications {
                activatePushNotificationsRow.isHiddenSignal.value = false

                bag += activatePushNotificationsRow.onSelect.onValueDisposePrevious { _ in
                    let register = PushNotificationsRegister(
                        title: String(key: .PUSH_NOTIFICATIONS_ALERT_TITLE),
                        message: "",
                        forceAsk: true
                    )

                    return viewController.present(register).onResult { result in
                        switch result {
                        case .success: activatePushNotificationsRow.isHiddenSignal.value = true
                        case .failure:
                            break
                        }
                    }.disposable
                }
            } else {
                activatePushNotificationsRow.isHiddenSignal.value = true
            }

            let showWhatsNew = ButtonRow(
                text: String(key: .ABOUT_SHOW_INTRO_ROW),
                style: .normalButton
            )
            bag += versionSection.append(showWhatsNew)

            bag += showWhatsNew.onSelect.onValue { _ in
                bag += self.client
                    .watch(query: WhatsNewQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale(), sinceVersion: "2.8.3"))
                    .compactMap { $0.data }
                    .filter { $0.news.count > 0 }
                    .onValue { data in
                        let whatsNew = WhatsNew(data: data)
                        viewController.present(whatsNew, options: [.prefersNavigationBarHidden(true)])
                    }
            }
        }

        bag += form.append(Spacing(height: 20))

        let otherSection = form.appendSection(
            headerView: nil,
            footerView: nil,
            style: .sectionPlain
        )

        let languageRow = LanguageRow(
            presentingViewController: viewController
        )

        bag += otherSection.append(languageRow) { row in
            bag += viewController.registerForPreviewing(
                sourceView: row.viewRepresentation,
                previewable: languageRow
            )
        }

        let licensesRow = LicensesRow(
            presentingViewController: viewController
        )

        bag += otherSection.append(licensesRow) { row in
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
