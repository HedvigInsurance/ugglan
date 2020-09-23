import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

struct Card {
    @ReadWriteState var titleIcon: UIImage
    @ReadWriteState var title: DisplayableString
    @ReadWriteState var body: DisplayableString
    @ReadWriteState var buttonText: DisplayableString
}

extension Card: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Signal<Void>) {
        let bag = DisposeBag()
        let view = UIView()
        view.layer.cornerRadius = .defaultCornerRadius

        view.backgroundColor = .tint(.yellowTwo)

        let contentView = UIStackView()
        contentView.axis = .vertical
        contentView.spacing = 16
        contentView.edgeInsets = UIEdgeInsets(horizontalInset: 24, verticalInset: 18)
        view.addSubview(contentView)

        contentView.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }

        let headerWrapperView = UIStackView()
        headerWrapperView.axis = .vertical
        headerWrapperView.alignment = .center
        contentView.addArrangedSubview(headerWrapperView)

        let headerView = UIStackView()
        headerView.alignment = .center
        headerView.spacing = 8
        headerWrapperView.addArrangedSubview(headerView)

        headerView.addArrangedSubview({
            let imageView = UIImageView()
            imageView.image = titleIcon
            imageView.contentMode = .scaleAspectFit

            bag += $titleIcon.bindTo(imageView, \.image)

            imageView.snp.makeConstraints { make in
                make.height.width.equalTo(24)
            }

            return imageView
        }())

        let titleLabel = UILabel(value: title, style: TextStyle.brand(.headline(color: .primary)).centerAligned)
        bag += $title.bindTo(titleLabel, \.value)

        headerView.addArrangedSubview(titleLabel)

        let bodyLabel = MultilineLabel(value: body, style: TextStyle.brand(.subHeadline(color: .secondary)).centerAligned)
        bag += $body.bindTo(bodyLabel.$value)

        bag += contentView.addArranged(bodyLabel) { view in
            contentView.setCustomSpacing(24, after: view)
        }

        let button = Button(title: buttonText, type: .standardSmall(backgroundColor: .tint(.yellowOne), textColor: .brand(.primaryButtonTextColor)))
        bag += $buttonText.bindTo(button.title)
        bag += contentView.addArranged(button.alignedTo(alignment: .center))

        return (view, Signal { callback in
            bag += button.onTapSignal.onValue(callback)
            return bag
        })
    }
}
