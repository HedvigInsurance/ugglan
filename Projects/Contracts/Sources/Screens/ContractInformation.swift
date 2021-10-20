import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

import SwiftUI

struct ContractInformationz: View {
    let contract: Contract
    
    var body: some View {
        VStack {
            if contract.upcomingAgreementDate?.localDateString != nil {
                hSection {
                    RenewalInformationCard(contract: contract)
                }.sectionContainerStyle(.transparent)
            }
            if let table = contract.currentAgreementsTable {
                ForEach(table.sections) { section in
                    hSection(section.rows, id: \.title) { row in
                        hRow {
                            hText(row.title)
                        }.withCustomAccessory({
                            Spacer()
                            hText(String(row.value), style: .body)
                                .foregroundColor(hLabelColor.secondary)
                                .padding(.trailing, 8)
                        })
                    }
                    .withHeader {
                        hText(section.title).body.foregroundColor(hLabelColor.secondary)
                    }
                }
            }
            if contract.currentAgreement.status != .terminated {
                if Localization.Locale.currentLocale.market == .se {
                    if contract.showsMovingFlowButton {
                        hSection {
                            hButton.LargeButtonOutlined {

                            } content: {
                                hText(L10n.HomeTab.editingSectionChangeAddressLabel)
                            }
                        }.sectionContainerStyle(.transparent)
                    }
                } else {
                    hSection {
                        hButton.LargeButtonText {

                        } content: {
                            hText(L10n.contractDetailHomeChangeInfo)
                        }
                    }.sectionContainerStyle(.transparent)
                }
            }
        }.padding(.bottom, 20)
    }
}

struct RenewalInformationCard: View {
    let contract: Contract
    
    var body: some View {
        VStack {
            hCard(
                titleIcon: hCoreUIAssets.refresh.image,
                title: L10n.InsuranceDetails.updateDetailsSheetTitle,
                bodyText: L10n.InsuranceDetails.AdressUpdateBody.No.address(
                    contract.upcomingAgreementDate?.localDateString ?? ""
                )
            ) {
                hButton.SmallButtonOutlined {
                    print("Hello")
                } content: {
                    L10n.InsuranceDetails.addressUpdateButton.hText()
                }
            }
        }
    }
}

struct ContractInformationView: UIViewControllerRepresentable {
    let contract: Contract

    public class Coordinator {
        let bag = DisposeBag()
        let contractInformation: ContractInformation
        let contract: Contract

        init(contract: Contract) {
            self.contract = contract
            self.contractInformation = ContractInformation(contract: contract)
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(contract: contract)
    }

    public func makeUIViewController(context: Context) -> some UIViewController {
        let (view, disposable) = context.coordinator.contractInformation.materialize()
        context.coordinator.bag += disposable
        return view
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

struct ContractInformation {
    let contract: Contract
}

extension ContractInformation: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = L10n.contractDetailMainTitle
        let bag = DisposeBag()

        let store: ContractStore = get()

        let form = FormView()

        if contract.upcomingAgreementDate?.localDateString == nil {
            let upcomingAgreementSection = form.appendSection(
                header: nil,
                footer: nil,
                style: .brandGroupedInset(separatorType: .none, appliesShadow: false)
            )

            let card = Card(
                titleIcon: hCoreUIAssets.refresh.image,
                title: L10n.InsuranceDetails.updateDetailsSheetTitle,
                body: L10n.InsuranceDetails.AdressUpdateBody.No.address(
                    contract.upcomingAgreementDate?.localDateString ?? ""
                ),
                buttonText: L10n.InsuranceDetails.addressUpdateButton,
                backgroundColor: .tint(.lavenderTwo),
                buttonType: contract.upcomingAgreementsTable.sections.isEmpty
                    ? .none
                    : .outline(
                        borderColor: .brand(.primaryText()),
                        textColor: .brand(.primaryText())
                    )
            )

            bag += upcomingAgreementSection.append(card)
                .onValueDisposePrevious { _ in
                    let innerBag = DisposeBag()

                    let upcomingAddressChangeDetails = UpcomingAddressChangeDetails(
                        details: contract.upcomingAgreementsTable
                    )
                    innerBag += viewController.present(
                        upcomingAddressChangeDetails.withCloseButton,
                        style: .detented(.scrollViewContentSize, .large)
                    )

                    return innerBag
                }
        }

        let section = form.appendSection()
        section.dynamicStyle = .brandGrouped(separatorType: .none)

        if let detailsTable = contract.currentAgreementsTable {
            bag += section.append(detailsTable)
        }

        form.appendSpacing(.custom(20))

        if contract.currentAgreement.status != .terminated {
            if Localization.Locale.currentLocale.market == .se {
                if contract.showsMovingFlowButton {
                    let changeAddressButton = ButtonRowViewWrapper(
                        title: L10n.HomeTab.editingSectionChangeAddressLabel,
                        type: .standardOutline(
                            borderColor: .brand(.primaryText()),
                            textColor: .brand(.primaryText())
                        ),
                        isEnabled: true,
                        animate: false
                    )
                    bag += section.append(changeAddressButton)

                    bag += changeAddressButton.onTapSignal.onValue {
                        store.send(.goToMovingFlow)
                    }
                }
            } else {
                let changeButton = ButtonSection(text: L10n.contractDetailHomeChangeInfo, style: .normal)
                bag += form.append(changeButton)

                bag += changeButton.onSelect.onValue {
                    let alert = Alert(
                        title: L10n.myHomeChangeAlertTitle,
                        message: L10n.myHomeChangeAlertMessage,
                        actions: [
                            Alert.Action(title: L10n.myHomeChangeAlertActionCancel) { false },
                            Alert.Action(title: L10n.myHomeChangeAlertActionConfirm) { true },
                        ]
                    )

                    viewController.present(alert)
                        .onValue { shouldContinue in
                            store.send(.goToFreeTextChat)
                        }
                }
            }
        }

        bag += viewController.install(form, options: [])

        return (viewController, bag)
    }
}
