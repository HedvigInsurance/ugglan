//
//  ReportBugRow.swift
//  Hedvig
//
//  Created by Gustaf Gunér on 2019-02-14.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Foundation
import Presentation
import MessageUI
import DeviceKit

struct ReportBugRow {
    let client: ApolloClient
    let presentingViewController: UIViewController
    
    init(client: ApolloClient = HedvigApolloClient.shared.client!, presentingViewController: UIViewController) {
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
        
        bag += events.onSelect.onValue { _ in
            if MFMailComposeViewController.canSendMail() {
                
                bag += self.client.fetch(query: MemberIdQuery())
                    .valueSignal
                    .compactMap { $0.data?.member.id }
                    .onValue { memberId in
                        let deviceInfo = String(.FEEDBACK_SCREEN_REPORT_BUG_EMAIL_ATTACHMENT(
                            device: device.description,
                            system: "\(device.systemName) \(device.systemVersion)",
                            appVersion: appVersion ?? "",
                            memberId: memberId))
                        
                        var attachments: [MFMailComposeViewControllerAttachment] = []
                        
                        if let data = deviceInfo.data(using: .utf8) {
                            attachments.append(MFMailComposeViewControllerAttachment(data, mimeType: "text/txt", fileName: "device-info.txt"))
                        }
                        
                        let mailView = MailView(
                            recipients: [emailAddress],
                            attachments: attachments
                        )
                        
                        let activityViewPresentation = Presentation(
                            mailView,
                            style: .activityView,
                            options: .defaults
                        )
                        
                        self.presentingViewController.present(activityViewPresentation)
                }
            }
        }
       
        return (row, bag)
    }
}
