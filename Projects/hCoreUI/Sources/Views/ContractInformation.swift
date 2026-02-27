import SwiftUI

public struct ContractInformation: View {
    let title: String?
    let subtitle: String?
    let pillowImage: Image?
    let status: String?

    public init(
        title: String?,
        subtitle: String?,
        pillowImage: Image?,
        status: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.pillowImage = pillowImage
        self.status = status
    }

    public var body: some View {
        HStack(spacing: .padding12) {
            if let pillowImage {
                pillowImage
                    .resizable()
                    .frame(width: 48, height: 48)
            }
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    hText(title ?? "", style: .heading1)
                    Spacer()
                    if let status {
                        hPill(text: status, color: .grey)
                            .hFieldSize(.medium)
                            .transition(.opacity)
                    }
                }
                if let subtitle {
                    hText(subtitle, style: .body1)
                        .foregroundColor(hTextColor.Translucent.secondary)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
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
