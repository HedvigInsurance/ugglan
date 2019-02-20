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
        var attachments: [MFMailComposeViewControllerAttachment] = []
        
        let deviceInfo = "Device name: \(UIDevice.current.name)\nSystem: \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)\nModel \(UIDevice.current.model)"
        
        print(deviceInfo)
        
        if let data = deviceInfo.data(using: .utf8) {
            attachments.append(MFMailComposeViewControllerAttachment(data, mimeType: "text/txt", fileName: "device-info.txt"))
        }
        
        let mailComposeViewController = MFMailComposeViewController.create(to: self.recipients, attachments: attachments)
        
        return (mailComposeViewController, NilDisposer())
    }    
}
