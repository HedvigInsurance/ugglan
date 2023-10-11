import Combine
import Flow
import Form
import Foundation
import Hero
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

private struct StatusPill: View {
    var text: String
    
    var body: some View {
        VStack {
            hText(text, style: .standardSmall)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 10)
        .foregroundColor(hTextColor.primary).colorScheme(.dark)
        .background(hTextColor.tertiaryTranslucent).colorScheme(.light)
        .cornerRadius(8)
    }
}

private struct ContractRowChevron: View {
    @SwiftUI.Environment(\.isEnabled) var isEnabled
    
    var body: some View {
        if isEnabled {
            Image(uiImage: hCoreUIAssets.arrowForward.image)
                .resizable()
                .frame(width: 24, height: 24)
        }
    }
}

private struct ContractRowButtonStyle: SwiftUI.ButtonStyle {
    let contract: Contract
    @ViewBuilder var background: some View {
        if let image = contract.pillowType?.bgImage {
            HStack(alignment: .center, spacing: 0) {
                Rectangle()
                    .foregroundColor(.clear)
                    .background(
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .scaleEffect(1.32)
                            .blur(radius: 20)
                    )
            }
        } else {
            hColorScheme(
                light: hTextColor.secondary,
                dark: hGrayscaleColor.greyScale900
            )
        }
    }
    
    @ViewBuilder var logo: some View {
        Image(uiImage: hCoreUIAssets.symbol.image.withRenderingMode(.alwaysTemplate))
            .resizable()
            .frame(width: 24, height: 24)
    }
    
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                if let terminationDate = contract.terminationDate {
                    if terminationDate == Date().localDateString {
                        StatusPill(text: L10n.contractStatusTerminatedToday).padding(.trailing, 4)
                    } else {
                        StatusPill(text: L10n.contractStatusToBeTerminated(terminationDate)).padding(.trailing, 4)
                    }
                } else if let activeFrom = contract.upcomingChangedAgreement?.activeFrom {
                    StatusPill(text: L10n.dashboardInsuranceStatusActiveUpdateDate(activeFrom)).padding(.trailing, 4)
                } else if let inceptionDate = contract.masterInceptionDate?.localDateToDate,
                          daysBetween(start: Date(), end: inceptionDate) > 0
                {
                    StatusPill(text: L10n.contractStatusActiveInFuture(inceptionDate.localDateString))
                        .padding(.trailing, 4)
                }
                Spacer()
                logo
            }
            Spacer()
            HStack {
                hText(contract.currentAgreement.productVariant.displayName)
                Spacer()
            }
            hText(contract.exposureDisplayName)
                .foregroundColor(hGrayscaleTranslucent.greyScaleTranslucent700)
        }
        .padding(16)
        .frame(minHeight: 200)
        .background(
            background
        )
        .clipShape(Squircle.default())
        .hShadow()
        .foregroundColor(hTextColor.primary)
        .colorScheme(.dark)
        .contentShape(Rectangle())
    }
    
    func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
}

struct ContractRow: View {
    @PresentableStore var store: ContractStore
    @State var frameWidth: CGFloat = 0
    
    var id: String
    var allowDetailNavigation = true
    var body: some View {
        PresentableStoreLens(
            ContractStore.self,
            getter: { state in
                state.contractForId(id)
            }
        ) { contract in
            if let contract = contract {
                SwiftUI.Button {
                    store.send(.openDetail(contractId: contract.id, title: contract.exposureDisplayName))
                } label: {
                    EmptyView()
                }
                .disabled(!allowDetailNavigation)
                .buttonStyle(ContractRowButtonStyle(contract: contract))
                .background(
                    GeometryReader { geo in
                        Color.clear.onReceive(Just(geo.size.width)) { width in
                            self.frameWidth = width
                        }
                    }
                )
            }
        }
        .presentableStoreLensAnimation(.easeInOut)
        .hShadow()
    }
}

struct ContractRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            ContractRow(id: "2").frame(height: 200)
            Spacer()
        }
        .onAppear {
            let store: ContractStore = globalPresentableStoreContainer.get()
            let contract = Contract(
                id: "1",
                currentAgreement:
                    Agreement(
                        premium: MonetaryAmount(amount: 0, currency: ""),
                        displayItems: [],
                        productVariant:
                            ProductVariant(
                                termsVersion: "",
                                typeOfContract: "",
                                partner: nil,
                                perils: [],
                                insurableLimits: [],
                                documents: [],
                                highlights: [],
                                FAQ: nil,
                                displayName: ""
                            )
                    ),
                exposureDisplayName: "",
                externalInsuranceCancellation: ContractExternalInsuranceCancellation(
                    id: "",
                    bankSignering:
                        ContractExternalInsuranceCancellation.BankSignering(
                            approvedByDate: "",
                            url: ""
                        ),
                    externalInsurer: ContractExternalInsuranceCancellation.ExternalInsurer(
                        id: "",
                        displayName: "",
                        insurelyId: ""
                    ),
                    status: .completed,
                    type: .bankSigned
                ),
                masterInceptionDate: "",
                terminationDate: "",
                supportsAddressChange: true,
                upcomingChangedAgreement:
                    Agreement(
                        premium: MonetaryAmount(amount: 0, currency: ""),
                        displayItems: [],
                        productVariant:
                            ProductVariant(
                                termsVersion: "",
                                typeOfContract: "",
                                partner: nil,
                                perils: [],
                                insurableLimits: [],
                                documents: [],
                                highlights: [],
                                FAQ: nil,
                                displayName: ""
                            )
                    ),
                upcomingRenewal:
                    ContractRenewal(
                        renewalDate: "",
                        draftCertificateUrl: ""
                    ),
                typeOfContract: .seHouse
            )
            let contracts = [contract]
            store.send(.setActiveContracts(contracts: contracts))
        }
    }
}
