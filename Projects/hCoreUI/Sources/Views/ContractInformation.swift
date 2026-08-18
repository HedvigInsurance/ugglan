import SwiftUI

public struct ContractInformation: View {
    let title: String?
    let subtitle: String?
    let pillowImage: Image?
    let status: String?
    let size: ContractInformationSizeType

    public init(
        title: String?,
        subtitle: String?,
        pillowImage: Image?,
        status: String? = nil,
        size: ContractInformationSizeType = .regular,
    ) {
        self.title = title
        self.subtitle = subtitle
        self.pillowImage = pillowImage
        self.status = status
        self.size = size
    }

    public var body: some View {
        HStack(spacing: .padding12) {
            if let pillowImage {
                pillowImage
                    .resizable()
                    .frame(width: size.pillowSize, height: size.pillowSize)
            }
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    hText(title ?? "", style: size.titleStyle)
                    Spacer()
                    if let status {
                        hPill(text: status, color: .grey)
                            .hFieldSize(.medium)
                            .transition(.opacity)
                    }
                }
                if let subtitle {
                    hText(subtitle, style: size.subtitleStyle)
                        .foregroundColor(hTextColor.Translucent.secondary)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}

public enum ContractInformationSizeType {
    case regular
    case small

    var pillowSize: CGFloat {
        switch self {
        case .regular:
            return 48
        case .small:
            return 40
        }
    }

    var titleStyle: HFontTextStyle {
        switch self {
        case .regular:
            return .heading1
        case .small:
            return .label
        }
    }

    var subtitleStyle: HFontTextStyle {
        switch self {
        case .regular:
            return .body1
        case .small:
            return .label
        }
    }
}

#Preview(body: {
    VStack {
        ContractInformation(
            title: "displayName",
            subtitle: "name",
            pillowImage: nil,
            status: "status"
        )
        .background(Color.red)
        ContractInformation(
            title: "displayName",
            subtitle: "name",
            pillowImage: nil
        )
        .background(Color.blue)
    }
})
