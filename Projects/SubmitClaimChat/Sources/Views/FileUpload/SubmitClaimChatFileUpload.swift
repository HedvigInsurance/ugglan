import Claims
import Combine
import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimChatFileUpload: View {
    let step: SubmitChatStepModel
    let model: ClaimIntentStepContentFileUpload
    @ObservedObject var fileUploadVm: FilesUploadViewModel
    @EnvironmentObject var viewModel: SubmitClaimChatViewModel
    @State var showImagePicker = false
    @State var showFilePicker = false
    @State var showCamera = false

    init(
        step: SubmitChatStepModel,
        model: ClaimIntentStepContentFileUpload,
        fileUploadVm: FilesUploadViewModel
    ) {
        self.step = step
        self.model = model
        self.fileUploadVm = fileUploadVm
        fileUploadVm.model.uploadUri = model.uploadURI
    }

    var body: some View {
        if step.sender == .member {
            showFilesView
        } else {
            hText(step.step.text)
        }
    }

    private var showFilesView: some View {
        Group {
            if fileUploadVm.hasFiles {
                VStack {
                    FilesGridView(vm: fileUploadVm.fileGridViewModel)
                    HStack(spacing: .padding8) {
                        hButton(
                            .small,
                            .secondary,
                            content: .init(title: L10n.ClaimStatusDetail.addMoreFiles),
                            {
                                showFilePickerAlert()
                            }
                        )
                        .disabled(fileUploadVm.isLoading || !step.isEnabled)
                        ZStack(alignment: .leading) {
                            hButton(.small, .primary, content: .init(title: L10n.generalContinueButton)) {
                                Task {
                                    let fileIds = await fileUploadVm.uploadFiles()
                                    await viewModel.submitFile(fileIds: fileIds)
                                }
                            }
                            .hButtonIsLoading(fileUploadVm.isLoading)
                            .disabled(fileUploadVm.fileGridViewModel.files.isEmpty || !step.isEnabled)
                            if fileUploadVm.isLoading {
                                GeometryReader { geo in
                                    Rectangle().fill(hGrayscaleTranslucent.greyScaleTranslucent800.inverted)
                                        .opacity(fileUploadVm.isLoading ? 1 : 0)
                                        .frame(width: fileUploadVm.progress * geo.size.width)
                                }
                            }
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
                        .hShadow()
                    }
                }
            } else {
                hSection {
                    hButton(
                        .large,
                        .primary,
                        content: .init(title: L10n.ClaimStatusDetail.addFiles),
                        {
                            showFilePickerAlert()
                        }
                    )
                    .hButtonIsLoading(fileUploadVm.isLoading)
                    .disabled(fileUploadVm.isLoading)
                }
                .sectionContainerStyle(.transparent)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker { images in
                fileUploadVm.addFiles(with: images)
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showFilePicker) {
            FileImporterView { files in
                fileUploadVm.addFiles(with: files)
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
                    fileUploadVm.addFiles(with: [file])
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

public struct FileUploadModel: Sendable {
    var uploadUri: String? = nil
    @State var uploads: [FileModel] = []
}

public struct FileModel: Codable, Equatable, Hashable, Sendable {
    let fileId: String
    let signedUrl: String
    let mimeType: String
    let name: String

    public init(fileId: String, signedUrl: String, mimeType: String, name: String) {
        self.fileId = fileId
        self.signedUrl = signedUrl
        self.mimeType = mimeType
        self.name = name
    }
}

@MainActor
public class FilesUploadViewModel: ObservableObject {
    @Published var hasFiles: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var progress: Double = 0
    var uploadProgress: Double = 0
    var timerProgress: Double = 0
    let uploadDelayDuration: Float = 1.5

    var model: FileUploadModel
    var claimFileUploadService = hClaimFileUploadService()
    @ObservedObject var fileGridViewModel: FileGridViewModel
    private var delayTimer: AnyCancellable?
    private var initObservers = [AnyCancellable]()

    public init(
        model: FileUploadModel
    ) {
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

    func uploadFiles() async -> [String] {
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
                let startDate = Date()

                async let sleepTask: () = Task.sleep(seconds: uploadDelayDuration)
                async let filesUploadTask = claimFileUploadService.uploadClaimsChatFile(
                    endPoint: model.uploadUri ?? "",
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
                let fileIds = data[1] as! [String]
                isLoading = false
                return fileIds
            } else {
                isLoading = false
                return alreadyUploadedFiles
            }
        } catch let ex {
            withAnimation {
                error = ex.localizedDescription
                isLoading = false
            }
        }
        return []
    }
}
