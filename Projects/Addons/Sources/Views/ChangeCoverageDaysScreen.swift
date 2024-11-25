import SwiftUI
import hCore
import hCoreUI

public struct ChangeCoverageDaysScreen: View {
    @ObservedObject var changeAddonNavigationVm: ChangeAddonNavigationViewModel

    let addon: AddonModel
    @State var selectedDaysId: String?

    init(
        addon: AddonModel,
        changeAddonNavigationVm: ChangeAddonNavigationViewModel
    ) {
        self.addon = addon
        self.changeAddonNavigationVm = changeAddonNavigationVm

        if let selectedDays = changeAddonNavigationVm.changeAddonVm.selectedCoverageDayId {
            self._selectedDaysId = State(initialValue: String(selectedDays))
        } else {
            self._selectedDaysId = State(initialValue: addon.coverageDays?.first?.id.uuidString)
        }
    }

    public var body: some View {
        hForm {
            VStack(spacing: .padding4) {
                ForEach(addon.coverageDays ?? [], id: \.self) { coverageDay in
                    hSection {
                        hRadioField(
                            id: coverageDay.id.uuidString,
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
                            selected: $selectedDaysId,
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
                        changeAddonNavigationVm.changeAddonVm.selectedCoverageDayId = selectedDaysId
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
            hText("addon.title", style: .heading1)
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
        addon: .init(
            title: "title",
            subTitle: "subTitle",
            tag: "+ 46 kr/mo",
            coverageDays: [
                .init(nbOfDays: 45, title: "Travel Plus 45 days", price: 49),
                .init(nbOfDays: 60, title: "Travel Plus 60 days", price: 79),
            ]
        ),
        changeAddonNavigationVm: .init(input: .init(contractId: "contractId"))
    )
}
