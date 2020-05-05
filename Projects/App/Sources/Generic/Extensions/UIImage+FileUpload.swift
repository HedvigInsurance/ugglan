//
//  UIImage+FileUpload.swift
//  test
//
//  Created by Sam Pettersson on 2020-02-20.
//

import Flow
import Foundation
import UIKit

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
