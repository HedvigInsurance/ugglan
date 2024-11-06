import Combine
import Photos
import PhotosUI
import SwiftUI
import hCore
import hCoreUI

struct ChatInputView: View {
    @StateObject var vm: ChatInputViewModel
    @State var height: CGFloat = 0
    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(hBorderColor.primary).frame(height: 1)
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .bottom) {
                    Button {
                        withAnimation {
                            self.vm.showBottomMenu.toggle()
                        }
                    } label: {
                        Image(uiImage: hCoreUIAssets.plus.image)
                            .resizable().frame(width: 24, height: 24)
                            .rotationEffect(vm.showBottomMenu ? .degrees(45) : .zero)
                            .foregroundColor(hTextColor.Opaque.primary)
                            .padding(.padding8)
                            .background(hSurfaceColor.Opaque.primary)
                            .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusM))
                    }
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

                        Button {
                            vm.sendTextMessage()
                        } label: {
                            hCoreUIAssets.sendChat.view
                                .resizable()
                                .frame(width: 24, height: 24)
                                .padding(.padding8)
                        }
                    }
                    .padding(.leading, .padding4)
                    .background(hSurfaceColor.Opaque.primary)
                    .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusM))
                }
                .padding([.horizontal, .top], 16)
                .fixedSize(horizontal: false, vertical: true)
                if vm.showBottomMenu {
                    HStack(spacing: 8) {
                        VStack(spacing: 8) {
                            bottomMenuItem(with: hCoreUIAssets.camera.image) {
                                vm.openCamera()
                            }
                            bottomMenuItem(with: hCoreUIAssets.image.image) {
                                vm.openImagePicker()
                            }
                            bottomMenuItem(with: hCoreUIAssets.document.image) {
                                vm.openFilePicker()
                            }
                        }
                        .fixedSize(
                            horizontal: /*@START_MENU_TOKEN@*/ true /*@END_MENU_TOKEN@*/,
                            vertical: /*@START_MENU_TOKEN@*/ true /*@END_MENU_TOKEN@*/
                        )
                        ImagesView(vm: vm.imagesViewModel)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.leading, .padding16)
                }
            }
        }
    }

    private func bottomMenuItem(with image: UIImage, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Image(uiImage: image)
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
        if inputText.count > 0 {
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
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.equalToSuperview().offset(8)
        }
    }

    @objc private func handleDoneButtonTap() {
        self.resignFirstResponder()
    }

    func updateHeight() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            withAnimation {
                self.height = min(self.contentSize.height, 200)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
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

            if let urls = UIPasteboard.general.urls, urls.count > 0 {
                for url in urls {
                    if let contentProvider = NSItemProvider(contentsOf: url) {
                        contentProvider.getFile { [weak self] file in
                            self?.onPaste?(file)
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
                name: "Camera shoot",
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
                    name: "\(Date().currentTimeMillis).jpeg",
                    source: .localFile(results: selectedItem)
                )
                files.append(file)
            } else if selectedItem.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                let file = File(
                    id: UUID().uuidString,
                    size: 0,
                    mimeType: .MOV,
                    name: "\(Date().currentTimeMillis).mov",
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
