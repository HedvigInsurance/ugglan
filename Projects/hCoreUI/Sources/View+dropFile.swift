import SwiftUI
import UniformTypeIdentifiers
import hCore

extension View {
    func fileDrop(isTargetedForDropdown: Binding<Bool>) -> some View {
        return self.modifier(OnFileDropModifier(isTargetedForDropdown: isTargetedForDropdown))
    }
}

struct OnFileDropModifier: ViewModifier {
    @Binding var isTargetedForDropdown: Bool

    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .onDrop(of: [UTType.item], isTargeted: $isTargetedForDropdown) { providers in
                    for item in providers {
                        let name = item.suggestedName ?? ""
                        if item.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                            _ = item.loadDataRepresentation(for: .image) { data, error in
                                if error == nil, let data {
                                    let image = UIImage(data: data)
                                    let data = image!.jpegData(compressionQuality: 0.9)!
                                    Task {
                                        let file = File(
                                            id: UUID().uuidString,
                                            size: Double(data.count),
                                            mimeType: .JPEG,
                                            name: name,
                                            source: .data(data: data)
                                        )
                                        //                                    let message = Message(type: .file(file: file))
                                        //                                    await vm.send(message: message)
                                    }
                                }
                            }
                        } else if item.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                            item.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { videoUrl, error in
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
                                        //                                    let message = Message(type: .file(file: file))
                                        //                                    await vm.send(message: message)
                                    }
                                }
                            }
                        } else if item.hasItemConformingToTypeIdentifier(UTType.item.identifier) {
                            item.loadFileRepresentation(forTypeIdentifier: UTType.item.identifier) { itemUrl, error in
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
                                        //                                    let message = Message(type: .file(file: file))
                                        //                                    await vm.send(message: message)
                                    }
                                }
                            }
                        }
                    }
                    return true
                }
        } else {
            content
        }

    }
}
