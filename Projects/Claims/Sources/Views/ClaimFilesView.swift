import SwiftUI
import hCore
import hCoreUI

public struct ClaimFilesView: View {
    @ObservedObject private var vm: ClaimFilesViewModel
    @State var showImagePicker = false
    @State var showFilePicker = false
    @State var showCamera = false
    public init(files: [File]) {
        self.vm = .init(files: files, options: [.add, .delete])
    }
    public var body: some View {
        hForm {
            hSection {
                FilesGridView(files: vm.files, options: vm.options) { file in
                    vm.removeFile(id: file.id)
                }
            }
            .padding(.vertical, 16)
            .sectionContainerStyle(.transparent)

        }
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: 8) {
                    hButton.LargeButton(type: .primaryAlt) {
                        showAlert()
                    } content: {
                        hText(L10n.ClaimStatusDetail.addMoreFiles)
                    }

                    hButton.LargeButton(type: .primary) {

                    } content: {
                        hText(L10n.saveAndContinueButtonLabel)
                    }
                }
            }
            .padding(.vertical, 16)
        }
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
    let options: ClaimFilesViewOptions
    init(files: [File], options: ClaimFilesViewOptions) {
        self.files = files
        self.options = options
    }

    @MainActor
    func add(file: File) {
        withAnimation {
            files.append(file)
        }
    }

    @MainActor
    func removeFile(id: String) {
        withAnimation {
            files.removeAll(where: { $0.id == id })
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
    return ClaimFilesView(files: files)
}
