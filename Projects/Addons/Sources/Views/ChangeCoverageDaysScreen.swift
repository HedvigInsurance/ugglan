import SwiftUI
import hCore
import hCoreUI

public struct ChangeCoverageDaysScreen: View {
    @ObservedObject var changeAddonNavigationVm: ChangeAddonNavigationViewModel

    let addonOption: AddonOptionModel
    @State var selectedSubOptionId: String?

    init(
        addonOption: AddonOptionModel,
        changeAddonNavigationVm: ChangeAddonNavigationViewModel
    ) {
        self.addonOption = addonOption
        self.changeAddonNavigationVm = changeAddonNavigationVm

        if let selectedSubOption = changeAddonNavigationVm.changeAddonVm.selectedSubOptionId {
            self._selectedSubOptionId = State(initialValue: String(selectedSubOption))
        } else {
            self._selectedSubOptionId = State(initialValue: addonOption.subOptions.first?.id.uuidString)
        }
    }

    public var body: some View {
        hForm {
            VStack(spacing: .padding4) {
                ForEach(addonOption.subOptions, id: \.id) { subOption in
                    hSection {
                        hRadioField(
                            id: subOption.id.uuidString,
                            itemModel: nil,
                            leftView: {
                                HStack {
                                    hText(subOption.title ?? "")
                                    Spacer()
                                    hPill(
                                        text: "+ " + subOption.price.formattedAmountPerMonth,
                                        color: .grey(translucent: true),
                                        colorLevel: .one
                                    )
                                    .hFieldSize(.small)
                                }
                                .asAnyView
                            },
                            selected: $selectedSubOptionId,
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
                        changeAddonNavigationVm.changeAddonVm.selectedSubOptionId = selectedSubOptionId
                        changeAddonNavigationVm.isChangeCoverageDaysPresented = nil
                    } content: {
                        hText(L10n.generalConfirm)
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

extension ChangeCoverageDaysScreen: TitleView {
    public func getTitleView() -> UIView {
        let view: UIView = UIHostingController(rootView: titleView).view
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }

    @ViewBuilder
    private var titleView: some View {
        VStack(alignment: .leading, spacing: 0) {
            hText(self.addonOption.title ?? "", style: .heading1)
                .foregroundColor(hTextColor.Opaque.primary)
            hText("Välj din skyddsnivå", style: .heading1)
                .foregroundColor(hTextColor.Opaque.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, .padding8)
    }
}

#Preview {
    ChangeCoverageDaysScreen(
        addonOption: .init(
            title: "Reseskydd",
            subtitle: "subtitle",
            price: nil,
            subOptions: [
                .init(
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
