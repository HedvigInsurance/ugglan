import Apollo
import Flow
import Form
import Foundation
import hCore
import Presentation
import UIKit
import hCoreUI

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

extension MenuChild {
    public static var login: MenuChild {
        MenuChild(
            title: L10n.settingsLoginRow,
            style: .default,
            image: hCoreUIAssets.memberCard.image
        ) { viewController in
            viewController.present(
                Login(),
                style: .detented(.large)
            )
        }
    }
}
