import Apollo
import Combine
import Flow
import Kingfisher
import Presentation
import SwiftUI
import hCore
import hGraphQL

public class NotLoggedViewModel: ObservableObject {
    @PresentableStore var store: MarketStore

    @Published var blurHash: String = ""
    @Published var imageURL: String = ""
    @Published var bootStrapped: Bool = false
    @Published var locale: Localization.Locale = .currentLocale
    @Published var title: String = L10n.MarketLanguageScreen.title
    @Published var buttonText: String = L10n.MarketLanguageScreen.continueButtonText
    @Published var viewState: ViewState = .loading
    var onLoad: () -> Void = {}
    var cancellables = Set<AnyCancellable>()
    let bag = DisposeBag()

    init() {
        ApplicationState.preserveState(.notLoggedIn)
        Localization.Locale.$currentLocale
            .distinct()
            .plain()
            .delay(by: 0.1)
            .publisher
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.title = L10n.MarketLanguageScreen.title
                self?.buttonText = L10n.MarketLanguageScreen.continueButtonText
            }
            .store(in: &cancellables)

        $bootStrapped
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                if value {
                    self?.viewState = .marketAndLanguage
                    self?.onLoad()
                }
            }
            .store(in: &cancellables)

        self.bootStrapped = true
    }

    func onCountryPressed() {
        store.send(.presentLanguageAndMarketPicker)
    }

    func onLoginPressed() {
        store.send(.loginButtonTapped)
    }

    func onOnBoardPressed() {
        store.send(.onboard)
    }

    enum ViewState {
        case loading
        case marketAndLanguage
    }
}
