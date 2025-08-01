import Foundation
import Kingfisher
import MobileCoreServices
import PhotosUI
import SwiftUI
import hCore

public struct ImagePicker: UIViewControllerRepresentable {
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

public struct FileImporterView: UIViewControllerRepresentable {
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
