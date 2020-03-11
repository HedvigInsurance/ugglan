//
//  LanguagePicker.swift
//  test
//
//  Created by Sam Pettersson on 2019-10-17.
//

import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import Space
import Common
import ComponentKit

extension UIView {
    var isPossiblyVisible: Signal<Bool> {
        return windowSignal.atOnce().filter { window in
            guard let window = window else {
                return false
            }

            let keyWindow = UIApplication.shared.keyWindow
            return keyWindow == window
        }.map { _ in true }
    }
}

struct PreMarketingLanguagePicker: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let (viewController, future) = LanguagePicker().materialize()

        future.onResult { _ in
            viewController.present(Marketing())
        }

        return (viewController, NilDisposer())
    }
}

struct LanguagePicker {
    @Inject var client: ApolloClient
}

extension LanguagePicker: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        ApplicationState.preserveState(.languagePicker)

        let mainView = UIView()
        mainView.backgroundColor = .hedvig(.primaryBackground)
        viewController.view = mainView

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.isLayoutMarginsRelativeArrangement = true
        mainView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }

        let titleHedvigLogo = UIImageView()
        titleHedvigLogo.image = Asset.wordmark.image
        titleHedvigLogo.contentMode = .scaleAspectFit
        stackView.addArrangedSubview(titleHedvigLogo)

        titleHedvigLogo.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(50)
        }

        let middleContainer = UIStackView()
        middleContainer.axis = .horizontal
        middleContainer.distribution = .equalSpacing
        middleContainer.alignment = .center
        middleContainer.edgeInsets = UIEdgeInsets(horizontalInset: 20, verticalInset: 0)
        middleContainer.isLayoutMarginsRelativeArrangement = true
        stackView.addArrangedSubview(middleContainer)

        middleContainer.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview()
        }

        let middleContent = UIStackView()
        middleContent.axis = .vertical
        middleContent.spacing = 10
        middleContainer.addArrangedSubview(middleContent)

        let textContainer = UIStackView()
        textContainer.axis = .vertical
        textContainer.spacing = 5
        textContainer.layoutMargins = UIEdgeInsets(horizontalInset: 20, verticalInset: 0)
        textContainer.isLayoutMarginsRelativeArrangement = true
        middleContent.addArrangedSubview(textContainer)

        textContainer.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview()
        }

        let titleLabel = UILabel(value: "Pick language", style: .standaloneLargeTitle)
        textContainer.addArrangedSubview(titleLabel)

        let descriptionLabel = UILabel(value: "You can change this later in settings.", style: .rowSubtitle)
        textContainer.addArrangedSubview(descriptionLabel)

        let form = FormView(sections: [], style: .defaultGrouped)
        middleContent.addArrangedSubview(form)

        form.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview()
        }

        let section = form.appendSection(header: nil, footer: nil, style: .sectionPlainRounded)

        textContainer.transform = CGAffineTransform(translationX: 0, y: 125)
        textContainer.alpha = 0
        form.transform = CGAffineTransform(translationX: 0, y: 100)
        form.alpha = 0

        bag += UIApplication.shared.appDelegate.hasFinishedLoading
            .delay(by: 1.25)
            .take(first: 1)
            .animated(style: .lightBounce(duration: 0.75), animations: { _ in
                textContainer.transform = CGAffineTransform.identity
                textContainer.alpha = 1
                form.transform = CGAffineTransform.identity
                form.alpha = 1
        })

        return (viewController, Future { completion in
            func pickLanguage(locale: Localization.Locale) {
                ApplicationState.setPreferredLocale(locale)
                Localization.Locale.currentLocale = locale
                TranslationsRepo.clear().onValue { _ in
                    UIApplication.shared.reloadAllLabels()
                }
                ApolloClient.initClient().always {
                    completion(.success)
                }
                bag += self.client.perform(mutation: UpdateLanguageMutation(language: locale.code)).onValue { _ in }
            }

            let englishRow = RowView(title: "English", style: .rowTitle, appendSpacer: false)
            bag += section.append(englishRow).onValue { _ in
                pickLanguage(locale: .en_SE)
            }

            englishRow.prepend(Asset.flagGB.image)
            englishRow.append(Asset.chevronRight.image)

            let swedishRow = RowView(title: "Svenska", style: .rowTitle, appendSpacer: false)
            bag += section.append(swedishRow).onValue { _ in
                pickLanguage(locale: .sv_SE)
            }

            swedishRow.prepend(Asset.flagSE.image)
            swedishRow.append(Asset.chevronRight.image)

            return bag
        })
    }
}
