import SwiftUI
import hCore
import hCoreUI

public struct ChangeCoverageDaysScreen: View {
    @EnvironmentObject var changeAddonNavigationVm: ChangeAddonNavigationViewModel
    let addon: AddonModel
    @State var selectedDays: String?

    public var body: some View {
        hForm {
            VStack(spacing: .padding4) {
                ForEach(addon.coverageDays ?? [], id: \.title) { coverageDay in
                    hSection {
                        hRadioField(
                            id: coverageDay.title,
                            itemModel: nil,
                            leftView: {
                                HStack {
                                    hText(coverageDay.title)
                                    Spacer()
                                    hPill(
                                        text: "+ \(coverageDay.nbOfDays) kr/mo",
                                        color: .grey(translucent: true),
                                        colorLevel: .one
                                    )
                                    .hFieldSize(.small)
                                }
                                .asAnyView
                            },
                            selected: $selectedDays,
                            error: .constant(nil),
                            useAnimation: true
                        )
                        .hFieldSize(.medium)
                        .hFieldLeftAttachedView
                    }
                }
            }
            .padding(.top, 32)

        }
        .hFormTitle(
            title: .init(
                .small,
                .heading1,
                addon.title,
                alignment: .leading
            ),
            subTitle: .init(
                .small,
                .heading1,
                "Välj din skyddsnivå"
            )
        )
        .hDisableScroll
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: .padding8) {
                    hButton.LargeButton(type: .primary) {
                        /* TODO: IMPLEMENT */
                    } content: {
                        hText(L10n.generalConfirm)
                    }

                    hButton.LargeButton(type: .ghost) {
                        /* TODO: IMPLEMENT */
                    } content: {
                        hText(L10n.generalCancelButton)
                    }
                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.top, 16)
        }
    }
}

#Preview {
    ChangeCoverageDaysScreen(
        addon: .init(
            title: "title",
            subTitle: "subTitle",
            tag: "+ 46 kr/mo",
            coverageDays: [
                .init(nbOfDays: 45, title: "Travel Plus 45 days", price: 49),
                .init(nbOfDays: 60, title: "Travel Plus 60 days", price: 79),
            ]
        )
    )
}
