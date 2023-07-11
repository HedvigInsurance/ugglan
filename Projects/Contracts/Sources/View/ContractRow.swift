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
        .padding([.top, .bottom], 4)
        .padding([.leading, .trailing], 10)
        .background(hTextColorNew.tertiaryTranslucent)
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
            hTextColorNew.secondary
        }
    }

    @ViewBuilder var logo: some View {
        if let logo = contract.logo {
            RemoteVectorIconView(icon: logo, backgroundFetch: true)
                .enableHero(
                    "ContractRow_\(contract.id)_logo",
                    modifiers: [.spring(stiffness: 250, damping: 25)]
                )
                .frame(width: 36, height: 36)
        } else {
            // Fallback to Hedvig logo if no logo
            Image(uiImage: hCoreUIAssets.symbol.image.withRenderingMode(.alwaysTemplate))
                .resizable()
                .enableHero(
                    "ContractRow_\(contract.id)_logo",
                    modifiers: [.spring(stiffness: 250, damping: 25)]
                )
                .frame(width: 24, height: 24)
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                ForEach(contract.statusPills, id: \.self) { pill in
                    StatusPill(text: pill)
                }
                Spacer()
                logo
            }
            Spacer()
            HStack {
                hText(contract.displayName)
                Spacer()
            }
            hText(contract.getDetails())
                .foregroundColor(hTextColorNew.negative.opacity(0.415))
        }
        .padding(16)
        .frame(minHeight: 200)
        .background(
            background
        )
        .clipShape(Squircle.default())
        .overlay(
            Squircle.default(lineWidth: .hairlineWidth)
                .stroke(hSeparatorColor.separator, lineWidth: .hairlineWidth)
        )
        .foregroundColor(hTextColorNew.negative)
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
                    store.send(.openDetail(contractId: contract.id))
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
                .enableHero(
                    "ContractRow_\(contract.id)",
                    modifiers: [
                        .spring(stiffness: 250, damping: 25),
                        .when(
                            { context -> Bool in !context.isMatched },
                            [
                                .init(applyFunction: { (state: inout HeroTargetState) in
                                    state.append(
                                        .translate(
                                            x: -frameWidth
                                                * 1.3,
                                            y: 0,
                                            z: 0
                                        )
                                    )
                                })
                            ]
                        ),
                    ]
                )
            }
        }
        .presentableStoreLensAnimation(.easeInOut)
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
                id: "2",
                typeOfContract: .noHomeContentOwn,
                upcomingAgreementsTable: DetailAgreementsTable(
                    sections: [
                        DetailAgreementsTable.Section(
                            title: "TITLE Details",
                            rows: [.init(title: "Title 1", subtitle: "Subtitle 1", value: "Value 1")]
                        )
                    ],
                    title: "Section title"
                ),
                currentAgreementsTable: nil,
                logo: nil,
                displayName: "Car Insurance",
                switchedFromInsuranceProvider: "Provider",
                upcomingRenewal: nil,
                contractPerils: [],
                insurableLimits: [],
                termsAndConditions: TermsAndConditions(displayName: "Terms", url: "URL"),
                currentAgreement: CurrentAgreement.init(
                    certificateUrl: "URL",
                    activeFrom: "Active from",
                    activeTo: "Active to",
                    premium: .sek(10),
                    status: .terminated
                ),
                statusPills: ["Activates 20.03.2024."],
                detailPills: ["Bellman", "Ba", "asdas", "asdasdasasdad", "1232", "SDASDASDS", "asdasd"]
            )
            let contracts = [contract]
            store.send(.setContracts(contracts: contracts))
        }
    }
}
