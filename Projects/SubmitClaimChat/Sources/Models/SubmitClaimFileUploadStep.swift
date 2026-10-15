import Claims
import Combine
import Environment
import Observation
import SwiftUI
import hCore

final class SubmitClaimFileUploadStep: ClaimIntentStepHandler {
    @ObservationIgnored private var _selectedOption: String?
    var selectedOption: String? {
        get {
            observationRegistrar.access(self, keyPath: \SubmitClaimFileUploadStep.selectedOption)
            return _selectedOption
        }
        set {
            observationRegistrar.withMutation(of: self, keyPath: \SubmitClaimFileUploadStep.selectedOption) {
                _selectedOption = newValue
            }
        }
    }

    @ObservationIgnored private var _showFileSourcePicker = false
    var showFileSourcePicker: Bool {
        get {
            observationRegistrar.access(self, keyPath: \SubmitClaimFileUploadStep.showFileSourcePicker)
            return _showFileSourcePicker
        }
        set {
            observationRegistrar.withMutation(of: self, keyPath: \SubmitClaimFileUploadStep.showFileSourcePicker) {
                _showFileSourcePicker = newValue
            }
        }
    }

    let model: ClaimIntentStepContentFileUpload
    let fileUploadVm: FilesUploadViewModel

    required init(
        claimIntent: ClaimIntent,
        service: ClaimIntentService,
        mainHandler: @escaping (SubmitClaimEvent) -> Void
    ) {
        guard case .fileUpload(let model) = claimIntent.currentStep.content else {
            fatalError("TextStepHandler initialized with non-single select content")
        }
        self.model = model
        let resumedUploads: [FileModel] = model.currentFiles.map { file in
            FileModel(
                fileId: file.id,
                signedUrl: file.url.absoluteString,
                mimeType: file.contentType.mime,
                name: file.fileName
            )
        }
        fileUploadVm = .init(model: .init(uploadUri: model.uploadURI, uploads: resumedUploads))
        super.init(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
    }

    override func executeStep() async throws -> ClaimIntentType {
        do {
            let url = Environment.current.claimsApiURL.appendingPathComponent(model.uploadURI)
            let uploadedFiles = await fileUploadVm.uploadFiles(url: url)
            let result = try await service.claimIntentSubmitFile(stepId: id, fileIds: uploadedFiles)

            guard let result else {
                throw ClaimIntentError.invalidResponse
            }
            return result
        } catch {
            throw error
        }
    }

    override func accessibilityEditHint() -> String {
        if state.isSkipped {
            return L10n.claimChatSkippedStep
        }
        let fileNames = fileUploadVm.fileGridViewModel.files.map { $0.name }
        return .accessibilitySubmittedValues(count: fileNames.count, values: fileNames)
    }
}

@MainActor
@Observable
public class FilesUploadViewModel {
    private enum TaskResult {
        case sleep
        case response(FileUploadResponseModel)
    }

    var hasFiles: Bool = false
    var isLoading: Bool = false
    var progress: Double = 0
    @ObservationIgnored var uploadProgress: Double = 0
    @ObservationIgnored var timerProgress: Double = 0
    let uploadDelayDuration: TimeInterval = 1.5

    @ObservationIgnored @Inject private var uploadClient: hSubmitClaimFileUploadClient
    let fileGridViewModel: FileGridViewModel
    @ObservationIgnored private var delayTimer: AnyCancellable?
    @ObservationIgnored private var filesWatcher: ObservationWatcher?
    @ObservationIgnored private var loadingWatcher: ObservationWatcher?

    public init(
        model: FileUploadModel
    ) {
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
            self?.fileGridViewModel.files.removeAll(where: { $0.id == file.id })
        }
        let fileGridViewModel = fileGridViewModel
        filesWatcher = ObservationWatcher {
            _ = fileGridViewModel.files
        } onChange: { [weak self] in
            self?.hasFiles = !fileGridViewModel.files.isEmpty
        }

        loadingWatcher = ObservationWatcher { [weak self] in
            _ = self?.isLoading
        } onChange: { [weak self] in
            guard let self else { return }
            let state = self.isLoading
            self.fileGridViewModel.update(options: state ? [.loading] : [.add, .delete])
        }
    }

    func addFiles(with files: [File]) {
        if !files.isEmpty {
            fileGridViewModel.files.append(contentsOf: files)
        }
    }

    fileprivate func uploadFiles(url: URL) async -> [String] {
        isLoading = true
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
                        self.progress = min(self.uploadProgress, self.timerProgress)
                    }

                let fileIds = try await withThrowingTaskGroup(of: TaskResult.self) { group in
                    group.addTask {
                        try await Task.sleep(for: .seconds(self.uploadDelayDuration))
                        return .sleep
                    }

                    group.addTask {
                        let multipart = MultipartFormDataRequest(url: url)
                        for file in filteredFiles {
                            var data: Data?
                            switch file.source {
                            case let .data(fileData):
                                data = fileData
                            case .url:
                                break
                            case let .localFile(results):
                                if let results {
                                    data = try? await results.itemProvider.getData().data
                                }
                            }
                            guard let data = data else { throw NetworkError.badRequest(message: nil) }
                            multipart.addDataField(
                                fieldName: "files",
                                fileName: file.name,
                                data: data,
                                mimeType: file.mimeType.mime
                            )
                        }
                        let response: FileUploadResponseModel = try await self.uploadClient.upload(
                            url: url,
                            multipart: multipart
                        ) { progress in
                            DispatchQueue.main.async {
                                self.uploadProgress = progress
                                self.progress = min(self.uploadProgress, self.timerProgress)
                            }
                        }
                        return .response(response)
                    }

                    var uploadedFileIds: [String] = []
                    for try await result in group {
                        if case .response(let model) = result {
                            uploadedFileIds = model.fileIds
                        }
                    }
                    return uploadedFileIds + alreadyUploadedFiles
                }

                delayTimer = nil
                self.progress = 1
                isLoading = false
                fileGridViewModel.options.remove(.delete)
                return fileIds
            } else {
                isLoading = false
                fileGridViewModel.options.remove(.delete)
                return alreadyUploadedFiles
            }
        } catch {
            delayTimer?.cancel()
            delayTimer = nil
            isLoading = false
        }
        return []
    }
}
