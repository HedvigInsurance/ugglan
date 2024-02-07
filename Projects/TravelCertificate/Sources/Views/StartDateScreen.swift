import Flow
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct StartDateScreen: View {

    @StateObject var vm = StartDateViewModel()
    @PresentableStore var store: TravelInsuranceStore
    var body: some View {
        form
    }

    var form: some View {
        PresentableStoreLens(
            TravelInsuranceStore.self,
            getter: { state in
                state.travelInsuranceModel
            }
        ) { travelInsuranceModel in
            hForm {}
                .sectionContainerStyle(.transparent)
                .hFormTitle(.standard, .title1, L10n.TravelCertificate.whenIsYourTrip)
                .hDisableScroll
                .hFormAttachToBottom {
                    VStack(spacing: 16) {
                        hSection {
                            VStack(spacing: 4) {
                                hDatePickerField(
                                    config: .init(
                                        minDate: travelInsuranceModel?.minStartDate,
                                        maxDate: travelInsuranceModel?.maxStartDate,
                                        placeholder: L10n.TravelCertificate.startDateTitle,
                                        title: L10n.TravelCertificate.startDateTitle
                                    ),
                                    selectedDate: travelInsuranceModel?.startDate
                                ) { date in
                                    store.send(.setDate(value: date, type: .startDate))
                                }

                                hFloatingTextField(
                                    masking: .init(type: .email),
                                    value: $vm.emailValue,
                                    equals: $vm.editValue,
                                    focusValue: .email,
                                    placeholder: L10n.emailRowTitle,
                                    error: $vm.emailError
                                )
                            }
                        }
                        hSection {
                            PresentableStoreLens(
                                TravelInsuranceStore.self,
                                getter: { state in
                                    state.travelInsuranceConfig
                                }
                            ) { config in
                                InfoCard(
                                    text: L10n.TravelCertificate.startDateInfo(config?.maxDuration ?? 0),
                                    type: .info
                                )
                            }
                        }
                        hSection {
                            hButton.LargeButton(type: .primary) {
                                Task {
                                    await vm.submit()
                                }
                            } content: {
                                hText(L10n.generalContinueButton)
                            }
                            .padding(.bottom, 16)
                        }
                    }
                }
        }
    }
}

class StartDateViewModel: ObservableObject {
    @Published var emailValue: String = ""
    @Published var emailError: String?
    @PresentableStore var store: TravelInsuranceStore
    @Published var editValue: StartDateViewEditType?

    init() {
        let store: TravelInsuranceStore = globalPresentableStoreContainer.get()
        emailValue = store.state.travelInsuranceModel?.email ?? ""
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

    func submit() async {
        if Masking(type: .email).isValid(text: emailValue) {
            DispatchQueue.main.async { [weak self] in guard let self = self else { return }
                self.emailError = nil
                self.store.send(.setEmail(value: self.emailValue))
                self.store.send(.navigation(.openWhoIsTravelingScreen))
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                withAnimation {
                    self?.emailError = L10n.myInfoEmailMalformedError
                }
            }
        }
    }
}

struct StartDateView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StartDateScreen()
        }
    }
}
