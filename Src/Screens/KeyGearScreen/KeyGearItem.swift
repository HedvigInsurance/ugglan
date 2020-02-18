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
import Presentation
import UIKit

struct KeyGearItem {
    let id: String
    @Inject var client: ApolloClient

    class KeyGearItemViewController: UIViewController {
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
        }

        enum PreservedNavigationBarAttributes {
            case backgroundImage(compact: UIImage?, defaultMetric: UIImage?)
            case barTintColor(color: UIColor?)
            case isTranslucent(value: Bool)
            case shadowImage(image: UIImage?)
            case tintColor(color: UIColor)
            case titleTextAttributes(attributes: [NSAttributedString.Key: Any]?)
            case barStyle(style: UIBarStyle)
        }

        var preservedNavigationBarAttributes: [PreservedNavigationBarAttributes] = []

        init() {
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewWillAppear(_: Bool) {
            let navigationBar = navigationController!.navigationBar

            preservedNavigationBarAttributes.append(.backgroundImage(compact: navigationBar.backgroundImage(for: .compact), defaultMetric: navigationBar.backgroundImage(for: .default)))
            preservedNavigationBarAttributes.append(.barTintColor(color: navigationBar.barTintColor))
            preservedNavigationBarAttributes.append(.isTranslucent(value: navigationBar.isTranslucent))
            preservedNavigationBarAttributes.append(.shadowImage(image: navigationBar.shadowImage))
            preservedNavigationBarAttributes.append(.tintColor(color: navigationBar.tintColor))
            preservedNavigationBarAttributes.append(.titleTextAttributes(attributes: navigationBar.titleTextAttributes))
            preservedNavigationBarAttributes.append(.barStyle(style: navigationBar.barStyle))

            navigationBar.tintColor = UIColor.white
            navigationBar.backIndicatorImage = Asset.backButtonWhite.image
            navigationBar.barTintColor = UIColor.transparent
            navigationBar.isTranslucent = true
            navigationBar.shadowImage = UIImage()
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            navigationBar.barStyle = .black

            let gradient = CAGradientLayer()
            var bounds = navigationBar.bounds
            bounds.size.height += UIApplication.shared.statusBarFrame.size.height
            gradient.frame = bounds
            gradient.colors = [UIColor.black.withAlphaComponent(0.7).cgColor, UIColor.black.withAlphaComponent(0).cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 0, y: 1)

            if let image = getGradientImage(gradientLayer: gradient) {
                navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
                navigationBar.setBackgroundImage(image, for: .compact)
            }
        }

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

        override func viewWillDisappear(_: Bool) {
            let navigationBar = navigationController!.navigationBar

            UIView.transition(with: navigationBar, duration: 0.35, options: [], animations: {
                self.preservedNavigationBarAttributes.forEach { attribute in
                    switch attribute {
                    case let .backgroundImage(compact, defaultMetric):
                        navigationBar.setBackgroundImage(defaultMetric, for: .default)
                        navigationBar.setBackgroundImage(compact, for: .compact)
                    case let .barTintColor(color):
                        navigationBar.barTintColor = color
                    case let .isTranslucent(value):
                        navigationBar.isTranslucent = value
                    case let .shadowImage(image):
                        navigationBar.shadowImage = image
                    case let .tintColor(color):
                        navigationBar.tintColor = color
                    case let .titleTextAttributes(attributes):
                        navigationBar.titleTextAttributes = attributes
                    case let .barStyle(style):
                        navigationBar.barStyle = style
                    }
                }
                self.preservedNavigationBarAttributes = []
            }, completion: nil)
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

        let dataSignal = client.watch(query: KeyGearItemQuery(id: id)).compactMap { $0.data?.keyGearItem }

        bag += dataSignal.onValue { data in
            print(data)
        }

        let scrollView = UIScrollView()
        scrollView.backgroundColor = .primaryBackground

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

        bag += viewController.install(form, options: [], scrollView: scrollView)

        let imagesSignal = dataSignal.map { $0.photos.compactMap { $0.file.preSignedUrl } }.compactMap { $0.compactMap { URL(string: $0) } }.readable(initial: [])

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

        bag += innerForm.append(KeyGearItemHeader(presentingViewController: viewController))

        bag += innerForm.append(Spacing(height: 10))

        let coveragesSection = innerForm.appendSection(header: String(key: .KEY_GEAR_ITEM_VIEW_COVERAGE_TABLE_TITLE))
        coveragesSection.dynamicStyle = .sectionPlain

        bag += coveragesSection.append(KeyGearCoverage())

        bag += innerForm.append(Spacing(height: 15))

        let nonCoveragesSection = innerForm.appendSection(header: String(key: .KEY_GEAR_ITEM_VIEW_NON_COVERAGE_TABLE_TITLE))
        nonCoveragesSection.dynamicStyle = .sectionPlain

        bag += nonCoveragesSection.append(KeyGearCoverage())

        bag += innerForm.append(Spacing(height: 30))

        let nameSection = innerForm.appendSection()
        nameSection.dynamicStyle = .sectionPlain

        bag += nameSection.append(EditableRow(valueSignal: .static("Namn"), placeholderSignal: .static("Namn"))).onValue { _ in
            print("was saved")
        }

        return (viewController, Future { completion in
            bag += optionsButton.onValue {
                viewController.present(Alert(actions: [
                    Alert.Action(title: "Delete", style: .destructive, action: { _ in
                        completion(.success)
                    }),
                    Alert.Action(title: "Cancel", style: .cancel, action: { _ in

                    }),
                ]), style: .sheet())
            }

            return bag
        })
    }
}
