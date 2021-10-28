import Disk
import Flow
import Foundation
import MobileCoreServices
import Photos
import UIKit

extension PHAsset {
    enum GenerateFileUploadError: Error {
        case failedToGenerateFileName, failedToGenerateMimeType, failedToGetVideoURL, failedToGetVideoData,
            failedToConvertHEIC
    }

    enum ProcessImageError: Error { case noData, failedToConvert, notAnImage }

    /// returns a UIImage when PHAsset has mediaType == .image
    var image: Future<UIImage?> {
        Future { completion in
            if self.mediaType != .image {
                completion(.failure(ProcessImageError.notAnImage))
                return NilDisposer()
            }

            PHImageManager.default()
                .requestImageDataAndOrientation(for: self, options: nil) { data, _, _, _ in
                    guard let data = data else {
                        completion(.failure(ProcessImageError.noData))
                        return
                    }
                    guard let image = UIImage(data: data) else {
                        completion(.failure(ProcessImageError.failedToConvert))
                        return
                    }

                    completion(.success(image))
                }

            return NilDisposer()
        }
    }

    /// generates a fileUpload for current PHAsset
    var fileUpload: Future<FileUpload> {
        Future { completion in let options = PHContentEditingInputRequestOptions()
            options.isNetworkAccessAllowed = true

            self.requestContentEditingInput(with: options) { contentInput, _ in
                switch self.mediaType {
                case .video:
                    PHImageManager.default()
                        .requestExportSession(
                            forVideo: self,
                            options: nil,
                            exportPreset: AVAssetExportPresetHighestQuality
                        ) { exportSession, _ in exportSession?.outputFileType = AVFileType.mp4
                            exportSession?.outputURL = try? Disk.url(
                                for: "hedvig-video-upload.mp4",
                                in: .caches
                            )

                            exportSession?
                                .exportAsynchronously(completionHandler: {
                                    guard let url = exportSession?.outputURL else {
                                        completion(
                                            .failure(
                                                GenerateFileUploadError
                                                    .failedToGetVideoURL
                                            )
                                        )
                                        return
                                    }

                                    let fileName = url.path

                                    guard let data = try? Data(contentsOf: url)
                                    else {
                                        completion(
                                            .failure(
                                                GenerateFileUploadError
                                                    .failedToGetVideoData
                                            )
                                        )
                                        return
                                    }

                                    let fileUpload = FileUpload(
                                        data: data,
                                        mimeType: url.mimeType,
                                        fileName: fileName
                                    )

                                    completion(.success(fileUpload))
                                })
                        }
                case .image:

                    guard let uti = contentInput?.uniformTypeIdentifier else {
                        completion(.failure(GenerateFileUploadError.failedToGenerateMimeType))
                        return
                    }

                    guard
                        let mimeType = UTTypeCopyPreferredTagWithClass(
                            uti as CFString,
                            kUTTagClassMIMEType as CFString
                        )?
                        .takeRetainedValue() as String?
                    else {
                        completion(.failure(GenerateFileUploadError.failedToGenerateMimeType))
                        return
                    }

                    PHImageManager.default()
                        .requestImageDataAndOrientation(for: self, options: nil) { data, _, _, _ in
                            guard let data = data else { return }
                            guard let fileName = contentInput?.fullSizeImageURL?.path else {
                                completion(
                                    .failure(
                                        GenerateFileUploadError
                                            .failedToGenerateFileName
                                    )
                                )
                                return
                            }

                            if fileName.lowercased().contains("heic") {
                                guard let image = UIImage(data: data),
                                    let jpegData = image.jpegData(
                                        compressionQuality: 0.9
                                    )
                                else {
                                    completion(
                                        .failure(
                                            GenerateFileUploadError
                                                .failedToConvertHEIC
                                        )
                                    )
                                    return
                                }

                                let fileUpload = FileUpload(
                                    data: jpegData,
                                    mimeType: "image/jpeg",
                                    fileName: fileName
                                )

                                completion(.success(fileUpload))
                            } else {
                                let fileUpload = FileUpload(
                                    data: data,
                                    mimeType: mimeType,
                                    fileName: fileName
                                )

                                completion(.success(fileUpload))
                            }
                        }
                case .unknown: break
                case .audio: break
                @unknown default: break
                }
            }

            return NilDisposer()
        }
    }
}
