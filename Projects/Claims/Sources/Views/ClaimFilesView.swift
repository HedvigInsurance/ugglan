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
                        FilesGridView(files: vm.files, options: vm.options) { file in
                            vm.removeFile(id: file.id)
                        }
                    }
                    .padding(.vertical, 16)

                }
                .hFormAttachToBottom {
                    hSection {
                        VStack(spacing: 8) {
                            hButton.LargeButton(type: .primaryAlt) {
                                showAlert()
                            } content: {
                                hText(L10n.ClaimStatusDetail.addMoreFiles)
                            }
                            .disabled(vm.isLoading)

                            hButton.LargeButton(type: .primary) {
                                Task {
                                    await vm.uploadFiles()
                                }
                            } content: {
                                hText(L10n.saveAndContinueButtonLabel)
                            }
                            .hButtonIsLoading(vm.isLoading)
                            .disabled(vm.files.isEmpty)
                        }
                    }
                    .padding(.vertical, 16)
                }
                .sectionContainerStyle(.transparent)
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker { image in
                        if let image {
                            vm.add(file: image)
                        }
                    }
                }
                .sheet(isPresented: $showFilePicker) {
                    FileImporterView { file in
                        vm.add(file: file)
                    }
                }
                .sheet(isPresented: $showCamera) {
                    CameraPickerView { image in
                        guard let data = image.jpegData(compressionQuality: 1) else { return }
                        vm.add(
                            file: .init(
                                id: UUID().uuidString,
                                size: Double(data.count),
                                mimeType: .JPEG,
                                name: "image_\(Date())",
                                source: .data(data: data)
                            )
                        )
                    }
                }
            }
        }
        .onAppear {
            showAlert()
        }
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            Spacer()
            hText(L10n.fileUploadIsUploading)
            ProgressView(value: vm.progress)
                .tint(hTextColor.primary)
                .frame(width: UIScreen.main.bounds.width * 0.53)
            Spacer()
            Spacer()
            Spacer()
        }
    }

    private var successView: some View {
        SuccessScreen(title: L10n.fileUploadFilesAdded)
    }

    func showAlert() {
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )

        alert.addAction(
            UIAlertAction(
                title: L10n.fileUploadPhotoLibrary,
                style: .default,
                handler: { _ in
                    showImagePicker = true
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: L10n.fileUploadTakePhoto,
                style: .default,
                handler: { _ in
                    showCamera = true
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: L10n.fileUploadChooseFiles,
                style: .default,
                handler: {
                    _
                    in showFilePicker = true
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: L10n.generalCancelButton,
                style: .destructive,
                handler: { _ in }
            )
        )

        UIApplication.shared.getTopViewController()?.present(alert, animated: true, completion: nil)
    }
}

class ClaimFilesViewModel: ObservableObject {
    @Published var files: [File] = []
    @Published var isLoading = false
    @Published var success = false
    @Published var error: String?
    @Published var progress: Double = 0
    private let endPoint: String
    let options: ClaimFilesViewOptions
    @Inject var claimFileUploadService: hClaimFileUploadService
    @Inject var fetchClaimService: hFetchClaimService

    @PresentableStore var store: ClaimsStore
    init(endPoint: String, files: [File], options: ClaimFilesViewOptions) {
        self.endPoint = endPoint
        self.files = files
        self.options = options
    }

    @MainActor
    func add(file: File) {
        DispatchQueue.main.async { [weak self] in
            withAnimation {
                self?.files.append(file)
            }
        }
    }

    @MainActor
    func removeFile(id: String) {
        withAnimation {
            files.removeAll(where: { $0.id == id })
        }
    }

    @MainActor
    func uploadFiles() async {
        withAnimation {
            isLoading = true
            setNavigationBarHidden(true)
        }
        do {
            let filteredFiles = files.filter({ if case .data = $0.source { return true } else { return false } })
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
        let topVC = UIApplication.shared.getTopViewController()
        if let topVC = topVC as? UITabBarController {
            if let nav = topVC.selectedViewController as? UINavigationController {
                nav.setNavigationBarHidden(hidden, animated: true)
            }
        }
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
