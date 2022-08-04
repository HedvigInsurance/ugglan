import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct ProfileRow: View {
    let title: String
    let subtitle: String?
    let icon: UIImage
    let onTap: () -> Void

    public var body: some View {
        hRow {
            HStack(spacing: 16) {
                Image(uiImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 2) {
                    hText(title)
                    if let subtitle = subtitle {
                        hText(subtitle, style: .footnote).foregroundColor(hLabelColor.secondary)
                    }
                }
            }
            .padding(0)
        }
        .withCustomAccessory({
            Spacer()
            StandaloneChevronAccessory()
        })
        .verticalPadding(12)
        .onTap {
            onTap()
        }
    }
}
