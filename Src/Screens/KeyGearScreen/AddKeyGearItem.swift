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
        viewController.navigationItem.leftBarButtonItem = cancelButton
        
        let form = FormView()
        bag += viewController.install(form)
        
        let pickImageBox = UIView()
        pickImageBox.backgroundColor = .purple
        
        form.prepend(pickImageBox)
        
        pickImageBox.snp.makeConstraints { make in
            make.height.equalTo(300)
        }
        
        return (viewController, Future { completion in
            bag += cancelButton.onValue {
                completion(.failure(GenericError.cancelled))
            }
            
            let button = Button(title: "Lägg till", type: .standard(backgroundColor: .primaryTintColor, textColor: .primaryText))
            
            func handleImage() {
                
            }
            
            bag += button.onTapSignal.onValue {
                viewController.present(ImagePicker(sourceType: .camera, mediaTypes: [.photo])).onValue { result in
                    if let image = result.right {
                        self.classifyImage(image).onValue { category in
                            let bubbleLoading = BubbleLoading(
                                originatingView: pickImageBox,
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
                    } else if let asset = result.left {
                        
                        let bubbleLoading = BubbleLoading(
                            originatingView: pickImageBox,
                            dismissSignal: Signal(after: 2)
                        )
                        
                        bag += asset.image.valueSignal.compactMap { $0 }.mapLatestToFuture { self.classifyImage($0) }.onValue { category in
                            asset.fileUpload.flatMap { $0.upload() }.onValue { key, bucket in
                               self.client.perform(mutation: CreateKeyGearItemMutation(input: CreateKeyGearItemInput(photos: [
                                 S3FileInput(bucket: bucket, key: key)
                               ], category: .computer)))
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

            }
            
            bag += form.prepend(button)
            
            return DelayedDisposer(bag, delay: 2)
        })
    }
}
