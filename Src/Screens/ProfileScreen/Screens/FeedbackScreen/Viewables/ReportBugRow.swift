//
//  ReportBugRow.swift
//  Hedvig
//
//  Created by Gustaf Gunér on 2019-02-14.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import Presentation
import MessageUI
import DeviceKit

struct ReportBugRow {
    let presentingViewController: UIViewController
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
    
        let deviceInfo = "Device: \(device)\nSystem: \(device.systemName) \(device.systemVersion)"
        
        var attachments: [MFMailComposeViewControllerAttachment] = []
        
        if let data = deviceInfo.data(using: .utf8) {
            attachments.append(MFMailComposeViewControllerAttachment(data, mimeType: "text/txt", fileName: "device-info.txt"))
        }
        
        bag += events.onSelect.onValue { _ in
            if MFMailComposeViewController.canSendMail() {
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
       
        return (row, bag)
    }
}
