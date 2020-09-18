import Apollo
import Flow
import Foundation
import hCore
import hCoreUI
import hGraphQL
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
            .brand(.primaryText())
        }

        containerStackView.addArrangedSubview(button)

        let dataSignal = client.watch(query: GraphQL.OfferQuery())

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

        let keyLabel = UILabel(value: L10n.startDateBtn, style: .brand(.headline(color: .primary)))
        stackView.addArrangedSubview(keyLabel)

        let valueLabel = UILabel(value: "", style: .brand(.headline(color: .link)))
        stackView.addArrangedSubview(valueLabel)

        let alert = Alert<Void>(title: L10n.alertTitleStartdate,
                                message: L10n.alertDescriptionStartdate,
                                tintColor: .black,
                                actions: [Alert.Action(title: L10n.alertCancel, action: {}),
                                          Alert.Action(title: L10n.alertContinue, action: {
                                              self.presentingViewController.present(
                                                  chooseStartDate.withCloseButton,
                                                  style: .detented(.scrollViewContentSize(20), .large),
                                                  options: [
                                                      .defaults,
                                                      .prefersLargeTitles(true),
                                                      .largeTitleDisplayMode(.always),
                                                  ]
                                              )
                                      })])

        bag += touchUpInside.onValue { _ in
            bag += self.client.fetch(query: GraphQL.OfferQuery()).onValue { data in
                if data.insurance.previousInsurer != nil, data.lastQuoteOfMember.asCompleteQuote?.startDate == nil {
                    self.presentingViewController.present(alert)
                } else {
                    self.presentingViewController.present(
                        chooseStartDate.withCloseButton,
                        style: .detented(.scrollViewContentSize(20), .large),
                        options: [
                            .defaults,
                            .prefersLargeTitles(true),
                            .largeTitleDisplayMode(.always),
                        ]
                    )
                }
            }
        }

        bag += client.watch(query: GraphQL.OfferQuery()).onValue { data in
            if data.insurance.previousInsurer != nil, data.lastQuoteOfMember.asCompleteQuote?.startDate == nil {
                valueLabel.value = L10n.startDateExpires
            } else if data.insurance.previousInsurer == nil, data.lastQuoteOfMember.asCompleteQuote?.startDate == nil {
                valueLabel.value = L10n.chooseDateBtn
            } else {
                valueLabel.value = data.lastQuoteOfMember.asCompleteQuote?.startDate ?? ""
            }
        }

        bag += dataSignal.map { $0.lastQuoteOfMember.asCompleteQuote?.startDate?.localDateToDate }.onValue { startDay in
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
