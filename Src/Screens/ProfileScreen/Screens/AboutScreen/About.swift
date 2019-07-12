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
    let presentingViewController: UIViewController
    let client: ApolloClient

    init(presentingViewController: UIViewController, client: ApolloClient = ApolloContainer.shared.client) {
        self.presentingViewController = presentingViewController
        self.client = client
    }
}

extension About: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = String(key: .ABOUT_SCREEN_TITLE)

        let bag = DisposeBag()

        let form = FormView()

        let licensesSection = form.appendSection(
            headerView: nil,
            footerView: nil,
            style: .sectionPlain
        )

        let licensesRow = LicensesRow(
            presentingViewController: presentingViewController
        )

        bag += licensesSection.append(licensesRow) { row in
            bag += self.presentingViewController.registerForPreviewing(
                sourceView: row.viewRepresentation,
                previewable: licensesRow
            )
        }

        bag += form.append(Spacing(height: 20))

        let versionSection = form.appendSection(
            headerView: nil,
            footerView: nil,
            style: .sectionPlain
        )

        let versionRow = VersionRow()
        bag += versionSection.append(versionRow)

        let memberIdRow = MemberIdRow()
        bag += versionSection.append(memberIdRow)

        let activatePushNotificationsRow = ButtonRow(
            text: "Aktivera pushnotiser",
            style: .normalButton
        )
        bag += versionSection.append(activatePushNotificationsRow)

        bag += activatePushNotificationsRow.onSelect.onValue { _ in
            UIApplication.shared.appDelegate.registerForPushNotifications()
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
                    self.presentingViewController.present(whatsNew, options: [.prefersNavigationBarHidden(true)])
                }
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
