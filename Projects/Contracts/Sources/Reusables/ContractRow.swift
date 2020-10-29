import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import UIKit

extension Date {
    var localized: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Foundation.Locale(identifier: Localization.Locale.currentLocale.rawValue)
        dateFormatter.dateStyle = .long
        let dateString = dateFormatter.string(from: self)

        return dateString
    }
}

struct ContractRow: Hashable {
    static func == (lhs: ContractRow, rhs: ContractRow) -> Bool {
        lhs.displayName == rhs.displayName
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(displayName)
    }

    let contract: GraphQL.ContractsQuery.Data.Contract
    let displayName: String
    let type: ContractType

    enum ContractType {
        case swedishApartment
        case swedishHouse
        case norwegianTravel
        case norwegianHome
    }

    var isContractActivated: Bool {
        contract.status.asActiveStatus != nil || contract.status.asTerminatedTodayStatus != nil || contract.status.asTerminatedInFutureStatus != nil
    }

    var gradientLayer: CAGradientLayer? {
        guard isContractActivated else {
            return nil
        }

        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0.984, green: 0.843, blue: 0.925, alpha: 1).cgColor,
            UIColor(red: 0.894, green: 0.871, blue: 0.969, alpha: 1).cgColor,
        ]
        layer.locations = [0, 1]

        return layer
    }

    var statusPills: [String] {
        if let status = contract.status.asActiveInFutureAndTerminatedInFutureStatus {
            let futureInceptionDate = status.futureInception?.localDateToDate ?? Date()
            let futureTerminationDate = status.futureTermination?.localDateToDate ?? Date()

            return [
                L10n.dashboardInsuranceStatusInactiveStartdate(futureInceptionDate.localized),
                L10n.dashboardInsuranceStatusActiveTerminationdate(futureTerminationDate.localized),
            ]
        } else if contract.status.asTerminatedTodayStatus != nil {
            return [
                L10n.dashboardInsuranceStatusTerminatedToday,
            ]
        } else if let status = contract.status.asActiveInFutureStatus {
            let futureInceptionDate = status.futureInception?.localDateToDate ?? Date()

            return [
                L10n.dashboardInsuranceStatusInactiveStartdate(futureInceptionDate.localized),
            ]
        } else if contract.status.asPendingStatus != nil {
            return [
                L10n.dashboardInsuranceStatusInactiveNoStartdate,
            ]
        }

        return []
    }

    private var coversHowManyPill: String {
        func getPill(numberCoinsured: Int) -> String {
            numberCoinsured > 0 ?
                L10n.InsuranceTab.coversYouPlusTag(numberCoinsured) :
                L10n.InsuranceTab.coversYouTag
        }

        switch type {
        case .swedishApartment:
            let numberCoinsured = contract.currentAgreement.asSwedishApartmentAgreement?.numberCoInsured ?? 0
            return getPill(numberCoinsured: numberCoinsured)
        case .swedishHouse:
            let numberCoinsured = contract.currentAgreement.asSwedishHouseAgreement?.numberCoInsured ?? 0
            return getPill(numberCoinsured: numberCoinsured)
        case .norwegianHome:
            let numberCoinsured = contract.currentAgreement.asNorwegianHomeContentAgreement?.numberCoInsured ?? 0
            return getPill(numberCoinsured: numberCoinsured)
        case .norwegianTravel:
            let numberCoinsured = contract.currentAgreement.asNorwegianHomeContentAgreement?.numberCoInsured ?? 0
            return getPill(numberCoinsured: numberCoinsured)
        }
    }

    var detailPills: [String] {
        switch type {
        case .swedishApartment:
            return [
                contract.currentAgreement.asSwedishApartmentAgreement?.address.street.uppercased(),
                coversHowManyPill,
            ].compactMap { $0 }
        case .swedishHouse:
            return [
                contract.currentAgreement.asSwedishHouseAgreement?.address.street.uppercased(),
                coversHowManyPill,
            ].compactMap { $0 }
        case .norwegianHome:
            return [
                contract.currentAgreement.asNorwegianHomeContentAgreement?.address.street.uppercased(),
                coversHowManyPill,
            ].compactMap { $0 }
        case .norwegianTravel:
            return [
                coversHowManyPill,
            ]
        }
    }
}

