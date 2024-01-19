import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct ChatTextViewRepresentable: UIViewRepresentable {
    private let text: String
    private let fixedWidth: CGFloat
    @Binding private var height: CGFloat
    @Binding private var width: CGFloat
    @Environment(\.colorScheme) var colorScheme

    public init(
        text: String,
        fixedWidth: CGFloat,
        height: Binding<CGFloat>,
        width: Binding<CGFloat>
    ) {
        self.text = text
        self.fixedWidth = fixedWidth
        _height = height
        _width = width
    }
    public func makeUIView(context: Context) -> some UIView {
        let textView = ChatTextView(
            text: text,
            fixedWidth: fixedWidth,
            height: $height,
            width: $width,
            colorScheme: colorScheme
        )
        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return textView
    }
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        if let uiView = uiView as? ChatTextView {
            uiView.setContent(from: text)
            uiView.calculateSize()
        }
    }
}

class ChatTextView: UIView, UITextViewDelegate {
    private let textView: UITextView
    private let fixedWidth: CGFloat
    private let colorScheme: ColorScheme
    @Binding private var height: CGFloat
    @Binding private var width: CGFloat
    init(
        text: String,
        fixedWidth: CGFloat,
        height: Binding<CGFloat>,
        width: Binding<CGFloat>,
        colorScheme: ColorScheme
    ) {
        _height = height
        _width = width
        self.fixedWidth = fixedWidth
        self.textView = UITextView()
        self.colorScheme = colorScheme
        super.init(frame: .zero)
        self.addSubview(textView)
        configureTextView()
        setContent(from: text)
        calculateSize()
    }

    private func configureTextView() {
        self.backgroundColor = .clear
        textView.isEditable = false
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.dataDetectorTypes = [.address, .link, .phoneNumber]
        let linkColor = hTextColor.primary.colorFor(colorScheme, .base).color.uiColor()
        textView.linkTextAttributes = [
            .foregroundColor: linkColor,
            .underlineStyle: NSUnderlineStyle.thick.rawValue,
            .underlineColor: linkColor,
        ]
        textView.textColor = hTextColor.primary.colorFor(colorScheme, .base).color.uiColor()
        textView.font = Fonts.fontFor(style: .standard)
        textView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(-6)
            make.trailing.equalToSuperview().offset(6)
            make.bottom.top.equalToSuperview()
        }
        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        textView.textContainerInset = .zero
        textView.delegate = self
    }

    func setContent(from text: String) {
        configureTextView()
        textView.text = text
    }

    func calculateSize() {
        let newSize = getSize()
        DispatchQueue.main.async { [weak self] in
            self?.height = newSize.height
            self?.width = newSize.width - 12
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

    }

    private func getSize() -> CGSize {
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        return newSize
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let store: ChatStore = globalPresentableStoreContainer.get()
        store.send(.navigation(action: .linkClicked(url: URL)))
        return false
    }
}

struct Label_Previews: PreviewProvider {
    @State static var height: CGFloat = 0
    @State static var width: CGFloat = 0

    static var previews: some View {
        VStack {
            ChatTextViewRepresentable(
                text: "teasd asd asd sds dasd asd asda sd asdas ad asd asd",
                fixedWidth: 300,
                height: $height,
                width: $width
            )
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: 300)
        }
        .environment(\.colorScheme, .light)
    }
}
