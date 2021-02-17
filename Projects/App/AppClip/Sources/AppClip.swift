import Apollo
import Embark
import Flow
import Form
import hCore
import hGraphQL
import SwiftUI
import UIKit

struct EmbarkView: UIViewControllerRepresentable {
    let name: String
    let state: EmbarkState
    let bag = DisposeBag()

    func makeUIViewController(context _: Context) -> UIViewController {
        let (viewController, embarkBag) = Embark(name: name, state: state).materialize()
        bag += embarkBag
        return viewController
    }

    func updateUIViewController(_: UIViewController, context _: Context) {}
}

struct EmbarkPlansView: UIViewControllerRepresentable {
    let bag = DisposeBag()

    func makeUIViewController(context _: Context) -> UIViewController {
        let (viewController, embarkBag) = EmbarkPlans().materialize()
        bag += embarkBag
        return viewController
    }

    func updateUIViewController(_: UIViewController, context _: Context) {}
}

@main
struct AppClip: App {
    let bag = DisposeBag()
    @State var hasInitialized = false

    var body: some Scene {
        WindowGroup {
            if hasInitialized {
                NavigationView {
                    EmbarkView(name: "Web Onboarding - Swedish Needer", state: .init(externalRedirectHandler: { _ in

                    })).navigationBarTitleDisplayMode(.inline)
                }
            } else {
                Text("").onAppear(perform: {
                    DefaultStyling.installCustom()

                    ApolloClient.bundle = Bundle.main
                    ApolloClient.acceptLanguageHeader = Localization.Locale.currentLocale.acceptLanguageHeader

                    bag += ApolloClient.initClient().onValue { store, client in
                        Dependencies.shared.add(module: Module {
                            store
                        })

                        Dependencies.shared.add(module: Module {
                            client
                        })

                        self.hasInitialized = true
                    }
                })
            }
        }
    }
}
