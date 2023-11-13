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
            if let contractId = getContractId(from: dynamicLinkUrl) {
                deepLinkDisposeBag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                    .onValue { [weak self] _ in
                        let contractStore: ContractStore = globalPresentableStoreContainer.get()
                        self?.deepLinkDisposeBag += contractStore.actionSignal.onValue { action in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self?.deepLinkDisposeBag.dispose()
                                let vc = InsuredPeopleNewScreen.journey(contractId: contractId)
                                let disposeBag = DisposeBag()
                                disposeBag += fromVC.present(vc)
                            }
                        }
                        contractStore.send(.fetchContracts)
                    }
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
        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        let contractIdFromContracts: String? = contractStore.state.activeContracts
            .first(where: { $0.nbOfMissingCoInsured > 0 }).map({ $0.id })

        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return contractIdFromContracts
        }
        guard let queryItems = urlComponents.queryItems else { return contractIdFromContracts }
        let items = queryItems as [NSURLQueryItem]
        if url.scheme == "https",
            let queryItem = items.first,
            queryItem.name == "contractId",
            let contractId = queryItem.value
        {
            return String(contractId)
        }
        return contractIdFromContracts
    }
}
