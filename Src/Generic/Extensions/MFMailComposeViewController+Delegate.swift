//
//  MFMailComposeViewController+Delegate.swift
//  Hedvig
//
//  Created by Gustaf Gunér on 2019-02-20.
//  Copyright © 2019 Hedvig. All rights reserved.
//

import Foundation
import MessageUI


public struct MFMailComposeViewControllerAttachment {
    let data: Data
    let mimeType: String
    let fileName: String
    
    init(_ data: Data, mimeType: String, fileName: String) {
        self.data = data
        self.mimeType = mimeType
        self.fileName = fileName
    }
}

public extension MFMailComposeViewController {
    public static func create(to: [String], subject: String = "", attachments: [MFMailComposeViewControllerAttachment] = []) -> MFMailComposeViewController {
        let viewController = MFMailComposeViewController()
        
        viewController.mailComposeDelegate = viewController
        
        viewController.setToRecipients(to)
        viewController.setSubject(subject)
        
        for attachment in attachments {
            print(attachment)
            viewController.addAttachmentData(attachment.data, mimeType: attachment.mimeType, fileName: attachment.fileName)
        }
        
        return viewController
    }
}

extension MFMailComposeViewController: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}
