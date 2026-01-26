import Photos
import PhotosUI
import SwiftUI
import hCore

public typealias SelectedFiles = ((_ files: [File]) -> Void)
extension View {
    public func showFileSourcePicker(_ show: Binding<Bool>, selecedFiles: @escaping SelectedFiles) -> some View {
        self.modifier(FileSourcePickerView(presentFileSourcePicker: show, selectedFiles: selecedFiles))
    }
}

private struct FileSourcePickerView: ViewModifier {
    @Binding private var presentFileSourcePicker: Bool
    @State private var showCamera: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var showFilePicker: Bool = false
    let selectedFiles: SelectedFiles
    init(presentFileSourcePicker: Binding<Bool>, selectedFiles: @escaping SelectedFiles) {
        self._presentFileSourcePicker = presentFileSourcePicker
        self.selectedFiles = selectedFiles
    }

    public func body(content: Content) -> some View {
        content
            .confirmationDialog("", isPresented: $presentFileSourcePicker, titleVisibility: .hidden) {
                Button(L10n.fileUploadPhotoLibrary) {
                    Task {
                        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
                        switch status {
                        case .notDetermined, .restricted, .denied:
                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                return
                            }
                            Dependencies.urlOpener.open(settingsUrl)
                        case .authorized, .limited:
                            showImagePicker = true
                        @unknown default:
                            showImagePicker = true
                        }
                    }
                }
                Button(L10n.fileUploadTakePhoto) {
                    showCamera = true
                }
                Button(L10n.fileUploadChooseFiles) {
                    showFilePicker = true
                }

                Button(L10n.generalCancelButton, role: .cancel) {}
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker { images in
                    selectedFiles(images)
                }
                .ignoresSafeArea()
            }
            .sheet(isPresented: $showFilePicker) {
                FileImporterView { files in
                    selectedFiles(files)
                }
                .ignoresSafeArea()
            }
            .sheet(isPresented: $showCamera) {
                CameraPickerView { image in
                    guard let data = image.jpegData(compressionQuality: 0.9)
                    else { return }
                    let file = File(
                        id: UUID().uuidString,
                        size: Double(data.count),
                        mimeType: .JPEG,
                        name: "image_\(Date()).jpeg",
                        source: .data(data: data)
                    )
                    selectedFiles([file])
                }
                .ignoresSafeArea()
            }
    }
}

private struct ImagePicker: UIViewControllerRepresentable {
    let filesSelected: (_ files: [File]) -> Void

    public init(
        filesSelected: @escaping (_: [File]) -> Void
    ) {
        self.filesSelected = filesSelected
    }

    public func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .any(of: [.images, .videos])

        config.selectionLimit = 5
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_: PHPickerViewController, context _: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        var didFinishAdding = false
        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.isEditing = false
            guard !didFinishAdding else { return }
            didFinishAdding = true
            var files = [File]()

            for selectedItem in results {
                if selectedItem.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    let id = UUID().uuidString
                    let file: File =
                        .init(
                            id: id,
                            size: 0,
                            mimeType: .JPEG,
                            name: "\(Date().displayDateWithTimeStamp).jpeg",
                            source: .localFile(results: selectedItem)
                        )
                    files.append(file)
                } else if selectedItem.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                    let id = UUID().uuidString
                    let file: File =
                        .init(
                            id: id,
                            size: 0,
                            mimeType: .MOV,
                            name: "\(Date().displayDateWithTimeStamp).mov",
                            source: .localFile(results: selectedItem)
                        )
                    files.append(file)
                }
            }
            picker.dismiss(animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.parent.filesSelected(files)
            }
        }
    }
}

private struct FileImporterView: UIViewControllerRepresentable {
    let imagesSelected: (_ filesSelected: [File]) -> Void
    @Environment(\.presentationMode) var presentationMode

    public init(
        imagesSelected: @escaping (_: [File]) -> Void
    ) {
        self.imagesSelected = imagesSelected
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item])
        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_: UIDocumentPickerViewController, context _: Context) {
        // No update needed
    }

    public class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: FileImporterView
        var didFinishAdding = false

        init(_ parent: FileImporterView) {
            self.parent = parent
        }

        public func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            var files: [File] = []
            guard !didFinishAdding else { return }
            didFinishAdding = true
            for url in urls {
                _ = url.startAccessingSecurityScopedResource()
                if let file = File(from: url) {
                    files.append(file)
                }

                url.stopAccessingSecurityScopedResource()
            }
            parent.imagesSelected(files)
            parent.presentationMode.wrappedValue.dismiss()
        }

        public func documentPickerWasCancelled(_: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

private struct CameraPickerView: UIViewControllerRepresentable {
    private var sourceType: UIImagePickerController.SourceType = .camera
    private let onImagePicked: (UIImage) -> Void

    @Environment(\.presentationMode) private var presentationMode

    public init(onImagePicked: @escaping (UIImage) -> Void) {
        self.onImagePicked = onImagePicked
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_: UIImagePickerController, context _: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(
            onDismiss: { presentationMode.wrappedValue.dismiss() },
            onImagePicked: onImagePicked
        )
    }

    public final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        private let onDismiss: () -> Void
        private let onImagePicked: (UIImage) -> Void

        init(onDismiss: @escaping () -> Void, onImagePicked: @escaping (UIImage) -> Void) {
            self.onDismiss = onDismiss
            self.onImagePicked = onImagePicked
        }

        public func imagePickerController(
            _: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                onImagePicked(image)
            }
            onDismiss()
        }

        public func imagePickerControllerDidCancel(_: UIImagePickerController) {
            onDismiss()
        }
    }
}
