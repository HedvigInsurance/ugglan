import Apollo
import Flow
import Foundation
import Presentation
import SnapKit
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

public struct RenewalCardView: View {
    @PresentableStore var store: HomeStore
    @State private var showMultipleAlert = false
    @State private var showFailedToOpenUrlAlert = false

    public init() {}

    private func buildSheetButtons(contracts: [Contract]) -> [ActionSheet.Button] {
        var buttons = contracts.map { contract in
            ActionSheet.Button.default(Text(contract.displayName)) {
                openDocument(contract)
            }
        }
        buttons.append(ActionSheet.Button.cancel())
        return buttons
    }

    private func dateComponents(from renewalDate: Date) -> DateComponents {
        return Calendar.current.dateComponents(
            [.day],
            from: Date(),
            to: renewalDate
        )
    }

    private func openDocument(_ contract: Contract) {
        if let draftCertificateUrl = contract.upcomingRenewal?.draftCertificateUrl,
            let url = URL(string: draftCertificateUrl)
        {
            store.send(.openDocument(contractURL: url))
        } else {
            showFailedToOpenUrlAlert = true
        }
    }

    public var body: some View {
        VStack {
            PresentableStoreLens(
                HomeStore.self,
                getter: { state in
                    state.upcomingRenewalContracts
                }
            ) { contracts in
                if contracts.count > 1,
                    contracts.allSatisfy({ contract in
                        contract.upcomingRenewal?.renewalDate == contracts.first?.upcomingRenewal?.renewalDate
                    }), let renewalDate = contracts.first?.upcomingRenewal?.renewalDate?.localDateToDate
                {
                    hCard(
                        titleIcon: hCoreUIAssets.document.image,
                        title: L10n.dashboardMultipleRenewalsPrompterTitle,
                        bodyText: L10n.dashboardMultipleRenewalsPrompterBody(
                            dateComponents(from: renewalDate).day ?? 0
                        ),
                        backgroundColor: hTintColor.lavenderTwo
                    ) {
                        hButton.SmallButtonOutlined {
                            showMultipleAlert = true
                        } content: {
                            L10n.dashboardMultipleRenewalsPrompterButton.hText()
                        }
                        .actionSheet(isPresented: $showMultipleAlert) {
                            ActionSheet(
                                title: Text(L10n.dashboardMultipleRenewalsPrompterButton),
                                buttons: buildSheetButtons(contracts: contracts)
                            )
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        ForEach(contracts, id: \.displayName) { contract in
                            let renewalDate = contract.upcomingRenewal?.renewalDate?.localDateToDate ?? Date()
                            hCard(
                                titleIcon: hCoreUIAssets.document.image,
                                title: L10n.dashboardRenewalPrompterTitle(
                                    contract.displayName.lowercased()
                                ),
                                bodyText: L10n.dashboardRenewalPrompterBody(
                                    dateComponents(from: renewalDate).day ?? 0
                                ),
                                backgroundColor: hTintColor.lavenderTwo
                            ) {
                                hButton.SmallButtonOutlined {
                                    openDocument(contract)
                                } content: {
                                    L10n.dashboardRenewalPrompterBodyButton.hText()
                                }
                            }
                        }
                    }
                }
            }
            .alert(isPresented: $showFailedToOpenUrlAlert) {
                Alert(
                    title: Text("Failed to open new insurance terms"),
                    message: Text("Try again, or write to us in the chat."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .presentableStoreLensAnimation(.default)
    }
}

struct RenewalCard { @Inject var client: ApolloClient }

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

        func openDocument(_ contract: GraphQL.HomeQuery.Data.Contract, viewController: UIViewController) {
            if let draftCertificateUrl = contract.upcomingRenewal?.draftCertificateUrl,
                let url = URL(string: draftCertificateUrl)
            {
                viewController.present(
                    Document(url: url, title: L10n.insuranceCertificateTitle).withCloseButton,
                    style: .detented(.large)
                )
            }
        }

        bag += client.watch(query: GraphQL.HomeQuery())
            .map { $0.contracts.filter { contract in contract.upcomingRenewal != nil } }
            .filter { !$0.isEmpty }
            .onValueDisposePrevious { contracts -> Disposable? in let bag = DisposeBag()

                if contracts.count > 1,
                    contracts.allSatisfy({ contract in
                        contract.upcomingRenewal?.renewalDate
                            == contracts.first?.upcomingRenewal?.renewalDate
                    }),
                    let renewalDate = contracts.first?.upcomingRenewal?.renewalDate.localDateToDate
                {
                    let components = Calendar.current.dateComponents(
                        [.day],
                        from: Date(),
                        to: renewalDate
                    )

                    bag += stackView.addArranged(Spacing(height: 56), onCreate: animateIn)
                    bag +=
                        stackView.addArranged(
                            Card(
                                titleIcon: hCoreUIAssets.document.image,
                                title: L10n.dashboardMultipleRenewalsPrompterTitle,
                                body: L10n.dashboardMultipleRenewalsPrompterBody(
                                    components.day ?? 0
                                ),
                                buttonText: L10n
                                    .dashboardMultipleRenewalsPrompterButton,
                                backgroundColor: .tint(.lavenderTwo),
                                buttonType: .outline(
                                    borderColor: .brand(.primaryText()),
                                    textColor: .brand(.primaryText())
                                )
                            ),
                            onCreate: animateIn
                        )
                        .onValue { buttonView in
                            guard let viewController = buttonView.viewController else {
                                return
                            }

                            let actions = contracts.compactMap { contract in
                                Alert.Action(
                                    title: contract.displayName,
                                    action: { _ in
                                        openDocument(
                                            contract,
                                            viewController: viewController
                                        )
                                    }
                                )
                            }

                            let alert = Alert(
                                actions: [
                                    actions,
                                    [
                                        Alert.Action(
                                            title: L10n
                                                .DashboardMultipleRenewalsPrompter
                                                .ActionSheet.cancel,
                                            style: .cancel,
                                            action: {}
                                        )
                                    ],
                                ]
                                .flatMap { $0 }
                            )

                            viewController.present(
                                alert,
                                style: .sheet(from: buttonView, rect: nil)
                            )
                        }
                } else {
                    bag += contracts.map { contract in let bag = DisposeBag()
                        let renewalDate =
                            contract.upcomingRenewal?.renewalDate.localDateToDate ?? Date()
                        let components = Calendar.current.dateComponents(
                            [.day],
                            from: Date(),
                            to: renewalDate
                        )

                        bag += stackView.addArranged(
                            Spacing(height: stackView.subviews.isEmpty ? 56 : 10),
                            onCreate: animateIn
                        )
                        bag +=
                            stackView.addArranged(
                                Card(
                                    titleIcon: hCoreUIAssets.document.image,
                                    title: L10n.dashboardRenewalPrompterTitle(
                                        contract.displayName.lowercased()
                                    ),
                                    body: L10n.dashboardRenewalPrompterBody(
                                        components.day ?? 0
                                    ),
                                    buttonText: L10n
                                        .dashboardRenewalPrompterBodyButton,
                                    backgroundColor: .tint(.lavenderTwo),
                                    buttonType: .outline(
                                        borderColor: .brand(.primaryText()),
                                        textColor: .brand(.primaryText())
                                    )
                                ),
                                onCreate: animateIn
                            )
                            .compactMap { _ in stackView.viewController }
                            .onValue { viewController in
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
