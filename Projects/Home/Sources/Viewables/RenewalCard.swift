import Apollo
import Flow
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import SnapKit
import UIKit

struct RenewalCard {
    @Inject var client: ApolloClient
}

extension RenewalCard: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let stackView = UIStackView()
        stackView.axis = .vertical

        func animateIn(_ view: UIView) {
            view.isHidden = true

            bag += Animated.now.animated(style: SpringAnimationStyle.lightBounce()) { _ in
                view.isHidden = false
            }
        }

        func openDocument(
            _ contract: GraphQL.HomeQuery.Data.Contract,
            viewController: UIViewController
        ) {
            if let draftCertificateUrl = contract.upcomingRenewal?.draftCertificateUrl,
                let url = URL(string: draftCertificateUrl) {
                viewController.present(
                    Document(
                        url: url,
                        title: L10n.insuranceCertificateTitle
                    ).withCloseButton,
                    style: .detented(.large)
                )
            }
        }

        bag += client.watch(query: GraphQL.HomeQuery())
            .map { $0.contracts.filter { contract in contract.upcomingRenewal != nil } }
            .filter { !$0.isEmpty }
            .onValueDisposePrevious { contracts -> Disposable? in
                let bag = DisposeBag()

                if
                    contracts.allSatisfy({ contract in
                        contract.upcomingRenewal?.renewalDate == contracts.first?.upcomingRenewal?.renewalDate
                    }),
                    let renewalDate = contracts.first?.upcomingRenewal?.renewalDate.localDateToDate {
                    let components = Calendar.current.dateComponents([.day], from: Date(), to: renewalDate)

                    bag += stackView.addArranged(Spacing(height: 56), onCreate: animateIn)
                    bag += stackView.addArranged(
                        Card(
                            titleIcon: hCoreUIAssets.document.image,
                            title: L10n.dashboardMultipleRenewalsPrompterTitle,
                            body: L10n.dashboardMultipleRenewalsPrompterBody(components.day ?? 0),
                            buttonText: L10n.dashboardMultipleRenewalsPrompterButton,
                            backgroundColor: .tint(.lavenderTwo),
                            buttonType: .outline(
                                borderColor: .brand(.primaryText()),
                                textColor: .brand(.primaryText())
                            )
                        ),
                        onCreate: animateIn
                    ).onValue { buttonView in
                        guard let viewController = buttonView.viewController else {
                            return
                        }

                        let actions = contracts.compactMap { contract in
                            Alert.Action(
                                title: contract.displayName,
                                action: { _ in openDocument(contract, viewController: viewController) }
                            )
                        }

                        let alert = Alert(
                            actions: [
                                actions,
                                [
                                    Alert.Action(title: L10n.DashboardMultipleRenewalsPrompter.ActionSheet.cancel, style: .cancel, action: {}),
                                ],
                            ].flatMap { $0 }
                        )

                        viewController.present(
                            alert,
                            style: .sheet(from: buttonView, rect: nil)
                        )
                    }
                } else {
                    bag += contracts.map { contract in
                        let bag = DisposeBag()
                        let renewalDate = contract.upcomingRenewal?.renewalDate.localDateToDate ?? Date()
                        let components = Calendar.current.dateComponents(
                            [.day],
                            from: Date(),
                            to: renewalDate
                        )

                        bag += stackView.addArranged(
                            Spacing(
                                height: stackView.subviews.isEmpty ? 56 : 10
                            ),
                            onCreate: animateIn
                        )
                        bag += stackView.addArranged(
                            Card(
                                titleIcon: hCoreUIAssets.document.image,
                                title: L10n.dashboardRenewalPrompterTitle(contract.displayName.lowercased()),
                                body: L10n.dashboardRenewalPrompterBody(components.day ?? 0),
                                buttonText: L10n.dashboardRenewalPrompterBodyButton,
                                backgroundColor: .tint(.lavenderTwo),
                                buttonType: .outline(
                                    borderColor: .brand(.primaryText()),
                                    textColor: .brand(.primaryText())
                                )
                            ),
                            onCreate: animateIn
                        ).compactMap { _ in stackView.viewController }.onValue { viewController in
                            openDocument(contract, viewController: viewController)
                        }

                        return bag
                    }
                }

                return bag
            }

        return (stackView, bag)
    }
}
