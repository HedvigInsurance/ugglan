import SwiftUI

public struct ContractInformation: View {
    let displayName: String?
    let exposureName: String?
    let pillowImage: UIImage?
    let multiplier = HFontTextStyle.body1.multiplier

    let status: String?
    public init(
        displayName: String?,
        exposureName: String?,
        pillowImage: UIImage?,
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
                Image(uiImage: pillowImage)
                    .resizable()
                    .frame(width: 48, height: 48)
            }
            VStack(alignment: .leading, spacing: multiplier != 1 ? .padding8 * multiplier : 0) {
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
