import SwiftUI

public struct ContractInformation: View {
    let displayName: String?
    let exposureName: String?
    let pillowImage: UIImage?
    let onInfoClick: (() -> Void)?

    public init(
        displayName: String?,
        exposureName: String?,
        pillowImage: UIImage?,
        onInfoClick: (() -> Void)? = nil
    ) {
        self.displayName = displayName
        self.exposureName = exposureName
        self.pillowImage = pillowImage
        self.onInfoClick = onInfoClick
    }

    public var body: some View {
        HStack(spacing: .padding12) {
            if let pillowImage {
                Image(uiImage: pillowImage)
                    .resizable()
                    .frame(width: 48, height: 48)
            }
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    hText(displayName ?? "", style: .heading1)
                    Spacer()
                    if let onInfoClick = onInfoClick {
                        Image(uiImage: hCoreUIAssets.infoOutlined.image)
                            .foregroundColor(hFillColor.Opaque.primary)
                            .onTapGesture {
                                onInfoClick()
                            }
                    }
                }
                hText(exposureName ?? "", style: .body1)
                    .foregroundColor(hTextColor.Translucent.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
