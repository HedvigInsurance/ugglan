//
//  ImagePicker.swift
//  hedvig
//
//  Created by Sam Pettersson on 2019-05-22.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import MobileCoreServices
import Photos
import Presentation
import UIKit

struct ImagePicker {
    let sourceType: UIImagePickerController.SourceType
    let mediaTypes: Set<MediaType>

    enum MediaType {
        case video, photo
    }
}

private var didPickImageCallbackerKey = 0
private var didCancelImagePickerCallbackerKey = 1

extension UIImagePickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var didPickImageCallbacker: Callbacker<PHAsset> {
        if let callbacker = objc_getAssociatedObject(self, &didPickImageCallbackerKey) as? Callbacker<PHAsset> {
            return callbacker
        }

        delegate = self

        let callbacker = Callbacker<PHAsset>()

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

    var didPickImageSignal: Signal<PHAsset> {
        didPickImageCallbacker.providedSignal
    }

    var didCancelSignal: Signal<Void> {
        didCancelImagePickerCallbacker.providedSignal
    }

    public func imagePickerControllerDidCancel(_: UIImagePickerController) {
        didCancelImagePickerCallbacker.callAll()
    }

    public func imagePickerController(
        _: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        guard let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset else {
            return
        }

        didPickImageCallbacker.callAll(with: asset)
    }
}

enum ImagePickerError: Error {
    case cancelled
}

extension ImagePicker: Presentable {
    func materialize() -> (UIImagePickerController, Future<PHAsset>) {
        let viewController = UIImagePickerController()
        viewController.sourceType = sourceType
        viewController.preferredPresentationStyle = .modally(
            presentationStyle: .pageSheet,
            transitionStyle: nil,
            capturesStatusBarAppearance: nil
        )

        viewController.mediaTypes = mediaTypes.map { type -> String in
            switch type {
            case .photo:
                return kUTTypeImage as String
            case .video:
                return kUTTypeMovie as String
            }
        }

        return (viewController, Future { completion in
            let bag = DisposeBag()

            bag += viewController.didPickImageSignal.onValue { asset in
                completion(.success(asset))
            }

            bag += viewController.didCancelSignal.onValue { _ in
                completion(.failure(ImagePickerError.cancelled))
            }

            return bag
        })
    }
}
