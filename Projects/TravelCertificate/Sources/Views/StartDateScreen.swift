import SwiftUI
import hCore
import hCoreUI

struct StartDateScreen: View {
    @ObservedObject var vm: StartDateViewModel
    @EnvironmentObject var router: Router

    var body: some View {
        form
    }

    var form: some View {
        hForm {}
            .sectionContainerStyle(.transparent)
            .hFormTitle(title: .init(.small, .heading2, L10n.TravelCertificate.whenIsYourTrip, alignment: .leading))
            .hFormAttachToBottom {
                hSection {
                    VStack(spacing: .padding16) {
                        VStack(spacing: .padding4) {
                            hDatePickerField(
                                config: .init(
                                    minDate: vm.specification.minStartDate,
                                    maxDate: vm.specification.maxStartDate,
                                    placeholder: L10n.TravelCertificate.startDateTitle,
                                    title: L10n.TravelCertificate.startDateTitle
                                ),
                                selectedDate: vm.date
                            ) { date in
                                vm.date = date
                            }

                            hFloatingTextField(
                                masking: .init(type: .email),
                                value: $vm.email,
                                equals: $vm.editValue,
                                focusValue: .email,
                                placeholder: L10n.emailRowTitle,
                                error: $vm.emailError
                            )
                        }
                        InfoCard(
                            text: L10n.TravelCertificate.startDateInfo(vm.specification.maxDuration),
                            type: .info
                        )
                        .accessibilitySortPriority(2)
                        hContinueButton {
                            Task {
                                await submit()
                            }
                        }
                    }
                }
            }
    }

    func submit() async {
        if Masking(type: .email).isValid(text: vm.email) {
            DispatchQueue.main.async {
                vm.emailError = nil
                router.push(TravelCertificateRouterActions.whoIsTravelling(specifiction: vm.specification))
            }
        } else {
            DispatchQueue.main.async {
                withAnimation {
                    vm.emailError = L10n.myInfoEmailMalformedError
                }
            }
        }
    }
}

class StartDateViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var date: Date
    @Published var emailError: String?
    @Published var editValue: StartDateViewEditType?
    let specification: TravelInsuranceContractSpecification
    init(specification: TravelInsuranceContractSpecification) {
        self.specification = specification
        email = specification.email ?? ""
        date = specification.minStartDate
    }

    enum StartDateViewEditType: hTextFieldFocusStateCompliant {
        static var last: StartDateViewEditType {
            StartDateViewEditType.email
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

struct StartDateView_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        return NavigationView {
            StartDateScreen(
                vm: .init(
                    specification: .init(
                        contractId: "",
                        displayName: "display name",
                        exposureDisplayName: "exposure display name",
                        minStartDate: Date(),
                        maxStartDate: Date().addingTimeInterval(60 * 60 * 24 * 10),
                        numberOfCoInsured: 0,
                        maxDuration: 45,
                        email: nil,
                        fullName: "full name"
                    )
                )
            )
        }
    }
}
