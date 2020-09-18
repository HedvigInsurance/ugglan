import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import SafariServices
import UIKit

struct OfferTermsLinks {
    @Inject var client: ApolloClient
}

extension OfferTermsLinks: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.edgeInsets = UIEdgeInsets(horizontalInset: 16, verticalInset: 0)

        func openUrl(_ url: URL) {
            stackView.viewController?.present(SFSafariViewController(url: url), animated: true, completion: nil)
        }

        bag += client.fetch(query: GraphQL.OfferQuery()).valueSignal.compactMap { $0.insurance }.onValueDisposePrevious { insurance in
            let innerBag = DisposeBag()

            if let policyUrl = URL(string: insurance.policyUrl) {
                let button = Button(title: L10n.offerTerms, type: .standard(backgroundColor: .lightGray, textColor: .black))

                innerBag += button.onTapSignal.onValue { _ in
                    openUrl(policyUrl)
                }

                innerBag += stackView.addArranged(button.wrappedIn(UIStackView()))
            }

            if let presaleUrl = URL(string: insurance.presaleInformationUrl) {
                let button = Button(title: L10n.offerPresaleInformation, type: .standard(backgroundColor: .lightGray, textColor: .black))

                innerBag += button.onTapSignal.onValue { _ in
                    openUrl(presaleUrl)
                }

                innerBag += stackView.addArranged(button.wrappedIn(UIStackView()))
            }

            if let privacyPolicyUrl = URL(string: L10n.privacyPolicyUrl) {
                let button = Button(title: L10n.offerPrivacyPolicy, type: .standard(backgroundColor: .lightGray, textColor: .black))

                innerBag += button.onTapSignal.onValue { _ in
                    openUrl(privacyPolicyUrl)
                }

                innerBag += stackView.addArranged(button)
            }

            return innerBag
        }

        return (stackView, bag)
    }
}
