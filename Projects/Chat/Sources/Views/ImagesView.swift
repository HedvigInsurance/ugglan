import CoreServices
import MobileCoreServices
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
                    title: L10n.chatMissingImagesPermissionSubtitle,
                    description: nil,
                    formPosition: nil
                )
                .hStateViewButtonConfig(
                    .init(
                        actionButton: .init(
                            buttonTitle: L10n.chatOpenAppSettingsButton,
                            buttonAction: {
                                vm.openSettings()
                            }
                        )
                    )
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(vm.files, id: \.creationDate) { file in
                            PHPAssetPreview(asset: file) { message in
                                vm.sendMessage(message)
                            }
                        }
                    }
                    .clipped()
                }
            }
        }
        .frame(height: 264)
        .onAppear {
            Task {
                await vm.fetchData()
            }
        }
    }
}

@MainActor
class ImagesViewModel: ObservableObject {
    @Published var files = [PHAsset]()
    @Published var permissionNotGranted = false
    var sendMessage: (_ message: Message) -> Void = { _ in }
    init() {}

    func fetchData() async {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        switch status {
        case .notDetermined, .restricted, .denied:
            withAnimation {
                self.permissionNotGranted = true
            }
        case .authorized, .limited:
            var list = [PHAsset]()
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: false)
            ]
            fetchOptions.fetchLimit = 50

            let imageAssets = PHAsset.fetchAssets(
                with: .image,
                options: fetchOptions
            )

            imageAssets.enumerateObjects { asset, _, _ in
                list.append(asset)
            }

            let videoAssets = PHAsset.fetchAssets(
                with: .video,
                options: fetchOptions
            )

            videoAssets.enumerateObjects { asset, _, _ in
                list.append(asset)
            }

            files = list
        @unknown default:
            break
        }
    }

    func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        Dependencies.urlOpener.open(settingsUrl)
    }
}

#Preview {
    ImagesView(vm: .init())
}

#Preview {
    PHPAssetPreview(asset: .init()) { _ in
    }
}

struct PHPAssetPreview: View {
    let asset: PHAsset
    @State private var image: UIImage?
    @State private var selected = false
    @State private var loading = false
    let onSend: (_ message: Message) -> Void
    @ViewBuilder
    var body: some View {
        Group {
            if let image {
                ZStack(alignment: .center) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .onTapGesture {
                            withAnimation {
                                selected.toggle()
                            }
                        }
                        .blur(radius: selected ? 20 : 0, opaque: true)

                    hButton(
                        .medium,
                        .secondaryAlt,
                        content: .init(title: L10n.chatUploadPresend),
                        {
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
                                    selected = false
                                }
                            }
                        }
                    )
                    .hCustomButtonView {
                        if loading {
                            ProgressView()
                                .foregroundColor(hTextColor.Opaque.primary)
                        } else {
                            hText(L10n.chatUploadPresend)
                                .foregroundColor(hTextColor.Opaque.primary)
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
        .frame(width: 205, height: 256)
        .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
        .contentShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
        .overlay(
            RoundedRectangle(cornerRadius: .cornerRadiusL).stroke(hBorderColor.primary, lineWidth: 0.5)
        )
    }
}

@MainActor
extension PHAsset {
    enum GenerateFileUploadError: Error {
        case failedToGenerateFileName,
            failedToGenerateMimeType,
            failedToGetVideoURL,
            failedToGetVideoData,
            failedToConvertHEIC
    }

    // generates a fileUpload for current PHAsset
    func getFile() async throws -> File {
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true
        let id = UUID().uuidString
        let file = try await withCheckedThrowingContinuation {
            (inCont: CheckedContinuation<File, Error>) in
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
                            let url = exportSession?.outputURL
                            exportSession?
                                .exportAsynchronously(completionHandler: {
                                    guard let url = url else {
                                        inCont.resume(throwing: GenerateFileUploadError.failedToGetVideoURL)
                                        return
                                    }

                                    let fileName = url.lastPathComponent

                                    guard let data = (try? Data(contentsOf: url))
                                    else {
                                        inCont.resume(throwing: GenerateFileUploadError.failedToGetVideoData)
                                        return
                                    }
                                    let file = File(
                                        id: id,
                                        size: 0,
                                        mimeType: MimeType.MP4,
                                        name: fileName,
                                        source: .data(data: data)
                                    )
                                    inCont.resume(returning: file)
                                })
                        }
                case .image:
                    guard let ext = contentInput?.fullSizeImageURL?.pathExtension else {
                        inCont.resume(throwing: GenerateFileUploadError.failedToGenerateMimeType)
                        return
                    }
                    guard let mimeType = UTType(filenameExtension: ext)?.preferredMIMEType else {
                        inCont.resume(throwing: GenerateFileUploadError.failedToGenerateMimeType)
                        return
                    }
                    PHImageManager.default()
                        .requestImageDataAndOrientation(for: self, options: nil) { data, _, _, _ in
                            guard let data = data else { return }
                            guard let fileName = contentInput?.fullSizeImageURL?.lastPathComponent else {
                                inCont.resume(throwing: GenerateFileUploadError.failedToGenerateFileName)
                                return
                            }

                            if mimeType.lowercased().contains("heic") {
                                guard let image = UIImage(data: data),
                                    let jpegData = image.jpegData(
                                        compressionQuality: 0.9
                                    )
                                else {
                                    inCont.resume(throwing: GenerateFileUploadError.failedToConvertHEIC)
                                    return
                                }

                                let file = File(
                                    id: id,
                                    size: 0,
                                    mimeType: .JPEG,
                                    name: fileName,
                                    source: .data(data: jpegData)
                                )
                                inCont.resume(returning: file)
                            } else {
                                let file = File(
                                    id: id,
                                    size: 0,
                                    mimeType: MimeType.findBy(mimeType: mimeType),
                                    name: fileName,
                                    source: .data(data: data)
                                )
                                inCont.resume(returning: file)
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
