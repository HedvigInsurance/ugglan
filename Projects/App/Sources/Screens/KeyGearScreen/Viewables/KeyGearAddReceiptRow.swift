import Apollo
import Flow
import Form
import Foundation
import Photos
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct KeyGearAddReceiptRow {
    @Inject var client: ApolloClient
    let presentingViewController: UIViewController
    let itemId: String
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

        let icon = Icon(icon: Asset.receipt.image, iconWidth: 40)

        let receiptText = MultilineLabel(
            value: L10n.keyGearItemViewReceiptTableTitle,
            style: .brand(.headline(color: .primary))
        )

        stackView.addArrangedSubview(icon)
        bag += stackView.addArranged(receiptText) { view in
            view.snp.makeConstraints { make in make.left.equalTo(icon.snp.right).offset(8)
                make.centerY.equalToSuperview()
            }
        }

        row.append(stackView)

        let button = LoadableButton(
            button: Button(
                title: L10n.keyGearItemViewReceiptCellAddButton,
                type: .outline(borderColor: .clear, textColor: .brand(.primaryTintColor))
            )
        )

        let buttonContainer = UIStackView()

        bag += row.append(button.wrappedIn(UIStackView()).wrappedIn(buttonContainer)) { stackView in
            stackView.alignment = .center
            stackView.axis = .vertical
        }

        let keyGearItemQuery = GraphQL.KeyGearItemQuery(
            id: itemId,
            languageCode: Localization.Locale.currentLocale.code
        )
        let receiptsSignal = client.watch(query: keyGearItemQuery).compactMap { $0.keyGearItem?.receipts }
            .readable(initial: [])

        bag += receiptsSignal.map { receipts in !receipts.isEmpty }
            .onValue { hasReceipts in
                button.button.title.value =
                    hasReceipts
                    ? L10n.keyGearItemViewReceiptShow : L10n.keyGearItemViewReceiptCellAddButton
            }

        bag += button.onTapSignal.withLatestFrom(receiptsSignal.atOnce().plain())
            .onValue { _, receipts in
                if let receiptUrlString = receipts.first?.file.preSignedUrl,
                    let receiptUrl = URL(string: receiptUrlString)
                {
                    self.presentingViewController.present(KeyGearReceipt(receipt: receiptUrl))
                    return
                }

                func handleDocuments(_ documents: [URL]) {
                    button.isLoadingSignal.value = true

                    guard let fileUrl = documents.first,
                        let file = try? GraphQLFile(
                            fieldName: "file",
                            originalName: "upload.\(fileUrl.pathExtension)",
                            fileURL: fileUrl
                        )
                    else {
                        button.isLoadingSignal.value = false
                        return
                    }

                    self.client
                        .upload(
                            operation: GraphQL.UploadFileMutation(file: "file"),
                            files: [file]
                        )
                        .onValue { data in let key = data.uploadFile.key
                            let bucket = data.uploadFile.bucket

                            self.client
                                .perform(
                                    mutation: GraphQL.AddReceiptMutation(
                                        id: self.itemId,
                                        file: GraphQL.S3FileInput(
                                            bucket: bucket,
                                            key: key
                                        )
                                    )
                                )
                                .onValue { _ in
                                    self.client
                                        .fetch(
                                            query: keyGearItemQuery,
                                            cachePolicy:
                                                .fetchIgnoringCacheData
                                        )
                                        .onValue { _ in
                                            button.isLoadingSignal.value =
                                                false
                                        }
                                }
                        }
                }

                func handleImage(_ image: Either<PHAsset, UIImage>) {
                    button.isLoadingSignal.value = true

                    func getFileUpload() -> Future<FileUpload> {
                        switch image {
                        case let .left(asset): return asset.fileUpload
                        case let .right(image): return image.fileUpload
                        }
                    }

                    getFileUpload()
                        .onValue { fileUpload in
                            let file = GraphQLFile(
                                fieldName: "file",
                                originalName: fileUpload.fileName,
                                data: fileUpload.data
                            )

                            self.client
                                .upload(
                                    operation: GraphQL.UploadFileMutation(
                                        file: "file"
                                    ),
                                    files: [file]
                                )
                                .onValue { data in let key = data.uploadFile.key
                                    let bucket = data.uploadFile.bucket

                                    self.client
                                        .perform(
                                            mutation:
                                                GraphQL
                                                .AddReceiptMutation(
                                                    id: self.itemId,
                                                    file:
                                                        GraphQL
                                                        .S3FileInput(
                                                            bucket:
                                                                bucket,
                                                            key:
                                                                key
                                                        )
                                                )
                                        )
                                        .onValue { _ in
                                            self.client
                                                .fetch(
                                                    query:
                                                        keyGearItemQuery,
                                                    cachePolicy:
                                                        .fetchIgnoringCacheData
                                                )
                                                .onValue { _ in
                                                    button
                                                        .isLoadingSignal
                                                        .value =
                                                        false
                                                }
                                        }
                                }
                        }
                }

                row.viewController?
                    .present(
                        KeyGearImagePicker(
                            presentingViewController: row.viewController!,
                            allowedTypes: [.camera, .photoLibrary, .document]
                        ),
                        style: .sheet(from: buttonContainer, rect: nil)
                    )
                    .onValue { either in
                        switch either {
                        case let .left(imageFuture): imageFuture.onValue { handleImage($0) }
                        case let .right(documentFuture):
                            documentFuture.onValue { handleDocuments($0) }
                        }
                    }
            }

        return (row, bag)
    }
}
