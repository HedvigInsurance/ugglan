import Apollo
import Flow
import Foundation
import hCore
import hCoreUI
import hGraphQL
import UIKit

struct OfferHeader {
    let containerScrollView: UIScrollView
    let presentingViewController: UIViewController
    @Inject var client: ApolloClient

    private let signCallbacker = Callbacker<Void>()

    var onSignTapSignal: Signal<Void> {
        signCallbacker.providedSignal
    }
}

extension OfferHeader: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let view = UIView()
        view.backgroundColor = .brand(.secondaryBackground())
        view.layer.cornerRadius = 6

        let bag = DisposeBag()

        bag += view.applyShadow { _ in
            UIView.ShadowProperties(
                opacity: 0.05,
                offset: CGSize(width: 0, height: 6),
                blurRadius: 3,
                color: UIColor.brand(.primaryShadowColor),
                path: nil,
                radius: 8
            )
        }

        bag += containerScrollView.contentOffsetSignal.onValue { contentOffset in
            view.transform = CGAffineTransform(
                translationX: 0,
                y: contentOffset.y / 5
            )
        }

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 25)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.spacing = 15

        view.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }

        bag += stackView.addArranged(Spacing(height: 10))

        let priceBubble = PriceBubble()
        bag += stackView.addArranged(priceBubble)

        bag += stackView.addArranged(Spacing(height: 15))

        let startDateButton = OfferStartDateButton(
            presentingViewController: presentingViewController
        )
        bag += stackView.addArranged(startDateButton)

        let signButton = Button(
            title: L10n.offerSignButton,
            type: .standardIcon(
                backgroundColor: .black,
                textColor: .white,
                icon: .left(image: Asset.bankIdLogo.image, width: 20)
            )
        )

        bag += signButton.onTapSignal.onValue { _ in
            self.signCallbacker.callAll()
        }

        bag += stackView.addArranged(signButton)

        let offerSignal = client.watch(query: GraphQL.OfferQuery())

        bag += offerSignal.bindTo(priceBubble.dataSignal)

        let offerDiscount = OfferDiscount(presentingViewController: presentingViewController)
        bag += offerSignal.compactMap { $0.redeemedCampaigns }.bindTo(offerDiscount.redeemedCampaignsSignal)

        bag += stackView.addArranged(offerDiscount)

        return (view, bag)
    }
}
