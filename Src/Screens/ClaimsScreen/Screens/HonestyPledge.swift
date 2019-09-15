//
//  HonestyPledge.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-24.
//

import Flow
import Foundation
import Presentation
import UIKit

struct HonestyPledge {}

extension HonestyPledge: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()

        let bag = DisposeBag()

        let containerStackView = UIStackView()
        containerStackView.alignment = .leading
        bag += containerStackView.applySafeAreaBottomLayoutMargin()

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 24)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.spacing = 10

        containerStackView.addArrangedSubview(stackView)

        let titleLabel = MultilineLabel(value: String(key: .HONESTY_PLEDGE_TITLE), style: .draggableOverlayTitle)
        bag += stackView.addArranged(titleLabel)

        let descriptionLabel = MultilineLabel(
            value: String(key: .HONESTY_PLEDGE_DESCRIPTION),
            style: .bodyOffBlack
        )
        bag += stackView.addArranged(descriptionLabel)

        let pusherView = UIView()
        pusherView.snp.makeConstraints { make in
            make.height.equalTo(10)
        }
        stackView.addArrangedSubview(pusherView)

        let slideToClaim = SlideToClaim()
        bag += stackView.addArranged(slideToClaim.wrappedIn(UIStackView())) { slideToClaimStackView in
            slideToClaimStackView.isLayoutMarginsRelativeArrangement = true
        }

        bag += containerStackView.applyPreferredContentSize(on: viewController)

        viewController.view = containerStackView

        return (viewController, Future { _ in
            bag += slideToClaim.onValue {
                viewController.present(
                    ClaimsChat(),
                    style: .default,
                    options: [.prefersNavigationBarHidden(false)]
                )
            }

            return DelayedDisposer(bag, delay: 1)
        })
    }
}
