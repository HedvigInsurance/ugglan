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
                                    //                                    await vm.uploadFiles()
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
                                    hButton.LargeButton(type: .ghost) {

                                    } content: {
                                        hText(L10n.NavBar.skip)
                                    }
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
    private let fileUploadManager = FileUploadManager()
    private let model: FlowClaimFileUploadStepModel
    @ObservedObject var fileGridViewModel: FileGridViewModel
    @PresentableStore var store: SubmitClaimStore
    private var cancellables = Set<AnyCancellable>()

    init(model: FlowClaimFileUploadStepModel) {
        self.model = model
        fileGridViewModel = .init(
            files: [],
            options: [.delete, .add]
        )
        fileUploadManager.resetuploadFilesPath()
        fileGridViewModel.$files
            .receive(on: RunLoop.main)
            .sink { _ in

            } receiveValue: { [weak self] files in
                self?.hasFiles = !files.isEmpty
            }
            .store(in: &cancellables)
        fileGridViewModel.onDelete = { [weak self] file in
            withAnimation {
                self?.fileGridViewModel.files.removeAll(where: { $0.id == file.id })
            }
        }

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
            //            store.send(.navigationAction(action: .openFilesFor(endPoint: model.targetUploadUrl, files: filess)))

        }
    }

}

#Preview{
    Localization.Locale.currentLocale = .en_SE
    return FilesUploadScreen(model: .init(id: "id", title: "title", targetUploadUrl: "url", uploads: []))
}
