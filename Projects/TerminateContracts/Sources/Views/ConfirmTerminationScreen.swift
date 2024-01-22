import SwiftUI
import hCore
import hCoreUI

struct ConfirmTerminationScreen: View {
    @PresentableStore var store: TerminationContractStore
    let config: TerminationConfirmConfig?
    let onSelected: () -> Void

    var body: some View {
        hForm {
            VStack(spacing: 16) {
                DisplayContractTable(
                    config: config,
                    terminationDate: store.state.terminationDateStep?.date?.displayDateDDMMMYYYYFormat ?? ""
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
        }
    }
}

public struct TerminationConfirmConfig: Codable & Equatable & Hashable {
    public var image: String?
    public var contractDisplayName: String
    public var contractExposureName: String

    public init(
        image: String?,
        contractDisplayName: String,
        contractExposureName: String
    ) {
        self.image = image
        self.contractDisplayName = contractDisplayName
        self.contractExposureName = contractExposureName
    }
}

#Preview{
    ConfirmTerminationScreen(
        config: .init(image: hCoreUIAssets.pillowHome.name, contractDisplayName: "", contractExposureName: ""),
        onSelected: {}
    )
}
