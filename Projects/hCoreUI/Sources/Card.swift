import Flow
import Form
import Foundation
import SwiftUI
import UIKit
import hCore

public struct hCard<Content: View, BgColor: hColor>: View {
    private var titleIcon: UIImage
    private var title: String
    private var bodyText: String
    private let content: Content
    private let backgroundColor: BgColor
    private let lightTextAppearance: Bool

    @Environment(\.colorScheme) var colorScheme: ColorScheme

    public init(
        titleIcon: UIImage,
        title: String,
        bodyText: String,
        backgroundColor: BgColor,
        lightTextAppearance: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.titleIcon = titleIcon
        self.title = title
        self.bodyText = bodyText
        self.lightTextAppearance = lightTextAppearance
        self.backgroundColor = backgroundColor
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
                .foregroundColor(hTextColorNew.secondary)
                .padding(10)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            content
        }
        .colorScheme(lightTextAppearance ? .light : colorScheme)
        .frame(maxWidth: .infinity)
        .padding()
        .background(backgroundColor)
        .clipShape(Squircle.default())
        .overlay(
            Squircle.default(lineWidth: .hairlineWidth)
                .stroke(lineWidth: .hairlineWidth)
                .foregroundColor(hSeparatorColorOld.separator)
        )
    }
}

extension hCard where Content == EmptyView {
    init(
        titleIcon: UIImage,
        title: String,
        bodyText: String,
        backgroundColor: BgColor
    ) {
        self.init(
            titleIcon: titleIcon,
            title: title,
            bodyText: bodyText,
            backgroundColor: backgroundColor,
            content: { EmptyView() }
        )
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
        headerView.distribution = .fill
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
