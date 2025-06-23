import SwiftUI
import hCore

public struct AccordionView: View {
    let peril: Perils?
    let title: String
    let description: String
    @State private var extended = false

    public init(peril: Perils) {
        self.peril = peril
        self.title = peril.title
        self.description = peril.description
    }

    public init(title: String, description: String) {
        self.title = title
        self.description = description
        self.peril = nil
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation {
                    extended.toggle()
                    UIAccessibility.post(notification: .layoutChanged, argument: nil)
                }
            }) {
                AccordionHeader(
                    peril: peril,
                    title: title,
                    description: description,
                    extended: $extended
                )
                .padding(.horizontal, .padding16)
                .padding(.top, 17)
                .padding(.bottom, .padding24)
            }
            .accessibilityLabel("\(title)")
            .accessibilityAddTraits(.isButton)
        }
        .modifier(
            BackgorundColorAnimation(
                animationTrigger: $extended,
                color: hSurfaceColor.Opaque.primary,
                animationColor: hSurfaceColor.Opaque.secondary
            )
        )
    }
}

struct AccordionHeader: View {
    let peril: Perils?
    let title: String
    let description: String
    @Binding var extended: Bool

    var body: some View {
        HStack(alignment: .top, spacing: .padding8) {
            if let color = peril?.color {
                Group {
                    if peril?.isDisabled ?? false {
                        Circle()
                            .fill(hFillColor.Opaque.disabled)
                    } else {
                        Circle()
                            .fill(Color(hexString: color))
                    }
                }
                .frame(width: 16, height: 16)
                .padding([.horizontal, .vertical], .padding4)
            }
            VStack(alignment: .leading, spacing: 17) {
                hText(title, style: .body1)
                    .lineLimit(extended ? nil : 1)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(peril?.textColor)

                if extended {
                    AccordionBody(peril: peril, description: description, extended: $extended)
                        .multilineTextAlignment(.leading)
                        .accessibilityElement(children: .contain)
                }
            }
            Spacer()
            ZStack {
                Group {
                    Image(
                        uiImage: hCoreUIAssets.minus.image
                    )
                    .resizable()
                    .frame(width: 24, height: 24)
                    .transition(.opacity.animation(.easeOut))
                    .rotationEffect(extended ? Angle(degrees: 360) : Angle(degrees: 270))
                    Image(
                        uiImage: hCoreUIAssets.minus.image
                    )
                    .resizable()
                    .frame(width: 24, height: 24)
                    .transition(.opacity.animation(.easeOut))
                    .rotationEffect(extended ? Angle(degrees: 360) : Angle(degrees: 180))
                }
                .foregroundColor(peril?.textColor)
            }
        }
        .accessibilityAddTraits(extended ? .isHeader : [])
    }
}

struct AccordionBody: View {
    let peril: Perils?
    let description: String
    @Binding var extended: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: .padding12) {
            hText(description, style: peril != nil ? .label : .body1)
                .padding(.bottom, .padding12)
                .foregroundColor(peril?.textColor)
            if let perilCover = peril?.covered {
                ForEach(Array(perilCover.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .top, spacing: 8) {
                        if perilCover.count > 1 {
                            hText(String(format: "%02d", index + 1), style: .label)
                                .foregroundColor(hTextColor.Opaque.tertiary)
                        }
                        hText(item, style: .label)
                    }
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityAddTraits(extended ? .isSelected : [])
        .accessibilityValue(extended ? L10n.voiceoverExpanded : L10n.voiceoverCollapsed)
    }
}

@MainActor
extension Perils {
    @hColorBuilder
    var textColor: some hColor {
        if self.isDisabled {
            hTextColor.Opaque.disabled
        } else {
            hTextColor.Opaque.primary
        }
    }
}

#Preview {
    hSection {
        AccordionView(
            title: "Label",
            description:
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent suscipit metus a porttitor pulvinar. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Phasellus ac tristique sem. Praesent sit amet nisi fermentum, dignissim est nec, tristique ante. Aliquam aliquet vestibulum nulla a congue."
        )
    }
}
