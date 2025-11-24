import Photos
import SwiftUI
import hCore
import hCoreUI

public struct ClaimFilesView: View {
    @ObservedObject private var vm: ClaimFilesViewModel
    @State private var showFileSourcePicker = false
    public init(endPoint: String, files: [File], onSuccess: @escaping (_ data: [ClaimFileUploadResponse]) -> Void) {
        vm = .init(
            endPoint: endPoint,
            files: files,
            options: [.add, .delete],
            onSuccess: onSuccess
        )
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
            } else if let error = vm.error {
                GenericErrorView(
                    description: error,
                    formPosition: .center
                )
                .hStateViewButtonConfig(
                    .init(
                        actionButton: .init(
                            buttonAction: {
                                withAnimation {
                                    vm.error = nil
                                }
                            }),
                        dismissButton: nil
                    )
                )
            } else {
                hForm {
                    hSection {
                        FilesGridView(vm: vm.fileGridViewModel)
                    }
                    .padding(.vertical, .padding16)
                }
                .hFormAttachToBottom {
                    hSection {
                        VStack(spacing: .padding8) {
                            hButton(
                                .large,
                                .secondary,
                                content: .init(title: L10n.ClaimStatusDetail.addMoreFiles),
                                {
                                    showFileSourcePicker = true
                                }
                            )
                            .disabled(vm.isLoading)

                            hButton(
                                .large,
                                .primary,
                                content: .init(title: L10n.fileUploadUploadFiles),
                                {
                                    Task {
                                        await vm.uploadFiles()
                                    }
                                }
                            )
                            .hButtonIsLoading(vm.isLoading)
                            .disabled(vm.fileGridViewModel.files.isEmpty)
                        }
                    }
                    .padding(.vertical, .padding16)
                }
                .sectionContainerStyle(.transparent)
            }
        }
        .showFileSourcePicker($showFileSourcePicker) { [weak vm] files in
            for file in files {
                vm?.add(file: file)
            }
        }
    }

    private var loadingView: some View {
        GeometryReader { proxy in
            hSection {
                VStack(spacing: 20) {
                    Spacer()
                    hText(L10n.fileUploadIsUploading)
                    ProgressView(value: vm.progress)
                        .frame(width: proxy.size.width * 0.53)
                        .progressViewStyle(hProgressViewStyle())
                    Spacer()
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }

    private var successView: some View {
        SuccessScreen(title: L10n.fileUploadFilesAdded)
    }
}

@MainActor
public class ClaimFilesViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var success = false
    @Published var error: String?
    @Published var progress: Double = 0
    private let endPoint: String
    let fileGridViewModel: FileGridViewModel
    private var onSuccess: (_ data: [ClaimFileUploadResponse]) -> Void
    var claimFileUploadService = hClaimFileUploadService()

    init(
        endPoint: String,
        files: [File],
        options: ClaimFilesViewOptions,
        onSuccess: @escaping (_ data: [ClaimFileUploadResponse]) -> Void
    ) {
        self.endPoint = endPoint
        self.onSuccess = onSuccess
        fileGridViewModel = .init(files: files, options: options)
        fileGridViewModel.onDelete = { [weak self] file in
            Task {
                self?.removeFile(id: file.id)
            }
        }
    }

    @MainActor
    func add(file: File) {
        withAnimation {
            self.fileGridViewModel.files.append(file)
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
            let filteredFiles = fileGridViewModel.files.filter {
                switch $0.source {
                case .data, .localFile:
                    return true
                case .url:
                    return false
                }
            }
            if !filteredFiles.isEmpty {
                let files = try await claimFileUploadService.upload(endPoint: endPoint, files: filteredFiles) {
                    [weak self] progress in
                    DispatchQueue.main.async {
                        withAnimation {
                            self?.progress = progress
                        }
                    }
                }
                success = true
                onSuccess(files)
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

    public struct ClaimFilesViewOptions: OptionSet, Sendable {
        public let rawValue: UInt

        public init(
            rawValue: UInt
        ) {
            self.rawValue = rawValue
        }

        public static let add = ClaimFilesViewOptions(rawValue: 1 << 0)
        public static let delete = ClaimFilesViewOptions(rawValue: 1 << 1)
        public static let loading = ClaimFilesViewOptions(rawValue: 1 << 2)
    }

    private func setNavigationBarHidden(_ hidden: Bool) {
        let nav = UIApplication.shared.getTopViewControllerNavigation()
        nav?.setNavigationBarHidden(hidden, animated: true)
    }
}

public struct FileUrlModel: Identifiable, Equatable {
    public var id: String?
    public var type: FileUrlModelType

    public init(
        type: FileUrlModelType
    ) {
        self.type = type
    }

    public enum FileUrlModelType: Codable, Equatable {
        case url(url: URL, name: String, mimeType: MimeType)
        case data(data: Data, name: String, mimeType: MimeType)

        public var asDocumentPreviewModelType: DocumentPreviewModel.DocumentPreviewType {
            switch self {
            case let .url(url, name, mimeType):
                return .url(url: url, name: name, mimeType: mimeType)
            case let .data(data, name, mimeType):
                return .data(data: data, name: name, mimeType: mimeType)
            }
        }
    }
}

#Preview {
    let files: [File] = [
        .init(
            id: "imageId1",
            size: 22332,
            mimeType: .PNG,
            name: "test-image",
            source: .url(
                url: URL(string: "https://filesamples.com/samples/image/png/sample_640%C3%97426.png")!,
                mimeType: .PNG
            )
        ),

        .init(
            id: "imageId2",
            size: 53443,
            mimeType: MimeType.PNG,
            name: "test-image2",
            source: .url(
                url: URL(string: "https://onlinepngtools.com/images/examples-onlinepngtools/giraffe-illustration.png")!,
                mimeType: .PNG
            )
        ),
        .init(
            id: "imageId3",
            size: 52176,
            mimeType: MimeType.PNG,
            name: "test-image3",
            source: .url(
                url: URL(string: "https://cdn.pixabay.com/photo/2017/06/21/15/03/example-2427501_1280.png")!,
                mimeType: .PNG
            )
        ),
        .init(
            id: "imageId4",
            size: 52176,
            mimeType: MimeType.PNG,
            name: "test-image4",
            source: .url(url: URL(string: "https://flif.info/example-images/fish.png")!, mimeType: .PNG)
        ),
        .init(
            id: "imageId5",
            size: 52176,
            mimeType: MimeType.PDF,
            name: "test-pdf long name it is possible to have it is long name .pdf",
            source: .url(
                url: URL(string: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf")!,
                mimeType: .PDF
            )
        ),
    ]
    return ClaimFilesView(endPoint: "", files: files) { _ in
    }
}
