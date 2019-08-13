//
//  RenewalsSection.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-13.
//

import Flow
import Form
import Foundation
import UIKit

struct RenewalsSection {
    let dataSignal: ReadWriteSignal<DashboardQuery.Data.Insurance?> = ReadWriteSignal(nil)
    let presentingViewController: UIViewController
}

extension RenewalsSection: Viewable {
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
        
        let titleLabel = MultilineLabel(value: String(key: .DASHBOARD_RENEWAL_PROMPTER_TITLE), style: TextStyle.rowTitleBold.centered())
        bag += containerStackView.addArranged(titleLabel)

        let infoLabel = MultilineLabel(value: "", style: TextStyle.bodyOffBlack.centered())
        bag += containerStackView.addArranged(infoLabel)

        let buttonContainer = UIView()
        let connectButton = Button(
            title: String(key: .DASHBOARD_RENEWAL_PROMPTER_CTA),
            type: .outline(borderColor: .purple, textColor: .purple)
        )
        bag += buttonContainer.add(connectButton) { buttonView in
            buttonView.snp.makeConstraints { make in
                make.height.centerY.centerX.equalToSuperview()
            }
        }

        bag += connectButton.onTapSignal.onValue { _ in
            self.presentingViewController.present(InsuranceCertificate(type: .renewal), options: [.autoPop, .largeTitleDisplayMode(.never)])
        }

        containerStackView.addArrangedSubview(buttonContainer)

        wrapper.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview().inset(16)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        bag += dataSignal.compactMap { $0?.renewal?.date }.onValue { stringDate in
            let formatter = DateFormatter.iso8601
            
            guard let date = formatter.date(from: stringDate) else {
                return
            }
            
            let calendar = Calendar.current

            let dateFrom = calendar.startOfDay(for: Date())
            let dateTo = calendar.startOfDay(for: date)

            let components = calendar.dateComponents([.day], from: dateFrom, to: dateTo)
            
            infoLabel.styledTextSignal.value = StyledText(
                text: String(key: .DASHBOARD_RENEWAL_PROMPTER_BODY(daysUntilRenewal: "\(components.day ?? 0)")),
                style: TextStyle.bodyOffBlack.centered()
            )
        }

        bag += dataSignal.wait(until: wrapper.hasWindowSignal).delay(by: 0.5).animated(style: SpringAnimationStyle.lightBounce()) { insurance in
            guard insurance?.renewal != nil else {
                containerStackView.alpha = 0
                
                bag += Signal(after: 0.25).animated(style: AnimationStyle.easeOut(duration: 0.25)) {
                    wrapper.animationSafeIsHidden = true
                }
                return
            }
            
            wrapper.animationSafeIsHidden = false
                        
            bag += Signal(after: 0.25).animated(style: AnimationStyle.easeOut(duration: 0.25)) {
                containerStackView.alpha = 1
            }
        }

        return (wrapper, bag)
    }
}

