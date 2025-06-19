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
                        CertificateFields(elements: elements, vm: vm)

                        if elements.contains(.infoCard), let maxDuration = vm.dateInput?.maxDuration {
                            CertificateInfoCard(maxDuration: maxDuration)
                        }

                        CertificateInputButton(
                            isLastScreenInFlow: isLastScreenInFlow,
                            action: vm.onButtonClick
                        )
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

private struct CertificateFields: View {
    let elements: [CertificateInputElement]
    @ObservedObject var vm: CertificateInputViewModel

    var body: some View {
        VStack(spacing: .padding4) {
            if elements.contains(.datePicker), let dateInput = vm.dateInput {
                hDatePickerField(
                    config: .init(
                        minDate: dateInput.minStartDate,
                        maxDate: dateInput.maxStartDate,
                        placeholder: L10n.TravelCertificate.startDateTitle,
                        title: L10n.TravelCertificate.startDateTitle
                    ),
                    selectedDate: dateInput.input
                ) { date in
                    vm.dateInput?.input = date
                }
            }

            if elements.contains(.email) {
                hFloatingTextField(
                    masking: .init(type: .email),
                    value: $vm.emailInput.input,
                    equals: $vm.emailInput.editValue,
                    focusValue: .email,
                    placeholder: L10n.emailRowTitle,
                    error: $vm.emailInput.error
                )
            }
        }
    }
}

private struct CertificateInfoCard: View {
    let maxDuration: Int

    var body: some View {
        InfoCard(
            text: L10n.TravelCertificate.startDateInfo(maxDuration),
            type: .info
        )
        .accessibilitySortPriority(2)
    }
}

private struct CertificateInputButton: View {
    let isLastScreenInFlow: Bool
    let action: () -> Void

    var body: some View {
        hButton(
            .large,
            .primary,
            content: .init(
                title: isLastScreenInFlow ? L10n.Certificates.createCertificate : L10n.generalContinueButton
            ),
            {
                action()
            }
        )
    }
}

public class CertificateInputViewModel: ObservableObject {
    @Published var emailInput: CertificateEmailInput
    @Published var dateInput: CertificateDateInput?
    @Binding var state: ProcessingState
    let onButtonClick: () -> Void
    let infoViewClicked: (() -> Void)?

    public init(
        emailInput: CertificateEmailInput? = .init(input: nil, error: nil),
        dateInput: CertificateDateInput? = nil,
        state: Binding<ProcessingState>? = nil,
        onButtonClick: @escaping () -> Void,
        infoViewClicked: (() -> Void)? = nil
    ) {
        self.emailInput = emailInput ?? .init(input: nil, error: nil)
        self.dateInput = dateInput
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

    public struct CertificateEmailInput {
        @State var editValue: StartDateViewEditType?
        @Binding var input: String
        @Binding var error: String?

        public init(
            input: Binding<String>? = .constant(""),
            error: Binding<String?>? = .constant(nil)
        ) {
            self._input = input ?? .constant("")
            self._error = error ?? .constant(nil)
        }
    }

    public struct CertificateDateInput {
        @Binding var input: Date
        let minStartDate: Date?
        let maxStartDate: Date?
        let maxDuration: Int?

        public init(
            input: Binding<Date>,
            minStartDate: Date? = nil,
            maxStartDate: Date? = nil,
            maxDuration: Int? = nil
        ) {
            self._input = input
            self.minStartDate = minStartDate
            self.maxStartDate = maxStartDate
            self.maxDuration = maxDuration
        }
    }
}

public enum CertificateInputElement {
    case datePicker
    case email
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
            emailInput: .init(input: $emailInput, error: .constant(nil)),
            dateInput: .init(
                input: $dateInput,
                minStartDate: "2025-06-01".localDateToDate,
                maxStartDate: "2026-06-01".localDateToDate,
                maxDuration: 30
            ),
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
