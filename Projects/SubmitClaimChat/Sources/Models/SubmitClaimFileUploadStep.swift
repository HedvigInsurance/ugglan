import Claims
import Combine
import Environment
import SwiftUI
import hCore

final class SubmitClaimFileUploadStep: ClaimIntentStepHandler {
    @Published var selectedOption: String?
    @Published var showFileSourcePicker = false

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
        fileUploadVm = .init(model: .init(uploadUri: model.uploadURI))
        super.init(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
    }

    override func executeStep() async throws -> ClaimIntentType {
        do {
            fileUploadVm.fileGridViewModel.update(options: [.loading])
            let url = Environment.current.claimsApiURL.appendingPathComponent(model.uploadURI)
            let uploadedFiles = await fileUploadVm.uploadFiles(url: url)
            let result = try await service.claimIntentSubmitFile(stepId: id, fildIds: uploadedFiles)

            guard let result else {
                throw ClaimIntentError.invalidResponse
            }
            fileUploadVm.fileGridViewModel.update(options: [])
            return result
        } catch {
            fileUploadVm.fileGridViewModel.update(options: [.add, .delete])
            throw error
        }
    }
}

@MainActor
public class FilesUploadViewModel: ObservableObject {
    private enum TaskResult {
        case sleep
        case response(FileUploadResponseModel)
    }

    @Published var hasFiles: Bool = false
    @Published var isLoading: Bool = false
    @Published var progress: Double = 0
    var uploadProgress: Double = 0
    var timerProgress: Double = 0
    let uploadDelayDuration: Float = 1.5

    @Inject private var uploadClient: hSubmitClaimFileUploadClient
    let fileGridViewModel: FileGridViewModel
    private var delayTimer: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()

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
        fileGridViewModel.$files
            .sink { [weak self] files in
                self?.hasFiles = !files.isEmpty
            }
            .store(in: &cancellables)

        $isLoading.sink { [weak self] state in
            self?.fileGridViewModel.update(options: state ? [.loading] : [.add, .delete])
        }
        .store(in: &cancellables)
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
                        try await Task.sleep(seconds: self.uploadDelayDuration)
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
                        ) { [weak self] progress in
                            DispatchQueue.main.async {
                                guard let self = self else { return }
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
                    return uploadedFileIds
                }

                delayTimer = nil
                self.progress = 1
                isLoading = false
                return fileIds
            } else {
                isLoading = false
                return alreadyUploadedFiles
            }
        } catch let ex {
            delayTimer?.cancel()
            delayTimer = nil
            isLoading = false
        }
        return []
    }
}
