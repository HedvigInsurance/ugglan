import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimOccurrencePlusLocationScreen: View {
    @PresentableStore var store: SubmitClaimStore
    @State var type: ClaimsFlowOccurrenceType?
    @State private var orientation = UIDeviceOrientation.unknown

    init() {
    }

    var body: some View {
        LoadingViewWithContent(.postDateOfOccurrenceAndLocation) {
            if orientation.isLandscape || UIWindow.isLandscape {
                hForm {
                    displayTitleAndProgressBar()
                    displayFieldsAndNotice()
                }
                .hUseNewStyle
                .hFormAttachToBottom {
                    displayButton()
                }
            } else {

                hForm {
                    displayTitleAndProgressBar()
                }
                .hDisableScroll
                .hUseNewStyle
                .hFormAttachToBottom {
                    VStack(spacing: 0) {
                        displayFieldsAndNotice()
                        displayButton()
                    }
                }
            }
        }
        .onChange(of: type) { newValue in
            if newValue == nil {
                UIApplication.dismissKeyboard()
                store.send(.dateOfOccurrenceAndLocationRequest)
            } else if newValue == .occurenceDate {
                UIApplication.dismissKeyboard()
            }
        }
        .onRotate { newOrientation in
            orientation = newOrientation
        }
    }

    @ViewBuilder
    private func displayTitleAndProgressBar() -> some View {
        ProgressBar()
        hTextNew(L10n.Claims.Incident.Screen.Date.Of.incident, style: .title2)
            .foregroundColor(hLabelColorNew.primary)
            .fixedSize(horizontal: false, vertical: true)
            .padding([.top, .leading, .trailing], 16)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private func displayFieldsAndNotice() -> some View {
        hSection {
            PresentableStoreLens(
                SubmitClaimStore.self,
                getter: { state in
                    state.locationStep
                }
            ) { locationStep in

                hFloatingField(
                    value: locationStep?.getSelectedOption()?.displayName ?? "",
                    placeholder: L10n.Claims.Location.Screen.title,
                    onTap: {
                        store.send(.navigationAction(action: .openLocationPicker(type: .setLocation)))
                    }
                )
                .frame(height: 72)
            }
        }
        .withoutBottomPadding
        .sectionContainerStyle(.opaque(useNewDesign: true))

        hSection {
            PresentableStoreLens(
                SubmitClaimStore.self,
                getter: { state in
                    state.dateOfOccurenceStep
                }
            ) { dateOfOccurenceStep in

                hFloatingField(
                    value: dateOfOccurenceStep?.dateOfOccurence ?? "",
                    placeholder: L10n.Claims.Item.Screen.Date.Of.Incident.button,
                    onTap: {
                        store.send(
                            .navigationAction(action: .openDatePicker(type: .setDateOfOccurrence))
                        )
                    }
                )
            }
        }
        .withoutBottomPadding
        .sectionContainerStyle(.opaque(useNewDesign: true))

        NoticeComponent(text: L10n.claimsDateNotSureNoticeLabel)
            .padding([.bottom, .top], 8)
    }

    @ViewBuilder
    private func displayButton() -> some View {
        hButton.LargeButtonFilled {
            store.send(.dateOfOccurrenceAndLocationRequest)
        } content: {
            hText(L10n.generalContinueButton, style: .body)
                .foregroundColor(hLabelColor.primary.inverted)
        }
        .frame(maxWidth: .infinity, alignment: .bottom)
        .padding([.leading, .trailing], 16)
        .padding(.bottom, 20)
    }
}

enum ClaimsFlowOccurrenceType: hTextFieldFocusStateCompliant {
    static var last: ClaimsFlowOccurrenceType {
        return ClaimsFlowOccurrenceType.occurenceDate
    }

    var next: ClaimsFlowOccurrenceType? {
        switch self {
        case .occurencePlace:
            return .occurenceDate
        case .occurenceDate:
            return nil
        }
    }

    case occurencePlace
    case occurenceDate
}

struct SubmitClaimOccurrencePlusLocationScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimOccurrencePlusLocationScreen()
    }
}

extension UIWindow {
    static var isLandscape: Bool {
        if #available(iOS 13.0, *) {
            return
                UIApplication.shared.windows
                .first?
                .windowScene?
                .interfaceOrientation
                .isLandscape ?? false
        } else {
            return UIApplication.shared.statusBarOrientation.isLandscape
        }
    }
}

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}
