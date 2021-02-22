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
        case .no:
            return BankIDLoginNorway().wrappedInCloseButton().materialize()
        case .dk:
            return NemIDLogin().wrappedInCloseButton().materialize()
        }
    } 
}
