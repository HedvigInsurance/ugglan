import Combine
import SwiftUI
import hCore
import hCoreUI

struct FilesUploadScreen: View {
    @State var showImagePicker = false
    @State var showFilePicker = false
    @State var showCamera = false
    @StateObject fileprivate var vm: FilesUploadViewModel

    init(model: FlowClaimFileUploadStepModel) {
        _vm = StateObject(wrappedValue: FilesUploadViewModel(model: model))
    }

    var body: some View {
        Group {
            if let error = vm.error {
                RetryView(subtitle: error) {
                    withAnimation {
                        vm.error = nil
                    }
                }
            } else if vm.hasFiles {
                hForm {
                    if vm.isLoading, vm.hasFilesToUpload {
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
                    } else {
                        hSection {
                            FilesGridView(vm: vm.fileGridViewModel)
                        }
                        .withHeader {
                            HStack {
                                hText("Uploaded files")
                                Spacer()
                                InfoViewHolder(title: "", description: "")
                            }
                        }
                        .padding(.vertical, 16)
                    }

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
                                hText(L10n.generalContinueButton)
                            }
                            .hButtonIsLoading(vm.isLoading)
                            .disabled(vm.fileGridViewModel.files.isEmpty)
                        }
                    }
                    .padding(.vertical, 16)
                }
                .sectionContainerStyle(.transparent)

            } else {
                hForm {}
                    .hFormTitle(.standard, .title1, L10n.claimsFileUploadTitle)
                    .hFormAttachToBottom {
                        hSection {
                            VStack(spacing: 16) {
                                InfoCard(text: L10n.claimsFileUploadInfo, type: .info)
                                VStack(spacing: 8) {
                                    hButton.LargeButton(type: .primary) {
                                        showFilePickerAlert()
                                    } content: {
                                        hText(L10n.ClaimStatusDetail.addFiles)
                                    }
                                    .hButtonIsLoading(vm.isLoading && !vm.skipPressed)
                                    .disabled(vm.isLoading && vm.skipPressed)
                                    hButton.LargeButton(type: .ghost) {
                                        vm.skip()
                                    } content: {
                                        hText(L10n.NavBar.skip)
                                    }
                                    .disabled(vm.isLoading && !vm.skipPressed)
                                    .hButtonIsLoading(vm.isLoading && vm.skipPressed)
                                }
                            }
                        }
                        .sectionContainerStyle(.transparent)
                    }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker { images in
                vm.addFiles(with: images)
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showFilePicker) {
            FileImporterView { files in
                vm.addFiles(with: files)
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showCamera) {
            CameraPickerView { image in
                guard let data = image.jpegData(compressionQuality: 0.9),
                    let thumbnailData = image.jpegData(compressionQuality: 0.1)
                else { return }
                let file: FilePickerDto = .init(
                    id: UUID().uuidString,
                    size: Double(data.count),
                    mimeType: .JPEG,
                    name: "image_\(Date()).jpeg",
                    data: data,
                    thumbnailData: thumbnailData,
                    extension: "jpeg"
                )
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    vm.addFiles(with: [file])
                }

            }
            .ignoresSafeArea()
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
}

private class FilesUploadViewModel: ObservableObject {
    @Published var hasFiles: Bool = false
    @Published var isLoading: Bool = false
    @Published var hasFilesToUpload: Bool = false
    @Published var skipPressed = false
    @Published var error: String?
    @Published var progress: Double = 0

    private let fileUploadManager = FileUploadManager()
    private let model: FlowClaimFileUploadStepModel
    @Inject var claimFileUploadService: hClaimFileUploadService
    @ObservedObject var fileGridViewModel: FileGridViewModel
    @PresentableStore var store: SubmitClaimStore

    private var cancellables = Set<AnyCancellable>()
    init(model: FlowClaimFileUploadStepModel) {
        self.model = model
        let files = model.uploads.compactMap({
            File(id: $0.fileId, size: 0, mimeType: .JPEG, name: "NAME", source: .url(url: URL(string: $0.signedUrl)!))
        })
        fileGridViewModel = .init(
            files: files,
            options: [.delete, .add]
        )
        fileUploadManager.resetuploadFilesPath()
        fileGridViewModel.$files
            .receive(on: RunLoop.main)
            .sink { _ in

            } receiveValue: { [weak self] files in
                withAnimation {
                    self?.hasFiles = !files.isEmpty
                }
            }
            .store(in: &cancellables)
        fileGridViewModel.onDelete = { [weak self] file in
            withAnimation {
                self?.fileGridViewModel.files.removeAll(where: { $0.id == file.id })
            }
        }

        store.loadingSignal
            .plain()
            .publisher
            .receive(on: RunLoop.main)
            .sink { _ in

            } receiveValue: { [weak self] state in
                guard let self else { return }
                withAnimation {
                    switch state[.postUploadFiles] {
                    case .loading:
                        self.isLoading = true
                    case let .error(error):
                        self.setNavigationBarHidden(false)
                        self.isLoading = false
                        self.skipPressed = false
                        self.error = error
                    case .none:
                        self.setNavigationBarHidden(false)
                        self.isLoading = false
                        self.skipPressed = false
                    }
                }
            }
            .store(in: &cancellables)

        self.$isLoading.receive(on: RunLoop.main)
            .sink { _ in

            } receiveValue: { [weak self] isLoading in
                self?.fileGridViewModel.update(options: isLoading ? [] : [.add, .delete])
            }
            .store(in: &cancellables)

    }

    func addFiles(with files: [FilePickerDto]) {
        if !files.isEmpty {
            let filess = files.compactMap(
                {
                    let dataPath = fileUploadManager.getPathForData(for: $0.id, andExtension: $0.extension)
                    let thumbnailPath = fileUploadManager.getPathForThumnailData(for: $0.id, andExtension: $0.extension)
                    return $0.asFile(with: dataPath, and: thumbnailPath)
                }
            )
            fileGridViewModel.files.append(contentsOf: filess)

        }
    }

    func skip() {
        hasFilesToUpload = false
        store.send(.submitFileUpload(ids: []))
    }

    func uploadFiles() async {
        withAnimation {
            isLoading = true
        }
        do {
            let alreadyUploadedFiles = fileGridViewModel.files
                .filter({
                    if case .url(_) = $0.source { return true } else { return false }
                })
                .compactMap({ $0.id })
            let filteredFiles = fileGridViewModel.files.filter({
                if case .localFile(_, _) = $0.source { return true } else { return false }
            })
            hasFilesToUpload = !filteredFiles.isEmpty
            if !filteredFiles.isEmpty {
                setNavigationBarHidden(true)
                let files = try await claimFileUploadService.upload(
                    endPoint: model.targetUploadUrl,
                    files: filteredFiles
                ) {
                    [weak self] progress in
                    DispatchQueue.main.async {
                        withAnimation {
                            self?.progress = progress
                        }
                    }
                }
                let uploadedFiles = files.compactMap({ $0.file?.fileId })
                store.send(.submitFileUpload(ids: alreadyUploadedFiles + uploadedFiles))
            } else {

                store.send(.submitFileUpload(ids: alreadyUploadedFiles))
            }
        } catch let ex {
            withAnimation {
                error = ex.localizedDescription
                setNavigationBarHidden(false)
                isLoading = false
            }
        }
    }

    private func setNavigationBarHidden(_ hidden: Bool) {
        let nav = UIApplication.shared.getTopViewControllerNavigation()
        nav?.setNavigationBarHidden(hidden, animated: true)
    }
}

#Preview{
    Localization.Locale.currentLocale = .en_SE
    return FilesUploadScreen(model: .init(id: "id", title: "title", targetUploadUrl: "url", uploads: []))
}
