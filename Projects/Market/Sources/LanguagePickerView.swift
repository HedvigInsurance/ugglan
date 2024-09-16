import Combine
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct LanguagePickerView: View {
    @StateObject private var vm = LanguagePickerViewModel()
    @EnvironmentObject var router: Router

    public init() {}

    public var body: some View {
        hForm {
            VStack(spacing: 8) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    languageView
                        .transition(.asymmetric(insertion: vm.insertion, removal: vm.removal))
                }
                .padding(.top, .padding8)

            }
        }
        .sectionContainerStyle(.transparent)
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: 8) {
                    hText(L10n.profileAboutAppVersion + " " + Bundle.main.appVersion, style: .finePrint)
                        .foregroundColor(hTextColor.Opaque.tertiary)

                    hButton.LargeButton(type: .primary) {
                        Task {
                            await vm.save()
                            router.dismiss()
                        }
                    } content: {
                        hText(L10n.generalSaveButton)
                    }
                    hButton.LargeButton(type: .ghost) {
                        router.dismiss()
                    } content: {
                        hText(L10n.generalCancelButton)
                    }

                }
            }
            .padding(.top, .padding8)
            .hWithoutDivider
        }
    }

    private var languageView: some View {
        hSection {
            VStack(spacing: 4) {
                ForEach(Localization.Locale.allCases, id: \.lprojCode) { locale in
                    hRadioField(
                        id: locale.rawValue,
                        leftView: {
                            HStack(spacing: 16) {
                                Image(uiImage: locale.icon)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                hText(locale.displayName, style: .heading2)
                                    .foregroundColor(hTextColor.Opaque.primary)
                            }
                            .asAnyView
                        },
                        selected: $vm.selectedLocaleCode
                    )
                }
            }
        }
    }
}

struct LanguagePickerView_Previews: PreviewProvider {
    static var previews: some View {
        LanguagePickerView()
    }
}

class LanguagePickerViewModel: ObservableObject {
    @Published var selectedLocale = Localization.Locale.currentLocale
    @Published var selectedLocaleCode: String? = Localization.Locale.currentLocale.value.rawValue

    @Published var insertion: AnyTransition = .move(edge: .leading)
    @Published var removal: AnyTransition = .move(edge: .trailing)
    var cancellables = Set<AnyCancellable>()

    init() {
        $selectedLocaleCode.sink { [weak self] selectedLocaleCode in
            if let selectedLocaleCode, let locale = Localization.Locale(rawValue: selectedLocaleCode) {
                self?.selectedLocale.value = locale
            }
        }
        .store(in: &cancellables)
    }

    func save() async {
        let store: MarketStore = globalPresentableStoreContainer.get()
        await store.sendAsync(.selectLanguage(language: self.selectedLocale.value.rawValue))
    }
}
