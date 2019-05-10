//
//  PaymentNeedsSetupSection.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-15.
//

import Flow
import Form
import Foundation
import UIKit

struct PaymentNeedsSetupSection {
    let dataSignal: ReadWriteSignal<MyPaymentQuery.Data?> = ReadWriteSignal(nil)
    let presentingViewController: UIViewController
}

extension PaymentNeedsSetupSection: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let wrapper = UIStackView()
        wrapper.isHidden = true
        wrapper.isLayoutMarginsRelativeArrangement = true

        let containerView = UIView()
        containerView.backgroundColor = .offLightGray
        containerView.layer.cornerRadius = 8

        let containerStackView = UIStackView()
        containerStackView.axis = .vertical
        containerStackView.spacing = 12
        containerStackView.alignment = .fill
        containerStackView.edgeInsets = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        containerStackView.alpha = 0

        containerView.addSubview(containerStackView)

        containerStackView.snp.makeConstraints { make in
            make.height.width.centerX.centerY.equalToSuperview()
        }

        let infoLabel = MultilineLabel(value: String(key: .DASHBOARD_PAYMENT_SETUP_INFO), style: TextStyle.bodyOffBlack.centered())
        bag += containerStackView.addArranged(infoLabel)

        let buttonContainer = UIView()
        let connectButton = Button(
            title: String(key: .DASHBOARD_PAYMENT_SETUP_BUTTON),
            type: .outline(borderColor: .purple, textColor: .purple)
        )
        bag += buttonContainer.add(connectButton) { buttonView in
            buttonView.snp.makeConstraints { make in
                make.height.centerY.centerX.equalToSuperview()
                make.width.equalToSuperview().inset(50)
            }
        }

        bag += connectButton.onTapSignal.onValue { _ in
            self.presentingViewController.present(DirectDebitSetup(), options: [.autoPop, .largeTitleDisplayMode(.never)])
        }

        containerStackView.addArrangedSubview(buttonContainer)

        wrapper.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview().inset(16)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        bag += dataSignal.wait(until: wrapper.hasWindowSignal).delay(by: 0.5).animated(style: SpringAnimationStyle.lightBounce()) { data in
            bag += Signal(after: 0.25).animated(style: AnimationStyle.easeOut(duration: 0.25), animations: { _ in
                containerStackView.alpha = 1
            })

            switch data?.directDebitStatus {
            case .active?, .pending?:
                wrapper.isHidden = false
            default:
                wrapper.isHidden = true
            }
        }

        return (wrapper, bag)
    }
}
