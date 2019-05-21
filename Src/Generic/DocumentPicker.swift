//
//  DocumentPicker.swift
//  hedvig
//
//  Created by Sam Pettersson on 2019-05-21.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import Presentation
import UIKit

struct DocumentPicker {}

private var didPickDocumentsCallbackerKey = 0

extension UIDocumentPickerViewController: UIDocumentPickerDelegate {
    private var didPickDocumentsCallbacker: Callbacker<[URL]> {
        if let callbacker = objc_getAssociatedObject(self, &didPickDocumentsCallbackerKey) as? Callbacker<[URL]> {
            return callbacker
        }

        delegate = self

        let callbacker = Callbacker<[URL]>()

        objc_setAssociatedObject(self, &didPickDocumentsCallbackerKey, callbacker, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        return callbacker
    }

    var didPickDocumentsSignal: Signal<[URL]> {
        return didPickDocumentsCallbacker.providedSignal
    }

    public func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        didPickDocumentsCallbacker.callAll(with: urls)
    }
}

extension DocumentPicker: Presentable {
    func materialize() -> (UIDocumentPickerViewController, Future<[URL]>) {
        let viewController = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
        viewController.preferredPresentationStyle = .modal

        return (viewController, Future { completion in
            let bag = DisposeBag()

            bag += viewController.didPickDocumentsSignal.onValue { urls in
                completion(.success(urls))
            }

            return bag
        })
    }
}
