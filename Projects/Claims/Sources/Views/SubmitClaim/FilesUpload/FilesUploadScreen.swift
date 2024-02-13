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
            if vm.hasFiles {
                hForm {
                    hSection {
                        FilesGridView(vm: vm.fileGridViewModel)
                    }
                    .padding(.vertical, 16)
                }
                .hDisableScroll
                .hFormAttachToBottom {
                    hSection {
                        VStack(spacing: 8) {
                            if let error = vm.error {
                                InfoCard(text: error, type: .attention)
                            }
                            hButton.LargeButton(type: .secondary) {
                                showFilePickerAlert()
                            } content: {
                                hText(L10n.ClaimStatusDetail.addMoreFiles)

                            }
                            .disabled(vm.isLoading)
                            ZStack(alignment: .leading) {
                                hButton.LargeButton(type: .primary) {
                                    Task {
                                        await vm.uploadFiles()
                                    }
                                } content: {
                                    hText(L10n.generalContinueButton)
                                }
                                .hButtonIsLoading(vm.isLoading)
                                .disabled(vm.fileGridViewModel.files.isEmpty)
                                if vm.isLoading {
                                    GeometryReader { geo in
                                        Rectangle().fill(hGrayscaleTranslucent.greyScaleTranslucent800.inverted)
                                            .opacity(vm.isLoading ? 1 : 0)
                                            .frame(width: vm.progress * geo.size.width)
                                    }
                                }

                            }
                            .fixedSize(horizontal: false, vertical: true)
                            .clipShape(Squircle.default())
                            .hShadow()

                        }
                    }
                    .padding(.vertical, 16)
                }
                .sectionContainerStyle(.transparent)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            hText(L10n.ClaimStatusDetail.uploadedFiles)
                        }
                    }
                }

            } else {
                hForm {}
                    .hFormTitle(.standard, .title1, L10n.claimsFileUploadTitle)
                    .hFormAttachToBottom {
                        hSection {
                            VStack(spacing: 16) {
                                if let error = vm.error {
                                    InfoCard(text: error, type: .attention)
                                } else {
                                    InfoCard(text: L10n.claimsFileUploadInfo, type: .info)
                                }
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
                    thumbnailData: thumbnailData
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

public class FilesUploadViewModel: ObservableObject {
    @Published var hasFiles: Bool = false
    @Published var isLoading: Bool = false
    @Published var hasFilesToUpload: Bool = false
    @Published var skipPressed = false
    @Published var error: String?
    @Published var progress: Double = 0
    var uploadProgress: Double = 0
    var timerProgress: Double = 0
    let uploadDelayDuration: UInt64 = 1_500_000_000

    private let fileUploadManager = FileUploadManager()
    private let model: FlowClaimFileUploadStepModel
    @Inject var claimFileUploadService: hClaimFileUploadService
    @ObservedObject var fileGridViewModel: FileGridViewModel
    @PresentableStore var store: SubmitClaimStore
    var delayTimer: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    init(model: FlowClaimFileUploadStepModel) {
        self.model = model
        let files = model.uploads.compactMap({
            File(
                id: $0.fileId,
                size: 0,
                mimeType: MimeType.findBy(mimeType: $0.mimeType),
                name: $0.name,
                source: .url(url: URL(string: $0.signedUrl)!)
            )
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
                self?.fileGridViewModel.update(options: isLoading ? [.loading] : [.add, .delete])
            }
            .store(in: &cancellables)

    }

    func addFiles(with files: [FilePickerDto]) {
        if !files.isEmpty {
            let filess = files.compactMap(
                {
                    return $0.asFile()
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
            error = nil
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
                let startDate = Date()
                async let sleepTask: () = Task.sleep(nanoseconds: uploadDelayDuration)
                async let filesUploadTask = claimFileUploadService.upload(
                    endPoint: model.targetUploadUrl,
                    files: filteredFiles
                ) { progress in
                    DispatchQueue.main.async { [weak self] in guard let self = self else { return }
                        self.uploadProgress = progress
                        withAnimation {
                            self.progress = min(self.uploadProgress, self.timerProgress)
                        }
                    }
                }
                delayTimer = Timer.publish(every: 0.2, on: .main, in: .common)
                    .autoconnect()
                    .map({ (output) in
                        return output.timeIntervalSince(startDate)
                    })
                    .eraseToAnyPublisher().subscribe(on: RunLoop.main, options: nil)
                    .sink { _ in
                    } receiveValue: { [weak self] timeInterval in
                        guard let self = self else { return }
                        self.timerProgress = min(1, timeInterval / 2)
                        withAnimation {
                            self.progress = min(self.uploadProgress, self.timerProgress)
                        }
                    }

                let data = try await [sleepTask, filesUploadTask] as [Any]
                delayTimer = nil
                withAnimation {
                    self.progress = 1
                }
                let files = data[1] as! [ClaimFileUploadResponse]
                let uploadedFiles = files.compactMap({ $0.file?.fileId })
                let filesToReplaceLocalFiles =
                    files
                    .compactMap({ $0.file })
                    .compactMap(
                        {
                            File(
                                id: $0.fileId,
                                size: 0,
                                mimeType: MimeType.findBy(mimeType: $0.mimeType),
                                name: $0.name,
                                source: .url(url: URL(string: $0.url)!)
                            )
                        }
                    )
                //added delay so we don't have a flickering
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                    guard let self = self else { return }
                    withAnimation {
                        if let index = self.fileGridViewModel.files.firstIndex(where: {
                            if case .localFile(_, _) = $0.source { return true } else { return false }
                        }) {
                            self.fileGridViewModel.files.replaceSubrange(
                                index...index + filteredFiles.count - 1,
                                with: filesToReplaceLocalFiles
                            )
                        }
                    }
                }
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
