import Addons
import ChangeTier
import Contracts
import CrossSell
import EditCoInsured
import Forever
import Foundation
import Home
import InsuranceEvidence
import MoveFlow
import PresentableStore
import Profile
import SubmitClaim
import SwiftUI
import TerminateContracts
import TravelCertificate
import hCore
import hCoreUI

extension View {
    func handleLoggedInPresentations(with vm: LoggedInNavigationViewModel) -> some View {
        modifier(LoggedInPresentations(vm: vm))
    }
}

struct LoggedInPresentations: ViewModifier {
    @ObservedObject var vm: LoggedInNavigationViewModel

    func body(content: Content) -> some View {
        content
            .modally(
                presented: $vm.isTravelInsurancePresented,
                options: .constant(.alwaysOpenOnTop)
            ) {
                TravelCertificateNavigation(
                    vm: vm.travelCertificateNavigationVm,
                    infoButtonPlacement: .leading,
                    useOwnNavigation: true
                )
                .handleEditCoInsured(
                    with: vm.travelCertificateNavigationVm.editCoInsuredVm
                )
            }
            .modally(
                presented: $vm.isInsuranceEvidencePresented,
                options: .constant(.alwaysOpenOnTop),
                tracking: nil
            ) {
                InsuranceEvidenceNavigation()
            }
            .modally(
                presented: $vm.isMoveContractPresented,
                options: .constant(.alwaysOpenOnTop)
            ) {
                HandleMoving()
            }
            .modally(
                item: $vm.isChangeTierPresented,
                options: .constant(.alwaysOpenOnTop),
                tracking: nil
            ) { changeTierInput in
                ChangeTierNavigation(input: changeTierInput)
            }
            .modally(
                item: $vm.isAddonPresented,
                options: .constant(.alwaysOpenOnTop),
                tracking: nil
            ) { addonInput in
                ChangeAddonNavigation(input: addonInput)
            }
            .detent(
                item: $vm.isAddonErrorPresented,

                options: .constant([.alwaysOpenOnTop])
            ) { error in
                GenericErrorView(description: error, formPosition: .compact)
                    .hStateViewButtonConfig(
                        .init(
                            actionButton: .init(
                                buttonAction: { [weak vm] in
                                    vm?.addonErrorRouter.dismiss()
                                }
                            )
                        )
                    )
                    .embededInNavigation(router: vm.addonErrorRouter, tracking: LoggedInNavigationDetentType.error)
            }
            .handleTerminateInsurance(vm: vm.terminateInsuranceVm) {
                dismissType in
                switch dismissType {
                case .done:
                    let contractStore: ContractStore = globalPresentableStoreContainer.get()
                    contractStore.send(.fetchContracts)
                    let homeStore: HomeStore = globalPresentableStoreContainer.get()
                    homeStore.send(.fetchQuickActions)
                case .chat:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                    }
                case let .openFeedback(url):
                    vm.openUrl(url: url)
                case .changeTierFoundBetterPriceStarted, .changeTierMissingCoverageAndTermsStarted:
                    break
                }
            }
            .modally(
                presented: $vm.isEuroBonusPresented,
                options: .constant(.alwaysOpenOnTop)
            ) {
                EuroBonusNavigation(useOwnNavigation: true)
            }
            .detent(
                item: $vm.isFaqTopicPresented,
                transitionType: .detent(style: [.large]),
                options: .constant(.alwaysOpenOnTop)
            ) { topic in
                HelpCenterTopicNavigation(topic: topic)
            }
            .detent(
                item: $vm.isFaqPresented,
                transitionType: .detent(style: [.large]),
                options: .constant(.alwaysOpenOnTop)
            ) { question in
                HelpCenterQuestionNavigation(question: question)
            }
    }
}
