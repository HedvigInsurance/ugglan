import Combine
import Photos
import PhotosUI
import SwiftUI
@preconcurrency import UIKit
import hCore
import hCoreUI

struct ChatInputView: View {
    @StateObject var vm: ChatInputViewModel
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(hBorderColor.primary).frame(height: 1)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    addFilesButton
                        .frame(maxHeight: .infinity)
                    inputField
                        .frame(maxHeight: .infinity)
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding([.horizontal, .top], .padding8)
                .animation(.easeInOut(duration: 0.2), value: vm.inputText)

                if vm.showBottomMenu {
                    bottomMenu
                }
            }
        }
        .releasesKeyboardRetentionOnDeinit()
    }

    private var addFilesButton: some View {
        Button {
            withAnimation {
                vm.showBottomMenu.toggle()
            }
        } label: {
            hCoreUIAssets.plus.view
                .resizable()
                .frame(width: 24, height: 24)
                .frame(maxHeight: .infinity)
                .rotationEffect(vm.showBottomMenu ? .degrees(45) : .zero)
                .foregroundColor(hTextColor.Opaque.primary)
                .padding(.horizontal, .padding10)
        }
        .background(hSurfaceColor.Opaque.primary)
        .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusM))
        .accessibilityValue(
            vm.showBottomMenu ? L10n.generalCloseButton : L10n.ClaimStatus.UploadedFiles.uploadButton
        )
    }

    private var inputField: some View {
        HStack(alignment: .bottom, spacing: 0) {
            TextField(L10n.chatInputPlaceholder, text: $vm.inputText, axis: .vertical)
                .modifier(hFontModifier(style: .body1))
                .foregroundColor(hTextColor.Opaque.primary)
                .tint(hTextColor.Opaque.primary)
                .lineLimit(1...5)
                .focused($isInputFocused)
                .padding(.horizontal, .padding8)
                .frame(minHeight: 40)
                .onChange(of: isInputFocused) { newValue in
                    vm.keyboardIsShown = newValue
                }
                .onChange(of: vm.keyboardIsShown) { newValue in
                    if isInputFocused != newValue {
                        isInputFocused = newValue
                    }
                }

            Button {
                vm.sendTextMessage()
            } label: {
                hCoreUIAssets.sendChat.view
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.padding8)
            }
            .frame(width: 44, height: 44)
            .accessibilityValue(L10n.voiceoverChatSendMessageButton)
        }
        .padding(.leading, .padding4)
        .background(hSurfaceColor.Opaque.primary)
        .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusM))
    }

    private var bottomMenu: some View {
        HStack(spacing: .padding8) {
            VStack(spacing: .padding8) {
                bottomMenuItem(
                    with: hCoreUIAssets.camera.view,
                    action: {
                        vm.openCamera()
                    }
                )
                .accessibilityValue(L10n.voiceoverChatCamera)
                bottomMenuItem(
                    with: hCoreUIAssets.image.view,
                    action: {
                        vm.openImagePicker()
                    }
                )
                .accessibilityValue(L10n.voiceoverChatCameraroll)
                bottomMenuItem(
                    with: hCoreUIAssets.document.view,
                    action: {
                        vm.openFilePicker()
                    }
                )
                .accessibilityValue(L10n.voiceoverChatFiles)
            }
            ImagesView(vm: vm.imagesViewModel)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .padding(.leading, .padding8)
    }

    private func bottomMenuItem(with image: Image, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(hFillColor.Opaque.primary)
                .padding(28)
                .background(hSurfaceColor.Opaque.primary)
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
        }
    }
}

#Preview {
    VStack {
        Spacer()
        ChatInputView(vm: .init())
    }
}

@MainActor
class ChatInputViewModel: NSObject, ObservableObject {
    @Published var inputText: String = ""
    @Published var keyboardIsShown = false {
        didSet {
            if keyboardIsShown {
                withAnimation {
                    showBottomMenu = false
                }
            }
        }
    }

    @Published var showBottomMenu = false {
        didSet {
            if showBottomMenu {
                keyboardIsShown = false
                UIApplication.dismissKeyboard()
            }
        }
    }

    var imagesViewModel = ImagesViewModel()
    var sendMessage: (_ message: Message) -> Void = { _ in }
    override init() {
        super.init()
        imagesViewModel.sendMessage = { [weak self] message in
            self?.sendMessage(message)
        }
    }

    func sendTextMessage() {
        if inputText.count > 0, inputText.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
            sendMessage(Message(type: .text(text: inputText, action: nil)))
            UIApplication.dismissKeyboard()
            inputText = ""
        }
    }

    func openCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.modalPresentationStyle = .overFullScreen
        UIApplication.shared.getTopViewController()?.present(picker, animated: true)
    }

    func openImagePicker() {
        var config = PHPickerConfiguration()
        config.filter = .any(of: [.images, .videos])
        config.selectionLimit = 5
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        picker.modalPresentationStyle = .overFullScreen
        UIApplication.shared.getTopViewController()?.present(picker, animated: true)
    }

    func openFilePicker() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item])
        picker.allowsMultipleSelection = true
        picker.delegate = self
        picker.modalPresentationStyle = .overFullScreen
        UIApplication.shared.getTopViewController()?.present(picker, animated: true)
    }
}

extension ChatInputViewModel: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let image = info[.originalImage] as? UIImage {
            let file = File(
                id: UUID().uuidString,
                size: 0,
                mimeType: .JPEG,
                name: "Camera shoot \(Date().displayDateWithTimeStamp).jpeg",
                source: .data(data: image.jpegData(compressionQuality: 0.9)!)
            )
            sendMessage(.init(type: .file(file: file)))
        }
        picker.dismiss(animated: true)
    }
}

extension ChatInputViewModel: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.isEditing = false
        var files = [File]()

        for selectedItem in results {
            if selectedItem.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                let file = File(
                    id: UUID().uuidString,
                    size: 0,
                    mimeType: .JPEG,
                    name: "\(Date().displayDateWithTimeStamp).jpeg",
                    source: .localFile(results: selectedItem)
                )
                files.append(file)
            } else if selectedItem.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                let file = File(
                    id: UUID().uuidString,
                    size: 0,
                    mimeType: .MOV,
                    name: "\(Date().displayDateWithTimeStamp).mov",
                    source: .localFile(results: selectedItem)
                )
                files.append(file)
            }
        }
        picker.dismiss(animated: true)
        for file in files {
            sendMessage(.init(type: .file(file: file)))
        }
    }
}

extension ChatInputViewModel: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        var files: [File] = []
        for url in urls {
            _ = url.startAccessingSecurityScopedResource()
            if let file = File(from: url) {
                files.append(file)
            }
            url.stopAccessingSecurityScopedResource()
        }
        for file in files {
            sendMessage(.init(type: .file(file: file)))
        }
        controller.dismiss(animated: true)
    }
}
