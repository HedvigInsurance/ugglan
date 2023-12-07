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
            if let error = vm.error {
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

    func showAlert() {
        // 1. Create Alert, ActionSheet type
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )

        // 2. Creeate Actions
        alert.addAction(
            UIAlertAction(
                title: "Photo Library",
                style: .default,
                handler: { _ in
                    showImagePicker = true
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: "Take Photo",
                style: .default,
                handler: { _ in
                    showCamera = true
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: "Choose Files",
                style: .default,
                handler: {
                    _
                    in showFilePicker = true
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: { _ in print("Cancel tap") }
            )
        )

        // 3. Show
        UIApplication.shared.getTopViewController()?.present(alert, animated: true, completion: nil)
    }
}

class ClaimFilesViewModel: ObservableObject {
    @Published var files: [File] = []
    @Published var isLoading = false
    @Published var error: String?
    private let endPoint: String
    let options: ClaimFilesViewOptions

    @Inject var claimFileUploadService: hClaimFileUploadService
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
        }
        do {
            let filteredFiles = files.filter({ if case .data = $0.source { return true } else { return false } })
            if !filteredFiles.isEmpty {
                _ = try await claimFileUploadService.upload(endPoint: endPoint, files: filteredFiles) { progress in }
            }
        } catch let ex {
            withAnimation {
                error = ex.localizedDescription
            }
        }
        withAnimation {
            isLoading = false
        }

    }

    struct ClaimFilesViewOptions: OptionSet {
        let rawValue: UInt

        static let add = ClaimFilesViewOptions(rawValue: 1 << 0)
        static let delete = ClaimFilesViewOptions(rawValue: 1 << 1)
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
