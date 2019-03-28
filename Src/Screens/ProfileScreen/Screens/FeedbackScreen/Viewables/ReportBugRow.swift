//
//  ReportBugRow.swift
//  Hedvig
//
//  Created by Gustaf Gunér on 2019-02-14.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import DeviceKit
import Flow
import Form
import Foundation
import MessageUI
import Presentation

struct ReportBugRow {
    let client: ApolloClient
    let presentingViewController: UIViewController

    init(client: ApolloClient = ApolloContainer.shared.client, presentingViewController: UIViewController) {
        self.client = client
        self.presentingViewController = presentingViewController
    }
}

extension ReportBugRow: Viewable {
    func materialize(events: SelectableViewableEvents) -> (KeyValueRow, Disposable) {
        let bag = DisposeBag()

        let row = KeyValueRow()

        let emailAddress = String(.FEEDBACK_IOS_EMAIL)

        row.keySignal.value = String(.FEEDBACK_SCREEN_REPORT_BUG_TITLE)
        row.valueSignal.value = emailAddress

        row.valueStyleSignal.value = .rowValueLink

        let device = Device()
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String

        let memberIdSignal = client.fetch(query: MemberIdQuery())
            .valueSignal
            .compactMap { $0.data?.member.id }.plain()

        bag += events.onSelect.withLatestFrom(memberIdSignal).onValue { _, memberId in
            let deviceInfo = String(.FEEDBACK_SCREEN_REPORT_BUG_EMAIL_ATTACHMENT(
                device: device.description,
                systemName: device.systemName,
                systemVersion: device.systemVersion,
                appVersion: appVersion ?? "",
                memberId: memberId
            ))

            var attachments: [MailViewAttachment] = []

            if let data = deviceInfo.data(using: .utf8) {
                attachments.append(MailViewAttachment(data, mimeType: "text/txt", fileName: "device-info.txt"))
            }

            let mailView = MailView(
                recipients: [emailAddress],
                subject: "",
                attachments: attachments
            )

            self.presentingViewController.present(
                mailView,
                style: .modally(),
                options: .defaults
            )
        }

        return (row, bag)
    }
}
