//
//  KeyGearAddReceiptRow.swift
//  test
//
//  Created by Pavel Barros Quintanilla on 2020-02-18.
//

import Apollo
import Flow
import Form
import Foundation
import Photos
import Presentation
import UIKit

struct KeyGearAddReceiptRow {
    @Inject var client: ApolloClient
    let itemId: String
}

struct KeyGearImagePicker: Presentable {
    let presentingViewController: UIViewController

    private enum PickType {
        case camera, photoLibrary, document
    }
    
    func materialize() -> (UIViewController, Future<Either<Future<Either<PHAsset, UIImage>>, Future<[URL]>>>) {
        let (viewController, alertResult) = Alert<PickType>(actions: [
            Alert.Action(title: "Camera", style: .default, action: { _ in
                .camera
            }),
            Alert.Action(title: "Photo Library", style: .default, action: { _ in
                .photoLibrary
            }),
            Alert.Action(title: "Document", style: .default, action: { _ in
                .document
            }),
            Alert.Action(title: "Cancel", style: .cancel, action: { _ in
                throw GenericError.cancelled
            }),
        ]).materialize()

        return (viewController, Future { completion in
            alertResult.onValue { result in
                switch result {
                case .camera:
                    completion(.success(.left(self.presentingViewController.present(
                        ImagePicker(
                            sourceType: .camera,
                            mediaTypes: [.photo]
                        ),
                        style: .default
                    ))))
                case .photoLibrary:
                    completion(.success(.left(self.presentingViewController.present(
                        ImagePicker(
                            sourceType: .photoLibrary,
                            mediaTypes: [.photo]
                        ),
                        style: .default
                    ))))
                case .document:
                    completion(.success(.right(self.presentingViewController.present(
                        DocumentPicker(),
                        style: .default
                    ))))
                }
            }.onError { error in
                completion(.failure(error))
            }

            return NilDisposer()
        })
    }
}

extension UIImage {
    
    private enum FileUploadError: Error {
        case couldntProcess
    }
    
    var fileUpload: Future<FileUpload> {
        Future { completion in
            guard let jpegData = self.jpegData(compressionQuality: 0.9) else {
                completion(.failure(FileUploadError.couldntProcess))
                                                   return NilDisposer()
                                               }
                                               let fileUpload = FileUpload(data: jpegData, mimeType: "image/jpeg", fileName: "image.jpeg")
            completion(.success(fileUpload))
            
            return NilDisposer()
        }
    }
}

extension KeyGearAddReceiptRow: Viewable {
    func materialize(events _: ViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()
        let row = RowView()
        row.distribution = .equalSpacing
        row.alignment = .fill

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .leading

        let icon = Icon(icon: Asset.receipt, iconWidth: 40)

        let receiptText = MultilineLabel(value: String(key: .KEY_GEAR_ITEM_VIEW_RECEIPT_TABLE_TITLE), style: .smallTitle)

        stackView.addArrangedSubview(icon)
        bag += stackView.addArranged(receiptText) { view in
            view.snp.makeConstraints { make in
                make.left.equalTo(icon.snp.right).offset(8)
                make.centerY.equalToSuperview()
            }
        }

        row.append(stackView)

        let button = LoadableButton(
            button: Button(
                title: String(key: .KEY_GEAR_ITEM_VIEW_RECEIPT_CELL_ADD_BUTTON),
                type: .outline(
                    borderColor: .transparent,
                    textColor: .purple
                )
            )
        )

        bag += row.append(button.wrappedIn(UIStackView()).wrappedIn(UIStackView())) { stackView in
            stackView.alignment = .center
            stackView.axis = .vertical
        }

        let receiptsSignal = client.watch(query: KeyGearItemQuery(id: itemId)).compactMap { $0.data?.keyGearItem?.receipts }.readable(initial: [])

        bag += receiptsSignal.map { receipts in
            !receipts.isEmpty
        }.onValue { hasReceipts in
            button.button.title.value = hasReceipts ? String(key: .KEY_GEAR_ITEM_VIEW_RECEIPT_SHOW) : String(key: .KEY_GEAR_ITEM_VIEW_RECEIPT_CELL_ADD_BUTTON)
        }

        bag += button.onTapSignal.withLatestFrom(receiptsSignal.atOnce().plain()).onValue { _, receipts in
            if !receipts.isEmpty {
                return
            }
            
            func handleDocuments(_ documents: [URL]) {
                button.isLoadingSignal.value = true
                
                guard
                    let fileUrl = documents.first,
                    let file = GraphQLFile(fieldName: "file", originalName: "upload.\(fileUrl.pathExtension)", fileURL: fileUrl) else {
                        button.isLoadingSignal.value = false
                    return
                }
                                
                self.client.upload(operation: UploadFileMutation(file: "file"), files: [file]).onValue { value in
                    if let key = value.data?.uploadFile.key, let bucket = value.data?.uploadFile.bucket {
                        self.client.perform(mutation: AddReceiptMutation(id: self.itemId, file: S3FileInput(bucket: bucket, key: key))).onValue { result in
                            self.client.fetch(query: KeyGearItemQuery(id: self.itemId), cachePolicy: .fetchIgnoringCacheData).onValue { _ in
                                button.isLoadingSignal.value = false
                            }
                        }
                    }
                }
            }
            
            func handleImage(_ image: Either<PHAsset, UIImage>) {
                button.isLoadingSignal.value = true

                func getFileUpload() -> Future<FileUpload> {
                    switch image {
                    case let .left(asset):
                        return asset.fileUpload
                    case let .right(image):
                        return image.fileUpload
                    }
                }
                
                getFileUpload().onValue { fileUpload in
                    let file = GraphQLFile(fieldName: "file", originalName: fileUpload.fileName, data: fileUpload.data)
                    
                    self.client.upload(operation: UploadFileMutation(file: "file"), files: [file]).onValue { value in
                        if let key = value.data?.uploadFile.key, let bucket = value.data?.uploadFile.bucket {
                            self.client.perform(mutation: AddReceiptMutation(id: self.itemId, file: S3FileInput(bucket: bucket, key: key))).onValue { result in
                                self.client.fetch(query: KeyGearItemQuery(id: self.itemId), cachePolicy: .fetchIgnoringCacheData).onValue { _ in
                                    button.isLoadingSignal.value = false
                                }
                            }
                        }
                    }
                }
            }

           row.viewController?.present(
                KeyGearImagePicker(presentingViewController: row.viewController!),
                style: .sheet()
            ).onValue { either in
                switch either {
                case let .left(imageFuture):
                    imageFuture.onValue { handleImage($0) }
                case let .right(documentFuture):
                    documentFuture.onValue { handleDocuments($0) }
                }
            }
        }

        return (row, bag)
    }
}