extension ContractRow: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (ContractRow) -> Disposable) {
        let view = UIStackView()
        view.edgeInsets = UIEdgeInsets(horizontalInset: 15, verticalInset: 0)

        let contentView = UIControl()
        contentView.layer.cornerRadius = .defaultCornerRadius
        contentView.layer.borderWidth = .hairlineWidth
        contentView.backgroundColor = .grayscale(.grayOne)
        view.addArrangedSubview(contentView)

        contentView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(170)
        }

        let gradientView = UIView()
        gradientView.layer.cornerRadius = .defaultCornerRadius
        gradientView.clipsToBounds = true
        contentView.addSubview(gradientView)

        gradientView.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }

        let symbolImageView = UIImageView()
        symbolImageView.image = hCoreUIAssets.symbol.image

        contentView.addSubview(symbolImageView)

        symbolImageView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(24)
        }

        let verticalContentContainer = UIStackView()
        verticalContentContainer.spacing = 20
        verticalContentContainer.edgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 40)
        verticalContentContainer.axis = .vertical
        verticalContentContainer.distribution = .equalSpacing
        contentView.addSubview(verticalContentContainer)

        verticalContentContainer.snp.makeConstraints { make in
            make.leading.top.bottom.trailing.equalToSuperview()
        }

        let statusPillsContainer = UIStackView()
        statusPillsContainer.axis = .vertical
        verticalContentContainer.addArrangedSubview(statusPillsContainer)

        let bottomContentContainer = UIStackView()
        bottomContentContainer.spacing = 8
        bottomContentContainer.axis = .vertical
        verticalContentContainer.addArrangedSubview(bottomContentContainer)

        let displayNameLabel = UILabel(value: "", style: .brand(.title2(color: .primary)))
        bottomContentContainer.addArrangedSubview(displayNameLabel)

        let detailPillsContainer = UIStackView()
        detailPillsContainer.axis = .vertical
        bottomContentContainer.addArrangedSubview(detailPillsContainer)

        let chevronImageView = UIImageView()
        chevronImageView.image = hCoreUIAssets.chevronRight.image

        contentView.addSubview(chevronImageView)

        chevronImageView.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(24)
        }

        return (view, { `self` in
            let bag = DisposeBag()

            bag += contentView.applyBorderColor { _ in
                .brand(.primaryBorderColor)
            }

            if let gradientLayer = self.gradientLayer {
                gradientView.layer.addSublayer(gradientLayer)

                bag += gradientView.didLayoutSignal.onValue {
                    gradientLayer.bounds = gradientView.layer.bounds
                    gradientLayer.frame = gradientView.layer.frame
                    gradientLayer.position = gradientView.layer.position
                }

                bag += {
                    gradientLayer.removeFromSuperlayer()
                }
            }

            displayNameLabel.value = self.displayName

            bag += contentView.signal(for: .touchDown).animated(style: .easeOut(duration: 0.25)) {
                contentView.backgroundColor = UIColor.grayscale(.grayOne).darkened(amount: 0.5)
            }

            bag += contentView.delayedTouchCancel().animated(style: .easeOut(duration: 0.25)) {
                contentView.backgroundColor = UIColor.grayscale(.grayOne)
            }

            bag += statusPillsContainer.addArranged(PillCollection(pills: self.statusPills.map { pill in
                Pill(title: pill, backgroundColor: .tint(.yellowOne))
            }))

            bag += detailPillsContainer.addArranged(PillCollection(pills: self.detailPills.map { pill in
                Pill(title: pill, backgroundColor: UIColor.white.withAlphaComponent(0.5))
            }))

            return bag
        })
    }
}
