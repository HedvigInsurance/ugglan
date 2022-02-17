import Apollo
import Claims
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct ActiveSection<ClaimsContent: UIView> {
    @Inject var client: ApolloClient
    var claimsContent: ClaimsContent
}

extension ActiveSection: Presentable {
    func materialize() -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let section = SectionView()

        section.dynamicStyle = .brandGrouped(
            insets: .init(top: 0, left: 14, bottom: 0, right: 14),
            separatorType: .none
        )

        section.append(claimsContent)

        bag += {
            claimsContent.removeFromSuperview()
        }

        bag += section.append(ConnectPaymentCard())
        bag += section.append(RenewalCard())
        bag += section.append(CommonClaimsCollection())

        return (section, bag)
    }
}
