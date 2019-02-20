//
//  ActivityView.swift
//  Hedvig
//
//  Created by Gustaf Gunér on 2019-02-14.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import Presentation
import UIKit
import MessageUI

struct MailView {
    let recipients: [String]
}

extension MailView: Presentable {
    func materialize() -> (MFMailComposeViewController, Disposable) {
        let mailComposeViewController = MFMailComposeViewController.create(to: self.recipients)
        
        return (mailComposeViewController, NilDisposer())
    }    
}
