import SwiftUI
import hCore
import hCoreUI

struct AddonSelectSubOptionScreen: View {
    @ObservedObject var changeAddonNavigationVm: ChangeAddonNavigationViewModel
    let addonOption: AddonOptionModel

    init(
        addonOption: AddonOptionModel,
        changeAddonNavigationVm: ChangeAddonNavigationViewModel
    ) {
        self.addonOption = addonOption
        self.changeAddonNavigationVm = changeAddonNavigationVm

        if changeAddonNavigationVm.changeAddonVm.selectedSubOption == nil {
            changeAddonNavigationVm.changeAddonVm.selectedSubOption = addonOption.subOptions.first
        }
    }

    var body: some View {
        hForm {
            VStack(spacing: .padding4) {
                ForEach(addonOption.subOptions, id: \.id) { subOption in
                    hSection {
                        hRadioField(
                            id: subOption,
                            itemModel: nil,
                            leftView: {
                                HStack {
                                    hText(subOption.title ?? "")
                                    Spacer()
                                    hPill(
                                        text: L10n.addonFlowPriceLabel(subOption.price.amount),
                                        color: .grey(translucent: true),
                                        colorLevel: .one
                                    )
                                    .hFieldSize(.small)
                                }
                                .asAnyView
                            },
                            selected: $changeAddonNavigationVm.changeAddonVm.selectedSubOption,
                            error: .constant(nil),
                            useAnimation: true
                        )
                        .hFieldSize(.medium)
                        .hFieldLeftAttachedView
                    }
                }
            }
            .padding(.top, .padding16)
        }
        .hDisableScroll
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: .padding8) {
                    hButton.LargeButton(type: .primary) {
                        changeAddonNavigationVm.isChangeCoverageDaysPresented = nil
                    } content: {
                        hText(L10n.addonFlowSelectButton)
                    }

                    hButton.LargeButton(type: .ghost) {
                        changeAddonNavigationVm.isChangeCoverageDaysPresented = nil
                    } content: {
                        hText(L10n.generalCancelButton)
                    }
                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.top, 16)
        }
        .configureTitleView(self)
    }
}

extension AddonSelectSubOptionScreen: TitleView {
    func getTitleView() -> UIView {
        let view: UIView = UIHostingController(rootView: titleView).view
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }

    @ViewBuilder
    private var titleView: some View {
        VStack(alignment: .leading, spacing: 0) {
            hText(L10n.addonFlowSelectSuboptionTitle, style: .heading1)
                .foregroundColor(hTextColor.Opaque.primary)
            hText(L10n.addonFlowSelectSuboptionSubtitle, style: .heading1)
                .foregroundColor(hTextColor.Opaque.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, .padding8)
    }
}

#Preview {
    AddonSelectSubOptionScreen(
        addonOption: .init(
            id: "Resesydd",
            title: "Reseskydd",
            subtitle: "subtitle",
            price: nil,
            subOptions: [
                .init(
                    id: "subOption",
                    title: "subOption",
                    subtitle: "",
                    price: .init(amount: "79", currency: "SEK")
                )
            ]
        ),
        changeAddonNavigationVm: .init(
            input: .init(contractId: "contractId")
        )
    )
}
