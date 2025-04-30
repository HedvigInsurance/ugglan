import SwiftUI
import hCore

public struct CertificateInputScreen: View {
    let title: String
    let subtitle: String?
    let isLastScreenInFlow: Bool
    let elements: [CertificateInputElement]
    @ObservedObject private var vm: CertificateInputViewModel
    @Environment(\.hWithTooltip) var withTooltip

    public init(
        title: String,
        subtitle: String? = nil,
        isLastScreenInFlow: Bool,
        elements: [CertificateInputElement],
        vm: CertificateInputViewModel
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isLastScreenInFlow = isLastScreenInFlow
        self.elements = elements
        self.vm = vm
    }

    public var body: some View {
        hForm {}
            .sectionContainerStyle(.transparent)
            .hFormTitle(
                title: .init(.small, .heading2, title, alignment: .leading),
                subTitle: subtitle != nil ? .init(.small, .heading2, subtitle ?? "", alignment: .leading) : nil
            )
            .hFormAttachToBottom {
                hSection {
                    VStack(spacing: .padding16) {
                        VStack(spacing: .padding4) {
                            if elements.contains(.datePicker) {
                                hDatePickerField(
                                    config: .init(
                                        minDate: vm.minStartDate,
                                        maxDate: vm.maxStartDate,
                                        placeholder: L10n.TravelCertificate.startDateTitle,
                                        title: L10n.TravelCertificate.startDateTitle
                                    ),
                                    selectedDate: vm.dateInput
                                ) { date in
                                    vm.dateInput = date
                                }
                            }

                            if elements.contains(.email) {
                                hFloatingTextField(
                                    masking: .init(type: .email),
                                    value: $vm.emailInput,
                                    equals: $vm.editValue,
                                    focusValue: .email,
                                    placeholder: L10n.emailRowTitle,
                                    error: $vm.emailError
                                )
                            }
                        }

                        if elements.contains(.infoCard), let maxDuration = vm.maxDuration {
                            InfoCard(
                                text: L10n.TravelCertificate.startDateInfo(maxDuration),
                                type: .info
                            )
                        }

                        hButton.LargeButton(type: .primary) {
                            vm.onButtonClick()
                        } content: {
                            hText(isLastScreenInFlow ? L10n.Certificates.createCertificate : L10n.generalContinueButton)
                        }
                    }
                }
            }
            .loadingWithButtonLoading($vm.state)
            .setToolbarLeading {
                if withTooltip {
                    ToolbarButtonView(types: .constant([ToolbarOptionType.insuranceEvidence]), placement: .leading) {
                        _ in
                        vm.infoViewClicked?()
                    }
                }
            }
    }
}

public class CertificateInputViewModel: ObservableObject {
    @Published var editValue: StartDateViewEditType?

    @Binding var emailInput: String
    @Binding var emailError: String?

    @Binding var dateInput: Date
    let minStartDate: Date?
    let maxStartDate: Date?
    let maxDuration: Int?

    @Binding var state: ProcessingState
    let onButtonClick: () -> Void
    let infoViewClicked: (() -> Void)?

    public init(
        emailInput: Binding<String>? = nil,
        emailError: Binding<String?>? = nil,
        dateInput: Binding<Date>? = nil,
        minStartDate: Date? = nil,
        maxStartDate: Date? = nil,
        maxDuration: Int? = nil,
        state: Binding<ProcessingState>? = nil,
        onButtonClick: @escaping () -> Void,
        infoViewClicked: (() -> Void)? = nil
    ) {
        self._emailInput = emailInput ?? .constant("")
        self._emailError = emailError ?? .constant(nil)
        self._dateInput = dateInput ?? .constant(Date())
        self.maxStartDate = maxStartDate
        self.minStartDate = minStartDate
        self.maxDuration = maxDuration
        self._state = state ?? .constant(.success)
        self.onButtonClick = onButtonClick
        self.infoViewClicked = infoViewClicked
    }

    enum StartDateViewEditType: hTextFieldFocusStateCompliant {
        static var last: StartDateViewEditType {
            return StartDateViewEditType.email
        }

        var next: StartDateViewEditType? {
            switch self {
            case .date:
                return .email
            case .email:
                return nil
            }
        }

        case date
        case email
    }
}

public enum CertificateInputElement {
    case datePicker
    case email
    case name
    case infoCard
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })

    @State var emailInput: String = ""
    @State var dateInput: Date = Date()

    return CertificateInputScreen(
        title: "title",
        subtitle: "sub title",
        isLastScreenInFlow: true,
        elements: [.email, .infoCard],
        vm: .init(
            emailInput: $emailInput,
            dateInput: $dateInput,
            minStartDate: "2025-06-01".localDateToDate,
            maxStartDate: "2026-06-01".localDateToDate,
            maxDuration: 30,
            state: .constant(.success),
            onButtonClick: {},
            infoViewClicked: {}
        )
    )
}

@MainActor
private struct EnvironmentHWithTooltip: @preconcurrency EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    public var hWithTooltip: Bool {
        get { self[EnvironmentHWithTooltip.self] }
        set { self[EnvironmentHWithTooltip.self] = newValue }
    }
}

extension View {
    public var hWithTooltip: some View {
        self.environment(\.hWithTooltip, true)
    }
}
