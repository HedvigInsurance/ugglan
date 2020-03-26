//
//  MarketPicker.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-03.
//

import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit

struct MarketPicker {
    @Inject var client: ApolloClient
    var didFinish: () -> Void
    
    init(didFinish: @escaping () -> Void = {}) {
        self.didFinish = didFinish
    }
}

extension MarketPicker {
    enum Market: CaseIterable {
        case norway, sweden

        var title: String {
            switch self {
            case .norway:
                return "Norge"
            case .sweden:
                return "Sverige"
            }
        }

        var locales: [Localization.Locale] {
            switch self {
            case .norway:
                return [.en_NO, .nb_NO]
            case .sweden:
                return [.en_SE, .sv_SE]
            }
        }

        var icon: UIImage {
            switch self {
            case .norway:
                return Asset.flagNO.image
            case .sweden:
                return Asset.flagSE.image
            }
        }
    }

    struct MarketSection: Viewable {
        let suggestedMarket: Market?

        func materialize(events _: ViewableEvents) -> (SectionView, Signal<Market>) {
            let bag = DisposeBag()

            let titleContainer = UIStackView()
            titleContainer.axis = .vertical

            let titleLabel = UILabel(value: String(key: .MARKET_PICKER_TITLE), style: .headlineLargeLargeLeft)
            titleContainer.addArrangedSubview(titleLabel)

            let section = SectionView(headerView: titleContainer, footerView: nil)
            section.dynamicStyle = .sectionPlainRounded

            let pickedMarketCallbacker = Callbacker<Market>()

            bag += Market.allCases.sorted(by: { (a, _) -> Bool in
                a == suggestedMarket
            }).map { market -> (RowView, Market, UIImageView) in
                let row = RowView(title: market.title, style: .rowTitle, appendSpacer: true)
                row.prepend(market.icon)
                let imageView = UIImageView()

                if market == suggestedMarket {
                    imageView.image = Asset.circularCheckmark.image
                }

                row.append(imageView)
                return (row, market, imageView)
            }.map { row, market, imageView in
                let bag = DisposeBag()
                bag += section.append(row).onValue { _ in
                    imageView.image = Asset.circularCheckmark.image
                    pickedMarketCallbacker.callAll(with: market)
                }

                bag += pickedMarketCallbacker.providedSignal.onValue { newMarket in
                    if market != newMarket {
                        imageView.image = nil
                    }
                }

                return bag
            }

            return (section, pickedMarketCallbacker.providedSignal.hold(bag))
        }
    }

    struct LanguageSection: Viewable {
        let pickedMarketSignal: Signal<Market>
        let presentingViewController: UIViewController
        @Inject var client: ApolloClient
        var didFinish: () -> Void

        func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
            let bag = DisposeBag()

            let titleContainer = UIStackView()
            titleContainer.axis = .vertical

            let titleLabel = UILabel(value: String(key: .MARKET_PICKER_TITLE), style: .headlineSmallSmallLeft)
            titleContainer.addArrangedSubview(titleLabel)

            let section = SectionView(headerView: titleContainer, footerView: nil)
            section.dynamicStyle = .sectionPlainRounded

            func pickLanguage(locale: Localization.Locale) {
                ApplicationState.setPreferredLocale(locale)
                Localization.Locale.currentLocale = locale
                TranslationsRepo.clear().onValue { _ in
                    UIApplication.shared.reloadAllLabels()
                }
                ApolloClient.initClient().always {}
                bag += client.perform(mutation: UpdateLanguageMutation(language: locale.code)).onValue { _ in
                    self.presentingViewController.present(Marketing())
                    self.didFinish()
                }
            }

            section.animationSafeIsHidden = true

            bag += pickedMarketSignal.onValueDisposePrevious { market in
                section.animationSafeIsHidden = false

                switch market {
                case .norway:
                    let innerBag = DisposeBag()
                    let norwegianRow = RowView(title: "Norsk (Bokmål)", style: .rowTitle, appendSpacer: false)
                    innerBag += section.append(norwegianRow).onValue { _ in
                        pickLanguage(locale: .nb_NO)
                    }
                    norwegianRow.append(Asset.chevronRight.image)

                    let englishRow = RowView(title: "English", style: .rowTitle, appendSpacer: false)
                    innerBag += section.append(englishRow).onValue { _ in
                        pickLanguage(locale: .en_NO)
                    }
                    englishRow.append(Asset.chevronRight.image)

                    innerBag += Disposer {
                        section.remove(englishRow)
                        section.remove(norwegianRow)
                    }

                    return innerBag
                case .sweden:
                    let innerBag = DisposeBag()

                    let swedishRow = RowView(title: "Svenska", style: .rowTitle, appendSpacer: false)
                    innerBag += section.append(swedishRow).onValue { _ in
                        pickLanguage(locale: .sv_SE)
                    }
                    swedishRow.append(Asset.chevronRight.image)

                    let englishRow = RowView(title: "English", style: .rowTitle, appendSpacer: false)
                    innerBag += section.append(englishRow).onValue { _ in
                        pickLanguage(locale: .en_SE)
                    }
                    englishRow.append(Asset.chevronRight.image)

                    innerBag += Disposer {
                        section.remove(englishRow)
                        section.remove(swedishRow)
                    }

                    return innerBag
                }
            }

            return (section, bag)
        }
    }
}

extension MarketPicker: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        ApplicationState.preserveState(.marketPicker)

        let form = FormView()
        form.dynamicStyle = .defaultPlain

        let titleHedvigLogo = UIImageView()
        titleHedvigLogo.image = Asset.wordmark.image
        titleHedvigLogo.contentMode = .scaleAspectFit

        form.prepend(titleHedvigLogo)

        titleHedvigLogo.snp.makeConstraints { make in
            make.width.equalTo(80)
            make.height.equalTo(30)
        }

        bag += viewController.install(form)

        let pickedMarketSignal: ReadWriteSignal<Market?> = ReadWriteSignal(nil)

        bag += client.fetch(query: GeoQuery()).valueSignal.compactMap { $0.data?.geo.countryIsoCode }.onValue { countryISOCode in
            switch countryISOCode {
            case "SE":
                pickedMarketSignal.value = .sweden
            case "NO":
                pickedMarketSignal.value = .norway
            default:
                pickedMarketSignal.value = nil
            }

            bag += form.append(Spacing(height: 40))
            bag += form.append(MarketSection(suggestedMarket: pickedMarketSignal.value)).onValue { market in
                pickedMarketSignal.value = market
            }
            bag += form.append(Spacing(height: 20))
            bag += form.append(LanguageSection(pickedMarketSignal: pickedMarketSignal.atOnce().compactMap { $0 }, presentingViewController: viewController, didFinish: self.didFinish))

            form.transform = CGAffineTransform(translationX: 0, y: 100)
            form.alpha = 0

            bag += UIApplication.shared.appDelegate.hasFinishedLoading.atOnce()
                .delay(by: 1.25)
                .take(first: 1)
                .animated(style: .lightBounce(duration: 0.75), animations: { _ in
                    form.transform = CGAffineTransform.identity
                    form.alpha = 1
                    form.layoutIfNeeded()
            })
        }

        return (viewController, bag)
    }
}
