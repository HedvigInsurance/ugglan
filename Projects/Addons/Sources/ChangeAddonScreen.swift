import SwiftUI
import hCore
import hCoreUI

public struct ChangeAddonScreen: View {
    @State var selectedAddon: String?

    public var body: some View {
        hForm {}
            .hFormTitle(
                title: .init(
                    .small,
                    .body2,
                    "Utöka ditt reseskydd",
                    alignment: .leading
                ),
                subTitle: .init(
                    .small,
                    .body2,
                    "Lorem ipsum dolor sit amet our"
                )
            )
            .hFormAttachToBottom {
                VStack(spacing: .padding8) {
                    addOnSection
                    hSection {
                        InfoCard(
                            text: "Click to learn more about our extended travel coverage Reseskydd Plus",
                            type: .neutral
                        )

                        hButton.LargeButton(type: .primary) {
                            /* TODO: IMPLEMENT */
                        } content: {
                            hText(L10n.generalContinueButton)
                        }
                        .padding(.top, .padding16)
                    }
                    .sectionContainerStyle(.transparent)
                }
            }
            .hDisableScroll
    }

    @ViewBuilder
    private var addOnSection: some View {
        let addons: [Addon] = [
            .init(title: "Reseskydd", subTitle: nil, tag: "Ingår"),
            .init(
                title: "Reseskydd Plus",
                subTitle: "För dig som reser mycket, bagageskydd, hjälp överallt i världen 24/7.",
                tag: "+ 49 kr/mo"
            ),
        ]

        VStack(spacing: .padding4) {
            ForEach(addons) { addon in
                hSection {
                    hRadioField(
                        id: addon.id.uuidString,
                        leftView: {
                            getLeftView(for: addon).asAnyView
                        },
                        selected: $selectedAddon,
                        error: .constant(nil),
                        useAnimation: true
                    )
                    .hFieldSize(.medium)
                    .hFieldLeftAttachedView
                }
            }
        }
    }

    private func getLeftView(for addon: Addon) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                hText(addon.title)
                    .fixedSize()
                Spacer()
                hPill(text: addon.tag, color: .grey(translucent: true), colorLevel: .one)
                    .hFieldSize(.small)
            }
            if let subTitle = addon.subTitle {
                hText(subTitle, style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
        }
    }
}

public struct Addon: Identifiable {
    public var id = UUID()
    let title: String
    let subTitle: String?
    let tag: String
}

#Preview {
    ChangeAddonScreen()
}
