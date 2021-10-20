import Flow
import Form
import Foundation
import UIKit
import hCore
import SwiftUI

/*public struct CardView: UIViewRepresentable {
    @Binding public var titleIcon: UIImage
    @Binding public var title: DisplayableString
    @Binding public var body: DisplayableString
    public var backgroundColor: UIColor
    @Binding public var buttonText: DisplayableString?
    public var buttonType: ButtonType?

    public init(
        titleIcon: Binding<UIImage>,
        title: Binding<DisplayableString>,
        body: Binding<DisplayableString>,
        backgroundColor: UIColor,
        buttonText: Binding<DisplayableString?>?,
        buttonType: ButtonType? = nil
    ) {
        _titleIcon = titleIcon
        _title = title
        _body = body
        self.backgroundColor = backgroundColor
        _buttonText = buttonText ?? Binding.constant(nil)
        self.buttonType = buttonType
    }

    public class Coordinator {
        let bag = DisposeBag()
        let isSelectedSignal: ReadWriteSignal<Bool>
        let bullet: Bullet

        init(
            isSelectedSignal: ReadWriteSignal<Bool>
        ) {
            self.isSelectedSignal = isSelectedSignal
            self.bullet = Bullet(isSelectedSignal: isSelectedSignal)
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(isSelectedSignal: .init(false))
    }

    public func makeUIView(context: Context) -> some UIView {
        let (view, disposable) = context.coordinator.bullet.materialize(
            events: ViewableEvents(wasAddedCallbacker: .init())
        )
        context.coordinator.isSelectedSignal.value = isSelected
        context.coordinator.bag += disposable
        return view
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.isSelectedSignal.value = isSelected
    }
}*/

public struct hCard<Content: View>: View {
    private var titleIcon: UIImage
    private var title: String
    private var bodyText: String
    private let content: Content
    
    public init(
        titleIcon: UIImage,
        title: String,
        bodyText: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.titleIcon = titleIcon
        self.title = title
        self.bodyText = bodyText
        self.content = content()
    }
    
    public var body: some View {
        VStack {
            HStack {
                SwiftUI.Image(uiImage: titleIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 20)
                title.hText(.headline)
            }
            bodyText
                .hText(.subheadline)
                .foregroundColor(hLabelColor.secondary)
                .padding(10)
                .multilineTextAlignment(.center)
                
            content
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(hTintColor.lavenderTwo)
        .border(hSeparatorColor.separator, width: .hairlineWidth)
        .cornerRadius(.defaultCornerRadius)
    }
}

extension hCard where Content == EmptyView {
    init(
        titleIcon: UIImage,
        title: String,
        bodyText: String
    ) {
        self.init(
            titleIcon: titleIcon,
            title: title,
            bodyText: bodyText,
            content: { EmptyView() }
        )
    }
}

struct CardPreview: PreviewProvider {
    static var previews: some View {
        Group {
            hCard(
                titleIcon: hCoreUIAssets.refresh.image,
                title: "Title",
                bodyText: "Subtitle"
            )
            hCard(
                titleIcon: hCoreUIAssets.refresh.image,
                title: "Title",
                bodyText: "Subtitle"
            ) {
                hButton.SmallButtonOutlined {
                    print("Hello")
                } content: {
                    "Button".hText()
                }
            }
            .preferredColorScheme(.light)
            hCard(
                titleIcon: hCoreUIAssets.refresh.image,
                title: "Title",
                bodyText: "Subtitle"
            ) {
                hButton.SmallButtonOutlined {
                    print("Hello")
                } content: {
                    "Button".hText()
                }
            }
            .preferredColorScheme(.dark)
        }
        .previewLayout(PreviewLayout.sizeThatFits)
        .padding()
        .previewDisplayName("Default preview")
    }
}

public struct Card {
    @ReadWriteState var titleIcon: UIImage
    @ReadWriteState var title: DisplayableString
    @ReadWriteState var body: DisplayableString
    var backgroundColor: UIColor
    @ReadWriteState var buttonText: DisplayableString?
    var buttonType: ButtonType?

    public init(
        titleIcon: UIImage,
        title: DisplayableString,
        body: DisplayableString,
        buttonText: DisplayableString? = nil,
        backgroundColor: UIColor,
        buttonType: ButtonType? = nil
    ) {
        self.titleIcon = titleIcon
        self.title = title
        self.body = body
        self.backgroundColor = backgroundColor
        self.buttonText = buttonText
        self.buttonType = buttonType
    }
}

extension Card: Viewable {
    public func materialize(events _: ViewableEvents) -> (UIView, Signal<UIControl>) {
        let bag = DisposeBag()
        let view = UIView()
        view.accessibilityIdentifier = "Card"
        view.layer.cornerRadius = .defaultCornerRadius
        view.layer.borderWidth = .hairlineWidth
        bag += view.applyBorderColor { _ -> UIColor in .brand(.primaryBorderColor) }

        view.backgroundColor = backgroundColor

        let contentView = UIStackView()
        contentView.axis = .vertical
        contentView.spacing = 16
        contentView.edgeInsets = UIEdgeInsets(horizontalInset: 24, verticalInset: 18)
        view.addSubview(contentView)

        contentView.snp.makeConstraints { make in make.top.bottom.trailing.leading.equalToSuperview() }

        let headerWrapperView = UIStackView()
        headerWrapperView.axis = .vertical
        headerWrapperView.alignment = .center
        contentView.addArrangedSubview(headerWrapperView)

        let headerView = UIStackView()
        headerView.alignment = .center
        headerView.distribution = .fillProportionally
        headerView.spacing = 8
        headerWrapperView.addArrangedSubview(headerView)

        headerView.addArrangedSubview(
            {
                let imageView = UIImageView()
                imageView.image = titleIcon
                imageView.contentMode = .scaleAspectFit
                imageView.tintColor = .typographyColor(.primary(state: .matching(backgroundColor)))
                imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)

                bag += $titleIcon.bindTo(imageView, \.image)

                imageView.snp.makeConstraints { make in make.height.width.equalTo(20) }

                return imageView
            }()
        )

        let titleLabel = UILabel(
            value: title,
            style: TextStyle.brand(.headline(color: .primary(state: .matching(backgroundColor))))
                .centerAligned
        )
        bag += $title.bindTo(titleLabel, \.value)

        headerView.addArrangedSubview(titleLabel)

        let bodyLabel = MultilineLabel(
            value: body,
            style: TextStyle.brand(.subHeadline(color: .secondary(state: .matching(backgroundColor))))
                .centerAligned
        )
        bag += $body.bindTo(bodyLabel.$value)

        bag += contentView.addArranged(bodyLabel) { view in contentView.setCustomSpacing(24, after: view) }

        let onTapCallbacker = Callbacker<UIControl>()

        if let buttonText = buttonText,
            let buttonType = buttonType
        {
            let button = Button(title: buttonText, type: buttonType)
            bag += $buttonText.compactMap { $0 }.bindTo(button.title)
            bag += contentView.addArranged(
                button.alignedTo(alignment: .center) { buttonView in
                    bag += button.onTapSignal.onValue { onTapCallbacker.callAll(with: buttonView) }
                }
            )
        }

        return (view, onTapCallbacker.providedSignal.hold(bag))
    }
}
