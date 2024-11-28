import SwiftUI
import hCoreUI

public struct AddonCardView: View {
    let openAddon: () -> Void

    public init(
        openAddon: @escaping () -> Void
    ) {
        self.openAddon = openAddon
    }

    public var body: some View {
        hSection {
            hRow {
                VStack(alignment: .leading) {
                    HStack {
                        hText("Travel Insurance Plus")
                        Spacer()
                        hPill(text: "49 kr/mo", color: .green, colorLevel: .one)
                            .hFieldSize(.small)
                    }
                    hText("Extended travel insurance with extra coverage for your travels", style: .label)
                        .foregroundColor(hTextColor.Opaque.secondary)

                    HStack(spacing: .padding8) {
                        hButton.SmallButton(type: .secondary) {
                        } content: {
                            hText("Learn more")
                        }
                        hButton.SmallButton(type: .primary) {
                            openAddon()
                        } content: {
                            hText("Explore options")
                        }
                    }
                }
            }
        }
        .sectionContainerStyle(.transparent)
        .border(hBorderColor.primary, width: 0.5)
        .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
    }
}

#Preview {
    AddonCardView(openAddon: {})
}
