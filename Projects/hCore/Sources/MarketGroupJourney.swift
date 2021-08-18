import Foundation
import Presentation

public struct MarketGroupJourney<InnerJourney: JourneyPresentation>: JourneyPresentation {
    public var onDismiss: (Error?) -> Void

    public var style: PresentationStyle

    public var options: PresentationOptions

    public var transform: (InnerJourney.P.Result) -> InnerJourney.P.Result

    public var configure: (JourneyPresenter<P>) -> Void

    public let presentable: InnerJourney.P

    public init(
        @JourneyBuilder _ content: @escaping (_ market: Localization.Locale.Market) -> InnerJourney
    ) {
        let presentation = content(Localization.Locale.currentLocale.market)

        self.presentable = presentation.presentable
        self.style = presentation.style
        self.options = presentation.options
        self.transform = presentation.transform
        self.configure = presentation.configure
        self.onDismiss = presentation.onDismiss
    }
}
