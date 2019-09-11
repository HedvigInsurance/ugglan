//
//  ImagePicker.swift
//  hedvig
//
//  Created by Sam Pettersson on 2019-05-22.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import Photos
import Presentation
import UIKit

struct ImagePicker {
    let sourceType: UIImagePickerController.SourceType
}

private var didPickImageCallbackerKey = 0
private var didCancelImagePickerCallbackerKey = 1

extension UIImagePickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var didPickImageCallbacker: Callbacker<URL> {
        if let callbacker = objc_getAssociatedObject(self, &didPickImageCallbackerKey) as? Callbacker<URL> {
            return callbacker
        }

        delegate = self

        let callbacker = Callbacker<URL>()

        objc_setAssociatedObject(self, &didPickImageCallbackerKey, callbacker, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        return callbacker
    }

    private var didCancelImagePickerCallbacker: Callbacker<Void> {
        if let callbacker = objc_getAssociatedObject(self, &didCancelImagePickerCallbackerKey) as? Callbacker<Void> {
            return callbacker
        }

        delegate = self

        let callbacker = Callbacker<Void>()

        objc_setAssociatedObject(self, &didCancelImagePickerCallbackerKey, callbacker, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        return callbacker
    }

    var didPickImageSignal: Signal<URL> {
        return didPickImageCallbacker.providedSignal
    }

    var didCancelSignal: Signal<Void> {
        return didCancelImagePickerCallbacker.providedSignal
    }

    public func imagePickerControllerDidCancel(_: UIImagePickerController) {
        didCancelImagePickerCallbacker.callAll()
    }

    public func imagePickerController(
        _: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        guard let assetUrl = info[UIImagePickerController.InfoKey.referenceURL] as? URL else {
            return
        }

        didPickImageCallbacker.callAll(with: assetUrl)
    }
}

enum ImagePickerError: Error {
    case cancelled
}

extension ImagePicker: Presentable {
    func materialize() -> (UIImagePickerController, Future<URL>) {
        let viewController = UIImagePickerController()
        viewController.sourceType = sourceType
        viewController.preferredPresentationStyle = .modally(
            presentationStyle: .pageSheet,
            transitionStyle: nil,
            capturesStatusBarAppearance: nil
        )

        return (viewController, Future { completion in
            let bag = DisposeBag()

            bag += viewController.didPickImageSignal.onValue { url in
                completion(.success(url))
            }

            bag += viewController.didCancelSignal.onValue { _ in
                completion(.failure(ImagePickerError.cancelled))
            }

            return bag
        })
    }
}
