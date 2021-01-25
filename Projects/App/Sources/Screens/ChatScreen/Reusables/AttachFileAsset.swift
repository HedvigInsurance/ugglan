import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Kingfisher
import Photos
import UIKit

struct AttachFileAsset: Reusable {
    let asset: PHAsset
    let type: AssetType
    let uploadFileDelegate = Flow.Delegate<FileUpload, Future<(key: String, bucket: String)>>()

    enum AssetType {
        case image, video
    }

    init(
        asset: PHAsset,
        type: AssetType
    ) {
        self.asset = asset
        self.type = type
    }

    static func makeAndConfigure() -> (make: UIView, configure: (AttachFileAsset) -> Disposable) {
        let view = UIControl()
        view.backgroundColor = .clear

        return (view, { `self` in
            let bag = DisposeBag()
            let sendOverlayBag = bag.innerBag()

            bag += view.signal(for: .touchUpInside).onValue { _ in
                if !sendOverlayBag.isEmpty {
                    sendOverlayBag.dispose()
                    return
                }

                let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
                effectView.layer.cornerRadius = 5
                effectView.clipsToBounds = true
                effectView.alpha = 0
                view.addSubview(effectView)

                let hideOverlayControl = UIControl()
                effectView.contentView.addSubview(hideOverlayControl)

                sendOverlayBag += hideOverlayControl.signal(for: .touchUpInside).onValue { _ in
                    sendOverlayBag.dispose()
                }

                hideOverlayControl.snp.makeConstraints { make in
                    make.width.height.centerX.centerY.equalToSuperview()
                }

                let button = Button(
                    title: L10n.chatUploadPresend,
                    type: .standard(backgroundColor: .brand(.primaryButtonBackgroundColor), textColor: .brand(.primaryButtonTextColor))
                )
                let loadableButton = LoadableButton(button: button, initialLoadingState: false)

                sendOverlayBag += loadableButton.onTapSignal.onValue { _ in
                    loadableButton.isLoadingSignal.value = true

                    self.asset.fileUpload.onValue { fileUpload in
                        self.uploadFileDelegate.call(fileUpload)?.onValue { _ in
                            loadableButton.isLoadingSignal.value = false
                            sendOverlayBag.dispose()
                        }
                    }
                }

                bag += hideOverlayControl.add(loadableButton) { buttonView in
                    buttonView.snp.makeConstraints { make in
                        make.center.equalToSuperview()
                    }

                    buttonView.transform = CGAffineTransform(translationX: 0, y: -view.frame.height)

                    sendOverlayBag += Signal(after: 0).animated(style: .mediumBounce()) { _ in
                        buttonView.transform = CGAffineTransform.identity
                    }

                    sendOverlayBag += {
                        bag += Signal(after: 0).animated(style: .mediumBounce()) { _ in
                            buttonView.transform = CGAffineTransform(translationX: 0, y: -view.frame.height)
                        }
                    }
                }

                effectView.snp.makeConstraints { make in
                    make.width.height.centerX.centerY.equalToSuperview()
                }

                sendOverlayBag += Signal(after: 0).animated(style: .easeOut(duration: 0.25)) { _ in
                    effectView.alpha = 1
                }

                sendOverlayBag += {
                    bag += Signal(after: 0).animated(style: .easeOut(duration: 0.25)) { _ in
                        effectView.alpha = 0
                    }.onValue { _ in
                        effectView.removeFromSuperview()
                    }
                }
            }

            PHImageManager.default().requestImage(for: self.asset, targetSize: view.frame.size, contentMode: .aspectFill, options: nil) { image, _ in
                guard let image = image else {
                    return
                }

                let imageView = UIImageView()
                imageView.clipsToBounds = true
                imageView.layer.cornerRadius = 5
                imageView.contentMode = .scaleAspectFill
                imageView.alpha = 0
                imageView.image = image
                view.addSubview(imageView)

                bag += {
                    imageView.removeFromSuperview()
                }

                imageView.snp.makeConstraints { make in
                    make.width.height.equalToSuperview()
                }

                bag += Signal(after: 0).animated(style: .easeOut(duration: 0.25)) { _ in
                    imageView.alpha = 1
                }
            }

            return bag
        })
    }
}
