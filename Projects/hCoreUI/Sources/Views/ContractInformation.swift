import SwiftUI

public struct ContractInformation: View {
    let displayName: String?
    let exposureName: String?
    let pillowImage: UIImage?

    public init(
        displayName: String?,
        exposureName: String?,
        pillowImage: UIImage?
    ) {
        self.displayName = displayName
        self.exposureName = exposureName
        self.pillowImage = pillowImage
    }

    public var body: some View {
        HStack(spacing: .padding12) {
            if let pillowImage {
                Image(uiImage: pillowImage)
                    .resizable()
                    .frame(width: 48, height: 48)
            }
            VStack(alignment: .leading, spacing: 0) {
                hText(displayName ?? "", style: .heading1)
                hText(exposureName ?? "", style: .body1)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
