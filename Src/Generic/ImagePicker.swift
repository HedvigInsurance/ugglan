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

struct ImagePicker {}

private var didPickImageCallbackerKey = 0

enum PHAssetError: Error {
    case retreiveUrlError
}

extension PHAsset {
    func getURL() -> Future<URL> {
        return Future { completion in
            if self.mediaType == .image {
                let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
                options.canHandleAdjustmentData = { (_: PHAdjustmentData) -> Bool in
                    true
                }
                self.requestContentEditingInput(with: options, completionHandler: { (contentEditingInput: PHContentEditingInput?, _: [AnyHashable: Any]) -> Void in
                    guard let url = contentEditingInput?.fullSizeImageURL as URL? else {
                        completion(.failure(PHAssetError.retreiveUrlError))
                        return
                    }
                    completion(.success(url))

                })
            } else if self.mediaType == .video {
                let options: PHVideoRequestOptions = PHVideoRequestOptions()
                options.version = .original
                PHImageManager.default().requestAVAsset(
                    forVideo: self,
                    options: options,
                    resultHandler: {
                        (asset: AVAsset?, _: AVAudioMix?, _: [AnyHashable: Any]?) in
                        if let urlAsset = asset as? AVURLAsset {
                            let localVideoUrl = urlAsset.url
                            completion(.success(localVideoUrl))
                        } else {
                            completion(.failure(PHAssetError.retreiveUrlError))
                        }
                    }
                )
            }

            return NilDisposer()
        }
    }
}

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

    var didPickImageSignal: Signal<URL> {
        return didPickImageCallbacker.providedSignal
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

extension ImagePicker: Presentable {
    func materialize() -> (UIImagePickerController, Future<URL>) {
        let viewController = UIImagePickerController()
        viewController.preferredPresentationStyle = .modal

        return (viewController, Future { completion in
            let bag = DisposeBag()

            bag += viewController.didPickImageSignal.onValue { url in
                completion(.success(url))
            }

            return bag
        })
    }
}
