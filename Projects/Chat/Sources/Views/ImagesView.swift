import CoreServices
import Photos
import SwiftUI
import hCore
import hCoreUI

struct ImagesView: View {
    @ObservedObject private var vm: ImagesViewModel
    init(vm: ImagesViewModel) {
        self.vm = vm
    }
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(vm.files, id: \.creationDate) { file in
                    PHPAssetPreview(asset: file) { message in
                        self.vm.sendMessage(message)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .frame(height: 264)
    }
}

class ImagesViewModel: ObservableObject {
    @Published var files = [PHAsset]()
    @Published var phAuthorizationStatus: PHAuthorizationStatus = .notDetermined
    var sendMessage: (_ message: Message) -> Void = { _ in }
    init() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] (status) in
            switch status {
            case .notDetermined, .restricted, .denied:
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                DispatchQueue.main.async { UIApplication.shared.open(settingsUrl) }
            case .authorized, .limited:
                var list = [PHAsset]()
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [
                    NSSortDescriptor(key: "creationDate", ascending: false)
                ]
                fetchOptions.fetchLimit = 50

                let imageAssets = PHAsset.fetchAssets(with: .image, options: fetchOptions)

                imageAssets.enumerateObjects { asset, _, _ in
                    list.append(asset)
                }

                let videoAssets = PHAsset.fetchAssets(with: .video, options: fetchOptions)

                videoAssets.enumerateObjects { asset, _, _ in
                    list.append(asset)
                }

                DispatchQueue.main.async {
                    self?.files = list
                }
            @unknown default:
                break
            }
            DispatchQueue.main.async {
                self?.phAuthorizationStatus = status
            }
        }
    }
}

#Preview{
    ImagesView(vm: .init())
}

struct PHPAssetPreview: View {
    let asset: PHAsset
    @State private var image: UIImage?
    @State var selected = false
    @State var loading = false
    let onSend: (_ message: Message) -> Void
    @ViewBuilder
    var body: some View {
        if let image {
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .onTapGesture {
                        withAnimation {
                            self.selected = true
                        }
                    }
                    .blur(radius: selected ? 3 : 0, opaque: true)
                Button {
                    Task {
                        withAnimation {
                            loading = true
                        }
                        do {
                            if let file = try? await asset.getFile() {
                                onSend(.init(type: .file(file: file)))
                            }
                        }
                        withAnimation {
                            loading = false
                            self.selected = false
                        }
                    }
                } label: {
                    if loading {
                        ProgressView()
                    } else {
                        hText(L10n.chatUploadPresend)
                    }
                }
                .opacity(selected ? 1 : 0)
            }
        } else {
            ProgressView()
                .onAppear {
                    PHImageManager.default()
                        .requestImage(
                            for: asset,
                            targetSize: .init(width: 300, height: 300),
                            contentMode: .aspectFit,
                            options: nil,
                            resultHandler: { image, _ in
                                self.image = image
                            }
                        )
                }
        }
    }
}

extension PHAsset {
    enum GenerateFileUploadError: Error {
        case failedToGenerateFileName, failedToGenerateMimeType, failedToGetVideoURL, failedToGetVideoData,
            failedToConvertHEIC, failedToConvertToFile
    }

    /// generates a fileUpload for current PHAsset
    func getFile() async throws -> File {
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true
        let id = UUID().uuidString
        let file = try await withCheckedThrowingContinuation {
            (inCont: CheckedContinuation<File, Error>) -> Void in
            //            let task = self.sessionClient.dataTask(with: request) { [weak self] (data, response, error) in
            //                do {
            //                    if let uploadedFiles: [ChatUploadFileResponseModel] = try self?
            //                        .handleResponse(data: data, response: response, error: error)
            //                    {
            //                        inCont.resume(returning: uploadedFiles)
            //                    }
            //                } catch let error {
            //                    inCont.resume(throwing: error)
            //                }
            //            }
            //            observation = task.progress.observe(\.fractionCompleted) { progress, _ in
            //                withProgress?(progress.fractionCompleted)
            //            }
            //            task.resume()

            requestContentEditingInput(with: options) { contentInput, _ in
                switch self.mediaType {
                case .video:
                    PHImageManager.default()
                        .requestExportSession(
                            forVideo: self,
                            options: nil,
                            exportPreset: AVAssetExportPresetHighestQuality
                        ) { exportSession, _ in
                            exportSession?.outputFileType = AVFileType.mp4
                            exportSession?.outputURL = FileUploadManager().getPathForData(for: id)

                            exportSession?
                                .exportAsynchronously(completionHandler: {
                                    guard let url = exportSession?.outputURL else {
                                        inCont.resume(throwing: GenerateFileUploadError.failedToGetVideoURL)
                                        return
                                    }

                                    let fileName = url.path

                                    guard let data = try? Data(contentsOf: url)
                                    else {
                                        inCont.resume(throwing: GenerateFileUploadError.failedToGetVideoData)
                                        return
                                    }
                                    let file = File(
                                        id: id,
                                        size: 0,
                                        mimeType: MimeType.MP4,
                                        name: fileName,
                                        source: .localFile(url: url, thumbnailURL: nil)
                                    )
                                    inCont.resume(returning: file)
                                })
                        }
                case .image:
                    guard let uti = contentInput?.uniformTypeIdentifier else {
                        inCont.resume(throwing: GenerateFileUploadError.failedToGenerateMimeType)
                        return
                    }
                    //
                    guard
                        let mimeType = UTTypeCopyPreferredTagWithClass(
                            uti as CFString,
                            kUTTagClassMIMEType as CFString
                        )?
                        .takeRetainedValue() as String?
                    else {
                        inCont.resume(throwing: GenerateFileUploadError.failedToGenerateMimeType)
                        return
                    }
                    PHImageManager.default()
                        .requestImageDataAndOrientation(for: self, options: nil) { data, _, _, _ in
                            guard let data = data else { return }
                            guard let fileName = contentInput?.fullSizeImageURL?.path else {
                                inCont.resume(throwing: GenerateFileUploadError.failedToGenerateFileName)
                                return
                            }

                            if fileName.lowercased().contains("heic") {
                                guard let image = UIImage(data: data),
                                    let jpegData = image.jpegData(
                                        compressionQuality: 0.9
                                    )
                                else {
                                    inCont.resume(throwing: GenerateFileUploadError.failedToConvertHEIC)
                                    return
                                }
                                if let file = FilePickerDto(
                                    id: id,
                                    size: 0,
                                    mimeType: .JPEG,
                                    name: fileName,
                                    data: jpegData,
                                    thumbnailData: nil
                                )
                                .asFile() {
                                    inCont.resume(returning: file)
                                } else {
                                    inCont.resume(throwing: GenerateFileUploadError.failedToConvertToFile)
                                }

                            } else {
                                if let file = FilePickerDto(
                                    id: id,
                                    size: 0,
                                    mimeType: MimeType.findBy(mimeType: mimeType),
                                    name: fileName,
                                    data: data,
                                    thumbnailData: nil
                                )
                                .asFile() {
                                    inCont.resume(returning: file)
                                } else {
                                    inCont.resume(throwing: GenerateFileUploadError.failedToConvertToFile)
                                }
                            }
                        }
                case .unknown: break
                case .audio: break
                @unknown default: break
                }
            }
        }
        return file
    }
}
