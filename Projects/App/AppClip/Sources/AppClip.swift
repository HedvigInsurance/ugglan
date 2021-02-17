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
                    EmbarkPlansView()
                        .navigationBarTitleDisplayMode(.inline)
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
                    }
                }).onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: handleUserActivity)
            }
        }
    }
    
    func handleUserActivity(_ userActivity: NSUserActivity) {
        enum WebLocale: String {
            case se
            case se_en = "se-en"
            case no
            case no_en = "no-en"
            
            var locale: Localization.Locale {
                switch self {
                case .se:
                    return .sv_SE
                case .se_en:
                    return .en_SE
                case .no:
                    return .nb_NO
                case .no_en:
                    return .en_NO
                }
            }
        }
        
        guard
            let incomingURL = userActivity.webpageURL,
            let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true)
        else {
            return
        }
        
        guard let localeCode = components.path?.dropFirst() else {
            return
        }
        
        let webLocale = WebLocale(rawValue: String(localeCode)) ?? .se
        
        Localization.Locale.currentLocale = webLocale.locale
        hasInitialized = true
    }
}
