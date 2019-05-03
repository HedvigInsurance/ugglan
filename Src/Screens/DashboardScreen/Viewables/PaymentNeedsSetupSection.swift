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

        let wrapper = UIView()
        wrapper.isHidden = true

        bag += dataSignal.onValue { data in
            let hasAlreadyConnected = data?.bankAccount != nil
            wrapper.isHidden = !hasAlreadyConnected
        }

        let containerView = UIView()
        containerView.backgroundColor = .offLightGray
        containerView.layer.cornerRadius = 8

        let containerStackView = UIStackView()
        containerStackView.axis = .vertical
        containerStackView.spacing = 12
        containerStackView.alignment = .center
        containerStackView.edgeInsets = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        containerView.addSubview(containerStackView)

        containerStackView.snp.makeConstraints { make in
            make.height.width.centerX.centerY.equalToSuperview()
        }

        let infoContainer = UIView()
        let infoLabel = MultilineLabel(styledText: StyledText(text: String(key: .DASHBOARD_PAYMENT_SETUP_INFO), style: .bodyOffBlack))
        bag += infoContainer.add(infoLabel) { labelView in
            labelView.textAlignment = .center
            labelView.snp.makeConstraints { make in
                make.height.width.centerY.centerX.equalToSuperview()
            }
        }
        containerStackView.addArrangedSubview(infoContainer)

        let buttonContainer = UIView()
        let connectButton = Button(
            title: String(key: .DASHBOARD_PAYMENT_SETUP_BUTTON),
            type: .outline(borderColor: .purple, textColor: .purple)
        )
        bag += buttonContainer.add(connectButton) { buttonView in
            buttonView.snp.makeConstraints { make in
                make.width.height.centerY.centerX.equalToSuperview()
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
            make.bottom.equalToSuperview().inset(25)
        }
        
        return (wrapper, bag)
    }
}
