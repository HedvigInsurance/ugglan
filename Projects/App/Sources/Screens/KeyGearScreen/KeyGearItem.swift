//
//  KeyGearItem.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-27.
//

import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Presentation
import UIKit

struct KeyGearItem {
    let id: String
    @Inject var client: ApolloClient

    func getGradientImage(gradientLayer: CAGradientLayer) -> UIImage? {
        var gradientImage: UIImage?
        UIGraphicsBeginImageContext(gradientLayer.frame.size)

        if let context = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        }

        UIGraphicsEndImageContext()

        return gradientImage
    }

    func addNavigationBar(
        scrollView _: UIScrollView,
        viewController: UIViewController
    ) -> (Disposable, UINavigationBar) {
        let bag = DisposeBag()

        let navigationBar = UINavigationBar()

        navigationBar.items = [viewController.navigationItem]

        navigationBar.tintColor = UIColor.clear
        navigationBar.barTintColor = UIColor.clear
        navigationBar.backIndicatorImage = Asset.backButtonWhite.image
        navigationBar.isTranslucent = true
        navigationBar.shadowImage = UIImage()
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationBar.barStyle = .blackTranslucent
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.setBackgroundImage(UIImage(), for: .compact)

        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.black.withAlphaComponent(0.7).cgColor, UIColor.black.withAlphaComponent(0).cgColor]
        gradient.locations = [0, 1]

        let gradientView = UIView()
        gradientView.layer.addSublayer(gradient)
        viewController.view.addSubview(gradientView)

        bag += gradientView.didLayoutSignal.onValue { _ in
            gradient.frame = gradientView.frame

            gradientView.snp.makeConstraints { make in
                make.height.equalTo(navigationBar).offset(gradientView.safeAreaInsets.top)
                make.trailing.leading.equalToSuperview()
            }
        }

        viewController.view.addSubview(navigationBar)

        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(viewController.view.safeAreaLayoutGuide.snp.top)
            make.trailing.equalTo(viewController.view.safeAreaLayoutGuide.snp.trailing)
            make.leading.equalTo(viewController.view.safeAreaLayoutGuide.snp.leading)
        }

        return (bag, navigationBar)
    }

    class KeyGearItemViewController: UIViewController {
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
        }

        init() {
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewWillAppear(_ animated: Bool) {
            navigationController?.setNavigationBarHidden(true, animated: animated)
            navigationController?.interactivePopGestureRecognizer?.delegate = nil
        }
    }
}

