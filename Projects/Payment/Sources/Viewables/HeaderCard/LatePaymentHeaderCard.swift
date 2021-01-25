import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Presentation
import UIKit

struct LatePaymentHeaderSection {
    @Inject var client: ApolloClient
    let failedCharges: Int
    let lastDate: String
}

extension LatePaymentHeaderSection: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let outerContainer = UIStackView()
        outerContainer.edgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        let view = UIStackView()
        view.edgeInsets = UIEdgeInsets(inset: 15)
        outerContainer.addArrangedSubview(view)

        let childView = UIView()
        childView.layer.borderWidth = .hairlineWidth
        bag += childView.applyBorderColor { _ -> UIColor in
            .brand(.primaryBorderColor)
        }

        view.addSubview(childView)

        childView.layer.cornerRadius = .defaultCornerRadius
        childView.backgroundColor = .brand(.secondaryBackground())

        childView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }

        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.alignment = .center
        containerView.edgeInsets = UIEdgeInsets(horizontalInset: 16, verticalInset: 20)

        childView.addSubview(containerView)

        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(childView.safeAreaLayoutGuide)
            make.top.bottom.equalToSuperview()
        }

        let icon = Icon(icon: hCoreUIAssets.circularCross.image, iconWidth: 25)
        containerView.addArrangedSubview(icon)

        icon.snp.makeConstraints { make in
            make.height.equalTo(25)
        }

        containerView.setCustomSpacing(10, after: icon)

        let infoLabel = MultilineLabel(
            value: L10n.paymentsLatePaymentsMessage(failedCharges, lastDate),
            style: TextStyle.brand(.body(color: .primary)).centerAligned
        )
        bag += containerView.addArranged(infoLabel)

        return (outerContainer, bag)
    }
}
