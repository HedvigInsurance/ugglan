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
            Rectangle().fill(hBorderColor.translucentOne).frame(height: 1)
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .bottom) {
                    Button {
                        withAnimation {
                            self.vm.showBottomMenu.toggle()
                        }
                    } label: {
                        Image(uiImage: hCoreUIAssets.plusSmall.image)
                            .resizable().frame(width: 16, height: 16)
                            .rotationEffect(vm.showBottomMenu ? .degrees(45) : .zero)
                            .foregroundColor(hTextColor.primary)
                            .padding(12)
                            .background(hBackgroundColor.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12).stroke(hBorderColor.opaqueOne, lineWidth: 0.5)
                            )
                    }
                    HStack(alignment: .bottom, spacing: 0) {
                        CustomTextViewRepresentable(
                            placeholder: L10n.chatInputPlaceholder,
                            text: $vm.inputText,
                            height: $height,
                            showBottomMenu: $vm.showBottomMenu
                        )
                        .frame(height: height)
                        .frame(minHeight: 40)

                        Button {
                            vm.sendTextMessage()
                        } label: {
                            hCoreUIAssets.sendChat.view
                                .resizable()
                                .frame(width: 24, height: 24)
                                .padding(8)
                        }
                    }
                    .padding(.leading, 4)
                    .background(hBackgroundColor.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12).stroke(hBorderColor.opaqueOne, lineWidth: 0.5)
                    )
                }
                .padding([.horizontal, .top], 16)
                .fixedSize(horizontal: false, vertical: true)
                if vm.showBottomMenu {
                    HStack(spacing: 8) {
                        VStack(spacing: 8) {
                            bottomMenuItem(with: hCoreUIAssets.camera.image) {
                                vm.openCamera()
                            }
                            bottomMenuItem(with: hCoreUIAssets.pictures.image) {
                                vm.openImagePicker()
                            }
                            bottomMenuItem(with: hCoreUIAssets.documents.image) {
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
                    .padding(.leading, 16)
                }
            }
        }
    }

    private func bottomMenuItem(with image: UIImage, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            RoundedRectangle(cornerRadius: 12)
                .fill(hBackgroundColor.primary)
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 24)
                        .foregroundColor(hTextColor.primary)
                )
                .frame(height: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: 12).stroke(hBorderColor.opaqueOne, lineWidth: 0.5)
                )
        }
    }
}

#Preview{
    VStack {
        Spacer()
        ChatInputView(vm: .init())
    }
}

class ChatInputViewModel: NSObject, ObservableObject {
    @Published var inputText: String = ""
    @Published var showBottomMenu = false {
        didSet {
            if showBottomMenu {
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
        picker.preferredPresentationStyle = .modal
        UIApplication.shared.getTopViewController()?.present(picker, animated: true)
    }

    func openImagePicker() {
        var config = PHPickerConfiguration()
        config.filter = .any(of: [.images, .videos])
        config.selectionLimit = 5
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        picker.preferredPresentationStyle = .modal
        UIApplication.shared.getTopViewController()?.present(picker, animated: true)
    }

    func openFilePicker() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item])
        picker.allowsMultipleSelection = true
        picker.delegate = self
        picker.preferredPresentationStyle = .modal
        UIApplication.shared.getTopViewController()?.present(picker, animated: true)
    }
}

struct CustomTextViewRepresentable: UIViewRepresentable {
    let placeholder: String
    @Binding var text: String
    @Binding var height: CGFloat
    @Binding var showBottomMenu: Bool
    func makeUIView(context: Context) -> some UIView {
        CustomTextView(
            placeholder: placeholder,
            inputText: $text,
            height: $height,
            showBottomMenu: $showBottomMenu
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
    private let placeholder: String
    @Binding private var inputText: String
    @Binding private var height: CGFloat
    @Binding private var showBottomMenu: Bool
    private var textCancellable: AnyCancellable?
    init(placeholder: String, inputText: Binding<String>, height: Binding<CGFloat>, showBottomMenu: Binding<Bool>) {
        self.placeholder = placeholder
        self._inputText = inputText
        self._height = height
        self._showBottomMenu = showBottomMenu
        super.init(frame: .zero, textContainer: nil)
        self.textContainerInset = .init(horizontalInset: 4, verticalInset: 4)
        self.delegate = self
        self.font = Fonts.fontFor(style: .standard)
        if inputText.wrappedValue.isEmpty {
            self.text = placeholder
            self.textColor = UIColor.lightGray
        } else {
            self.text = inputText.wrappedValue
            self.textColor = UIColor.black
        }
        self.backgroundColor = .clear
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(handleDoneButtonTap)
        )
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([space, doneButton], animated: false)

        self.inputAccessoryView = toolbar
    }

    @objc private func handleDoneButtonTap() {
        self.resignFirstResponder()
    }

    func updateHeight() {
        DispatchQueue.main.async { [weak self] in guard let self = self else { return }
            withAnimation {
                self.height = min(self.contentSize.height, 200)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        showBottomMenu = false
        if textView.textColor == placeholderTextColor {
            textView.text = nil
            textView.textColor = editingTextColor
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            self?.inputText = textView.text
            self?.updateHeight()
        }
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            textView.text = placeholder
            textView.textColor = placeholderTextColor
        }
    }

    func updateColors() {
        if text.isEmpty {
            self.text = placeholder
            self.textColor = placeholderTextColor
        } else {
            self.textColor = editingTextColor
        }
    }

    private var editingTextColor: UIColor {
        let colorScheme: ColorScheme = UITraitCollection.current.userInterfaceStyle == .light ? .light : .dark
        return hTextColor.primary.colorFor(colorScheme, .base).color.uiColor()
    }
    private var placeholderTextColor: UIColor {
        let colorScheme: ColorScheme = UITraitCollection.current.userInterfaceStyle == .light ? .light : .dark
        return hTextColor.secondary.colorFor(colorScheme, .base).color.uiColor()
    }
}

extension ChatInputViewModel: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let image = info[.originalImage] as? UIImage {
            let data = FilePickerDto(
                id: UUID().uuidString,
                size: 0,
                mimeType: .JPEG,
                name: "camera shoot",
                data: image.jpegData(compressionQuality: 0.9)!,
                thumbnailData: image.jpegData(compressionQuality: 0.1)!
            )
            if let file = data.asFile() {
                sendMessage(.init(type: .file(file: file)))
            }
        }
        picker.dismiss(animated: true)
    }

}

extension ChatInputViewModel: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let selectedItems =
            results
            .map { $0.itemProvider }
        picker.isEditing = false
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
        dispatchGroup.notify(queue: .main) { [weak self] in
            picker.dismiss(animated: true)
            for fileDTO in files {
                if let file = fileDTO.asFile() {
                    self?.sendMessage(.init(type: .file(file: file)))
                }
            }
        }
    }
}

extension ChatInputViewModel: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        var files: [FilePickerDto] = []
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
                    thumbnailData: nil
                )
            )
            url.stopAccessingSecurityScopedResource()
        }
        for fileDTO in files {
            if let file = fileDTO.asFile() {
                self.sendMessage(.init(type: .file(file: file)))
            }
        }
        controller.dismiss(animated: true)

    }
}
