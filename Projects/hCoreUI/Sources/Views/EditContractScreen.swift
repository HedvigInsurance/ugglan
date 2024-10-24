import SwiftUI
import hCore

public struct EditContractScreen: View {
    @State var selectedType: EditType?
    @State var selectedValue: String?

    let editTypes: [EditType]
    let onSelectedType: (EditType) -> Void
    @EnvironmentObject var router: Router

    public init(editTypes: [EditType], onSelectedType: @escaping (EditType) -> Void) {
        self.editTypes = editTypes
        self.onSelectedType = onSelectedType
    }

    public var body: some View {
        hForm {
            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    ForEach(editTypes, id: \.rawValue) { editType in
                        hSection {
                            hRadioField(
                                id: editType.rawValue,
                                leftView: {
                                    VStack(alignment: .leading, spacing: .padding2) {
                                        HStack {
                                            hText(editType.title)
                                        }
                                        hText(editType.subtitle, style: .label)
                                            .foregroundColor(hTextColor.Translucent.secondary)
                                    }
                                    .asAnyView
                                },
                                selected: $selectedValue,
                                error: nil,
                                useAnimation: true
                            )
                            .hFieldSize(.medium)
                        }
                    }
                }
                infoView
                hSection {
                    VStack(spacing: 8) {
                        hButton.LargeButton(type: .primary) { [weak router] in
                            if let selectedType {
                                router?.dismiss()
                                onSelectedType(selectedType)
                            }
                        } content: {
                            hText(selectedType?.buttonTitle ?? L10n.generalContinueButton, style: .body1)
                        }
                        .disabled(selectedType == nil)

                        hButton.LargeButton(type: .ghost) {
                            router.dismiss()
                        } content: {
                            hText(L10n.generalCancelButton)
                        }
                    }
                }
                .sectionContainerStyle(.transparent)
                .padding(.bottom, .padding16)
            }
        }
        .hDisableScroll
        .onChange(of: selectedValue) { value in
            selectedType = EditType(rawValue: value ?? "")
        }
    }

    @ViewBuilder
    var infoView: some View {
        if selectedType == .coInsured && !Dependencies.featureFlags().isEditCoInsuredEnabled {
            hSection {
                InfoCard(
                    text: L10n.InsurancesTab.contactUsToEditCoInsured,
                    type: .info
                )
            }
            .transition(.opacity)
            .sectionContainerStyle(.transparent)
        }
    }

    @hColorBuilder
    func retColor(isSelected: Bool) -> some hColor {
        if isSelected {
            hTextColor.Opaque.primary
        } else {
            hSurfaceColor.Opaque.primary
        }
    }

    @hColorBuilder
    func getBorderColor(isSelected: Bool) -> some hColor {
        if isSelected {
            hTextColor.Opaque.primary
        } else {
            hBorderColor.secondary
        }
    }
}

struct EditContract_Previews: PreviewProvider {
    static var previews: some View {
        EditContractScreen(editTypes: []) { _ in

        }
    }
}
