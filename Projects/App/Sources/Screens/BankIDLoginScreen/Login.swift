import Apollo
import Flow
import Form
import Foundation
import hCore
import Presentation
import UIKit

struct Login {
    @Inject var client: ApolloClient
}

extension Login: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        switch Localization.Locale.currentLocale.market {
        case .se:
            return BankIDLoginSweden().wrappedInCloseButton().materialize()
        case .no, .dk:
            return WebLoginFlow().wrappedInCloseButton().materialize()
        }
    }
}

struct WebLoginFlow: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let (viewController, future) = BankIDLoginView().materialize()
        let bag = DisposeBag()

        return (viewController, Future { completion in
            bag += future.onValue { id in
                bag += viewController
                    .present(
                        WebViewLogin(idNumber: id),
                        style: .default
                    ).onValue {
                        completion(.success)
                    }
            }
            return bag
        })
    }
}
