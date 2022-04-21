import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct SignSection {}

extension QuoteBundle.AppConfiguration.ApproveButtonTerminology {
    var displayValue: String {
        switch self {
        case .approveChanges:
            return L10n.offerApproveChanges
        case .confirmPurchase:
            return L10n.offerConfirmPurchase
        default:
            return ""
        }
    }
}

extension SignSection: Presentable {
    func materialize() -> (SectionView, Disposable) {
        let section = SectionView()
        let bag = DisposeBag()

        let store: OfferStore = self.get()

        let row = RowView()
        section.append(row)

        bag += store.stateSignal
            .map {
                (
                    $0.offerData?.signMethodForQuotes,
                    $0.currentVariant?.bundle.appConfiguration.approveButtonTerminology
                )
            }
            .distinct(==)
            .onValueDisposePrevious { signMethodForQuotes, approveButtonTerminology in
                let innerBag = DisposeBag()

                switch signMethodForQuotes {
                case .swedishBankId:
                    let signButton = Button(
                        title: L10n.offerSignButton,
                        type: .standardIcon(
                            backgroundColor: .brand(.secondaryButtonBackgroundColor),
                            textColor: .brand(.secondaryButtonTextColor),
                            icon: .left(image: hCoreUIAssets.bankIdLogo.image, width: 20)
                        )
                    )

                    if store.state.isQuoteCart {
                        innerBag += signButton.onTapSignal.onValue {
                            store.send(.setupQuoteCartForCheckout)
                        }

                        innerBag += store.stateSignal.map { $0.checkoutStatus }
                            .onValue { status in
                                guard status == .pending else { return }
                                row.viewController?
                                    .present(
                                        SwedishBankIdSign(),
                                        style: .detented(.preferredContentSize),
                                        options: [
                                            .defaults, .prefersLargeTitles(true),
                                            .largeTitleDisplayMode(.always),
                                        ]
                                    )
                            }
                    } else {
                        innerBag += signButton.onTapSignal.compactMap { _ in row.viewController }
                            .onValue { viewController in
                                viewController.present(
                                    SwedishBankIdSign(),
                                    style: .detented(.preferredContentSize),
                                    options: [
                                        .defaults, .prefersLargeTitles(true),
                                        .largeTitleDisplayMode(.always),
                                    ]
                                )
                            }
                    }

                    innerBag += row.append(signButton)
                case .norwegianBankId, .danishBankId:
                    break
                case .simpleSign:
                    let signButton = Button(
                        title: L10n.offerSignButton,
                        type: .standard(
                            backgroundColor: .brand(.secondaryButtonBackgroundColor),
                            textColor: .brand(.secondaryButtonTextColor)
                        )
                    )

                    innerBag += signButton.onTapSignal.compactMap { _ in row.viewController }
                        .onValue { viewController in
                            store.send(.startCheckout)
                        }

                    innerBag += row.append(signButton)
                case .approveOnly:
                    let signButton = Button(
                        title: approveButtonTerminology?.displayValue ?? "",
                        type: .standard(
                            backgroundColor: .brand(.secondaryButtonBackgroundColor),
                            textColor: .brand(.secondaryButtonTextColor)
                        )
                    )

                    let loadableSignButton = LoadableButton(button: signButton)

                    innerBag += loadableSignButton.onTapSignal
                        .onValue { _ in
                            loadableSignButton.isLoadingSignal.value = true

                            let store: OfferStore = get()
                            store.send(.startSign)

                            bag += store.onAction(
                                .sign(event: .failed),
                                {
                                    loadableSignButton.isLoadingSignal.value = false
                                }
                            )
                        }

                    innerBag += row.append(loadableSignButton)
                case .unknown, .none:
                    break
                }

                return innerBag
            }

        return (section, bag)
    }
}
