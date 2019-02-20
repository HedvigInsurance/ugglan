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
                
        let emailAddress = "ios@hedvig.com"
        
        row.keySignal.value = "Rapportera bugg"
        row.valueSignal.value = emailAddress
        
        row.valueStyleSignal.value = .rowTitlePurple
    
        let device = Device()
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        
        bag += events.onSelect.onValue { _ in
            if MFMailComposeViewController.canSendMail() {
                self.client.fetch(query: MemberIdQuery()) { (result, error) in
                    if let memberId = result?.data?.member.id {
                        let deviceInfo = "Device: \(device)\nSystem: \(device.systemName) \(device.systemVersion)\nApp Version: \(appVersion ?? "")\nMember ID: \(memberId)"
                        
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
        }
       
        return (row, bag)
    }
}
