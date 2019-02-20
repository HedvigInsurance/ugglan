//
//  MFMailComposeViewController+Delegate.swift
//  Hedvig
//
//  Created by Gustaf Gunér on 2019-02-20.
//  Copyright © 2019 Hedvig. All rights reserved.
//

import Foundation
import MessageUI

public extension MFMailComposeViewController {
    public static func create(to: [String]) -> MFMailComposeViewController {
        let viewController = MFMailComposeViewController()
        viewController.mailComposeDelegate = viewController
        viewController.setToRecipients(to)
        
        return viewController
    }
}

extension MFMailComposeViewController: MFMailComposeViewControllerDelegate {
    public func mailComposeController(controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}
