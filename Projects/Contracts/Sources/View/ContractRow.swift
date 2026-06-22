import Combine
import SwiftUI
import TagKit
import hCore
import hCoreUI

public struct ContractRow: View {
    @State var frameWidth: CGFloat = 0
    let contract: Contract
    let onClick: (() -> Void)?
    var onBottomContentHeightChange: ((CGFloat) -> Void)?

    public init(
        contract: Contract,
        onClick: (() -> Void)? = nil,
        onBottomContentHeightChange: ((CGFloat) -> Void)? = nil
    ) {
        self.contract = contract
        self.onClick = onClick
        self.onBottomContentHeightChange = onBottomContentHeightChange
    }

    public var body: some View {
        SwiftUI.Button {
            onClick?()
        } label: {
            EmptyView()
        }
        .buttonStyle(
            ContractRowButtonStyle(
                contract: contract,
                onBottomContentHeightChange: onBottomContentHeightChange
            )
        )
        .background(
            GeometryReader { geo in
                Color.clear
                    .onReceive(Just(geo.size.width)) { width in
                        frameWidth = width
                    }
            }
        )
        .hShadow()
    }
}

private struct ContractRowButtonStyle: SwiftUI.ButtonStyle {
    let contract: Contract
    var onBottomContentHeightChange: ((CGFloat) -> Void)?
    let tagsToShow: [(text: String, type: PillType)]
    @Environment(\.contractRowContentTruncate) var contractRowContentTruncate
    @State private var contractRowContentTruncateInternal: Bool = false

    private var image: Image? { contract.pillowType?.bgImage }
    private var contractDisplayName: String { contract.currentAgreement?.productVariant.displayName ?? "" }
    private var contractExposureName: String { contract.exposureDisplayName }

    public init(
        contract: Contract,
        onBottomContentHeightChange: ((CGFloat) -> Void)? = nil
    ) {
        self.contract = contract
        self.onBottomContentHeightChange = onBottomContentHeightChange

        var tagsToShow = [(text: String, type: PillType)]()
        if let tierDisplayName = contract.currentAgreement?.productVariant.displayNameTier {
            tagsToShow.append((tierDisplayName, .tier))
        }
        if contract.active {
            tagsToShow.append((L10n.dashboardInsuranceStatusActive, .text))
        } else if contract.activeInFuture {
            tagsToShow.append(
                (
                    L10n.contractStatusActiveInFuture(
                        contract.masterInceptionDate?.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                    ), .text
                )
            )
        }
        if let terminationMessage = contract.terminationMessage {
            tagsToShow.append((terminationMessage, .text))
        } else if let activeFrom = contract.upcomingChangedAgreement?.agreementDate.activeFrom {
            tagsToShow.append(
                (
                    L10n.dashboardInsuranceStatusActiveUpdateDate(
                        activeFrom.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                    ), .text
                )
            )
        } else if contract.masterInceptionDate == nil {
            tagsToShow.append((L10n.contractStatusPending, .text))
        }
        self.tagsToShow = tagsToShow
    }

    @ViewBuilder var background: some View {
        if let image {
            HStack(alignment: .center, spacing: 0) {
                Rectangle()
                    .foregroundColor(.clear)
                    .background(
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .scaleEffect(1.32)
                            .blur(radius: 20)
                    )
            }
        } else {
            hFillColor.Opaque.tertiary
        }
    }

    @ViewBuilder var logo: some View {
        hCoreUIAssets.helipadBig.view
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(hFillColor.Opaque.white)
            .colorScheme(.dark)
    }

    func makeBody(configuration _: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: .padding6) {
                TagList(
                    tags: tagsToShow.map(\.text)
                ) { tag in
                    StatusPill(text: tag, type: tagsToShow.first(where: { $0.text == tag })?.type ?? .text)
                }
                .tagFlow(
                    .horizontal(
                        .init(
                            horizontalAlignment: .leading,
                            verticalAlignment: .center,
                            horizontalSpacing: .padding3,
                            verticalSpacing: .padding3
                        )
                    )
                )
                .padding(.vertical, -.padding3)
                .padding(.horizontal, -.padding3)
                Spacer()
                logo
            }
            Spacer()
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    hText(contractDisplayName)
                        .foregroundColor(hTextColor.Opaque.white)
                        .lineLimit(contractRowContentTruncateInternal ? 1 : nil)
                    Spacer()
                }
                hText(contractExposureName)
                    .foregroundColor(hTextColor.Translucent.secondary)
                    .colorScheme(.dark)
                    .lineLimit(contractRowContentTruncateInternal ? 1 : nil)
            }
            .padding(.top, .padding10)
            .padding(.bottom, .padding16)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onReceive(Just(geo.size.height)) { height in
                            onBottomContentHeightChange?(height)
                        }
                }
            )
        }
        .padding(.horizontal, .padding16)
        .padding(.top, .padding16)
        .frame(minHeight: 200)
        .background(
            background
        )
        .border(hBorderColor.primary, width: 0.5)
        .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusXL))
        .hShadow()
        .contentShape(Rectangle())
        .onAppear {
            contractRowContentTruncateInternal = contractRowContentTruncate
        }
        .onChange(of: contractRowContentTruncate) { contractRowContentTruncate in
            Task {
                await delay(1)
                contractRowContentTruncateInternal = contractRowContentTruncate
            }
        }
    }
}

extension EnvironmentValues {
    @Entry public var contractRowContentTruncate: Bool = false
}

extension View {
    public func contractCardTruncate(to value: Bool) -> some View {
        environment(\.contractRowContentTruncate, value)
    }
}

@MainActor
private enum PillType {
    case text
    case tier

    @hColorBuilder
    var getBackgroundColor: some hColor {
        switch self {
        case .text:
            hFillColor.Translucent.tertiary
        case .tier:
            hFillColor.Translucent.secondary
        }
    }
}

private struct StatusPill: View {
    var text: String
    var type: PillType

    var body: some View {
        VStack {
            hText(text, style: .label)
        }
        .padding(.vertical, .padding3)
        .padding(.horizontal, .padding6)
        .foregroundColor(hTextColor.Opaque.white)
        .background(type.getBackgroundColor).colorScheme(.light)
        .cornerRadius(.cornerRadiusXS)
    }
}

#Preview {
    let variant = ProductVariant(
        termsVersion: "",
        typeOfContract: TypeOfContract.seApartmentRent.rawValue,
        perils: [],
        insurableLimits: [],
        documents: [],
        displayName: "Insurance",
        displayNameTier: "tier display name",
        tierDescription: nil
    )
    let agreement = Agreement(
        id: "agreementId",
        basePremium: .sek(200),
        itemCost: nil,
        displayItems: [],
        productVariant: variant,
        addonVariant: []
    )
    let contract = Contract(
        id: "contractId",
        currentAgreement: agreement,
        exposureDisplayName: "Address ∙ Coverage",
        exposureDisplayNameShort: "",
        masterInceptionDate: "2024-01-01",
        terminationDate: nil,
        supportsAddressChange: false,
        supportsCoInsured: false,
        supportsCoOwners: false,
        supportsTravelCertificate: false,
        supportsChangeTier: false,
        supportsTermination: false,
        upcomingChangedAgreement: nil,
        upcomingRenewal: nil,
        firstName: "",
        lastName: "",
        ssn: nil,
        typeOfContract: .seApartmentRent,
        coInsured: [],
        coOwners: [],
        missingPetChipId: false
    )
    return hSection {
        ContractRow(contract: contract)
    }
}
