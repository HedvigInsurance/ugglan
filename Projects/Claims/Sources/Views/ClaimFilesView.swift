import SwiftUI
import hCore
import hCoreUI

public struct ClaimFilesView: View {
    @ObservedObject private var vm: ClaimFilesViewModel
    @State var showImagePicker = false
    @State var showFilePicker = false
    @State var showCamera = false
    public init(endPoint: String, files: [File]) {
        self.vm = .init(endPoint: endPoint, files: files, options: [.add, .delete])
    }
    public var body: some View {
        Group {
            if vm.isLoading || vm.success {
                BlurredProgressOverlay {
                    if vm.isLoading {
                        loadingView
                    } else if vm.success {
                        successView
                    }
                }
                .presentableStoreLensAnimation(.default)
            } else if let error = vm.error {
                RetryView(subtitle: error) {
                    withAnimation {
                        vm.error = nil
                    }
                }
            } else {
                hForm {
                    hSection {
                        FilesGridView(vm: vm.fileGridViewModel)
                    }
                    .padding(.vertical, 16)

                }
                .hFormAttachToBottom {
                    hSection {
                        VStack(spacing: 8) {
                            hButton.LargeButton(type: .secondary) {
                                showFilePickerAlert()
                            } content: {
                                hText(L10n.ClaimStatusDetail.addMoreFiles)

                            }
                            .disabled(vm.isLoading)

                            hButton.LargeButton(type: .primary) {
                                Task {
                                    await vm.uploadFiles()
                                }
                            } content: {
                                hText(L10n.fileUploadUploadFiles)
                            }
                            .hButtonIsLoading(vm.isLoading)
                            .disabled(vm.fileGridViewModel.files.isEmpty)
                        }
                    }
                    .padding(.vertical, 16)
                }
                .sectionContainerStyle(.transparent)
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker { images in
                        for image in images {
                            let dataPath = vm.fileUploadManager.getPathForData(
                                for: image.id,
                                andExtension: image.extension
                            )
                            let thumbnailPath = vm.fileUploadManager.getPathForThumnailData(
                                for: image.id,
                                andExtension: image.extension
                            )
                            if let file = image.asFile(with: dataPath, and: thumbnailPath) {
                                vm.add(file: file)
                            }
                        }
                    }
                    .ignoresSafeArea()
                }
                .sheet(isPresented: $showFilePicker) {
                    FileImporterView { files in
                        for file in files {
                            let dataPath = vm.fileUploadManager.getPathForData(
                                for: file.id,
                                andExtension: file.extension
                            )
                            let thumbnailPath = vm.fileUploadManager.getPathForThumnailData(
                                for: file.id,
                                andExtension: file.extension
                            )
                            if let file = file.asFile(with: dataPath, and: thumbnailPath) {
                                vm.add(file: file)
                            }
                        }
                    }
                    .ignoresSafeArea()
                }
                .sheet(isPresented: $showCamera) {
                    CameraPickerView { image in
                        guard let data = image.jpegData(compressionQuality: 0.9),
                            let thumbnailData = image.jpegData(compressionQuality: 0.1)
                        else { return }
                        let file = FilePickerDto(
                            id: UUID().uuidString,
                            size: Double(data.count),
                            mimeType: .JPEG,
                            name: "image_\(Date()).jpeg",
                            data: data,
                            thumbnailData: thumbnailData,
                            extension: "jpeg"
                        )
                        let dataPath = vm.fileUploadManager.getPathForData(for: file.id, andExtension: file.extension)
                        let thumbnailPath = vm.fileUploadManager.getPathForThumnailData(
                            for: file.id,
                            andExtension: file.extension
                        )
                        if let file = file.asFile(with: dataPath, and: thumbnailPath) {
                            vm.add(file: file)
                        }

                    }
                    .ignoresSafeArea()
                }
            }
        }
    }

    private func showFilePickerAlert() {
        FilePicker.showAlert { selected in
            switch selected {
            case .camera:
                showCamera = true
            case .imagePicker:
                showImagePicker = true
            case .filePicker:
                showFilePicker = true
            }
        }
    }

    private var loadingView: some View {
        hSection {
            VStack(spacing: 20) {
                Spacer()
                hText(L10n.fileUploadIsUploading)
                ProgressView(value: vm.progress)
                    .tint(hTextColor.primary)
                    .frame(width: UIScreen.main.bounds.width * 0.53)
                Spacer()
            }
        }
        .sectionContainerStyle(.transparent)
    }

    private var successView: some View {
        SuccessScreen(title: L10n.fileUploadFilesAdded)
    }
}

class ClaimFilesViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var success = false
    @Published var error: String?
    @Published var progress: Double = 0
    private let endPoint: String
    let fileUploadManager = FileUploadManager()
    var fileGridViewModel: FileGridViewModel
    @Inject var claimFileUploadService: hClaimFileUploadService
    @Inject var fetchClaimService: hFetchClaimService

    @PresentableStore var store: ClaimsStore
    init(endPoint: String, files: [File], options: ClaimFilesViewOptions) {
        self.endPoint = endPoint
        self.fileGridViewModel = .init(files: files, options: options)
        self.fileGridViewModel.onDelete = { file in
            Task { [weak self] in
                await self?.removeFile(id: file.id)
            }
        }
    }

    @MainActor
    func add(file: File) {
        DispatchQueue.main.async { [weak self] in
            withAnimation {
                self?.fileGridViewModel.files.append(file)
            }
        }
    }

    @MainActor
    func removeFile(id: String) {
        withAnimation {
            self.fileGridViewModel.files.removeAll(where: { $0.id == id })
        }
    }

    @MainActor
    func uploadFiles() async {
        withAnimation {
            isLoading = true
            setNavigationBarHidden(true)
        }
        do {
            let filteredFiles = fileGridViewModel.files.filter({
                if case .localFile(_, _) = $0.source { return true } else { return false }
            })
            if !filteredFiles.isEmpty {
                _ = try await claimFileUploadService.upload(endPoint: endPoint, files: filteredFiles) {
                    [weak self] progress in
                    DispatchQueue.main.async {
                        withAnimation {
                            self?.progress = progress
                        }
                    }
                }
                success = true
                let claims = try await fetchClaimService.get()
                store.send(.setClaims(claims: claims))
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                    self?.setNavigationBarHidden(false)
                    self?.fileUploadManager.resetuploadFilesPath()
                    self?.store.send(.navigation(action: .dismissAddFiles))
                }
            }
        } catch let ex {
            withAnimation {
                error = ex.localizedDescription
            }
        }
        withAnimation {
            isLoading = false
            if !success {
                setNavigationBarHidden(false)
            }
        }

    }

    struct ClaimFilesViewOptions: OptionSet {
        let rawValue: UInt

        static let add = ClaimFilesViewOptions(rawValue: 1 << 0)
        static let delete = ClaimFilesViewOptions(rawValue: 1 << 1)
    }

    private func setNavigationBarHidden(_ hidden: Bool) {
        let nav = UIApplication.shared.getTopViewControllerNavigation()
        nav?.setNavigationBarHidden(hidden, animated: true)
    }
}

#Preview{
    let files: [File] = [
        .init(
            id: "imageId1",
            size: 22332,
            mimeType: .PNG,
            name: "test-image",
            source: .url(url: URL(string: "https://filesamples.com/samples/image/png/sample_640%C3%97426.png")!)
        ),

        .init(
            id: "imageId2",
            size: 53443,
            mimeType: MimeType.PNG,
            name: "test-image2",
            source: .url(
                url: URL(string: "https://onlinepngtools.com/images/examples-onlinepngtools/giraffe-illustration.png")!
            )
        ),
        .init(
            id: "imageId3",
            size: 52176,
            mimeType: MimeType.PNG,
            name: "test-image3",
            source: .url(url: URL(string: "https://cdn.pixabay.com/photo/2017/06/21/15/03/example-2427501_1280.png")!)
        ),
        .init(
            id: "imageId4",
            size: 52176,
            mimeType: MimeType.PNG,
            name: "test-image4",
            source: .url(url: URL(string: "https://flif.info/example-images/fish.png")!)
        ),
        .init(
            id: "imageId5",
            size: 52176,
            mimeType: MimeType.PDF,
            name: "test-pdf long name it is possible to have it is long name .pdf",
            source: .url(url: URL(string: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf")!)
        ),
    ]
    return ClaimFilesView(endPoint: "", files: files)
}

struct FilePicker {
    static func showAlert(closure: @escaping (_ selected: SelectedFileInputType) -> Void) {
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: UIDevice.current.userInterfaceIdiom == .phone ? .actionSheet : .alert
        )

        alert.addAction(
            UIAlertAction(
                title: L10n.fileUploadPhotoLibrary,
                style: .default,
                handler: { _ in
                    closure(.imagePicker)
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: L10n.fileUploadTakePhoto,
                style: .default,
                handler: { _ in
                    closure(.camera)
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: L10n.fileUploadChooseFiles,
                style: .default,
                handler: { _ in
                    closure(.filePicker)
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: L10n.generalCancelButton,
                style: .cancel,
                handler: { _ in }
            )
        )

        UIApplication.shared.getTopViewController()?.present(alert, animated: true, completion: nil)
    }

    enum SelectedFileInputType {
        case camera
        case imagePicker
        case filePicker
    }
}
