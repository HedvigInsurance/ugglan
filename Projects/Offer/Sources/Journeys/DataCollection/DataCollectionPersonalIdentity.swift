import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct DataCollectionAuthOption: Identifiable, Equatable, Hashable {
    static func == (lhs: DataCollectionAuthOption, rhs: DataCollectionAuthOption) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var id: String {
        label
    }
    var masking: Masking
    var label: String
}

public struct DataCollectionPersonalIdentity: View {
    public init() {
        self._authOption = State(initialValue: Self.authOptions.first!)
    }

    @State var inputtedValue = ""
    @PresentableStore var store: DataCollectionStore

    @State var authOption: DataCollectionAuthOption

    static var authOptions: [DataCollectionAuthOption] {
        switch Localization.Locale.currentLocale.market {
        case .no:
            return [
                DataCollectionAuthOption(
                    masking: .init(type: .norwegianPersonalNumber),
                    label: L10n.InsurelyNoSsn.inputLabel
                ),
                DataCollectionAuthOption(
                    masking: .init(type: .digits),
                    label: L10n.phoneNumberRowTitle
                ),
            ]
        case .se:
            return [
                DataCollectionAuthOption(
                    masking: .init(type: .personalNumber),
                    label: L10n.InsurelySeSsn.inputLabel
                )
            ]
        default:
            return []
        }
    }

    public var body: some View {
        hForm {
            hSection {
                L10n.InsurelySeSsn.title
                    .hText(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if Self.authOptions.count > 1 {
                    Picker("View", selection: $authOption) {
                        ForEach(Self.authOptions) { option in
                            hText(option.label).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.top, 40)
                }

                hTextField(
                    masking: authOption.masking,
                    value: $inputtedValue
                )
                .padding(.top, 40)

                VStack {
                    hButton.LargeButtonFilled {
                        if authOption.masking.type == .digits {
                            store.send(.setCredential(credential: .phoneNumber(number: inputtedValue)))
                        } else {
                            store.send(.setCredential(credential: .personalNumber(number: inputtedValue)))
                        }

                        store.send(.startAuthentication)
                    } content: {
                        L10n.InsurelySsn.continueButtonText.hText()
                    }
                }
                .padding(.top, 40)
                .disabled(!authOption.masking.isValid(text: inputtedValue))
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

extension DataCollectionPersonalIdentity {
    static func journey<InnerJourney: JourneyPresentation>(
        modally: Bool = false,
        @JourneyBuilder _ next: @escaping () -> InnerJourney
    ) -> some JourneyPresentation {
        HostingJourney(
            DataCollectionStore.self,
            rootView: DataCollectionPersonalIdentity(),
            style: .detented(.large, modally: modally)
        ) { action in
            if case .startAuthentication = action {
                next()
            }
        }
        .configureTitle(L10n.Insurely.title)
    }
}

@available(iOS 15, *)
struct DataCollectionPersonalIdentityPreview: PreviewProvider {
    static var previews: some View {
        Group {
            JourneyPreviewer(
                DataCollectionPersonalIdentity.journey(modally: true) {
                    ContinueJourney()
                }
            )
            .preferredColorScheme(.light)
            JourneyPreviewer(
                DataCollectionPersonalIdentity.journey(modally: true) {
                    ContinueJourney()
                }
            )
            .preferredColorScheme(.dark)
        }
        .mockProvider()
    }
}
