import SwiftUI
import hCore

public struct AccordionView: View {
    let peril: Perils?
    let title: String
    let description: String
    @State private var extended = false
    public init(peril: Perils) {
        self.peril = peril
        title = peril.title
        description = peril.description
    }

    public init(title: String, description: String) {
        self.title = title
        self.description = description
        peril = nil
    }

    public var body: some View {
        ZStack {
            ColorAnimationView(
                animationTrigger: $extended,
                color: hSurfaceColor.Opaque.primary,
                animationColor: hSurfaceColor.Opaque.secondary
            )
            VStack(spacing: 0) {
                AccordionHeader(peril: peril, title: title, extended: $extended)
                    .padding(.bottom, .padding18)
                    .accessibilityAddTraits(.isButton)
                if extended {
                    AccordionBody(peril: peril, description: description, extended: $extended)
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .onTapGesture(count: 1) {
            withAnimation {
                extended.toggle()
                UIAccessibility.post(notification: .layoutChanged, argument: nil)
            }
        }
    }
}

struct AccordionHeader: View {
    let peril: Perils?
    let title: String
    @Binding var extended: Bool
    var body: some View {
        hSection {
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
                    .multilineTextAlignment(.leading)
                    .foregroundColor(peril?.textColor)
                    .accessibilityLabel("\(title)")
                    .accessibilityValue(extended ? L10n.voiceoverExpanded : L10n.voiceoverCollapsed)
                Spacer()
                Group {
                    ZStack {
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
                }
                .foregroundColor(peril?.textColor)
            }
            .padding(.top, .padding16)
        }
        .accessibilityElement(children: .combine)
    }
}

struct AccordionBody: View {
    let peril: Perils?
    let description: String
    @Binding var extended: Bool

    var body: some View {
        hSection {
            VStack(alignment: .leading, spacing: .padding24) {
                hText(description, style: peril != nil ? .label : .body1)
                    .foregroundColor(peril?.textColor)
                if let perilCover = peril?.covered, !perilCover.isEmpty {
                    VStack(alignment: .leading, spacing: .padding12) {
                        ForEach(Array(perilCover.enumerated()), id: \.offset) { index, item in
                            HStack(alignment: .top, spacing: 8) {
                                if perilCover.count > 1 {
                                    hText(String(format: "%02d", index + 1), style: .label)
                                        .foregroundColor(hTextColor.Opaque.tertiary)
                                }
                                hText(item, style: .label)
                                Spacer()
                            }
                            .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding(.horizontal, peril?.color == nil ? 0 : .padding32)
            .padding(.bottom, .padding24)
        }
        .accessibilityElement(children: .combine)
    }
}

@MainActor
extension Perils {
    @hColorBuilder
    var textColor: some hColor {
        if isDisabled {
            hTextColor.Opaque.disabled
        } else {
            hTextColor.Opaque.primary
        }
    }
}

#Preview {
    hSection {
        AccordionView(
            peril: .init(
                id: "id",
                title: "title",
                description:
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent suscipit metus a porttitor pulvinar. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Phasellus ac tristique sem. Praesent sit amet nisi fermentum, dignissim est nec, tristique ante. Aliquam aliquet vestibulum nulla a congue.",
                color: "#000000",
                covered: []
            )
        )
        AccordionView(
            title: "Label",
            description:
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent suscipit metus a porttitor pulvinar. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Phasellus ac tristique sem. Praesent sit amet nisi fermentum, dignissim est nec, tristique ante. Aliquam aliquet vestibulum nulla a congue."
        )
    }
}
