//
//  OfferStartDateButton.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-14.
//

import Apollo
import Flow
import Foundation
import hCore
import Presentation
import UIKit

struct OfferStartDateButton {
    let presentingViewController: UIViewController
    @Inject var client: ApolloClient
}

extension OfferStartDateButton: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()

        let containerStackView = UIStackView()
        containerStackView.alignment = .fill
        containerStackView.axis = .vertical

        let button = UIControl()
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 6
        button.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001).concatenating(CGAffineTransform(translationX: 0, y: -30))
        button.alpha = 0
        bag += button.applyBorderColor { _ -> UIColor in
            .primaryText
        }

        containerStackView.addArrangedSubview(button)

        let dataSignal = client.watch(query: OfferQuery())

        bag += dataSignal.take(first: 1).animated(style: SpringAnimationStyle.mediumBounce(delay: 1)) { _ in
            button.transform = CGAffineTransform.identity
            button.alpha = 1
        }

        let touchUpInside = button.signal(for: .touchUpInside)
        bag += touchUpInside.feedback(type: .impactLight)

        let chooseStartDate = ChooseStartDate()

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 8
        stackView.layoutMargins = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.isUserInteractionEnabled = false
        button.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        let keyLabel = UILabel(value: L10n.startDateBtn, style: .bodyButtonText)
        stackView.addArrangedSubview(keyLabel)

        let valueLabel = UILabel(value: "", style: .bodyBookButtonText)
        stackView.addArrangedSubview(valueLabel)

        let iconView = Icon(icon: Asset.chevronRight, iconWidth: 20)
        iconView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        stackView.addArrangedSubview(iconView)

        iconView.snp.makeConstraints { make in
            make.width.equalTo(20)
        }

        let alert = Alert<Void>(title: L10n.alertTitleStartdate,
                                message: L10n.alertDescriptionStartdate,
                                tintColor: .black,
                                actions: [Alert.Action(title: L10n.alertCancel, action: {}),
                                          Alert.Action(title: L10n.alertContinue, action: {
                                              self.presentingViewController.present(
                                                  chooseStartDate.withCloseButton,
                                                  style: .modally()
                                              )
                                      })])

        bag += touchUpInside.onValue { _ in
            bag += self.client.fetch(query: OfferQuery()).map { $0.data }.onValue { result in
                if result?.insurance.previousInsurer != nil, result?.lastQuoteOfMember.asCompleteQuote?.startDate == nil {
                    self.presentingViewController.present(alert)
                } else {
                    self.presentingViewController.present(
                        chooseStartDate.withCloseButton,
                        style: .modally()
                    )
                }
            }
        }

        bag += client.watch(query: OfferQuery()).map { $0.data }.onValue { result in
            if result?.insurance.previousInsurer != nil, result?.lastQuoteOfMember.asCompleteQuote?.startDate == nil {
                valueLabel.value = L10n.startDateExpires
            } else if result?.insurance.previousInsurer == nil, result?.lastQuoteOfMember.asCompleteQuote?.startDate == nil {
                valueLabel.value = L10n.chooseDateBtn
            } else {
                valueLabel.value = result?.lastQuoteOfMember.asCompleteQuote?.startDate ?? ""
            }
        }

        bag += dataSignal.map { $0.data?.lastQuoteOfMember.asCompleteQuote?.startDate?.localDateToDate }.onValue { startDay in
            if let startDate = startDay {
                if Calendar.current.isDateInToday(startDate) {
                    valueLabel.value = L10n.startDateToday
                } else {
                    valueLabel.value = startDate.localDateString ?? ""
                }
            }
        }

        return (containerStackView, bag)
    }
}
