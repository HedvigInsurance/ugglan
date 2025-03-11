import Combine
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct LanguageAndMarketPickerView: View {
    @StateObject private var vm = LanguageAndMarketPickerViewModel()
    @EnvironmentObject var router: Router

    public init() {}

    public var body: some View {
        hForm {
            VStack(spacing: 8) {
                hSection {
                    Picker("View", selection: $vm.selected) {
                        ForEach(LanguageAndMarketPicker.allCases) { view in
                            hText(view.title, style: .label).tag(view)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .sectionContainerStyle(.transparent)
                ForEach(LanguageAndMarketPicker.allCases) { panel in
                    if vm.selected == panel {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            viewFor(view: panel)
                                .transition(.asymmetric(insertion: vm.insertion, removal: vm.removal))
                        }
                    }
                }
                .padding(.top, .padding8)

            }
        }
        .hFormContentPosition(.compact)
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

    @ViewBuilder
    func viewFor(view: LanguageAndMarketPicker) -> some View {
        switch view {
        case .market:
            marketView
        case .language:
            languageView
        }
    }

    private var marketView: some View {
        hSection {
            VStack(spacing: 4) {
                ForEach(Market.activatedMarkets, id: \.title) { market in
                    hRadioField(
                        id: market.rawValue,
                        leftView: {
                            HStack(spacing: 16) {
                                Image(uiImage: market.icon)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                hText(market.title, style: .heading2)
                                    .foregroundColor(hTextColor.Opaque.primary)
                            }
                            .asAnyView
                        },
                        selected: $vm.selectedMarketCode
                    )
                }
            }
        }
    }

    private var languageView: some View {
        hSection {
            VStack(spacing: 4) {
                ForEach(vm.selectedMarket.languages, id: \.lprojCode) { locale in
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

struct LanguageAndMarketPickerView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageAndMarketPickerView()
    }
}

@MainActor
class LanguageAndMarketPickerViewModel: ObservableObject {
    @Published var selectedLocale = Localization.Locale.currentLocale.value
    @Published var selectedLocaleCode: String? = Localization.Locale.currentLocale.value.rawValue

    @Published var selectedMarket: Market
    @Published var selectedMarketCode: String?

    @Published var trigger = LanguageAndMarketPicker.language
    @Published var previous = LanguageAndMarketPicker.language

    @Published var insertion: AnyTransition = .move(edge: .leading)
    @Published var removal: AnyTransition = .move(edge: .trailing)
    var cancellables = Set<AnyCancellable>()

    @Published var selected: LanguageAndMarketPicker = .market {
        willSet {
            if previous != selected {
                insertion = previous.move(selected)
                removal = selected.move(previous)

                withAnimation {
                    trigger = selected
                    previous = selected
                }
            }
        }
    }

    init() {
        let store: MarketStore = globalPresentableStoreContainer.get()
        selectedMarket = store.state.market
        selectedMarketCode = store.state.market.rawValue
        $selectedLocaleCode.sink { [weak self] selectedLocaleCode in
            if let selectedLocaleCode, let locale = Localization.Locale(rawValue: selectedLocaleCode) {
                self?.selectedLocale = locale
            }
        }
        .store(in: &cancellables)
        $selectedMarketCode.sink { [weak self] selectedMarketCode in
            if let selectedMarketCode, let market = Market(rawValue: selectedMarketCode) {
                self?.selectedMarket = market
                if let currentSelectedLocale = market.languages.first(where: {
                    $0 == Localization.Locale.currentLocale.value
                }
                ) {
                    self?.selectedLocaleCode = currentSelectedLocale.rawValue
                } else {
                    self?.selectedLocaleCode = market.preferredLanguage.rawValue
                }
            }
        }
        .store(in: &cancellables)
    }

    func save() async {
        let store: MarketStore = globalPresentableStoreContainer.get()
        await store.sendAsync(.selectMarket(market: selectedMarket))
        await store.sendAsync(.selectLanguage(language: self.selectedLocale.rawValue))
    }
}

enum LanguageAndMarketPicker: Int, CaseIterable, Identifiable {
    case market
    case language

    var id: Int { self.rawValue }

    var title: String {
        switch self {
        case .market:
            return L10n.MarketPickerModal.title
        case .language:
            return L10n.LanguagePickerModal.title
        }
    }

    func move(_ otherPanel: LanguageAndMarketPicker) -> AnyTransition {
        return otherPanel.rawValue < self.rawValue ? .move(edge: .trailing) : .move(edge: .leading)
    }
}
