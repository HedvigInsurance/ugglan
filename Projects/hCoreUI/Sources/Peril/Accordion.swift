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
                    extended: extended
                )
                .padding(.horizontal, .padding16)
                .padding(.vertical, 17)
            }
            .accessibilityLabel("\(title)")
            .accessibilityAddTraits(.isButton)
            .modifier(
                BackgorundColorAnimation(
                    animationTrigger: $extended,
                    color: hSurfaceColor.Opaque.primary,
                    animationColor: hSurfaceColor.Opaque.secondary
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))

            if extended {
                AccordionBody(peril: peril, description: description)
                    .padding(.bottom, .padding8)
                    .accessibilityElement(children: .contain)
            }
        }
    }
}

struct AccordionHeader: View {
    let peril: Perils?
    let title: String
    let extended: Bool

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
            hText(title, style: .body1)
                .lineLimit(extended ? nil : 1)
                .foregroundColor(getTextColor)
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
                .foregroundColor(getTextColor)
            }
        }
        .accessibilityAddTraits(extended ? .isHeader : [])
    }

    @hColorBuilder
    var getTextColor: some hColor {
        if peril?.isDisabled ?? false {
            hTextColor.Opaque.disabled
        } else {
            hTextColor.Opaque.primary
        }
    }
}

struct AccordionBody: View {
    let peril: Perils?
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: .padding12) {
            hText(description, style: peril != nil ? .label : .body1)
                .padding(.bottom, .padding12)
                .foregroundColor(getTextColor)
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
        .padding(.horizontal, .padding32)
        .accessibilityAddTraits(extended ? .isSelected : [])
        .accessibilityValue(extended ? L10n.voiceoverExpanded : L10n.voiceoverCollapsed)
    }

    @hColorBuilder
    var getTextColor: some hColor {
        if peril?.isDisabled ?? false {
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
