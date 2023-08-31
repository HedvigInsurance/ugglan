import Flow
import Form
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct SetTerminationDate: View {
    @State private var terminationDate = Date()
    let onSelected: (Date) -> Void

    public init(
        onSelected: @escaping (Date) -> Void
    ) {
        self.onSelected = onSelected
    }

    public var body: some View {

        LoadingViewWithContent(ContractStore.self, [.sendTerminationDate], [.sendTerminationDate]) {
            hForm {}
                .hDisableScroll
                .hFormTitle(.small, .title1, L10n.setTerminationDateText)
                .hFormAttachToBottom {
                    VStack(spacing: 16) {
                        hSection {
                            hRow {
                                HStack {
                                    hText(L10n.terminationDateText, style: .body)
                                    Spacer()
                                    hText(terminationDate.displayDateDotFormat ?? "", style: .body)
                                        .foregroundColor(hTextColorNew.secondary)
                                }
                                .padding(.bottom, 8)
                                .padding(.horizontal, 8)
                            }
                            .noSpacing()
                            .slideUpFadeAppearAnimation(delay: 0.4)

                            PresentableStoreLens(
                                ContractStore.self,
                                getter: { state in
                                    state.terminationDateStep
                                }
                            ) { termination in
                                DatePicker(
                                    L10n.terminationDateText,
                                    selection: self.$terminationDate.animation(.easeInOut(duration: 0.2)),
                                    in: convertDateFormat(
                                        inputDate: termination?.minDate ?? ""
                                    )...convertDateFormat(inputDate: termination?.maxDate ?? ""),
                                    displayedComponents: [.date]
                                )
                                .environment(
                                    \.locale,
                                    Locale.init(identifier: Localization.Locale.currentLocale.rawValue)
                                )
                                .datePickerStyle(.graphical)
                                .slideUpFadeAppearAnimation(delay: 0.4)
                            }
                        }
                        hSection {
                            hButton.LargeButtonPrimary {
                                onSelected(terminationDate)
                            } content: {
                                hText(L10n.terminationConfirmButton, style: .body)
                                    .foregroundColor(hLabelColor.primary.inverted)
                            }
                        }
                    }
                    .padding(.bottom, 16)
                    .sectionContainerStyle(.transparent)
                }
        }
    }

    func convertDateFormat(inputDate: String) -> Date {
        return inputDate.localDateToDate ?? Date()
    }
}
