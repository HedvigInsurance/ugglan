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
            .foregroundColor(hTextColor.primary)
            .colorScheme(.dark)
    }

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                if let terminationDate = contract.terminationDate {
                    if contract.terminatedToday {
                        StatusPill(text: L10n.contractStatusTerminatedToday).padding(.trailing, 4)
                    } else {
                        StatusPill(text: L10n.contractStatusToBeTerminated(terminationDate)).padding(.trailing, 4)
                    }
                } else if let activeFrom = contract.upcomingChangedAgreement?.activeFrom {
                    StatusPill(text: L10n.dashboardInsuranceStatusActiveUpdateDate(activeFrom)).padding(.trailing, 4)
                } else if contract.activeInFuture {
                    StatusPill(text: L10n.contractStatusActiveInFuture(contract.masterInceptionDate ?? ""))
                        .padding(.trailing, 4)
                }
                Spacer()
                logo
            }
            Spacer()
            HStack {
                hText(contract.currentAgreement!.productVariant.displayName)
                    .foregroundColor(hTextColor.primary)
                    .colorScheme(.dark)
                Spacer()
            }
            hText(contract.exposureDisplayName)
                .foregroundColor(hGrayscaleTranslucent.greyScaleTranslucent600)
                .colorScheme(.dark)
        }
        .padding(16)
        .frame(minHeight: 200)
        .background(
            background
        )
        .border(hBorderColor.translucentOne, width: 0.5)
        .colorScheme(.light)
        .clipShape(Squircle.default())
        .hShadow()
        .contentShape(Rectangle())
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
                    store.send(
                        .openDetail(
                            contractId: contract.id,
                            title: contract.currentAgreement?.productVariant.displayName ?? ""
                        )
                    )
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
                                displayName: ""
                            )
                    ),
                exposureDisplayName: "",
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
