import Foundation
import MobileCoreServices
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers
import hCore

public struct File: Codable, Equatable, Identifiable, Hashable {
    public let id: String
    let size: Double
    let mimeType: MimeType
    let name: String
    let source: FileSource
}

public enum FileSource: Codable, Equatable, Hashable {
    case data(data: Data)
    case url(url: URL)
}

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

struct FileImporterView: UIViewControllerRepresentable {
    let imageSelected: (_ fileSelected: File) -> Void

    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let mimeTypes: [MimeType] = [.AVI, .CSS, .CSV, .DOCX, .GIF, .JPEG, .JPG, .PNG, .PDF, .PPTX, .TXT, .XLSX, .HEIC]
        let uttps = mimeTypes.compactMap({ $0.mime }).compactMap({ UTType(mimeType: $0) })
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

            guard let data = FileManager.default.contents(atPath: url.relativePath) else { return }
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

        public func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
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
