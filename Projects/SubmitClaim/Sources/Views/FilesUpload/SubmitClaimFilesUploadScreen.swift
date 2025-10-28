import Claims
import Combine
import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimFilesUploadScreen: View {
    @State var showImagePicker = false
    @State var showFilePicker = false
    @State var showCamera = false
    @StateObject fileprivate var vm: FilesUploadViewModel
    @ObservedObject var claimsNavigationVm: SubmitClaimNavigationViewModel

    init(
        claimsNavigationVm: SubmitClaimNavigationViewModel
    ) {
        self.claimsNavigationVm = claimsNavigationVm
        let model = claimsNavigationVm.fileUploadModel ?? .init(targetUploadUrl: "", uploads: [])
        _vm = StateObject(wrappedValue: FilesUploadViewModel(model: model))
    }

    var body: some View {
        Group {
            if vm.hasFiles {
                hForm {
                    hSection {
                        FilesGridView(vm: vm.fileGridViewModel)
                    }
                    .padding(.vertical, .padding16)
                }
                .hFormAlwaysAttachToBottom {
                    hSection {
                        VStack(spacing: .padding8) {
                            if let error = vm.error {
                                InfoCard(text: error, type: .attention)
                            }
                            hButton(
                                .large,
                                .secondary,
                                content: .init(title: L10n.ClaimStatusDetail.addMoreFiles),
                                {
                                    showFilePickerAlert()
                                }
                            )
                            .disabled(vm.isLoading)
                            ZStack(alignment: .leading) {
                                hContinueButton {
                                    Task {
                                        let step = await vm.uploadFiles(
                                            newClaimContext: claimsNavigationVm.currentClaimContext ?? ""
                                        )

                                        if let step {
                                            claimsNavigationVm.navigate(data: step)
                                        }
                                    }
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
                            .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
                            .hShadow()
                        }
                    }
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
                hForm {
                    hSection {
                        infoView
                    }
                }
                .hFormContentPosition(.bottom)
                .hFormTitle(
                    title: .init(
                        .small,
                        .heading2,
                        L10n.claimsFileUploadTitle,
                        alignment: .leading
                    )
                )
                .hFormAlwaysAttachToBottom {
                    hSection {
                        VStack(spacing: .padding8) {
                            hButton(
                                .large,
                                .primary,
                                content: .init(title: L10n.ClaimStatusDetail.addFiles),
                                {
                                    showFilePickerAlert()
                                }
                            )
                            .hButtonIsLoading(vm.isLoading && !vm.skipPressed)
                            .disabled(vm.isLoading && vm.skipPressed)
                            hButton(
                                .large,
                                .ghost,
                                content: .init(title: L10n.NavBar.skip),
                                {
                                    skip()
                                }
                            )
                            .disabled(vm.isLoading && !vm.skipPressed)
                            .hButtonIsLoading(vm.isLoading && vm.skipPressed)
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
                guard let data = image.jpegData(compressionQuality: 0.9)
                else { return }
                let file: File = .init(
                    id: UUID().uuidString,
                    size: Double(data.count),
                    mimeType: .JPEG,
                    name: "image_\(Date()).jpeg",
                    source: .data(data: data)
                )
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    vm.addFiles(with: [file])
                }
            }
            .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private var infoView: some View {
        if let error = vm.error {
            InfoCard(text: error, type: .attention)
        } else {
            InfoCard(text: L10n.claimsFileUploadInfo, type: .info)
                .accessibilitySortPriority(2)
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

    func skip() {
        Task {
            let step = await vm.submitFileUpload(
                ids: [],
                newClaimContext: claimsNavigationVm.currentClaimContext ?? ""
            )

            if let step {
                claimsNavigationVm.navigate(data: step)
            }
        }
    }
}

@MainActor
public class FilesUploadViewModel: ObservableObject {
    @Published var hasFiles: Bool = false
    @Published var isLoading: Bool = false
    @Published var skipPressed = false
    @Published var error: String?
    @Published var progress: Double = 0
    var uploadProgress: Double = 0
    var timerProgress: Double = 0
    let uploadDelayDuration: UInt64 = 1_500_000_000

    private let model: FlowClaimFileUploadStepModel
    var claimFileUploadService = hClaimFileUploadService()
    @ObservedObject var fileGridViewModel: FileGridViewModel
    private var delayTimer: AnyCancellable?
    private var initObservers = [AnyCancellable]()
    private let submitClaimService = SubmitClaimService()

    public init(model: FlowClaimFileUploadStepModel) {
        self.model = model
        let files = model.uploads.compactMap {
            File(
                id: $0.fileId,
                size: 0,
                mimeType: MimeType.findBy(mimeType: $0.mimeType),
                name: $0.name,
                source: .url(url: URL(string: $0.signedUrl)!, mimeType: MimeType.findBy(mimeType: $0.mimeType))
            )
        }
        fileGridViewModel = .init(
            files: files,
            options: [.delete, .add]
        )

        fileGridViewModel.onDelete = { [weak self] file in
            withAnimation {
                self?.fileGridViewModel.files.removeAll(where: { $0.id == file.id })
            }
        }
        fileGridViewModel.$files
            .sink { [weak self] files in
                withAnimation {
                    self?.hasFiles = !files.isEmpty
                }
            }
            .store(in: &initObservers)

        $isLoading.sink { [weak self] state in
            self?.fileGridViewModel.update(options: state ? [.loading] : [.add, .delete])
        }
        .store(in: &initObservers)
    }

    func addFiles(with files: [File]) {
        if !files.isEmpty {
            fileGridViewModel.files.append(contentsOf: files)
        }
    }

    func uploadFiles(newClaimContext: String) async -> SubmitClaimStepResponse? {
        withAnimation {
            error = nil
            isLoading = true
        }
        do {
            let alreadyUploadedFiles = fileGridViewModel.files
                .filter {
                    switch $0.source {
                    case .url:
                        return true
                    case .data, .localFile:
                        return false
                    }
                }
                .compactMap(\.id)
            let filteredFiles = fileGridViewModel.files.filter {
                switch $0.source {
                case .data, .localFile:
                    return true
                case .url:
                    return false
                }
            }
            if !filteredFiles.isEmpty {
                setNavigationBarHidden(true)
                let startDate = Date()
                async let sleepTask: () = Task.sleep(nanoseconds: uploadDelayDuration)
                async let filesUploadTask = claimFileUploadService.upload(
                    endPoint: model.targetUploadUrl,
                    files: filteredFiles
                ) { progress in
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.uploadProgress = progress
                        withAnimation {
                            self.progress = min(self.uploadProgress, self.timerProgress)
                        }
                    }
                }
                delayTimer = Timer.publish(every: 0.2, on: .main, in: .common)
                    .autoconnect()
                    .map { output in
                        output.timeIntervalSince(startDate)
                    }
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
                let uploadedFiles = files.compactMap { $0.file?.fileId }
                let filesToReplaceLocalFiles =
                    files
                    .compactMap(\.file)
                    .compactMap(
                        {
                            File(
                                id: $0.fileId,
                                size: 0,
                                mimeType: MimeType.findBy(mimeType: $0.mimeType),
                                name: $0.name,
                                source: .url(
                                    url: URL(string: $0.url)!,
                                    mimeType: MimeType.findBy(mimeType: $0.mimeType)
                                )
                            )
                        }
                    )
                // added delay so we don't have a flickering

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                    guard let self = self else { return }
                    for file in filesToReplaceLocalFiles {
                        if let index = self.fileGridViewModel.files.firstIndex(where: {
                            if case .localFile = $0.source { return true } else { return false }
                        }) {
                            self.fileGridViewModel.files[index] = file
                        }
                    }
                }
                return await submitFileUpload(
                    ids: alreadyUploadedFiles + uploadedFiles,
                    newClaimContext: newClaimContext
                )
            } else {
                return await submitFileUpload(ids: alreadyUploadedFiles, newClaimContext: newClaimContext)
            }
        } catch let ex {
            withAnimation {
                error = ex.localizedDescription
                setNavigationBarHidden(false)
                isLoading = false
            }
        }
        return nil
    }

    func submitFileUpload(ids: [String], newClaimContext: String) async -> SubmitClaimStepResponse? {
        do {
            let data = try await submitClaimService.submitFileUpload(ids: ids, context: newClaimContext, model: model)
            setNavigationBarHidden(false)
            skipPressed = false
            isLoading = false
            return data
        } catch let exception {
            withAnimation {
                self.setNavigationBarHidden(false)
                self.isLoading = false
                self.skipPressed = false
                self.error = exception.localizedDescription
            }
        }
        return nil
    }

    private func setNavigationBarHidden(_ hidden: Bool) {
        let nav = UIApplication.shared.getTopViewControllerNavigation()
        nav?.setNavigationBarHidden(hidden, animated: true)
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)
    return SubmitClaimFilesUploadScreen(claimsNavigationVm: .init())
}
