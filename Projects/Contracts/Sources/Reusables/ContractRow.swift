import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Hero
import hGraphQL
import UIKit

struct ContractRow: Hashable {
    static func == (lhs: ContractRow, rhs: ContractRow) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(displayName)
        hasher.combine(statusPills)
        hasher.combine(isContractActivated)
        hasher.combine(detailPills)
    }

    let contract: GraphQL.ContractsQuery.Data.Contract
    let displayName: String
    let type: ContractType

    enum ContractType {
        case swedishApartment
        case swedishHouse
        case norwegianTravel
        case norwegianHome
        case danishHome
    }

    var allowDetailNavigation = true
}

extension ContractRow: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (ContractRow) -> Disposable) {
        let view = UIStackView()
        view.edgeInsets = UIEdgeInsets(horizontalInset: 15, verticalInset: 0)
        view.insetsLayoutMarginsFromSafeArea = true

        let contentView = UIControl()
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = .defaultCornerRadius
        contentView.layer.borderWidth = .hairlineWidth

        let backgroundColor = UIColor(light: .grayscale(.grayOne), dark: .grayscale(.grayFive))
        contentView.backgroundColor = backgroundColor
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

            contentView.accessibilityIdentifier = String(describing: self)
            contentView.hero.id = "contentView_\(self.contract.id)"
            contentView.layer.zPosition = .greatestFiniteMagnitude
            contentView.hero.modifiers = [
                .spring(stiffness: 250, damping: 25),
                .when({ context -> Bool in
                    !context.isMatched
                }, [.init(applyFunction: { (state: inout HeroTargetState) in
                    state.append(.translate(x: -contentView.frame.width * 1.3, y: 0, z: 0))
                })]),
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
                bag += contentView.trackedTouchUpInsideSignal
                    .compactMap { _ in contentView.viewController }
                    .onValue { viewController in
                        guard let navigationController = viewController.navigationController else {
                            return
                        }

                        if !UITraitCollection.isCatalyst {
                            navigationController.hero.isEnabled = true
                            navigationController.hero.navigationAnimationType = .fade
                        }

                        viewController.present(
                            ContractDetail(contractRow: self),
                            options: [.largeTitleDisplayMode(.never), .autoPop]
                        ).onResult { _ in
                            if !UITraitCollection.isCatalyst {
                                navigationController.hero.isEnabled = false
                            }
                        }
                    }

                bag += contentView.signal(for: .touchUpInside).feedback(type: .impactLight)

                bag += contentView.signal(for: .touchDown).animated(style: .easeOut(duration: 0.25)) {
                    touchFocusView.backgroundColor = backgroundColor.darkened(amount: 0.2).withAlphaComponent(0.25)
                }

                bag += contentView.delayedTouchCancel().animated(style: .easeOut(duration: 0.25)) {
                    touchFocusView.backgroundColor = .clear
                }
            }

            bag += statusPillsContainer.addArranged(PillCollection(pills: self.statusPills.map { pill in
                .make(Pill(title: pill.uppercased(), tintColor: .tint(.yellowOne)))
            }))

            bag += detailPillsContainer.addArranged(PillCollection(pills: self.detailPills.map { pill in
                .make(EffectedPill(title: pill.uppercased()))
            }))

            return bag
        })
    }
}
