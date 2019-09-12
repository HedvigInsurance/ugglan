//
//  PHAsset+FileUpload.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-09-12.
//

import Foundation
import Flow
import Photos

extension PHAsset {
    enum GenerateFileUploadError: Error {
        case failedToGenerateFileName, failedToGenerateMimeType
    }
    
    // generates a fileUpload for current PHAsset
    var fileUpload: Future<FileUpload> {
        Future { completion in
            let options = PHContentEditingInputRequestOptions()
            options.isNetworkAccessAllowed = true
            
            self.requestContentEditingInput(with: options) { (contentInput, _) in
                guard let fileName = contentInput?.fullSizeImageURL?.path else {
                    completion(.failure(GenerateFileUploadError.failedToGenerateFileName))
                    return
                }
                guard let mimeType = contentInput?.uniformTypeIdentifier else {
                    completion(.failure(GenerateFileUploadError.failedToGenerateMimeType))
                    return
                }
                
                PHImageManager.default().requestImageData(for: self, options: nil) { (data, _, _, _) in
                    guard let data = data else {
                        return
                    }
                    
                    let fileUpload = FileUpload(
                        data: data,
                        mimeType: mimeType,
                        fileName: fileName
                    )
                    
                    completion(.success(fileUpload))
                }
            }
            
            return NilDisposer()
        }
    }
}
