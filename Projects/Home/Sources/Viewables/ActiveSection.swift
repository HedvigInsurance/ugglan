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

struct ActiveSection { @Inject var client: ApolloClient }

extension ActiveSection: Presentable {
    func materialize() -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let section = SectionView()

        section.dynamicStyle = .brandGrouped(
            insets: .init(top: 0, left: 14, bottom: 0, right: 14),
            separatorType: .none
        )

        let claims = Claims()
        let hostingView = HostingView(rootView: claims)

        section.append(hostingView)

        bag += {
            hostingView.removeFromSuperview()
        }

        bag += section.append(ConnectPaymentCard())
        bag += section.append(RenewalCard())
        bag += section.append(CommonClaimsCollection())

        return (section, bag)
    }
}
