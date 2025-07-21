import Combine
import Photos
import PhotosUI
import SwiftUI
@preconcurrency import UIKit
import hCore
import hCoreUI

struct ChatInputView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @StateObject var vm: ChatInputViewModel
    @State var height: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(hBorderColor.primary).frame(height: 1)
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .bottom) {
                    addFilesButton
                    inputField
                }
                .padding([.horizontal, .top], .padding8)

                if vm.showBottomMenu {
                    bottomMenu
                }
            }
        }
    }

    private var addFilesButton: some View {
        Button {
            withAnimation {
                self.vm.showBottomMenu.toggle()
            }
        } label: {
            hCoreUIAssets.plus.view
                .resizable().frame(width: 24, height: 24)
                .rotationEffect(vm.showBottomMenu ? .degrees(45) : .zero)
                .foregroundColor(hTextColor.Opaque.primary)
                .padding(.padding8)
                .background(hSurfaceColor.Opaque.primary)
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusM))
        }
        .accessibilityValue(
            vm.showBottomMenu ? L10n.generalCloseButton : L10n.ClaimStatus.UploadedFiles.uploadButton
        )
    }

    private var inputField: some View {
        HStack(alignment: .bottom, spacing: 0) {
            CustomTextViewRepresentable(
                placeholder: L10n.chatInputPlaceholder,
                text: $vm.inputText,
                height: $height,
                keyboardIsShown: $vm.keyboardIsShown
            ) { file in
                vm.sendMessage(.init(type: .file(file: file)))
            }
            .frame(height: height)
            .frame(minHeight: 40)
            .fixedSize(horizontal: false, vertical: verticalSizeClass == .regular ? false : true)

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
            self.sendMessage(Message(type: .text(text: inputText)))
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

struct CustomTextViewRepresentable: UIViewRepresentable {
    let placeholder: String
    @Binding var text: String
    @Binding var height: CGFloat
    @Binding var keyboardIsShown: Bool
    @Environment(\.colorScheme) var schema
    let onPaste: ((File) -> Void)?
    func makeUIView(context: Context) -> some UIView {
        CustomTextView(
            placeholder: placeholder,
            inputText: $text,
            height: $height,
            keyboardIsShown: $keyboardIsShown,
            onPaste: onPaste
        )
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        if let uiView = uiView as? CustomTextView {
            if text == "" && !uiView.isFirstResponder {
                uiView.text = text
                uiView.updateHeight()
                uiView.updateColors()
            }
        }
    }
}

@MainActor
private class CustomTextView: UITextView, UITextViewDelegate {
    @Binding private var inputText: String
    @Binding private var height: CGFloat
    @Binding private var keyboardIsShown: Bool
    private var textCancellable: AnyCancellable?
    private var placeholderLabel = UILabel()
    let onPaste: ((File) -> Void)?
    init(
        placeholder: String,
        inputText: Binding<String>,
        height: Binding<CGFloat>,
        keyboardIsShown: Binding<Bool>,
        onPaste: ((File) -> Void)?
    ) {
        self._inputText = inputText
        self.onPaste = onPaste
        self._height = height
        self._keyboardIsShown = keyboardIsShown
        super.init(frame: .zero, textContainer: nil)
        self.textContainerInset = .init(top: 4, left: 4, bottom: 4, right: 4)
        self.delegate = self
        self.font = Fonts.fontFor(style: .body1)
        self.text = inputText.wrappedValue
        self.textColor = UIColor.black
        self.backgroundColor = .clear
        placeholderLabel.font = Fonts.fontFor(style: .body1)
        placeholderLabel.text = placeholder
        self.addSubview(placeholderLabel)
        placeholderLabel.accessibilityElementsHidden = true
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.equalToSuperview().offset(8)
        }
        self.accessibilityLabel = placeholderLabel.text
    }

    @objc private func handleDoneButtonTap() {
        self.resignFirstResponder()
    }

    func updateHeight() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            withAnimation {
                self.height = min(self.contentSize.height, 150)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        keyboardIsShown = true
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.inputText = textView.text
            self?.updateHeight()
            self?.updateColors()
        }
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        keyboardIsShown = false
    }

    func updateColors() {
        self.placeholderLabel.isHidden = !text.isEmpty
        self.placeholderLabel.textColor = placeholderTextColor
        self.textColor = editingTextColor
    }

    private var editingTextColor: UIColor {
        let colorScheme: ColorScheme = UITraitCollection.current.userInterfaceStyle == .light ? .light : .dark
        return hTextColor.Opaque.primary.colorFor(colorScheme, .base).color.uiColor()
    }
    private var placeholderTextColor: UIColor {
        let colorScheme: ColorScheme = UITraitCollection.current.userInterfaceStyle == .light ? .light : .dark
        return hTextColor.Opaque.secondary.colorFor(colorScheme, .base).color.uiColor()
    }

    override func paste(_ sender: Any?) {
        if let action = (sender as? UIKeyCommand)?.action, action == #selector(UIResponder.paste(_:)) {
            if let images = UIPasteboard.general.images, images.count > 0 {
                for image in images {
                    if let data = image.jpegData(compressionQuality: 0.9) {
                        let file = File(
                            id: UUID().uuidString,
                            size: Double(data.count),
                            mimeType: .JPEG,
                            name: "image_\(Date())",
                            source: .data(data: data)
                        )
                        self.onPaste?(file)
                    }
                }
                return
            } else if let urls = UIPasteboard.general.urls, urls.count > 0 {
                for url in urls {
                    if let contentProvider = NSItemProvider(contentsOf: url) {
                        Task { [weak self] in
                            if let file = await contentProvider.getFile() {
                                self?.onPaste?(file)
                            }
                        }
                    }
                }
            } else {
                super.paste(sender)
            }
        } else {
            super.paste(sender)
        }
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponder.paste(_:)) {
            if let imagesFileTypes = UIPasteboard.typeListImage as? [String],
                UIPasteboard.general.contains(pasteboardTypes: imagesFileTypes)
            {
                return true
            } else if let urlTypes = UIPasteboard.typeListURL as? [String],
                UIPasteboard.general.contains(pasteboardTypes: urlTypes)
            {
                return true
            }
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

extension ChatInputViewModel: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public func imagePickerController(
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
            self.sendMessage(.init(type: .file(file: file)))
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
            self.sendMessage(.init(type: .file(file: file)))
        }
        controller.dismiss(animated: true)

    }
}
