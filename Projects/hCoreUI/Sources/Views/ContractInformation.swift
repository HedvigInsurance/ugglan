import SwiftUI

public struct ContractInformation: View {
    let displayName: String?
    let description: String?
    let pillowImage: UIImage?
    let status: String?

    public init(
        displayName: String?,
        description: String?,
        pillowImage: UIImage?,
        status: String? = nil
    ) {
        self.displayName = displayName
        self.description = description
        self.pillowImage = pillowImage
        self.status = status
    }

    public var body: some View {
        HStack(spacing: .padding12) {
            if let pillowImage {
                Image(uiImage: pillowImage)
                    .resizable()
                    .frame(width: 48, height: 48)
            }
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    hText(displayName ?? "", style: .heading1)
                    Spacer()
                    if let status {
                        hPill(text: status, color: .grey)
                            .hFieldSize(.medium)
                            .transition(.opacity)
                    }
                }
                if let description {
                    hText(description, style: .body1)
                        .foregroundColor(hTextColor.Translucent.secondary)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview(body: {
    VStack {
        ContractInformation(
            displayName: "displayName",
            description: "name",
            pillowImage: nil,
            status: "status"
        )
        .background(Color.red)
        ContractInformation(
            displayName: "displayName",
            description: "name",
            pillowImage: nil
        )
        .background(Color.blue)

    }
})
