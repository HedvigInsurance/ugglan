import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import UIKit

struct OfferTermsBulletPoints {
    @Inject var client: ApolloClient
}

extension OfferTermsBulletPoints {
    func bullets(for type: GraphQL.InsuranceType) -> [BulletPoint] {
        var bulletList: [BulletPoint] = []

        if type.isApartment {
            bulletList.append(BulletPoint(title: L10n.offerTermsNoBindingPeriod))

            if type.isOwnedApartment {
                bulletList.append(BulletPoint(title: L10n.offerTermsNoCoverageLimit))
            }

            if type.isStudent {
                bulletList.append(
                    BulletPoint(
                        title: L10n.offerTermsMaxCompensation(L10n.maxCompensationStudent)
                    )
                )
            } else {
                bulletList.append(
                    BulletPoint(
                        title: L10n.offerTermsMaxCompensation(L10n.maxCompensation)
                    )
                )
            }

            bulletList.append(
                BulletPoint(
                    title: L10n.offerTermsDeductible(L10n.deductible)
                )
            )
        } else {
            bulletList.append(
                BulletPoint(
                    title: L10n.offerHouseTrustHouse
                )
            )

            bulletList.append(
                BulletPoint(
                    title: L10n.offerTermsMaxCompensation(L10n.maxCompensationHouse)
                )
            )

            bulletList.append(
                BulletPoint(
                    title: L10n.offerTermsDeductible(L10n.deductible),
                    message: L10n.offerTrustIncreasedDeductible
                )
            )
        }

        return bulletList
    }
}

extension OfferTermsBulletPoints {
    struct BulletPoint: Viewable {
        let title: String
        let message: String?

        init(title: String, message: String? = nil) {
            self.title = title
            self.message = message
        }

        func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
            let bag = DisposeBag()
            let stackView = UIStackView()
            stackView.spacing = 15

            let checkMark = Icon(icon: Asset.circularCheckmark.image, iconWidth: 20)
            stackView.addArrangedSubview(checkMark)

            checkMark.snp.makeConstraints { make in
                make.width.equalTo(20)
            }

            let textStackView = UIStackView()
            textStackView.axis = .vertical
            textStackView.spacing = 5

            stackView.addArrangedSubview(textStackView)

            let titleLabel = MultilineLabel(value: title, style: .brand(.headline(color: .primary)))
            bag += textStackView.addArranged(titleLabel)

            if let message = message {
                stackView.alignment = .top

                let messageLabel = MultilineLabel(value: message, style: .brand(.headline(color: .primary)))
                bag += textStackView.addArranged(messageLabel)
            }

            return (stackView, bag)
        }
    }
}

extension OfferTermsBulletPoints: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15

        bag += stackView.didMoveToWindowSignal.take(first: 1).onValue {
            stackView.snp.makeConstraints { make in
                make.width.equalToSuperview().multipliedBy(0.8)
            }
        }

        bag += client
            .fetch(query: GraphQL.OfferQuery())
            .valueSignal
            .compactMap { $0.insurance.type }
            .onValueDisposePrevious { insuranceType in
                let innerBag = DisposeBag()

                innerBag += self.bullets(for: insuranceType).map { bulletPoint in
                    stackView.addArranged(bulletPoint)
                }

                return innerBag
            }

        return (stackView, bag)
    }
}
