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

// Hack to integrate with React Native
var honestyPledgeOpenClaimsFlow: (_ presentingViewController: UIViewController) -> Void = { viewController in
    viewController.present(LoggedIn(), style: .default, options: [.prefersNavigationBarHidden(false)])
}

extension HonestyPledge: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        viewController.preferredContentSize = CGSize(width: 0, height: 300)
        
        let bag = DisposeBag()

        let containerStackView = UIStackView()
        containerStackView.alignment = .leading

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.edgeInsets = UIEdgeInsets(horizontalInset: 32, verticalInset: 25)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.spacing = 10

        containerStackView.addArrangedSubview(stackView)
        
        let titleLabel = MultilineLabel(value: String(key: .HONESTY_PLEDGE_TITLE), style: .standaloneLargeTitle)
        bag += stackView.addArranged(titleLabel)

        let descriptionLabel = MultilineLabel(
            value: String(key: .HONESTY_PLEDGE_DESCRIPTION),
            style: .bodyOffBlack
        )
        bag += stackView.addArranged(descriptionLabel)

        let slideToClaim = SlideToClaim()
        bag += stackView.addArranged(slideToClaim.wrappedIn(UIStackView())) { slideToClaimStackView in
            slideToClaimStackView.edgeInsets = UIEdgeInsets(horizontalInset: 0, verticalInset: 20)
            slideToClaimStackView.isLayoutMarginsRelativeArrangement = true
        }

        viewController.view = containerStackView

        return (viewController, Future { completion in
            bag += slideToClaim.onValue {
                honestyPledgeOpenClaimsFlow(viewController)
            }

            return DelayedDisposer(bag, delay: 1)
        })
    }
}
