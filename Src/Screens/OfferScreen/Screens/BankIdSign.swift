//
//  BankIdSign.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-12.
//

import Foundation
import Flow
import Presentation
import UIKit
import Apollo

struct BankIdSign {
    let client: ApolloClient
    
    init(client: ApolloClient = ApolloContainer.shared.client) {
        self.client = client
    }
}

extension BankIdSign: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        let bag = DisposeBag()
        
        let view = UIView()
        viewController.view = view
        
        let containerStackView = UIStackView()
        containerStackView.axis = .vertical
        containerStackView.alignment = .leading
        bag += containerStackView.applySafeAreaBottomLayoutMargin()
        bag += containerStackView.applyPreferredContentSize(on: viewController)
        
        view.addSubview(containerStackView)
        
        containerStackView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        containerStackView.addArrangedSubview(Icon(icon: Asset.bankIdLogo, iconWidth: 120))
        bag += containerStackView.addArranged(LoadingIndicator(showAfter: 0, color: .purple))
        
        bag += self.client.subscribe(
            subscription: SignStatusSubscription()
        ).compactMap { $0.data?.signStatus?.status?.signState }
            .filter { state in state == .completed }
            .take(first: 1)
            .onValue { _ in
                viewController.present(LoggedIn(), options: [.prefersNavigationBarHidden(true)])
            }

        bag += self.client.perform(mutation: SignOfferMutation()).valueSignal.compactMap { result in result.data?.signOfferV2.autoStartToken }.onValue { autoStartToken in
            let urlScheme = Bundle.main.urlScheme ?? ""
            guard let url = URL(string: "bankid:///?autostarttoken=\(autoStartToken)&redirect=\(urlScheme)://bankid") else { return }

            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                let alert = Alert<Void>(
                    title: String(key: .TRUSTLY_MISSING_BANK_ID_APP_ALERT_TITLE),
                    message: String(key: .TRUSTLY_MISSING_BANK_ID_APP_ALERT_MESSAGE),
                    actions: [
                        Alert.Action(
                            title: String(key: .TRUSTLY_MISSING_BANK_ID_APP_ALERT_ACTION)
                        ) { () },
                    ]
                )

                viewController.present(alert)
            }
        }
        
        return (viewController, Future { completion in
            
            return bag
        })
    }
}
