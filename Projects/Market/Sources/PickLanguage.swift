import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import SwiftUI

//public struct PickLanguage {
//    let currentMarket: Market
//
//    public init(
//        currentMarket: Market
//    ) {
//        self.currentMarket = currentMarket
//    }
//}
//
//extension PickLanguage: Presentable {
//    public func materialize() -> (UIViewController, Future<Localization.Locale>) {
//        let viewController = UIViewController()
//        viewController.title = L10n.LanguagePickerModal.title
//        let bag = DisposeBag()
//
//        let form = FormView()
//        bag += viewController.install(form)
//
//        let titleSection = form.appendSection()
//        bag += titleSection.append(
//            MultilineLabel(value: L10n.LanguagePickerModal.text, style: .brand(.body(color: .secondary)))
//                .insetted(UIEdgeInsets(inset: 15))
//        )
//
//        let section = form.appendSection()
//        return (
//            viewController,
//            Future { completion in
//
//                currentMarket.languages.forEach { language in
//                    let row = RowView(title: language.displayName)
//
//                    if language == Localization.Locale.currentLocale {
//                        row.append(Asset.checkmark.image)
//                    }
//
//                    bag += section.append(row).onValue { completion(.success(language)) }
//                }
//
//                return bag
//            }
//        )
//    }
//}



public struct PickLanguage: View {
    let currentMarket: Market
    @PresentableStore var store: MarketStore
    
    public init(
        currentMarket: Market
    ) {
        self.currentMarket = currentMarket
    }
    
    public var body: some View {
        hForm {
            hSection(currentMarket.languages, id: \.lprojCode) { locale in
                hRow {
                    locale.displayName.hText()
                }
                .withSelectedAccessory(locale == Localization.Locale.currentLocale)
                .onTap {
                    
                }
            }
            .dividerInsets(.leading, 50)
        }
    }
}

extension PickLanguage {
    public var journey: some JourneyPresentation {
        HostingJourney(
            MarketStore.self,
            rootView: self,
            style: .detented(.scrollViewContentSize),
            options: [.defaults, .prefersLargeTitles(true)]
        ) { action in
            if case .selectMarket = action {
                PopJourney()
            }
        }
        .configureTitle(L10n.MarketLanguageScreen.languageLabel)
        .withDismissButton
    }
}
