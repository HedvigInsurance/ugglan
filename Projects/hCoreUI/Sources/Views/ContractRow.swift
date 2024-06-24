import Combine
import SwiftUI
import hCore

public struct ContractRow: View {
    @State var frameWidth: CGFloat = 0

    let image: UIImage?
    let terminationMessage: String?
    let contractDisplayName: String
    let contractExposureName: String

    let activeFrom: String?
    let activeInFuture: Bool?
    let masterInceptionDate: String?

    let onClick: (() -> Void)?

    public init(
        image: UIImage?,
        terminationMessage: String?,
        contractDisplayName: String,
        contractExposureName: String,
        activeFrom: String? = nil,
        activeInFuture: Bool? = nil,
        masterInceptionDate: String? = nil,
        onClick: (() -> Void)? = nil
    ) {
        self.image = image
        self.terminationMessage = terminationMessage
        self.contractDisplayName = contractDisplayName
        self.contractExposureName = contractExposureName

        self.activeFrom = activeFrom
        self.activeInFuture = activeInFuture
        self.masterInceptionDate = masterInceptionDate

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
                masterInceptionDate: masterInceptionDate
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

    public init(
        image: UIImage?,
        contractDisplayName: String,
        contractExposureName: String,
        terminationMessage: String? = nil,

        activeFrom: String? = nil,
        activeInFuture: Bool? = nil,
        masterInceptionDate: String? = nil
    ) {
        self.image = image
        self.contractDisplayName = contractDisplayName
        self.contractExposureName = contractExposureName
        self.terminationMessage = terminationMessage

        self.activeFrom = activeFrom
        self.activeInFuture = activeInFuture
        self.masterInceptionDate = masterInceptionDate
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
        Image(uiImage: hCoreUIAssets.helipadBig.image.withRenderingMode(.alwaysTemplate))
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(hFillColor.Opaque.white)
            .colorScheme(.dark)
    }

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                if let terminationMessage {
                    StatusPill(text: terminationMessage).padding(.trailing, .padding4)
                } else if let activeFrom {
                    StatusPill(
                        text: L10n.dashboardInsuranceStatusActiveUpdateDate(
                            activeFrom.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                        )
                    )
                    .padding(.trailing, .padding4)
                } else if activeInFuture ?? false {
                    StatusPill(
                        text: L10n.contractStatusActiveInFuture(
                            masterInceptionDate?.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                        )
                    )
                    .padding(.trailing, .padding4)
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
        .clipShape(Squircle.default())
        .hShadow()
        .contentShape(Rectangle())
    }
}

private struct StatusPill: View {
    var text: String

    var body: some View {
        VStack {
            hText(text, style: .standardSmall)
        }
        .padding(.vertical, 3)
        .padding(.horizontal, .padding6)
        .foregroundColor(hTextColor.Opaque.white)
        .background(hFillColor.Translucent.tertiary).colorScheme(.light)
        .cornerRadius(8)
    }
}

#Preview{
    hSection {
        ContractRow(
            image: hCoreUIAssets.pillowHome.image,
            terminationMessage: "Active",
            contractDisplayName: "Insurance",
            contractExposureName: "Address ∙ Coverage"
        )
    }
}
