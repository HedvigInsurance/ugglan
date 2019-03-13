//
//  MFMailComposeViewController+Signal.swift
//  Hedvig
//
//  Created by Gustaf Gunér on 2019-02-20.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import MessageUI

extension MFMailComposeViewController: MFMailComposeViewControllerDelegate {
    private static var _didFinishWithCallbacker: UInt8 = 1

    private var didFinishWithCallbacker: Callbacker<(MFMailComposeResult, Error?)> {
        if let callbacker = objc_getAssociatedObject(
            self,
            &MFMailComposeViewController._didFinishWithCallbacker
        ) as? Callbacker<(MFMailComposeResult, Error?)> {
            return callbacker
        }

        let callbacker = Callbacker<(MFMailComposeResult, Error?)>()

        objc_setAssociatedObject(
            self,
            &MFMailComposeViewController._didFinishWithCallbacker,
            callbacker,
            objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        mailComposeDelegate = self

        return callbacker
    }

    var didFinishWithSignal: Signal<(MFMailComposeResult, Error?)> {
        return didFinishWithCallbacker.signal()
    }

    public func mailComposeController(_: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        didFinishWithCallbacker.callAll(with: (result, error))
    }
}
