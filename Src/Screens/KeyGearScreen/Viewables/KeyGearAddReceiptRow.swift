//
//  KeyGearAddReceiptRow.swift
//  test
//
//  Created by Pavel Barros Quintanilla on 2020-02-18.
//

import Foundation
import Flow
import Form
import Presentation
import UIKit
import Photos
import Apollo

struct KeyGearAddReceiptRow {
    @Inject var client: ApolloClient
}

// imagepicker

extension KeyGearAddReceiptRow: Viewable {
    func materialize(events: ViewableEvents) -> (RowView, Signal<Void>) {
        let bag = DisposeBag()
        let row = RowView()
        row.distribution = .equalSpacing
        row.alignment = .fill
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .leading
        
        let icon = Icon(icon: Asset.addReceiptSecondaryCopy, iconWidth: 40)
        
        let receiptText = MultilineLabel(value: String(key: .KEY_GEAR_ITEM_VIEW_RECEIPT_TABLE_TITLE), style: .smallTitle)
        
        stackView.addArrangedSubview(icon)
        bag += stackView.addArranged(receiptText) { view in
            view.snp.makeConstraints { make in
                make.left.equalTo(icon.snp.right).offset(8)
                make.centerY.equalToSuperview()
            }
        }
        
        row.append(stackView)
        
        let control = UIControl()
        let addReceiptText = MultilineLabel(value: String(key: .KEY_GEAR_ITEM_VIEW_RECEIPT_CELL_ADD_BUTTON), style: .blockRowDescription)
        bag += control.add(addReceiptText) { label in
            label.textColor = .purple
            label.snp.makeConstraints { make in
                make.top.left.right.bottom.equalToSuperview()
            }
        }
        
        row.append(control)
        control.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
        }
        
        bag += control.signal(for: .touchUpInside).onValue({ _ in
 
            bag += row.viewController!.present(
                ImagePicker(
                    sourceType: .camera,
                    mediaTypes: [.photo]),
                style: .default
                
            ).valueSignal.onValue({ result in
                switch result {
                case .left:
                    if let asset = result.left {
                        asset.fileUpload.onValue({ fileUpload in
                        }).onError { error in
                            log.error(error.localizedDescription)
                        }
                    }
                    
                case .right:
                    if let image = result.right {
                        guard let jpegData = image.jpegData(compressionQuality: 0.9) else {
                            log.error("couldn't process image")
                            return
                        }
                        
                        let fileUpload = FileUpload(data: jpegData, mimeType: "image/jpeg", fileName: "image.jpeg")
                        let file = GraphQLFile(fieldName: "file", originalName: fileUpload.fileName, data: fileUpload.data)
                        print("!!!!!!!!FILE: \(file)")
                        
                        self.client.upload(operation: UploadFileMutation(file: "file"), files: [file]).onValue { value in
                            if let key = value.data?.uploadFile.key, let bucket = value.data?.uploadFile.bucket {
                                print("KEY: \(key) BUCKET: \(bucket)")
                            }
                        }
                    }
                }
            })
        })

        return (row, control.signal(for: .touchUpInside).hold(bag))
    }
}

