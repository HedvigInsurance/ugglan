import Combine
import SwiftUI
import hCore

public struct ContractRow: View {
    @State var frameWidth: CGFloat = 0

    let image: UIImage?
    let terminationMessage: String?
    let contractDisplayName: String
    let contractExposureName: String

    let onClick: (() -> Void)?

    public init(
        image: UIImage?,
        terminationMessage: String?,
        contractDisplayName: String,
        contractExposureName: String,
        onClick: (() -> Void)? = nil
    ) {
        self.image = image
        self.terminationMessage = terminationMessage
        self.contractDisplayName = contractDisplayName
        self.contractExposureName = contractExposureName
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
                terminationMessage: terminationMessage
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
                if let terminationMessage {
                    StatusPill(text: terminationMessage).padding(.trailing, 4)
                } else if let activeFrom {
                    StatusPill(text: L10n.dashboardInsuranceStatusActiveUpdateDate(activeFrom)).padding(.trailing, 4)
                } else if activeInFuture ?? false {
                    StatusPill(text: L10n.contractStatusActiveInFuture(masterInceptionDate ?? ""))
                        .padding(.trailing, 4)
                }
                Spacer()
                logo
            }
            Spacer()
            HStack {
                hText(contractDisplayName)
                    .foregroundColor(hTextColor.primary)
                    .colorScheme(.dark)
                Spacer()
            }
            hText(contractExposureName)
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

#Preview{
    ContractRow(
        image: hCoreUIAssets.pillowHome.image,
        terminationMessage: "",
        contractDisplayName: "",
        contractExposureName: ""
    )
}
