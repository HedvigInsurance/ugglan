import Combine
import SwiftUI
import hCore
import hCoreUI

struct CoInusuredInput: View, KeyboardReadable {
    @State var fullName: String = ""
    let name: String?
    let number: String?
    @State var personalNumber: String = ""
    @State var type: CoInsuredInputType?
    @State var keyboardEnabled: Bool = false
    @PresentableStore var store: ContractStore
    let isDeletion: Bool

    public init(
        isDeletion: Bool,
        name: String?,
        personalNumber: String?
    ) {
        self.isDeletion = isDeletion
        self.name = name
        self.number = personalNumber
    }

    var body: some View {
        hForm {
            VStack(spacing: 4) {

                if isDeletion {
                    hSection {
                        hFloatingField(
                            value: name ?? "",
                            placeholder: L10n.fullNameText,
                            onTap: {}
                        )
                    }
                    .hFieldTrailingView {
                        Image(uiImage: hCoreUIAssets.lockSmall.image)
                            .foregroundColor(hTextColor.secondary)
                    }
                    .disabled(true)
                    .sectionContainerStyle(.transparent)

                    hSection {
                        hFloatingField(
                            value: number ?? "",
                            placeholder: L10n.TravelCertificate.personalNumber,
                            onTap: {}
                        )
                    }
                    .hFieldTrailingView {
                        Image(uiImage: hCoreUIAssets.lockSmall.image)
                            .foregroundColor(hTextColor.secondary)
                    }
                    .disabled(true)
                    .sectionContainerStyle(.transparent)

                } else {
                    hSection {
                        hFloatingTextField(
                            masking: Masking(type: .none),
                            value: $fullName,
                            equals: $type,
                            focusValue: .fullName,
                            placeholder: L10n.fullNameText
                        )
                        .onReceive(keyboardPublisher) { newIsKeyboardEnabled in
                            keyboardEnabled = newIsKeyboardEnabled
                        }
                    }
                    .sectionContainerStyle(.transparent)

                    hSection {
                        hFloatingTextField(
                            masking: Masking(type: .personalNumber),
                            value: $personalNumber,
                            equals: $type,
                            focusValue: .personalNumber,
                            placeholder: L10n.TravelCertificate.ssnLabel
                        )
                    }
                    .onReceive(keyboardPublisher) { newIsKeyboardEnabled in
                        keyboardEnabled = newIsKeyboardEnabled
                    }
                    .sectionContainerStyle(.transparent)
                }
                hSection {
                    hButton.LargeButton(type: .primary) {
                        if isDeletion {
                            store.send(.removeLocalCoInsured(name: name ?? "", personalNumber: number ?? ""))
                        } else {
                            store.send(.addLocalCoInsured(name: fullName, personalNumber: personalNumber))
                        }
                    } content: {
                        hText(
                            isDeletion
                                ? L10n.removeConfirmationButton
                                : (saveIsDisabled ? L10n.generalSaveButton : L10n.generalAddButton)
                        )
                        .transition(.opacity.animation(.easeOut))
                    }
                }
                .padding(.top, 12)
                .disabled(saveIsDisabled && !isDeletion)

                hButton.LargeButton(type: .ghost) {
                    store.send(.dismissEdit)
                } content: {
                    hText(L10n.generalCancelButton)
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
            }
        }
    }

    var saveIsDisabled: Bool {
        let personalNumberValid = !Masking(type: .personalNumber).isValid(text: personalNumber)
        let fullNameValied = !Masking(type: .fullName).isValid(text: fullName)
        if personalNumberValid || fullNameValied {
            return true
        }
        return false
    }
}

struct CoInusuredInput_Previews: PreviewProvider {
    static var previews: some View {
        CoInusuredInput(isDeletion: false, name: "", personalNumber: "")
    }
}

enum CoInsuredInputType: hTextFieldFocusStateCompliant {
    static var last: CoInsuredInputType {
        return CoInsuredInputType.fullName
    }

    var next: CoInsuredInputType? {
        switch self {
        default:
            return nil
        }
    }

    case fullName
    case personalNumber
}

protocol KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> { get }
}

extension KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },

            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
}
