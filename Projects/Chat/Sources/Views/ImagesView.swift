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
        Group {
            if vm.permissionNotGranted {
                GenericErrorView(
                    title: "Notifications permission",
                    description: "Please allow access to the images",
                    buttons: .init(
                        actionButton: .init(
                            buttonTitle: L10n.Profile.AppSettingsSection.title,
                            buttonAction: {
                                vm.openSettings()
                            }
                        )
                    )
                )
                .background(Color.red)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(vm.files, id: \.creationDate) { file in
                            PHPAssetPreview(asset: file) { message in
                                self.vm.sendMessage(message)
                            }
                            .frame(width: 205, height: 256)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12).stroke(hBorderColor.opaqueOne, lineWidth: 0.5)
                            )
                        }
                    }
                    .clipped()
                }
            }
        }
        .frame(height: 264)
        .onAppear {
            vm.fetchData()
        }
    }
}

class ImagesViewModel: ObservableObject {
    @Published var files = [PHAsset]()
    @Published var permissionNotGranted = false
    var sendMessage: (_ message: Message) -> Void = { _ in }
    init() {}

    func fetchData() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] (status) in
            switch status {
            case .notDetermined, .restricted, .denied:
                DispatchQueue.main.async {
                    withAnimation {
                        self?.permissionNotGranted = true
                    }
                }
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
        }
    }
    func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(settingsUrl)
    }
}

#Preview{
    ImagesView(vm: .init())
}

struct PHPAssetPreview: View {
    let asset: PHAsset
    @State private var image: UIImage?
    @State private var selected = false
    @State private var loading = false
    let onSend: (_ message: Message) -> Void
    @ViewBuilder
    var body: some View {
        if let image {
            ZStack(alignment: .center) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .onTapGesture {
                        withAnimation {
                            self.selected.toggle()
                        }
                    }
                    .blur(radius: selected ? 10 : 0, opaque: true)
                hButton.MediumButton(type: .secondaryAlt) {
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
                } content: {
                    if loading {
                        ProgressView()
                            .foregroundColor(hTextColor.primary)
                    } else {
                        hText(L10n.chatUploadPresend)
                            .foregroundColor(hTextColor.primary)
                    }
                }
                .opacity(selected ? 1 : 0)
                .fixedSize()
            }
        } else {
            ProgressView()
                .onAppear {
                    PHImageManager.default()
                        .requestImage(
                            for: asset,
                            targetSize: .init(width: 600, height: 600),
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

    // generates a fileUpload for current PHAsset
    func getFile() async throws -> File {
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true
        let id = UUID().uuidString
        let file = try await withCheckedThrowingContinuation {
            (inCont: CheckedContinuation<File, Error>) -> Void in
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
