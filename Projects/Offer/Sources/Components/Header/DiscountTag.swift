import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct DiscountTag {
    @Inject var state: OldOfferState
}

extension DiscountTag: Presentable {
    func materialize() -> (UIView, Disposable) {
        let view = UIView()
        view.animationSafeIsHidden = true
        view.backgroundColor = .tint(.lavenderOne)
        let bag = DisposeBag()

        let horizontalCenteringStackView = UIStackView()
        horizontalCenteringStackView.edgeInsets = UIEdgeInsets(inset: 10)
        horizontalCenteringStackView.axis = .vertical
        horizontalCenteringStackView.alignment = .center
        horizontalCenteringStackView.distribution = .equalCentering
        view.addSubview(horizontalCenteringStackView)

        horizontalCenteringStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let contentStackView = UIStackView()
        contentStackView.axis = .horizontal
        contentStackView.spacing = 2
        contentStackView.alignment = .center
        contentStackView.distribution = .equalCentering
        horizontalCenteringStackView.addArrangedSubview(contentStackView)

        let textStyle = TextStyle.brand(.caption1(color: .primary(state: .positive))).centerAligned.uppercased

        let titleLabel = UILabel(
            value: "",
            style: textStyle
        )
        contentStackView.addArrangedSubview(titleLabel)

        bag += state.dataSignal
            .animated(style: SpringAnimationStyle.lightBounce()) { data in
                guard let campaign = data?.redeemedCampaigns.first, let campaignManagement =
                        data?.quoteBundle.appConfiguration, campaignManagement.showCampaignManagement
                else {
                    view.animationSafeIsHidden = true
                    return
                }

                view.animationSafeIsHidden = false
                titleLabel.value = campaign.displayValue ?? ""
            }

        return (view, bag)
    }
}
