import SwiftUI
import hCore
import hCoreUI

struct ConfirmTerminationScreen: View {
    @PresentableStore var store: TerminationContractStore
    let config: TerminationConfirmConfig
    let onSelected: () -> Void

    var body: some View {
        hForm {
            VStack(spacing: 16) {
                DisplayContractTable(
                    config: config,
                    terminationDate: (store.state.config?.isDeletion ?? false)
                        ? Date().displayDateDDMMMYYYYFormat ?? ""
                        : store.state.terminationDateStep?.date?.displayDateDDMMMYYYYFormat ?? ""
                )
                DisplayQuestionView()
            }
        }
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: 8) {
                    hButton.LargeButton(type: .alert) {
                        onSelected()
                    } content: {
                        hText(L10n.terminationConfirmButton)
                    }
                    hButton.LargeButton(type: .ghost) {
                        store.send(.dismissTerminationFlow)
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

#Preview{
    ConfirmTerminationScreen(
        config: .init(contractId: "", image: .home, contractDisplayName: "", contractExposureName: ""),
        onSelected: {}
    )
}
