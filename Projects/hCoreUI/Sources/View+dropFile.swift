import SwiftUI
import UniformTypeIdentifiers
import hCore

extension View {
    public func fileDrop(isTargetedForDropdown: Binding<Bool>, onFileDrop: @escaping (File) -> Void) -> some View {
        return self.modifier(OnFileDropModifier(isTargetedForDropdown: isTargetedForDropdown, onFileDrop: onFileDrop))
    }
}

struct OnFileDropModifier: ViewModifier {
    @Binding var isTargetedForDropdown: Bool
    let onFileDrop: (File) -> Void

    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .onDrop(of: [UTType.item], isTargeted: $isTargetedForDropdown) { providers in
                    for item in providers {
                        item.getFile { file in
                            onFileDrop(file)
                        }
                    }
                    return true
                }
        } else {
            content
        }

    }
}

extension NSItemProvider {
    public func getFile(onFileResolved: @escaping (File) -> Void) {
        let name = self.suggestedName ?? ""
        if self.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            self.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
                if let url, let data = FileManager.default.contents(atPath: url.relativePath),
                    let image = UIImage(data: data),
                    let data = image.jpegData(compressionQuality: 0.9)
                {
                    let file = File(
                        id: UUID().uuidString,
                        size: Double(data.count),
                        mimeType: .JPEG,
                        name: name,
                        source: .data(data: data)
                    )
                    onFileResolved(file)
                }
            }
        } else if self.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            self.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { videoUrl, error in
                if let videoUrl, let data = FileManager.default.contents(atPath: videoUrl.relativePath),
                    let mimeType = UTType(filenameExtension: videoUrl.pathExtension)?.preferredMIMEType
                {
                    Task {
                        let mimeType = MimeType.findBy(mimeType: mimeType)
                        let file = File(
                            id: UUID().uuidString,
                            size: Double(data.count),
                            mimeType: mimeType,
                            name: name,
                            source: .data(data: data)
                        )
                        onFileResolved(file)
                    }
                }
            }
        } else if self.hasItemConformingToTypeIdentifier(UTType.item.identifier) {
            self.loadFileRepresentation(forTypeIdentifier: UTType.item.identifier) { itemUrl, error in
                if let itemUrl, let data = FileManager.default.contents(atPath: itemUrl.relativePath),
                    let mimeType = UTType(filenameExtension: itemUrl.pathExtension)?.preferredMIMEType
                {
                    Task {
                        let mimeType = MimeType.findBy(mimeType: mimeType)
                        let file = File(
                            id: UUID().uuidString,
                            size: Double(data.count),
                            mimeType: mimeType,
                            name: name,
                            source: .data(data: data)
                        )
                        onFileResolved(file)
                    }
                }
            }
        }
    }
}
