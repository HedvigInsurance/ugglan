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
        
        bag += events.onSelect.onValue { _ in
            if MFMailComposeViewController.canSendMail() {
                let mailView = MailView(
                    recipients: [emailAddress]
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
