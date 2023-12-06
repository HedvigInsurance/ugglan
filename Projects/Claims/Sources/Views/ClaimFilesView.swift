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
            
        }.hFormAttachToBottom {
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
            }.padding(.vertical, 16)
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
                guard let data = image.jpegData(compressionQuality: 1) else {return}
                vm.add(file: .init(
                    id: UUID().uuidString,
                    size: Double(data.count),
                    mimeType: .JPEG,
                    name: "image_\(Date())",
                    source: .data(data: data))
                )
            }
        }
    }
    
    func showAlert() {
        // 1. Create Alert, ActionSheet type
        let alert = UIAlertController(title: nil,
                                      message: nil,
                                      preferredStyle: .actionSheet)

        // 2. Creeate Actions
        alert.addAction(UIAlertAction(title: "Photo Library",
                                      style: .default,
                                      handler: { _ in
            showImagePicker = true
        }))
        alert.addAction(UIAlertAction(title: "Take Photo",
                                      style: .default,
                                      handler: { _ in
            showCamera = true
        }))
        alert.addAction(UIAlertAction(title: "Choose Files",
                                      style: .default,
                                      handler: { _
            in showFilePicker = true
        }))
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel,
                                      handler: { _ in print("Cancel tap") }))

        // 3. Show
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
            files.removeAll(where: {$0.id == id})
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
            source: .url(url: URL(string: "https://onlinepngtools.com/images/examples-onlinepngtools/giraffe-illustration.png")!)
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



import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    let fileSelected: (_ file: File?) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage, let data = image.jpegData(compressionQuality: 1) {
                        self.parent.fileSelected(
                            .init(
                                id: UUID().uuidString,
                                size: Double(data.count),
                                mimeType: .JPEG,
                                name: "image.name",
                                source: .data(data: data)
                            )
                        )
                    }
                }
            }
        }
    }
}

import MobileCoreServices
import UniformTypeIdentifiers

struct FileImporterView: UIViewControllerRepresentable {
    let imageSelected: (_ fileSelected: File) -> Void

    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let mimeTypes:[MimeType] = [.AVI, .CSS, .CSV, .DOCX, .GIF, .JPEG, .JPG, .PNG, .PDF, .PPTX, .TXT, .XLSX]
        let uttps = mimeTypes.compactMap({$0.mime}).compactMap({UTType(mimeType: $0)})
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: uttps)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No update needed
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: FileImporterView

        init(_ parent: FileImporterView) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first, url.startAccessingSecurityScopedResource() else {
                 print("Error getting access")
                 return
            }

            guard let data = FileManager.default.contents(atPath: url.relativePath)  else { return }
            let mimeType = MimeType.findBy(mimeType: url.mimeType)
            parent.imageSelected(
                .init(
                    id: UUID().uuidString,
                    size: Double(data.count),
                    mimeType: mimeType,
                    name: url.lastPathComponent,
                    source: .data(data: data)
                )
            )
            url.stopAccessingSecurityScopedResource()
            parent.presentationMode.wrappedValue.dismiss()
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct CameraPickerView: UIViewControllerRepresentable {
    
    private var sourceType: UIImagePickerController.SourceType = .camera
    private let onImagePicked: (UIImage) -> Void
    
    @Environment(\.presentationMode) private var presentationMode
    
    public init(onImagePicked: @escaping (UIImage) -> Void) {
        self.onImagePicked = onImagePicked
    }
    
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = self.sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(
            onDismiss: { self.presentationMode.wrappedValue.dismiss() },
            onImagePicked: self.onImagePicked
        )
    }
    
    final public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        private let onDismiss: () -> Void
        private let onImagePicked: (UIImage) -> Void
        
        init(onDismiss: @escaping () -> Void, onImagePicked: @escaping (UIImage) -> Void) {
            self.onDismiss = onDismiss
            self.onImagePicked = onImagePicked
        }
        
        public func imagePickerController(_ picker: UIImagePickerController,
                                          didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                self.onImagePicked(image)
            }
            self.onDismiss()
        }
        public func imagePickerControllerDidCancel(_: UIImagePickerController) {
            self.onDismiss()
        }
    }
}
