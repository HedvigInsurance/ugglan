//
//  UpsellingFooter.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-30.
//

import Apollo
import Flow
import Form
import Foundation
import UIKit

struct UpsellingFooter {
    @Inject var client: ApolloClient
}

extension UpsellingFooter {
    struct UpsellingBox: Viewable {
        let title: String
        let description: String
        let buttonText: String

        func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
            let outerView = UIStackView()
            let stylingView = UIView()
            stylingView.layer.cornerRadius = 8
            stylingView.backgroundColor = .secondaryBackground

            outerView.addArrangedSubview(stylingView)

            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 10
            stackView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 20)
            stackView.isLayoutMarginsRelativeArrangement = true
            stylingView.addSubview(stackView)

            stackView.snp.makeConstraints { make in
                make.top.bottom.leading.trailing.equalToSuperview()
            }

            let bag = DisposeBag()

            bag += stackView.addArranged(MultilineLabel(value: title, style: .headLineSmallSmallCenter))
            bag += stackView.addArranged(MultilineLabel(value: description, style: .bodySmallSmallCenter)) { view in
                stackView.setCustomSpacing(20, after: view)
            }

            let button = Button(
                title: buttonText,
                type: .standardSmall(backgroundColor: .primaryButtonBackgroundColor, textColor: .white)
            )

            bag += button.onTapSignal.onValue { _ in
                stackView.viewController?.present(FreeTextChat().withCloseButton, style: .modally())
            }

            bag += stackView.addArranged(button.wrappedIn(UIStackView())) { view in
                view.axis = .vertical
                view.alignment = .center
            }

            return (outerView, bag)
        }
    }
}

extension UpsellingFooter: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 20, right: 15)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.alpha = 0
        stackView.transform = CGAffineTransform(translationX: 0, y: 100)
        let bag = DisposeBag()

        bag += client.watch(query: ContractsQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale()))
            .compactMap { $0.data?.contracts }
            .delay(by: 0.5)
            .onValueDisposePrevious { contracts in
                let innerBag = DisposeBag()

                innerBag += Signal(after: 0).animated(style: SpringAnimationStyle.lightBounce()) { _ in
                    stackView.alpha = 1
                    stackView.transform = CGAffineTransform.identity
                }

                switch Localization.Locale.currentLocale.market {
                case .no:
                    let hasTravelAgreement = contracts.contains(where: { contract -> Bool in
                        contract.currentAgreement.asNorwegianTravelAgreement != nil // todo
                    })

                    if !hasTravelAgreement {
                        innerBag += stackView.addArranged(UpsellingBox(
                            title: String(key: .UPSELL_NOTIFICATION_TRAVEL_TITLE),
                            description: String(key: .UPSELL_NOTIFICATION_TRAVEL_DESCRIPTION),
                            buttonText: String(key: .UPSELL_NOTIFICATION_TRAVEL_CTA)
                        ))
                    }

                    let hasHomeContentsAgreement = contracts.contains(where: { contract -> Bool in
                        contract.currentAgreement.asNorwegianHomeContentAgreement != nil
                    })

                    if !hasHomeContentsAgreement {
                        innerBag += stackView.addArranged(UpsellingBox(
                            title: String(key: .UPSELL_NOTIFICATION_CONTENT_TITLE),
                            description: String(key: .UPSELL_NOTIFICATION_CONTENT_DESCRIPTION),
                            buttonText: String(key: .UPSELL_NOTIFICATION_CONTENT_CTA)
                        ))
                    }
                case .se:
                    break
                }

                return innerBag
            }

        return (stackView, bag)
    }
}
