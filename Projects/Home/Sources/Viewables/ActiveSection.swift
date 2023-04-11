import Apollo
import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct ActiveSection<ClaimsContent: View, CommonClaims: View> {
    @Inject var giraffe: hGiraffe
    var claimsContent: ClaimsContent
    var commonClaims: CommonClaims
}

extension ActiveSection: Presentable {
    func materialize() -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let section = SectionView()

        section.dynamicStyle = .brandGrouped(
            insets: .init(top: 0, left: 14, bottom: 0, right: 14),
            separatorType: .none
        )

        let hostingView = HostingView(rootView: claimsContent)

        section.append(hostingView)

        bag += {
            hostingView.removeFromSuperview()
        }

        if hAnalyticsExperiment.connectPaymentReminder {
            bag += section.append(ConnectPaymentCard())
            bag += section.append(RenewalCard())
        }

        if hAnalyticsExperiment.homeCommonClaim {
            let commonClaimsView = HostingView(rootView: commonClaims)
            section.append(commonClaimsView)
        }

        return (section, bag)
    }
}
