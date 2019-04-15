//
//  ActivityView.swift
//  Hedvig
//
//  Created by Gustaf Gunér on 2019-02-14.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import MessageUI
import Presentation
import UIKit

struct MailView {
    let recipients: [String]
    let subject: String
    let attachments: [MailViewAttachment]
}

struct MailViewAttachment {
    let data: Data
    let mimeType: String
    let fileName: String

    init(_ data: Data, mimeType: String, fileName: String) {
        self.data = data
        self.mimeType = mimeType
        self.fileName = fileName
    }
}

enum MailViewError: LocalizedError {
    case cantSendMail
}

extension MailView: Presentable {
    func materialize() -> (UIViewController, Future<MFMailComposeResult>) {
        if !MFMailComposeViewController.canSendMail() {
            let alert = Alert(
                title: String(key: .MAIL_VIEW_CANT_SEND_ALERT_TITLE),
                message: String(key: .MAIL_VIEW_CANT_SEND_ALERT_MESSAGE),
                actions: [Alert.Action(title: String(key: .MAIL_VIEW_CANT_SEND_ALERT_BUTTON)) { () }]
            )

            let (viewController, future) = alert.materialize()

            return (viewController, Future { completion in
                future.onValue({ _ in
                    completion(.failure(MailViewError.cantSendMail))
                })

                return NilDisposer()
            })
        }

        let viewController = MFMailComposeViewController()

        viewController.setToRecipients(recipients)
        viewController.setSubject(subject)

        for attachment in attachments {
            viewController.addAttachmentData(attachment.data, mimeType: attachment.mimeType, fileName: attachment.fileName)
        }

        return (viewController, Future { completion in
            let bag = DisposeBag()

            bag += viewController.didFinishWithSignal.onValue({ result, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(result))
                }
            })

            return bag
        })
    }
}
