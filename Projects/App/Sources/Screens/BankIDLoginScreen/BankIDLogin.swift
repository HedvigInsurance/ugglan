import Apollo
import Flow
import Form
import Foundation
import hCore
import Presentation
import UIKit

struct BankIDLogin {
    @Inject var client: ApolloClient
}

extension BankIDLogin: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        switch Localization.Locale.currentLocale.market {
        case .se:
            return BankIDLoginSweden().withCloseButton.materialize()
        case .no:
            return BankIDLoginNorway().withCloseButton.materialize()
        }
    }
}
