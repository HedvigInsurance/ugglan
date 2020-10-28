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

        view.snp.makeConstraints { make in
            make.height.equalTo(200)
        }

        let contentView = UIView()
        contentView.layer.cornerRadius = .defaultCornerRadius
        contentView.backgroundColor = .grayscale(.grayOne)

        view.addArrangedSubview(contentView)

        let symbolImageView = UIImageView()
        symbolImageView.image = hCoreUIAssets.symbol.image

        contentView.addSubview(symbolImageView)

        symbolImageView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(24)
        }

        let statusPillsContainer = UIStackView()
        statusPillsContainer.spacing = 8
        statusPillsContainer.alignment = .leading
        statusPillsContainer.edgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 0, right: 12)
        contentView.addSubview(statusPillsContainer)

        statusPillsContainer.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.width.equalToSuperview().inset(30)
        }

        let bottomContentContainer = UIStackView()
        bottomContentContainer.axis = .vertical
        bottomContentContainer.edgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 12, right: 12)
        contentView.addSubview(bottomContentContainer)

        bottomContentContainer.snp.makeConstraints { make in
            make.width.leading.bottom.equalToSuperview()
        }

        let detailPillsContainer = UIStackView()
        detailPillsContainer.spacing = 8
        detailPillsContainer.alignment = .leading
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

            bag += self.statusPills.map { pill in
                statusPillsContainer.addArranged(Pill(title: pill))
            }

            let statusPillsStretchingView = UIView()
            statusPillsStretchingView.setContentHuggingPriority(.defaultLow, for: .horizontal)
            statusPillsContainer.addArrangedSubview(statusPillsStretchingView)

            bag += {
                statusPillsContainer.removeArrangedSubview(statusPillsStretchingView)
            }

            bag += self.detailPills.map { pill in
                detailPillsContainer.addArranged(Pill(title: pill))
            }

            let detailPillsStretchingView = UIView()
            detailPillsStretchingView.setContentHuggingPriority(.defaultLow, for: .horizontal)
            detailPillsContainer.addArrangedSubview(detailPillsStretchingView)

            bag += {
                detailPillsContainer.removeArrangedSubview(detailPillsStretchingView)
            }

            return bag
        })
    }
}
