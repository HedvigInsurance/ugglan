import Combine
import SwiftUI
import hCore
import hCoreUI

public struct ContractRow: View {
    @State var frameWidth: CGFloat = 0

    let image: UIImage?
    let terminationMessage: String?
    let contractDisplayName: String
    let contractExposureName: String
    let activeFrom: String?
    let activeInFuture: Bool?
    let masterInceptionDate: String?
    let tierDisplayName: String?

    let onClick: (() -> Void)?

    public init(
        image: UIImage?,
        terminationMessage: String?,
        contractDisplayName: String,
        contractExposureName: String,
        activeFrom: String? = nil,
        activeInFuture: Bool? = nil,
        masterInceptionDate: String? = nil,
        tierDisplayName: String?,
        onClick: (() -> Void)? = nil
    ) {
        self.image = image
        self.terminationMessage = terminationMessage
        self.contractDisplayName = contractDisplayName
        self.contractExposureName = contractExposureName
        self.activeFrom = activeFrom
        self.activeInFuture = activeInFuture
        self.masterInceptionDate = masterInceptionDate
        self.tierDisplayName = tierDisplayName

        self.onClick = onClick
    }

    public var body: some View {
        SwiftUI.Button {
            onClick?()
        } label: {
            EmptyView()
        }
        .buttonStyle(
            ContractRowButtonStyle(
                image: image,
                contractDisplayName: contractDisplayName,
                contractExposureName: contractExposureName,
                terminationMessage: terminationMessage,
                activeFrom: activeFrom,
                activeInFuture: activeInFuture,
                masterInceptionDate: masterInceptionDate,
                tierDisplayName: tierDisplayName
            )
        )
        .background(
            GeometryReader { geo in
                Color.clear.onReceive(Just(geo.size.width)) { width in
                    self.frameWidth = width
                }
            }
        )
        .hShadow()
    }
}

private struct ContractRowButtonStyle: SwiftUI.ButtonStyle {
    let image: UIImage?
    let contractDisplayName: String
    let contractExposureName: String
    let terminationMessage: String?
    let activeFrom: String?
    let activeInFuture: Bool?
    let masterInceptionDate: String?
    let tierDisplayName: String?

    public init(
        image: UIImage?,
        contractDisplayName: String,
        contractExposureName: String,
        terminationMessage: String? = nil,
        activeFrom: String? = nil,
        activeInFuture: Bool? = nil,
        masterInceptionDate: String? = nil,
        tierDisplayName: String?
    ) {
        self.image = image
        self.contractDisplayName = contractDisplayName
        self.contractExposureName = contractExposureName
        self.terminationMessage = terminationMessage

        self.activeFrom = activeFrom
        self.activeInFuture = activeInFuture
        self.masterInceptionDate = masterInceptionDate
        self.tierDisplayName = tierDisplayName
    }

    @ViewBuilder var background: some View {
        if let image {
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
            hFillColor.Opaque.tertiary
        }
    }

    @ViewBuilder var logo: some View {
        Image(uiImage: HCoreUIAsset.helipadBig.image)
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(hFillColor.Opaque.white)
            .colorScheme(.dark)
    }

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: .padding6) {
                if let tierDisplayName, Dependencies.featureFlags().isTiersEnabled {
                    StatusPill(text: tierDisplayName, type: .tier)
                }
                if let terminationMessage {
                    StatusPill(text: terminationMessage, type: .text)
                } else if let activeFrom {
                    StatusPill(
                        text: L10n.dashboardInsuranceStatusActiveUpdateDate(
                            activeFrom.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                        ),
                        type: .text
                    )
                } else if activeInFuture ?? false {
                    StatusPill(
                        text: L10n.contractStatusActiveInFuture(
                            masterInceptionDate?.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                        ),
                        type: .text
                    )
                } else {
                    StatusPill(
                        text: L10n.dashboardInsuranceStatusActive,
                        type: .text
                    )
                }
                Spacer()
                logo
            }
            Spacer()
            HStack {
                hText(contractDisplayName)
                    .foregroundColor(hTextColor.Opaque.white)
                Spacer()
            }
            hText(contractExposureName)
                .foregroundColor(hTextColor.Translucent.secondary)
                .colorScheme(.dark)
        }
        .padding(.padding16)
        .frame(minHeight: 200)
        .background(
            background
        )
        .border(hBorderColor.primary, width: 0.5)
        .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
        .hShadow()
        .contentShape(Rectangle())
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
        .padding(.vertical, 3)
        .padding(.horizontal, .padding6)
        .foregroundColor(hTextColor.Opaque.white)
        .background(type.getBackgroundColor).colorScheme(.light)
        .cornerRadius(.cornerRadiusS)
    }
}

#Preview {
    hSection {
        ContractRow(
            image: hCoreUIAssets.pillowHome.image,
            terminationMessage: "Active",
            contractDisplayName: "Insurance",
            contractExposureName: "Address ∙ Coverage",
            tierDisplayName: "tier display name"
        )
    }
}
