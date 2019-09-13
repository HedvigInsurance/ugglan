//
//  PHAsset+FileUpload.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-09-12.
//

import Foundation
import Flow
import Photos
import MobileCoreServices
import Disk

extension PHAsset {
    enum GenerateFileUploadError: Error {
        case failedToGenerateFileName, failedToGenerateMimeType, failedToGetVideoURL, failedToGetVideoData
    }
    
    // generates a fileUpload for current PHAsset
    var fileUpload: Future<FileUpload> {
        Future { completion in
            let options = PHContentEditingInputRequestOptions()
            options.isNetworkAccessAllowed = true
            
            self.requestContentEditingInput(with: options) { (contentInput, _) in
                switch self.mediaType {
                case .video:
                    PHImageManager.default().requestExportSession(
                        forVideo: self,
                        options: nil,
                        exportPreset: AVAssetExportPresetHighestQuality
                    ) { (exportSession, _) in
                        exportSession?.outputFileType = AVFileType.mp4
                        exportSession?.outputURL = try? Disk.url(for: "hedvig-video-upload.mp4", in: .caches)
                                                
                        exportSession?.exportAsynchronously(completionHandler: {
                            guard let url = exportSession?.outputURL else {
                                completion(.failure(GenerateFileUploadError.failedToGetVideoURL))
                                return
                            }
                                                    
                            let fileName = url.path
                            
                            guard let data = try? Data(contentsOf: url) else {
                                completion(.failure(GenerateFileUploadError.failedToGetVideoData))
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
                    
                    guard let mimeType = UTTypeCopyPreferredTagWithClass(
                        uti as CFString,
                        kUTTagClassMIMEType as CFString
                    )?.takeRetainedValue() as String? else {
                        completion(.failure(GenerateFileUploadError.failedToGenerateMimeType))
                        return
                    }
                    
                    PHImageManager.default().requestImageData(for: self, options: nil) { (data, _, _, _) in
                        guard let data = data else {
                            return
                        }
                        guard let fileName = contentInput?.fullSizeImageURL?.path else {
                                           completion(.failure(GenerateFileUploadError.failedToGenerateFileName))
                                           return
                                       }
                        
                        let fileUpload = FileUpload(
                            data: data,
                            mimeType: mimeType,
                            fileName: fileName
                        )
                        
                        completion(.success(fileUpload))
                    }
                case .unknown:
                    break
                case .audio:
                    break
                @unknown default:
                    break
                }
            }
            
            return NilDisposer()
        }
    }
}
