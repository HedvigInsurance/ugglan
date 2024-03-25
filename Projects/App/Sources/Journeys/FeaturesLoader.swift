import Claims
import Combine
import Contracts
import Flow
import Foundation
import Presentation
import Profile
import SwiftUI
import hCore
import hCoreUI

struct ExperimentsLoaderScreen: View {
    @State var cancelable: AnyCancellable?
    var body: some View {
        VStack {
            Spacer()
            Image(uiImage: hCoreUIAssets.wordmark.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40)
            Spacer()
        }
        .ignoresSafeArea()
        .onAppear {
            Task {
                let profileStore: ProfileStore = globalPresentableStoreContainer.get()
                profileStore.send(.updateLanguage)
                let contractStore: ContractStore = globalPresentableStoreContainer.get()
                await contractStore.sendAsync(.fetchContracts)
                UIApplication.shared.appDelegate.setupFeatureFlags(onComplete: { success in
                    DispatchQueue.main.async {
                        let window = UIApplication.shared.appDelegate.window
                        UIView.transition(
                            with: window,
                            duration: 0.3,
                            options: .transitionCrossDissolve,
                            animations: {}
                        )
                        UIApplication.shared.appDelegate.bag += UIApplication.shared.appDelegate.window.present(
                            AppJourney.tabJourney
                        )
                    }
                })
            }
        }
    }
}

extension ExperimentsLoaderScreen {
    var journey: some JourneyPresentation {
        HostingJourney(rootView: self)
    }
}
