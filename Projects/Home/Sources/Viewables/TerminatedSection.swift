import Apollo
import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct TerminatedSection<ClaimsContent: View> {
    @Inject var client: ApolloClient
    var claimsContent: ClaimsContent
}

extension TerminatedSection: Presentable {
    func materialize() -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let section = SectionView()
        section.dynamicStyle = .brandGrouped(separatorType: .none)

        var titleLabel = MultilineLabel(value: "", style: .brand(.prominentTitle(color: .primary)))
        bag += section.append(titleLabel)

        section.appendSpacing(.inbetween)

        client.fetch(query: GiraffeGraphQL.HomeQuery())
            .onValue { data in
                titleLabel.value = L10n.HomeTab.terminatedWelcomeTitle(data.member.firstName ?? "")
            }

        let subtitleLabel = MultilineLabel(
            value: L10n.HomeTab.terminatedBody,
            style: .brand(.body(color: .secondary))
        )
        bag += section.append(subtitleLabel)

        section.appendSpacing(.top)

        let hostingView = HostingView(rootView: claimsContent)
        section.append(hostingView)
        bag += {
            hostingView.removeFromSuperview()
        }

        return (section, bag)
    }
}
