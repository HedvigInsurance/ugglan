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
    var state = State()
    
    struct State {
        let imageSignal = ReadWriteSignal<UIImage?>(nil)
        let categorySignal = ReadWriteSignal<KeyGearItemCategory?>(nil)
        
        var isValidSignal: ReadSignal<Bool> {
            combineLatest(imageSignal, categorySignal).map { (image, category) in
                image != nil && category != nil
            }
        }
    }
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
                
        let addPhotoButton = AddPhotoButton()
        bag += state.imageSignal.bindTo(addPhotoButton.pickedPhotoSignal)
        
        let addPhotoButtonSignal = form.prepend(addPhotoButton)
        
        bag += form.append(Spacing(height: 10))
        
        let categoryPickerSection = form.appendSection(header: String(key: .KEY_GEAR_ADD_ITEM_TYPE_HEADLINE))
        categoryPickerSection.dynamicStyle = .sectionPlain
        bag += categoryPickerSection.append(
            CategoryPicker(
                onSelectCategorySignal: state.categorySignal.compactMap { $0 }.distinct()
            )
        ).onValue { category in
            self.state.categorySignal.value = category
        }
        
        bag += form.append(Spacing(height: 30))
        
        let saveButton = LoadableButton(
            button: Button(
            title: String(key: .KEY_GEAR_ADD_ITEM_SAVE_BUTTON),
            type: .standard(backgroundColor: .primaryTintColor, textColor: .white)
        )
        )
        bag += state.isValidSignal
            .atOnce()
            .map { valid in valid ? ButtonType.standard(backgroundColor: .primaryTintColor, textColor: .white) : ButtonType.standard(backgroundColor: .gray, textColor: .white) }.bindTo(saveButton.button.type)
        
        let saveButtonPointer = ViewPointer()
        bag += form.append(saveButton.wrappedIn(UIStackView()), onCreate: saveButtonPointer.handler)
                
        return (viewController, Future { completion in
            bag += cancelButton.onValue {
                completion(.failure(GenericError.cancelled))
            }
            
            func save() {
                saveButton.isLoadingSignal.value = true
                
                guard let jpegData = self.state.imageSignal.value?.jpegData(compressionQuality: 0.9) else {
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
                        let bubbleLoading = BubbleLoading(
                                           originatingView: saveButtonPointer.current,
                                           dismissSignal: Signal(after: 2)
                                       )
                        
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
            
            bag += saveButton.onTapSignal.onValue(save)
                        
            func handleImage(image: UIImage) {
                self.state.imageSignal.value = image
                
                self.classifyImage(image).onValue { category in
                    guard let category = category else {
                        return
                    }
                    
                    self.state.categorySignal.value = category
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
