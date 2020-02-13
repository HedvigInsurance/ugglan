//
//  AddKeyGearItem.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-27.
//

import Foundation
import Flow
import UIKit
import Apollo
import Presentation
import Form

struct AddKeyGearItem {
    @Inject var client: ApolloClient
}

extension AddKeyGearItem: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        let bag = DisposeBag()
        
        viewController.title = String(key: .KEY_GEAR_ADD_ITEM_PAGE_TITLE)
        
        let cancelButton = UIBarButtonItem(title: String(key: .KEY_GEAR_ADD_ITEM_PAGE_CLOSE_BUTTON), style: .navigationBarButton)
        viewController.navigationItem.rightBarButtonItem = cancelButton
        
        let form = FormView()
        bag += viewController.install(form)
        
        let pickImageBox = UIView()
        
        let addPhotoButtonPointer = ViewPointer()
        
        let addPhotoButtonSignal = form.prepend(AddPhotoButton(), onCreate: addPhotoButtonPointer.handler)
        
        return (viewController, Future { completion in
            bag += cancelButton.onValue {
                completion(.failure(GenericError.cancelled))
            }
                        
            func handleImage(image: UIImage) {
                self.classifyImage(image).onValue { category in
                    
                    guard let category = category else {
                        addPhotoButtonPointer.current?.alpha = 0
                        return
                    }
                    
                    let bubbleLoading = BubbleLoading(
                        originatingView: addPhotoButtonPointer.current,
                        dismissSignal: Signal(after: 2)
                    )
                    
                    guard let jpegData = image.jpegData(compressionQuality: 0.9) else {
                         log.error("couldn't process image")
                         return
                     }
                    
                    let fileUpload = FileUpload(
                        data: jpegData,
                        mimeType: "image/jpeg",
                        fileName: "image.jpg"
                    )
                    
                    fileUpload.upload().onValue { key, bucket in
                        self.client.perform(mutation: CreateKeyGearItemMutation(input: CreateKeyGearItemInput(photos: [
                          S3FileInput(bucket: bucket, key: key)
                        ], category: .computer)))
                        
                        self.client.fetch(query: KeyGearItemsQuery(), cachePolicy: .fetchIgnoringCacheData).onValue { result in
                            print(result)
                        }
                    }
                    
                    viewController.present(
                        bubbleLoading,
                        style: .modally(
                            presentationStyle: .overFullScreen,
                            transitionStyle: .none,
                            capturesStatusBarAppearance: true
                        ),
                        options: [.unanimated]
                    ).onValue { _ in
                        completion(.success)
                    }
                }
            }
            
            bag += addPhotoButtonSignal.onValue {
                viewController.present(ImagePicker(sourceType: .camera, mediaTypes: [.photo])).onValue { result in
                    if let image = result.right {
                        handleImage(image: image)
                    } else if let asset = result.left {
                        bag += asset.image.valueSignal.compactMap { $0 }.onValue(handleImage)
                    }
                }
            }
                        
            return DelayedDisposer(bag, delay: 2)
        })
    }
}
