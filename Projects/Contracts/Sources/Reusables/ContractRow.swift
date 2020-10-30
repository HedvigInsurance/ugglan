import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Hero
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

    var allowDetailNavigation = true

    var isContractActivated: Bool {
        contract.status.asActiveStatus != nil || contract.status.asTerminatedTodayStatus != nil || contract.status.asTerminatedInFutureStatus != nil
    }

    var gradientColors: [UIColor] {
        switch type {
        case .norwegianHome, .swedishHouse, .swedishApartment:
            return [
                UIColor(dynamic: { trait -> UIColor in
                    if trait.userInterfaceStyle == .dark {
                        return UIColor(red: 0.42, green: 0.30, blue: 0.21, alpha: 1.00)
                    }

                    return UIColor(red: 0.984, green: 0.843, blue: 0.925, alpha: 1)
                }),
                UIColor(dynamic: { trait -> UIColor in
                    if trait.userInterfaceStyle == .dark {
                        return UIColor(red: 0.25, green: 0.46, blue: 0.68, alpha: 1.00)
                    }

                    return UIColor(red: 0.894, green: 0.871, blue: 0.969, alpha: 1)
                }),
            ]
        case .norwegianTravel:
            return [
                UIColor(dynamic: { trait -> UIColor in
                    if trait.userInterfaceStyle == .dark {
                        return UIColor(red: 0.25, green: 0.46, blue: 0.68, alpha: 1.00)
                    }

                    return UIColor(red: 0.73, green: 0.69, blue: 0.89, alpha: 1.00)
                }),
                UIColor(dynamic: { trait -> UIColor in
                    if trait.userInterfaceStyle == .dark {
                        return UIColor(red: 0.63, green: 0.47, blue: 0.33, alpha: 1.00)
                    }

                    return UIColor(red: 0.97, green: 0.73, blue: 0.57, alpha: 1.00)
                }),
            ]
        }
    }

    var orbTintColor: UIColor {
        guard isContractActivated else {
            return .clear
        }

        switch type {
        case .norwegianHome, .swedishHouse, .swedishApartment:
            return UIColor(dynamic: { trait -> UIColor in
                if trait.userInterfaceStyle == .dark {
                    return UIColor(red: 0.80, green: 0.71, blue: 0.51, alpha: 1.00)
                }

                return UIColor(red: 0.937, green: 0.918, blue: 0.776, alpha: 1)
            })
        case .norwegianTravel:
            return UIColor(dynamic: { trait -> UIColor in
                if trait.userInterfaceStyle == .dark {
                    return UIColor(red: 0.78, green: 0.68, blue: 0.54, alpha: 1.00)
                }

                return UIColor(red: 0.89, green: 0.80, blue: 0.81, alpha: 1.00)
            })
        }
    }

    var gradientLayer: CAGradientLayer? {
        guard isContractActivated else {
            return nil
        }

        let layer = CAGradientLayer()
        layer.colors = gradientColors.map { $0.cgColor }
        layer.locations = [0, 1]

        layer.startPoint = CGPoint(x: 0.0, y: 0.0)
        layer.endPoint = CGPoint(x: 1.0, y: 0.0)

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
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = .defaultCornerRadius
        contentView.layer.borderWidth = .hairlineWidth
        contentView.backgroundColor = .grayscale(.grayOne)
        view.addArrangedSubview(contentView)

        contentView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(170)
        }

        let gradientView = UIView()
        gradientView.isUserInteractionEnabled = false
        gradientView.layer.cornerRadius = .defaultCornerRadius
        gradientView.clipsToBounds = true
        contentView.addSubview(gradientView)

        gradientView.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }

        let orbImageView = UIImageView()
        orbImageView.tintColor = .clear
        orbImageView.image = Asset.contractRowOrb.image

        contentView.addSubview(orbImageView)

        orbImageView.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }

        let touchFocusView = UIView()
        touchFocusView.isUserInteractionEnabled = false
        contentView.addSubview(touchFocusView)

        touchFocusView.snp.makeConstraints { make in
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
        verticalContentContainer.isUserInteractionEnabled = false
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

            chevronImageView.isHidden = !self.allowDetailNavigation

            contentView.hero.id = "contentView_\(self.contract.id)"
            contentView.layer.zPosition = .greatestFiniteMagnitude
            contentView.hero.modifiers = [
                .spring(stiffness: 250, damping: 25),
                .when({ context -> Bool in
                    !context.isMatched
                }, [.translate(x: -500, y: 0, z: 0)]),
            ]

            bag += contentView.applyBorderColor { _ in
                .brand(.primaryBorderColor)
            }

            orbImageView.tintColor = self.orbTintColor

            bag += contentView.traitCollectionSignal.atOnce().onValueDisposePrevious { _ -> Disposable? in
                let bag = DisposeBag()

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

                return bag
            }

            displayNameLabel.value = self.displayName

            if self.allowDetailNavigation {
                bag += contentView.signal(for: .touchUpInside)
                    .compactMap { _ in contentView.viewController }
                    .onValue { viewController in
                        guard let navigationController = viewController.navigationController else {
                            return
                        }

                        if navigationController.hero.isEnabled {
                            navigationController.hero.isEnabled = false
                        }

                        navigationController.hero.isEnabled = true
                        navigationController.hero.navigationAnimationType = .fade

                        viewController.present(ContractDetail(contractRow: self), options: [.largeTitleDisplayMode(.never), .autoPop])
                    }

                bag += contentView.signal(for: .touchDown).animated(style: .easeOut(duration: 0.25)) {
                    touchFocusView.backgroundColor = UIColor.grayscale(.grayOne).darkened(amount: 0.2).withAlphaComponent(0.25)
                }

                bag += contentView.delayedTouchCancel().animated(style: .easeOut(duration: 0.25)) {
                    touchFocusView.backgroundColor = .clear
                }
            }

            bag += statusPillsContainer.addArranged(PillCollection(pills: self.statusPills.map { pill in
                Pill(title: pill, backgroundColor: .tint(.yellowOne))
            }))

            bag += detailPillsContainer.addArranged(PillCollection(pills: self.detailPills.map { pill in
                Pill(title: pill, backgroundColor: UIColor.brand(.primaryBackground()).withAlphaComponent(0.5))
            }))

            return bag
        })
    }
}
