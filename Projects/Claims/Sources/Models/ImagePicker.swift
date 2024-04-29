import Foundation
import Kingfisher
import MobileCoreServices
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers
import hCore

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
                if selectedItem.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    selectedItem.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { imageUrl, error in
                        if let imageUrl,
                            let pathData = FileManager.default.contents(atPath: imageUrl.relativePath),
                            let image = UIImage(data: pathData),
                            let data = image.jpegData(compressionQuality: 0.9),
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
                                    thumbnailData: thumbnailData
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
                                    thumbnailData: nil
                                )
                            files.append(file)
                        }
                        dispatchGroup.leave()
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
                if let file = FilePickerDto(from: url) {
                    files.append(file)
                }
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
