//
//  OfferStartDateButton.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-14.
//

import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import Common
import Space
import ComponentKit

struct OfferStartDateButton {
    let containerScrollView: UIScrollView
    let presentingViewController: UIViewController
    @Inject var client: ApolloClient
}

extension OfferStartDateButton: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()

        let containerStackView = UIStackView()
        containerStackView.alignment = .center
        containerStackView.axis = .vertical

        let button = UIControl()
        button.layer.borderWidth = 1
        button.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001).concatenating(CGAffineTransform(translationX: 0, y: -30))
        button.alpha = 0
        bag += button.applyBorderColor { _ -> UIColor in
            .white
        }

        bag += button.applyCornerRadius { _ -> CGFloat in
            button.layer.frame.height / 2
        }

        containerStackView.addArrangedSubview(button)

        bag += containerScrollView.contentOffsetSignal.onValue { contentOffset in
            containerStackView.transform = CGAffineTransform(
                translationX: 0,
                y: contentOffset.y / 5
            )
        }

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
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.layoutMargins = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.isUserInteractionEnabled = false
        button.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        let keyLabel = UILabel(value: String(key: .START_DATE_BTN), style: .bodyButtonText)
        stackView.addArrangedSubview(keyLabel)
        keyLabel.textColor = .white

        let valueLabel = UILabel(value: "", style: .bodyBoldButtonText)
        valueLabel.textColor = .white
        stackView.addArrangedSubview(valueLabel)

        let iconView = Icon(icon: Asset.chevronRightWhite.image, iconWidth: 20)
        iconView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        stackView.addArrangedSubview(iconView)

        let alert = Alert<Void>(title: String(key: .ALERT_TITLE_STARTDATE),
                                message: String(key: .ALERT_DESCRIPTION_STARTDATE),
                                tintColor: .black,
                                actions: [Alert.Action(title: String(key: .ALERT_CANCEL), action: {}),
                                          Alert.Action(title: String(key: .ALERT_CONTINUE), action: {
                                              bag += self.presentingViewController.present(
                                                  DraggableOverlay(
                                                      presentable: chooseStartDate,
                                                      presentationOptions: [.defaults, .prefersNavigationBarHidden(true)]
                                                  )
                                              )
                                      })])

        bag += touchUpInside.onValue { _ in
            bag += self.client.fetch(query: OfferQuery()).map { $0.data }.onValue { result in
                if result?.insurance.previousInsurer != nil, result?.lastQuoteOfMember.asCompleteQuote?.startDate == nil {
                    self.presentingViewController.present(alert)
                } else {
                    bag += self.presentingViewController.present(
                        DraggableOverlay(
                            presentable: chooseStartDate,
                            presentationOptions: [.defaults, .prefersNavigationBarHidden(true)]
                        )
                    ).disposable
                }
            }
        }

        bag += client.watch(query: OfferQuery()).map { $0.data }.onValue { result in

            if result?.insurance.previousInsurer != nil, result?.lastQuoteOfMember.asCompleteQuote?.startDate == nil {
                valueLabel.text = String(key: .START_DATE_EXPIRES)
            } else if result?.insurance.previousInsurer == nil, result?.lastQuoteOfMember.asCompleteQuote?.startDate == nil {
                valueLabel.text = String(key: .CHOOSE_DATE_BTN)
            } else {
                valueLabel.text = result?.lastQuoteOfMember.asCompleteQuote?.startDate
            }
        }

        bag += dataSignal.map { $0.data?.lastQuoteOfMember.asCompleteQuote?.startDate?.description.localDateToDate }.onValue { startDay in
            if let startDate = startDay {
                if Calendar.current.isDateInToday(startDate) {
                    valueLabel.text = String(key: .START_DATE_TODAY)
                } else {
                    valueLabel.text = startDate.localDateString
                }
            }
        }

        return (containerStackView, bag)
    }
}
