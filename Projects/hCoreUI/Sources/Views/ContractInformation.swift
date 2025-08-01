import SwiftUI

public struct ContractInformation: View {
    let displayName: String?
    let exposureName: String?
    let pillowImage: Image?
    let status: String?

    public init(
        displayName: String?,
        exposureName: String?,
        pillowImage: Image?,
        status: String? = nil
    ) {
        self.displayName = displayName
        self.exposureName = exposureName
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
                    hText(displayName ?? "", style: .heading1)
                    Spacer()
                    if let status {
                        hPill(text: status, color: .grey)
                            .hFieldSize(.medium)
                            .transition(.opacity)
                    }
                }
                if let exposureName {
                    hText(exposureName, style: .body1)
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
            displayName: "displayName",
            exposureName: "name",
            pillowImage: nil,
            status: "status"
        )
        .background(Color.red)
        ContractInformation(
            displayName: "displayName",
            exposureName: "name",
            pillowImage: nil
        )
        .background(Color.blue)
    }
})
