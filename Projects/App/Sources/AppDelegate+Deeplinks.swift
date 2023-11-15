import Contracts
import CoreDependencies
import Flow
import Foundation
import Payment
import Presentation
import Profile
import UIKit
import hAnalytics
import hCore

extension AppDelegate {
    func handleDeepLink(_ dynamicLinkUrl: URL, fromVC: UIViewController) {
        guard let path = dynamicLinkUrl.pathComponents.compactMap({ DeepLink(rawValue: $0) }).first else {
            return
        }
        guard ApplicationState.currentState?.isOneOf([.loggedIn]) == true else { return }

        if path == .directDebit {
            deepLinkDisposeBag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                .onValue { [weak self] _ in
                    UIApplication.shared.getTopViewController()?
                        .present(
                            PaymentSetup(setupType: .initial)
                                .journeyThenDismiss
                        )
                        .onValue { _ in

                        }
                    self?.deepLinkDisposeBag.dispose()
                }
        } else if path == .sasEuroBonus {
            deepLinkDisposeBag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                .onValue { [weak self] _ in
                    let profileStore: ProfileStore = globalPresentableStoreContainer.get()
                    self?.deepLinkDisposeBag += profileStore.actionSignal.onValue { action in
                        if case .setMemberDetails = action {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                if let shouldShowEuroBonus = profileStore.state.partnerData?.shouldShowEuroBonus {
                                    self?.deepLinkDisposeBag.dispose()
                                    let vc = EuroBonusView.journey
                                    let disposeBag = DisposeBag()
                                    disposeBag += fromVC.present(vc)
                                }
                            }
                        }
                    }
                    profileStore.send(.fetchMemberDetails)
                }
        } else if path == .editCoInsured {
            let contractId = getContractId(from: dynamicLinkUrl)
            deepLinkDisposeBag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                .onValue { [weak self] _ in
                    let contractStore: ContractStore = globalPresentableStoreContainer.get()
                    self?.deepLinkDisposeBag += contractStore.actionSignal
                        .filter(predicate: { action in
                            if case .setActiveContracts = action {
                                return true
                            }
                            return false
                        })
                        .onValue { _ in
                            let ugglanStore: UgglanStore = globalPresentableStoreContainer.get()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                if let contractId, let contract = contractStore.state.contractForId(contractId) {
                                    ugglanStore.send(.makeTabActive(deeplink: .insurances))
                                    contractStore.send(
                                        .openDetail(
                                            contractId: contractId,
                                            title: contract.currentAgreement?.productVariant.displayName ?? ""
                                        )
                                    )
                                } else {
                                    ugglanStore.send(.makeTabActive(deeplink: .home))
                                }
                            }
                            self?.deepLinkDisposeBag.dispose()
                        }
                    contractStore.send(.fetchContracts)
                }
        } else {
            deepLinkDisposeBag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                .onValue { [weak self] _ in
                    let store: UgglanStore = globalPresentableStoreContainer.get()
                    store.send(.makeTabActive(deeplink: path))
                    self?.deepLinkDisposeBag.dispose()
                }
        }
    }

    private func getContractId(from url: URL) -> String? {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        guard let queryItems = urlComponents.queryItems else { return nil }
        return queryItems.first(where: { $0.name == "contractId" })?.value
        //        let items = queryItems as [NSURLQueryItem]
        //        if url.scheme == "https",
        //            let queryItem = items.first,
        //            queryItem.name == "contractId",
        //            let contractId = queryItem.value
        //        {
        //            return String(contractId)
        //        }
        //        return nil
    }
}
