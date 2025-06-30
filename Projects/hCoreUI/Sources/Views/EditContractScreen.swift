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
            VStack(spacing: .padding16) {
                VStack(spacing: .padding4) {
                    ForEach(editTypes, id: \.rawValue) { editType in
                        hSection {
                            hRadioField(
                                id: editType.rawValue,
                                leftView: {
                                    VStack(
                                        alignment: .leading,
                                        spacing: .padding2
                                    ) {
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
                        .accessibilityElement(children: .combine)
                    }
                }
                infoView
                hSection {
                    VStack(spacing: .padding8) {
                        hButton(
                            .large,
                            .primary,
                            content: .init(title: selectedType?.buttonTitle ?? L10n.generalContinueButton),
                            { [weak router] in
                                if let selectedType {
                                    router?.dismiss()
                                    onSelectedType(selectedType)
                                }
                            }
                        )
                        .disabled(selectedType == nil)
                        .accessibilityHint(
                            selectedType != nil
                                ? L10n.voiceoverOptionSelected + (selectedType?.title ?? "")
                                : L10n.voiceoverPickerInfo(selectedType?.buttonTitle ?? L10n.generalContinueButton)
                        )

                        hCancelButton {
                            router.dismiss()
                        }
                    }
                }
                .sectionContainerStyle(.transparent)
                .padding(.bottom, .padding16)
            }
        }
        .hFormContentPosition(.compact)
        .onChange(of: selectedValue) { value in
            selectedType = EditType(rawValue: value ?? "")
        }
    }

    @ViewBuilder
    var infoView: some View {
        if selectedType == .coInsured {
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