extension KeyGearItem: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()
        let viewController = KeyGearItemViewController()

        let optionsButton = UIBarButtonItem()
        optionsButton.tintColor = .white
        optionsButton.image = Asset.menuIcon.image

        viewController.navigationItem.rightBarButtonItem = optionsButton

        let backButton = UIButton(type: .custom)
        backButton.setImage(Asset.backButtonWhite.image, for: .normal)
        backButton.tintColor = .white

        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(button: backButton)

        let view = UIView()
        view.backgroundColor = .primaryBackground
        viewController.view = view

        let dataSignal = client.watch(
            query: KeyGearItemQuery(id: id, languageCode: Localization.Locale.currentLocale.code),
            cachePolicy: .returnCacheDataAndFetch
        ).compactMap { $0.data?.keyGearItem }

        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.backgroundColor = .primaryBackground

        scrollView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        bag += scrollView.scrollToRevealFirstResponder { view -> UIEdgeInsets in
            let rowInsets = alignToRow(view)

            return UIEdgeInsets(
                top: rowInsets.top,
                left: rowInsets.left,
                bottom: rowInsets.bottom - 20,
                right: rowInsets.right
            )
        }
        bag += scrollView.adjustInsetsForKeyboard()

        let form = FormView()

        bag += form.didLayoutSignal.take(first: 1).onValue { _ in
            form.dynamicStyle = DynamicFormStyle.default.restyled { (style: inout FormStyle) in
                style.insets = UIEdgeInsets(top: -scrollView.safeAreaInsets.top, left: 0, bottom: 20, right: 0)
            }
        }

        scrollView.embedView(form, scrollAxis: .vertical)

        let imagesSignal = dataSignal.map { (images: $0.photos.compactMap { $0.file.preSignedUrl }, category: $0.category) }.compactMap { data -> [Either<URL, KeyGearItemCategory>] in
            if data.images.isEmpty {
                return [.right(data.category)]
            }

            return data.images.compactMap { URL(string: $0) }.map { .left($0) }
        }.readable(initial: [])

        bag += form.prepend(KeyGearImageCarousel(imagesSignal: imagesSignal)) { imageCarouselView in
            bag += scrollView.contentOffsetSignal.onValue { offset in
                let realOffset = offset.y + scrollView.safeAreaInsets.top

                if realOffset < 0 {
                    imageCarouselView.transform = CGAffineTransform(
                        translationX: 0,
                        y: realOffset * 0.5
                    ).concatenating(
                        CGAffineTransform(
                            scaleX: 1 + abs(realOffset / imageCarouselView.frame.height),
                            y: 1 + abs(realOffset / imageCarouselView.frame.height)
                        )
                    )
                } else {
                    imageCarouselView.transform = CGAffineTransform(
                        translationX: 0,
                        y: realOffset * 0.5
                    )
                }
            }
        }

        let formContainer = UIView()
        formContainer.backgroundColor = .primaryBackground
        form.append(formContainer)

        let innerForm = FormView()
        formContainer.addSubview(innerForm)

        innerForm.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }

        bag += innerForm.append(KeyGearItemHeader(presentingViewController: viewController, itemId: id))

        bag += innerForm.append(Spacing(height: 10))

        let claimsSection = innerForm.appendSection()
        claimsSection.dynamicStyle = .sectionPlain

        let claimsRow = RowView(title: L10n.keyGearReportClaimRow, style: .rowTitle)
        claimsRow.append(Asset.chevronRight.image)

        bag += claimsSection.append(claimsRow).onValue { _ in
            viewController.present(
                HonestyPledge(),
                style: .modally(),
                options: [.defaults]
            )
        }

        bag += innerForm.append(Spacing(height: 10))

        let coveragesSection = innerForm.appendSection(header: L10n.keyGearItemViewCoverageTableTitle)
        coveragesSection.dynamicStyle = .sectionPlain

        bag += dataSignal.map { $0.covered }.onValueDisposePrevious { covered -> Disposable? in
            let bag = DisposeBag()

            bag += covered.map { coveredItem in
                coveragesSection.append(KeyGearCoverage(type: .included, title: coveredItem.title?.translations?.first?.text ?? ""))
            }

            return bag
        }

        bag += innerForm.append(Spacing(height: 15))

        let nonCoveragesSection = innerForm.appendSection(header: L10n.keyGearItemViewNonCoverageTableTitle)
        nonCoveragesSection.dynamicStyle = .sectionPlain

        bag += dataSignal.map { $0.exceptions }.onValueDisposePrevious { exceptions -> Disposable? in
            let bag = DisposeBag()

            bag += exceptions.map { exceptionItem in
                nonCoveragesSection.append(KeyGearCoverage(type: .excluded, title: exceptionItem.title?.translations?.first?.text ?? ""))
            }

            return bag
        }

        bag += innerForm.append(Spacing(height: 30))

        let receiptFooter = UIStackView()
        bag += receiptFooter.addArranged(MultilineLabel(value: L10n.keyGearItemViewReceiptTableFooter, style: .sectionHeader))

        let receiptSection = innerForm.appendSection(headerView: nil, footerView: receiptFooter)
        receiptSection.dynamicStyle = .sectionPlain

        bag += receiptSection.append(KeyGearAddReceiptRow(presentingViewController: viewController, itemId: id))

        bag += innerForm.append(Spacing(height: 15))

        let nameSection = innerForm.appendSection()
        nameSection.dynamicStyle = .sectionPlain

        let nameValueSignal = dataSignal.map { $0.name ?? "" }.readable(initial: "").writable(setValue: { _ in })
        let nameRow = EditableRow(
            valueSignal: nameValueSignal,
            placeholderSignal: .static(L10n.keyGearItemViewItemNameTableTitle)
        )

        let (navigationBarBag, navigationBar) = addNavigationBar(
            scrollView: scrollView,
            viewController: viewController
        )
        bag += navigationBarBag

        bag += nameSection.append(nameRow).onValue { name in
            viewController.navigationItem.title = name
            navigationBar.items = [viewController.navigationItem]
            self.client.perform(mutation: UpdateKeyGearItemNameMutation(id: self.id, name: name)).onValue { _ in }
        }

        bag += dataSignal.onValue { data in
            viewController.navigationItem.title = data.name
            navigationBar.items = [viewController.navigationItem]
        }

        bag += navigationBar.didLayoutSignal.onValue { _ in
            scrollView.scrollIndicatorInsets = UIEdgeInsets(
                top: navigationBar.frame.height,
                left: 0,
                bottom: 0,
                right: 0
            )
        }

        bag += navigationBar.traitCollectionSignal.atOnce().onValue { trait in
            if trait.userInterfaceIdiom == .pad {
                viewController.navigationItem.leftBarButtonItem = nil
            } else {
                viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(button: backButton)
            }

            navigationBar.items = [viewController.navigationItem]
        }

        return (viewController, Future { completion in
            bag += optionsButton.onValue {
                viewController.present(Alert(actions: [
                    Alert.Action(title: L10n.keyGearItemDelete, style: .destructive, action: { _ in
                        completion(.success)
                    }),
                    Alert.Action(title: L10n.keyGearItemOptionsCancel, style: .cancel, action: { _ in
                        throw GenericError.cancelled
                    }),
                ]), style: .sheet(from: optionsButton.view, rect: nil)).onValue { _ in
                    self.client.perform(mutation: DeleteKeyGearItemMutation(id: self.id)).onValue { _ in
                        self.client.fetch(query: KeyGearItemsQuery(), cachePolicy: .fetchIgnoringCacheData).onValue { _ in
                            completion(.success)
                        }
                    }
                }
            }

            bag += backButton.onValue { _ in
                completion(.success)
            }

            return DelayedDisposer(bag, delay: 2.0)
        })
    }
}
