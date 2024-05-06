import Claims
import Contacts
import Foundation
import Home
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

extension AppJourney {
    static func claimDetailJourney(claim: ClaimModel) -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: ClaimDetailView(claim: claim)
        ) { action in
            if case .closeClaimStatus = action {
                PopJourney()
            } else if case let .navigation(navAction) = action {
                if case let .openFilesFor(claim, files) = navAction {
                    openFilesFor(claim: claim, files: files)
                }
            }
        }
        .hidesBottomBarWhenPushed
    }

    private static func openFilesFor(claim: ClaimModel, files: [File]) -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: ClaimFilesView(endPoint: claim.targetFileUploadUri, files: files) { _ in
                let claimStore: ClaimsStore = globalPresentableStoreContainer.get()
                claimStore.send(.fetchClaims)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    let nav = UIApplication.shared.getTopViewControllerNavigation()
                    nav?.setNavigationBarHidden(false, animated: true)
                    let claimStore: ClaimsStore = globalPresentableStoreContainer.get()
                    claimStore.send(.navigation(action: .dismissAddFiles))
                }
            },
            style: .modally(presentationStyle: .overFullScreen),
            options: .largeNavigationBar
        ) { action in
            if case let .navigation(navAction) = action {
                if case .dismissAddFiles = navAction {
                    PopJourney()
                }
            }
        }
        .onDismiss {
            let store: ClaimsStore = globalPresentableStoreContainer.get()
            store.send(.refreshFiles)
        }
        .withDismissButton

    }

    @JourneyBuilder
    static func startClaimsJourney(from origin: ClaimsOrigin) -> some JourneyPresentation {
        DismissJourney()
    }

    @ViewBuilder
    static func honestyPledge(from origin: ClaimsOrigin) -> some View {
        HonestyPledge(onConfirmAction: {

        })
    }
}

extension JourneyPresentation {
    func sendActionOnDismiss<S: Store>(_ storeType: S.Type, _ action: S.Action) -> Self {
        return self.onDismiss {
            let store: S = self.presentable.get()

            store.send(action)
        }
    }
}
