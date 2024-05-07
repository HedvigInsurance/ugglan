import Chat
import Contracts
import CoreDependencies
import Flow
import Foundation
import Home
import Payment
import Presentation
import Profile
import SwiftUI
import TerminateContracts
import hCore
import hGraphQL

extension AppDelegate {
    func handleDeepLink(_ dynamicLinkUrl: URL, fromVC: UIViewController) {
        guard let path = dynamicLinkUrl.pathComponents.compactMap({ DeepLink(rawValue: $0) }).first else {
            return
        }
        guard ApplicationState.currentState?.isOneOf([.loggedIn]) == true else { return }
        log.info("Deep link clicked: \(path)", attributes: ["url": dynamicLinkUrl])

        if path == .directDebit {
            deepLinkDisposeBag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                .onValue { _ in
                    /* TODO: ADD deeplink for connect payments */
                }
        } else if path == .sasEuroBonus {
            deepLinkDisposeBag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                .onValue { [weak self] _ in
                    let profileStore: ProfileStore = globalPresentableStoreContainer.get()
                    self?.deepLinkDisposeBag += profileStore.actionSignal.onValue { action in
                        if case .setMemberDetails = action {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                if let shouldShowEuroBonus = profileStore.state.partnerData?.shouldShowEuroBonus {
                                    /* TODO: ADD deeplink for euro bonus */
                                }
                            }
                        }
                    }
                    profileStore.send(.fetchMemberDetails)
                }
        } else if path == .contract {
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
                            ugglanStore.send(.closeChat)
                            let chatStore: ChatStore = globalPresentableStoreContainer.get()
                            chatStore.send(.navigation(action: .closeChat))
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                ugglanStore.send(.makeTabActive(deeplink: .insurances))
                                if let contractId {
                                    if let contract = contractStore.state.contractForId(contractId) {
                                        // TODO: add logic to open contract detail
                                    } else {
                                        // TODO: add logic to open contract detail error screen
                                    }
                                } else {
                                    ugglanStore.send(.makeTabActive(deeplink: .home))
                                }
                            }
                            self?.deepLinkDisposeBag.dispose()
                        }
                    contractStore.send(.fetchContracts)
                }
        } else if path == .payments {
            deepLinkDisposeBag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                .onValue { [weak self] _ in
                    /* TODO: Add deep link for payments */
                }
        } else if path == .travelCertificate {
            deepLinkDisposeBag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                .onValue { [weak self] _ in
                    /* TODO: Add deep link for travel certificate */
                }
        } else if path == .helpCenter {
            deepLinkDisposeBag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                .onValue { [weak self] _ in

                    let store: UgglanStore = globalPresentableStoreContainer.get()
                    store.send(.makeTabActive(deeplink: .home))

                    let homeStore: HomeStore = globalPresentableStoreContainer.get()
                    homeStore.send(.openHelpCenter)
                    self?.deepLinkDisposeBag.dispose()
                }

        } else if path == .moveContract {
            deepLinkDisposeBag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                .onValue { [weak self] _ in
                    /* TODO: Add deep link for moving flow certificate */
                }
        } else if path == .terminateContract {
            deepLinkDisposeBag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                .onValue { [weak self] _ in
                    self?.deepLinkDisposeBag.dispose()
                    let contractStore: ContractStore = globalPresentableStoreContainer.get()

                    let contractsConfig: [TerminationConfirmConfig] = contractStore.state.activeContracts
                        .filter({ $0.canTerminate })
                        .map({
                            $0.asTerminationConfirmConfig
                        })
                    /* TODO: Add deep link for moving termination flow */
                }

        } else if path == .openChat {
            deepLinkDisposeBag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                .onValue { _ in
                    /* TODO: Add deep link for chat */
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
    }
}

extension URL {
    public var contractName: String? {
        guard let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return nil }
        guard let queryItems = urlComponents.queryItems else { return nil }
        let contractIdString = queryItems.first(where: { $0.name == "contractId" })?.value
        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        return contractStore.state.contractForId(contractIdString ?? "")?.currentAgreement?.productVariant.displayName
    }
}
