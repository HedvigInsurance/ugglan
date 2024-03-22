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
                hSection {
                    VStack {
                        Group {
                            hText(L10n.terminationFlowCancellationTitle, style: .title3)
                            hText("Confirm your information", style: .title3)
                                .foregroundColor(hTextColor.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .sectionContainerStyle(.transparent)

                displayInfoSection
                //                displayPaymentInformation
            }
            .padding(.top, 8)
        }
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: 16) {
                    InfoCard(
                        text:
                            "We remind you of the importance of maintaining continuous insurance coverage to ensure future compensation. By cancelling you confirm that you have read this information.",
                        type: .attention
                    )

                    hButton.LargeButton(type: .primary) {
                        onSelected()
                    } content: {
                        hText(L10n.terminationConfirmButton)
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }

    var displayInfoSection: some View {
        PresentableStoreLens(
            TerminationContractStore.self,
            getter: { state in
                state
            }
        ) { termination in
            VStack(spacing: 4) {
                hSection {
                    hRow {
                        VStack(alignment: .leading) {
                            hText(config.contractDisplayName)
                            hText(config.contractExposureName, style: .standardSmall)
                                .foregroundColor(hTextColor.secondaryTranslucent)
                        }
                    }
                }

                hSection {
                    hFloatingField(
                        value: termination.terminationDateStep?.date?.displayDateDDMMMYYYYFormat
                            ?? " ",
                        placeholder: L10n.terminationDateText,
                        onTap: {
                            store.send(.navigationAction(action: .openTerminationDatePickerScreen))
                        }
                    )
                }
            }
        }
    }

    var displayPaymentInformation: some View {
        PresentableStoreLens(
            TerminationContractStore.self,
            getter: { state in
                state
            }
        ) { termination in
            hSection {
                hRow {
                    HStack {
                        VStack(alignment: .leading) {
                            hText("Today - " + (termination.terminationDateStep?.date?.displayDateDDMMMFormat ?? ""))
                            let daysUntilTermination = termination.terminationDateStep?.date?.daysBetween(start: Date())
                            hText(String(daysUntilTermination ?? 0) + " days", style: .standardSmall)
                        }
                        Spacer()
                        hText("189 kr")
                    }
                    .padding(.bottom, 16)
                }
                .verticalPadding(0)
                .hWithoutDividerPadding
                .foregroundColor(hTextColor.secondary)

                hRow {
                    VStack(alignment: .leading) {
                        HStack {
                            hText("RARING", style: .standardSmall)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            Squircle.default()
                                .fill(hFillColor.opaqueOne)
                        )
                        hText("3 invited friends")
                            .foregroundColor(hTextColor.secondary)
                    }
                    Spacer()
                    hText("-30 kr")
                        .foregroundColor(hTextColor.secondary)
                }
                .hWithoutDividerPadding

                hRow {
                    VStack(alignment: .leading) {
                        hText("Total due " + (termination.terminationDateStep?.date?.displayDateDDMMMFormat ?? ""))
                    }
                    Spacer()
                    if #available(iOS 16.0, *) {
                        hText("189 kr")
                            .strikethrough()
                            .foregroundColor(hTextColor.secondary)
                    } else {
                        hText("189 kr")
                            .foregroundColor(hTextColor.secondary)
                    }
                    hText("159 kr")
                }
            }
            .withHeader {
                HStack {
                    hText("Final payment")
                    Spacer()
                    InfoViewHolder(title: "Final payment", description: "info")
                }
            }
            .sectionContainerStyle(.transparent)
            .hWithoutHorizontalPadding
        }
    }
}

public struct TerminationContractConfig: Codable & Equatable & Hashable {
    let contracts: [TerminationConfirmConfig]

    public init(
        contracts: [TerminationConfirmConfig]
    ) {
        self.contracts = contracts
    }
}

public struct TerminationConfirmConfig: Codable & Equatable & Hashable {
    public var contractId: String
    //    public var image: PillowType?
    public var contractDisplayName: String
    public var contractExposureName: String
    //    public var activeFrom: String?
    public var isDeletion: Bool?
    public var titleMarker: String?
    public var fromSelectInsurances: Bool

    public init(
        contractId: String,
        //        image: PillowType?,
        contractDisplayName: String,
        contractExposureName: String,
        //        activeFrom: String? = nil,
        titleMarker: String? = nil,
        fromSelectInsurances: Bool
    ) {
        self.contractId = contractId
        //        self.image = image
        self.contractDisplayName = contractDisplayName
        self.contractExposureName = contractExposureName
        //        self.activeFrom = activeFrom
        self.titleMarker = titleMarker
        self.fromSelectInsurances = fromSelectInsurances
    }
}

#Preview{
    ConfirmTerminationScreen(
        config: .init(contractId: "", contractDisplayName: "", contractExposureName: "", fromSelectInsurances: false),
        onSelected: {}
    )
}
