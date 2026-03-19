import Kingfisher
import SwiftUI
import hCoreUI

struct SingleSelectValueView: View {
    let item: SingleSelectValue
    let onTap: (() -> Void)?
    @Environment(\.hFieldSize) var fieldSize
    private var isSmallSize: Bool {
        fieldSize == .small
    }
    var body: some View {
        let row = hRow {
            HStack(spacing: .padding16) {
                image
                content
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }

        if let onTap {
            hSection {
                row.withChevronAccessory
                    .hRowContentAlignment(.top)
                    .onTapGesture {
                        onTap()
                    }
            }
        } else {
            hSection {
                row.verticalPadding(12)
            }
        }
    }
    @ViewBuilder
    private var image: some View {
        if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
            KFImage(url)
                .placeholder {
                    WordmarkActivityIndicator(.standard)
                }
                .onFailureImage(hCoreUIAssets.helipadBig.image)
                .resizable()
                .fade(duration: 0.1)
                .aspectRatio(contentMode: .fit)
                .frame(width: isSmallSize ? 24 : 38, height: isSmallSize ? 24 : 38)
                .padding(.padding4)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusXS))
                .overlay {
                    RoundedRectangle(cornerRadius: .cornerRadiusXS)
                        .stroke(hBorderColor.primary, lineWidth: 1)
                }
                .frame(width: isSmallSize ? 32 : 46)
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: isSmallSize ? -2 : 4) {
            hText(item.title, style: .heading1)
            if let subtitle = item.subtitle {
                hText(subtitle, style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    VStack {
        SingleSelectValueView(
            item: .init(
                title: "title",
                subtitle: "subtitle",
                value: "value",
                imageUrl: "https://d2rro69q822tnr.cloudfront.net/produktbilder/163169278255445648779_small.jpg"
            )
        ) {
        }

        SingleSelectValueView(
            item: .init(
                title: "title",
                subtitle: "subtitle",
                value: "value",
                imageUrl: "https://d2rro69q822tnr.cloudfront.net/produktbilder/163169278255445648779_small.jpg"
            ),
            onTap: nil
        )
        .hFieldSize(.small)

        SingleSelectValueView(
            item: .init(
                title: "title that is long and goes into 2 lines",
                subtitle: "subtitle",
                value: "value",
                imageUrl: "https://d2rro69q822tnr.cloudfront.net/produktbilder/163169278255445648779_small.jpg"
            )
        ) {
        }

        SingleSelectValueView(
            item: .init(
                title: "title that is long and goes into 2 lines",
                subtitle: "subtitle",
                value: "value",
                imageUrl: "https://d2rro69q822tnr.cloudfront.net/produktbilder/163169278255445648779_small.jpg"
            ),
            onTap: nil
        )
        .hFieldSize(.small)
    }
}
