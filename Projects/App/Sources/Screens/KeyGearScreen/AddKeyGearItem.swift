//
//  AddKeyGearItem.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-27.
//

import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit

struct AddKeyGearItem {
    @Inject var client: ApolloClient
    var state = State()

    struct State {
        let imageSignal = ReadWriteSignal<UIImage?>(nil)
        let categorySignal = ReadWriteSignal<KeyGearItemCategory?>(nil)

        var isValidSignal: ReadSignal<Bool> {
            combineLatest(imageSignal, categorySignal).map { image, category in
                image != nil && category != nil
            }
        }
    }
}

extension AddKeyGearItem: Presentable {
    func materialize() -> (UIViewController, Future<String>) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        viewController.title = L10n.keyGearAddItemPageTitle

        let cancelButton = UIBarButtonItem(title: L10n.keyGearAddItemPageCloseButton, style: .navigationBarButton)
        viewController.navigationItem.rightBarButtonItem = cancelButton

        let form = FormView()
        bag += viewController.install(form)

        let addPhotoButton = AddPhotoButton()
        bag += state.imageSignal.bindTo(addPhotoButton.pickedPhotoSignal)

        let addPhotoButtonSignal = form.prepend(addPhotoButton)

        bag += form.append(Spacing(height: 10))

        let categoryPickerSection = form.appendSection(header: L10n.keyGearAddItemTypeHeadline)
        categoryPickerSection.alpha = 0.5
        categoryPickerSection.isUserInteractionEnabled = false
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
                title: L10n.keyGearAddItemSaveButton,
                type: .standard(backgroundColor: .primaryButtonBackgroundColor, textColor: .primaryButtonTextColor)
            )
        )
        bag += state.isValidSignal
            .atOnce()
            .map { valid in
                valid ?
                    ButtonType.standard(backgroundColor: .primaryButtonBackgroundColor, textColor: .primaryButtonTextColor) :
                    ButtonType.standard(backgroundColor: .gray, textColor: .white)
            }.bindTo(saveButton.button.type)

        let saveButtonContainer = UIStackView()
        saveButtonContainer.axis = .vertical
        saveButtonContainer.alignment = .center

        bag += state.isValidSignal
            .atOnce()
            .bindTo(saveButtonContainer, \.isUserInteractionEnabled)

        bag += form.append(saveButton.wrappedIn(UIStackView()).wrappedIn(saveButtonContainer))

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
                        S3FileInput(bucket: bucket, key: key),
                    ], category: .computer))).onValue { result in
                        self.client.fetch(query: KeyGearItemsQuery(), cachePolicy: .fetchIgnoringCacheData).onValue { _ in
                            let bubbleLoading = BubbleLoading(
                                originatingView: saveButtonContainer,
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
                                completion(.success(result.data?.createKeyGearItem.id ?? ""))
                            }
                        }
                    }
                }
            }

            bag += saveButton.onTapSignal.onValue(save)

            func handleImage(image: UIImage) {
                self.state.imageSignal.value = image

                self.classifyImage(image).onValue { category in
                    bag += Signal(after: 0).animated(style: AnimationStyle.easeOut(duration: 0.35)) { _ in
                        categoryPickerSection.alpha = 1
                        categoryPickerSection.isUserInteractionEnabled = true
                    }

                    guard let category = category else {
                        return
                    }

                    self.state.categorySignal.value = category
                }
            }

            bag += addPhotoButtonSignal.onValue { view in
                viewController.present(
                    KeyGearImagePicker(presentingViewController: viewController, allowedTypes: [.camera, .photoLibrary]),
                    style: .sheet(from: view, rect: nil)
                ).flatMap { $0.left! }.onValue { result in
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
