//
//  AttachFilePane.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-07-30.
//

import Apollo
import Flow
import Form
import Foundation
import Photos
import UIKit

struct AttachFilePane {
    let isOpenSignal: ReadWriteSignal<Bool>
    let chatState: ChatState
    @Inject var client: ApolloClient

    init(
        isOpenSignal: ReadWriteSignal<Bool>,
        chatState: ChatState
    ) {
        self.isOpenSignal = isOpenSignal
        self.chatState = chatState
    }
}

struct FileUpload {
    let data: Data
    let mimeType: String
    let fileName: String

    func upload() -> Future<(key: String, bucket: String)> {
        let client: ApolloClient = Dependencies.shared.resolve()

        let file = GraphQLFile(
            fieldName: "file",
            originalName: fileName,
            mimeType: mimeType,
            data: data
        )

        return Future { completion in
            client.upload(
                operation: UploadFileMutation(file: "image"),
                files: [file],
                queue: DispatchQueue.global(qos: .background)
            ).onValue { result in
                guard let key = result.data?.uploadFile.key, let bucket = result.data?.uploadFile.bucket else {
                    return
                }

                completion(.success((key, bucket)))
            }.disposable
        }
    }
}

extension AttachFilePane: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIStackView()
        view.axis = .vertical
        view.isLayoutMarginsRelativeArrangement = true
        view.insetsLayoutMarginsFromSafeArea = true

        bag += isOpenSignal.atOnce().map { !$0 }.animated(style: SpringAnimationStyle.lightBounce(), animations: { isHidden in
            view.animationSafeIsHidden = isHidden
            view.layoutSuperviewsIfNeeded()
        })

        view.backgroundColor = .purple

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(horizontalInset: 15, verticalInset: 10)
        layout.headerReferenceSize = CGSize(width: 100, height: 1)

        let collectionKit = CollectionKit<EmptySection, AttachFileAsset>(
            table: Table(rows: []),
            layout: layout
        )
        collectionKit.view.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        bag.hold(collectionKit)

        bag += collectionKit.delegate.sizeForItemAt.set { _ -> CGSize in
            let height = collectionKit.view.frame.height
            return CGSize(width: height, height: height)
        }

        func uploadFile(_ fileUpload: FileUpload) -> Future<(key: String, bucket: String)> {
            let future = fileUpload.upload()

            future.onValue { key, _ in
                self.chatState.sendChatFileResponseMutation(
                    key: key,
                    mimeType: fileUpload.mimeType
                )
                self.isOpenSignal.value = false
            }

            return future
        }

        let header = FilePickerHeader()

        bag += header.uploadFileDelegate.set { fileUpload -> Future<(key: String, bucket: String)> in
            uploadFile(fileUpload)
        }

        bag += collectionKit.registerViewForSupplementaryElement(
            kind: UICollectionView.elementKindSectionHeader
        ) { _ in
            header
        }

        collectionKit.view.backgroundColor = .transparent

        view.addArrangedSubview(collectionKit.view)

        collectionKit.view.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }

        bag += view.didMoveToWindowSignal.onValue { _ in
            view.snp.remakeConstraints { make in
                make.width.equalToSuperview()
                make.height.equalTo(300)
            }
        }

        bag += collectionKit.onValueDisposePrevious { table in
            DisposeBag(table.map { asset -> Disposable in
                asset.uploadFileDelegate.set { data -> Future<(key: String, bucket: String)> in
                    uploadFile(data)
                }
            })
        }

        bag += isOpenSignal.atOnce().filter { $0 }.onValue { _ in
            PHPhotoLibrary.requestAuthorization { _ in
                var list: [AttachFileAsset] = []

                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [
                    NSSortDescriptor(key: "creationDate", ascending: false),
                ]
                fetchOptions.fetchLimit = 50

                let imageAssets = PHAsset.fetchAssets(with: .image, options: fetchOptions)

                imageAssets.enumerateObjects { asset, _, _ in
                    list.append(AttachFileAsset(asset: asset, type: .image))
                }

                let videoAssets = PHAsset.fetchAssets(with: .video, options: fetchOptions)

                videoAssets.enumerateObjects { asset, _, _ in
                    list.append(AttachFileAsset(asset: asset, type: .video))
                }

                DispatchQueue.main.async {
                    collectionKit.table = Table(rows: list)
                }
            }
        }

        return (view, bag)
    }
}
