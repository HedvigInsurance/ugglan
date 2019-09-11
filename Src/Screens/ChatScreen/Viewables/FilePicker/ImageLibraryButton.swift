//
//  ImageLibraryButton.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-09.
//

import Foundation
import UIKit
import Flow
import Form
import Photos

struct ImageLibraryButton {
    let uploadFileDelegate = Delegate<Data, Signal<Bool>>()
}

extension ImageLibraryButton: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (ImageLibraryButton) -> Disposable) {
        let view = UIView()
        
        return (view, { `self` in
            let bag = DisposeBag()
            
            bag += view.add(self) { buttonView in
                buttonView.snp.makeConstraints { make in
                    make.width.height.equalToSuperview()
                }
            }.onValue({ _ in
                
            })
            
            return bag
        })
    }
}

struct PickerButton: Viewable {
    let icon: UIImage
    
    func materialize(events: ViewableEvents) -> (UIView, Signal<Void>) {
        let bag = DisposeBag()
        let button = UIControl()
        button.backgroundColor = .secondaryBackground
        button.layer.borderColor = UIColor.primaryBorder.cgColor
        button.layer.borderWidth = UIScreen.main.hairlineWidth
        button.layer.cornerRadius = 5
        
        let imageView = UIImageView()
        imageView.image = icon
        imageView.tintColor = .primaryText
        
        button.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(45)
            make.center.equalToSuperview()
        }
        
        return (button, Signal<Void> { callback in
            bag += button.signal(for: .touchUpInside).onValue(callback)
            return bag
        })
    }
}

extension ImageLibraryButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Signal<Void>) {
        let bag = DisposeBag()
        
        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.distribution = .fillEqually
        containerView.spacing = 5
        
        func processAsset(_ asset: PHAsset) -> Disposable {
            let innerBag = DisposeBag()
            
            PHImageManager.default().requestImageData(for: asset, options: nil) { (data, _, _, _) in
                guard let data = data else {
                    return
                }
                innerBag += self.uploadFileDelegate.call(data)?.onValue({ _ in
                    print("loading")
                })
            }
            
            return innerBag
        }
        
        let cameraButton = PickerButton(icon: Asset.camera.image)
        bag += containerView.addArranged(cameraButton).onValueDisposePrevious { _ in
            containerView.viewController?.present(
                ImagePicker(
                    sourceType: .camera,
                    mediaTypes: [.video, .photo]
                )
            ).valueSignal.onValueDisposePrevious(processAsset)
        }
                
        let photoLibraryButton = PickerButton(icon: Asset.photoLibrary.image)
        bag += containerView.addArranged(photoLibraryButton).onValueDisposePrevious { _ in
            containerView.viewController?.present(
                ImagePicker(
                    sourceType: .photoLibrary,
                    mediaTypes: [.video, .photo]
                )
            ).valueSignal.onValueDisposePrevious(processAsset)
        }
        
        let filesButton = PickerButton(icon: Asset.files.image)
        bag += containerView.addArranged(filesButton).onValueDisposePrevious { _ in
            containerView.viewController?.present(
                DocumentPicker()
            ).valueSignal.onValueDisposePrevious(on: .background) { urls -> Disposable in
                let datas = urls.compactMap { url -> Future<Data> in
                    let fileCoordinator = NSFileCoordinator()
                    return fileCoordinator.coordinate(
                        readingItemAt: url,
                        options: .withoutChanges
                    )
                }
                
                return join(datas).valueSignal
                    .map { datas -> [Disposable] in
                        datas.compactMap {
                            self.uploadFileDelegate.call($0)?.onValue({ didUpload in
                                print(didUpload)
                            })
                        }
                    }.onValueDisposePrevious { list -> Disposable? in
                    return DisposeBag(list)
                }
            }
        }
        
        return (containerView, Signal<Void> { callback -> Disposable in
            return bag
        })
    }
}
