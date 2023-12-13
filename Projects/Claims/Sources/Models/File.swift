import Foundation
import Kingfisher
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
    case localFile(url: URL, thumbnailURL: URL?)
    case url(url: URL)
}

struct ImagePicker: UIViewControllerRepresentable {
    let filesSelected: (_ files: [FilePickerDto]) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .any(of: [.images, .videos])

        config.selectionLimit = 5
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
        var didFinishAdding = false
        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            let selectedItems =
                results
                .map { $0.itemProvider }
            picker.isEditing = false
            guard !didFinishAdding else { return }
            didFinishAdding = true

            let dispatchGroup = DispatchGroup()
            var files = [FilePickerDto]()

            for selectedItem in selectedItems {
                dispatchGroup.enter()  // signal IN
                if selectedItem.canLoadObject(ofClass: UIImage.self) {
                    selectedItem.loadObject(ofClass: UIImage.self) { image, _ in
                        if let image = image as? UIImage, let data = image.jpegData(compressionQuality: 0.9),
                            let thumbnailData = image.jpegData(compressionQuality: 0.1)
                        {
                            let id = UUID().uuidString
                            let file: FilePickerDto =
                                .init(
                                    id: id,
                                    size: Double(data.count),
                                    mimeType: .JPEG,
                                    name: "\(Date().currentTimeMillis).jpeg",
                                    data: data,
                                    thumbnailData: thumbnailData,
                                    extension: "jpeg"
                                )
                            files.append(file)
                        }
                        dispatchGroup.leave()
                    }
                } else if selectedItem.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                    selectedItem.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { videoUrl, error in
                        if let videoUrl, let data = FileManager.default.contents(atPath: videoUrl.relativePath) {
                            let file: FilePickerDto =
                                .init(
                                    id: UUID().uuidString,
                                    size: Double(data.count),
                                    mimeType: .MOV,
                                    name: "\(Date().currentTimeMillis).mov",
                                    data: data,
                                    thumbnailData: nil,
                                    extension: "mov"
                                )
                            files.append(file)
                        }
                        dispatchGroup.leave()
                    }
                }
            }
            dispatchGroup.notify(queue: .main) {
                picker.dismiss(animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    self.parent.filesSelected(files)
                }
            }
        }
    }
}

struct FileImporterView: UIViewControllerRepresentable {
    let imagesSelected: (_ filesSelected: [FilePickerDto]) -> Void

    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item])
        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No update needed
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: FileImporterView
        var didFinishAdding = false

        init(_ parent: FileImporterView) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            var files: [FilePickerDto] = []
            guard !didFinishAdding else { return }
            didFinishAdding = true
            for url in urls {
                _ = url.startAccessingSecurityScopedResource()
                guard let data = FileManager.default.contents(atPath: url.relativePath) else { return }
                let mimeType = MimeType.findBy(mimeType: url.mimeType)
                files.append(
                    .init(
                        id: UUID().uuidString,
                        size: Double(data.count),
                        mimeType: mimeType,
                        name: url.lastPathComponent,
                        data: data,
                        thumbnailData: nil,
                        extension: url.pathExtension
                    )
                )
                url.stopAccessingSecurityScopedResource()
            }
            parent.imagesSelected(files)
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

struct FilePickerDto {
    let id: String
    let size: Double
    let mimeType: MimeType
    let name: String
    let data: Data
    let thumbnailData: Data?
    let `extension`: String
}

extension FilePickerDto {
    func asFile(with dataUrl: URL, and thumbnailUrl: URL) -> File? {
        do {
            try data.write(to: dataUrl)
            var useThumbnailUrl = false
            if let thumbnailData {
                useThumbnailUrl = true
                try thumbnailData.write(to: thumbnailUrl)
            }
            return File(
                id: id,
                size: size,
                mimeType: mimeType,
                name: name,
                source: .localFile(url: dataUrl, thumbnailURL: useThumbnailUrl ? thumbnailUrl : nil)
            )
        } catch let ex {
            return nil
        }
    }
}
