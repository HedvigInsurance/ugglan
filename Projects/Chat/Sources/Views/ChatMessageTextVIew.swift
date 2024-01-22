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
        return textView
    }
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        if let uiView = uiView as? ChatTextView {
            uiView.calculateSize()
        }
    }
}

class ChatTextView: UITextView, UITextViewDelegate {
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
        self.colorScheme = colorScheme
        super.init(frame: .zero, textContainer: nil)
        self.textContainerInset = .init(horizontalInset: 0, verticalInset: 0)
        configureTextView()
        self.text = text
        calculateSize()
    }

    private func configureTextView() {
        self.backgroundColor = .clear
        isEditable = false
        isUserInteractionEnabled = true
        isScrollEnabled = true
        dataDetectorTypes = [.address, .link, .phoneNumber]
        let linkColor = hTextColor.primary.colorFor(colorScheme, .base).color.uiColor()
        linkTextAttributes = [
            .foregroundColor: linkColor,
            .underlineStyle: NSUnderlineStyle.thick.rawValue,
            .underlineColor: linkColor,
        ]
        textColor = hTextColor.primary.colorFor(colorScheme, .base).color.uiColor()
        font = Fonts.fontFor(style: .standard)
        delegate = self
    }

    func calculateSize() {
        let newSize = getSize()
        //        self.frame.size = newSize
        //        self.contentSize = newSize
        DispatchQueue.main.async { [weak self] in
            self?.height = newSize.height
            self?.width = newSize.width
        }
    }

    private func getSize() -> CGSize {
        let newSize = sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
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
