//
//  BankIDLogin.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-05.
//

import Apollo
import Flow
import Form
import Foundation
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
