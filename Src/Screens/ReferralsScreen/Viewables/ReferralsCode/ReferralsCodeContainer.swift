//
//  ReferralsCodeContainer.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-05-31.
//

import Flow
import Form
import Foundation
import UIKit

struct ReferralsCodeContainer {
    let codeSignal: Signal<String>
    let presentingViewController: UIViewController

    init(codeSignal: Signal<String>, presentingViewController: UIViewController) {
        self.codeSignal = codeSignal
        self.presentingViewController = presentingViewController
    }
}

extension ReferralsCodeContainer: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 5

        let titleLabel = MultilineLabel(
            value: String(key: .REFERRAL_PROGRESS_CODE_TITLE),
            style: TextStyle.centeredBodyOffBlack
        )
        bag += stackView.addArranged(titleLabel)

        let referralsCode = ReferralsCode(codeSignal: codeSignal, presentingViewController: presentingViewController)
        bag += stackView.addArranged(referralsCode) { referralsCodeView in
            referralsCodeView.snp.makeConstraints { make in
                make.trailing.leading.equalToSuperview().inset(16)
            }
        }

        return (stackView, bag)
    }
}
