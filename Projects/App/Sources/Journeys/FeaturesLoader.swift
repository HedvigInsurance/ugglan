import Claims
import Combine
import Contracts
import Flow
import Foundation
import Presentation
import Profile
import SwiftUI
import UIKit
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
            let profileStore: ProfileStore = globalPresentableStoreContainer.get()
            profileStore.send(.updateLanguage)
            let contractStore: ContractStore = globalPresentableStoreContainer.get()
            contractStore.send(.fetchContracts)
            cancelable = contractStore.actionSignal.publisher.sink { _ in
            } receiveValue: { action in
                if case .fetchCompleted = action {
                    cancelable = nil
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
}

extension ExperimentsLoaderScreen {
    var journey: some JourneyPresentation {
        HostingJourney(rootView: ExperimentsLoaderScreen())
    }
}

struct NotificationLoader: Presentable {

    func materialize() -> (UIViewController, FiniteSignal<UNAuthorizationStatus>) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        viewController.view.backgroundColor = .brand(.primaryBackground())

        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        viewController.view.addSubview(activityIndicatorView)

        activityIndicatorView.startAnimating()

        activityIndicatorView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }

        return (
            viewController,
            FiniteSignal { callback in
                let current = UNUserNotificationCenter.current()
                current.getNotificationSettings(completionHandler: { settings in
                    callback(.value(settings.authorizationStatus))
                })

                return bag
            }
        )
    }
}
