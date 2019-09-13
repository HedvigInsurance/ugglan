//
//  FilePickerHeader.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-09.
//

import Foundation
import UIKit
import Flow
import Form
import Photos

struct FilePickerHeader {
    let uploadFileDelegate = Delegate<FileUpload, Signal<Bool>>()
}

extension FilePickerHeader: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (FilePickerHeader) -> Disposable) {
        let view = UIView()
        
        return (view, { `self` in
            let bag = DisposeBag()
            
            bag += view.add(self) { buttonView in
                buttonView.snp.makeConstraints { make in
                    make.width.height.equalToSuperview()
                }
            }.onValue { _ in }
            
            return bag
        })
    }
}

extension FilePickerHeader: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Signal<Void>) {
        let bag = DisposeBag()
        
        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.distribution = .fillEqually
        containerView.spacing = 5
        
        func processAsset(_ asset: PHAsset) -> Disposable {
            let innerBag = DisposeBag()
            
            asset.fileUpload.onValue { fileUpload in
                innerBag += self.uploadFileDelegate.call(
                    fileUpload
                )?.onValue { _ in }
            }.onError { error in
                log.error(error.localizedDescription)
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
                let fileUploads = urls.compactMap { url -> Future<FileUpload> in
                    let fileCoordinator = NSFileCoordinator()
                    
                    return fileCoordinator.coordinate(
                        readingItemAt: url,
                        options: .withoutChanges
                    ).map { data in
                        FileUpload(data: data, mimeType: url.mimeType, fileName: url.path)
                    }
                }
                
                return join(fileUploads).valueSignal
                    .map { fileUploads -> [Disposable] in
                        fileUploads.compactMap {
                            self.uploadFileDelegate.call($0)?.onValue { _ in }
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
