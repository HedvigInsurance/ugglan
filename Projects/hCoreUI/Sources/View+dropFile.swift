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
