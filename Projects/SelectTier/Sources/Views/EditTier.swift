import SwiftUI
import hCore
import hCoreUI

struct EditTier: View {
    @State var selectedTier: String?

    var body: some View {
        hForm {
            hRadioField(
                id: "id",
                leftView: {
                    AnyView(EmptyView())
                },
                selected: $selectedTier
            )

            /* TODO: IMPLEMENT THIS */
            //            let config: ItemConfig = .init(
            //                items: [()],
            //                preSelectedItems: {
            //                    return []
            //                },
            //                onSelected: { item in
            //
            //                },
            //                onCancel: nil,
            //                singleSelect: true,
            //                attachToBottom: false,
            //                disableIfNoneSelected: true,
            //                manualInputPlaceholder: nil,
            //                manualBrandName: nil,
            //                withTitle: "title",
            //                hButtonText: nil,
            //                infoCard: nil,
            //                fieldSize: .medium
            //            )
            //            ItemPickerScreen(config: config)
        }
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: .padding8) {
                    hButton.LargeButton(type: .primary) {

                    } content: {
                        hText(L10n.generalContinueButton)
                    }

                    hButton.LargeButton(type: .ghost) {

                    } content: {
                        hText(L10n.generalCancelButton)
                    }

                }
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

#Preview{
    EditTier()
}
