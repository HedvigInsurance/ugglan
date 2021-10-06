import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct Header {
    let scrollView: UIScrollView
    static let trailingAlignmentBreakpoint: CGFloat = 800
    static let trailingAlignmentFormPercentageWidth: CGFloat = 0.40
    static let insetTop: CGFloat = 30
}

extension Header: Presentable {
    func materialize() -> (UIStackView, Disposable) {
        let view = UIStackView()

        let store: OfferStore = self.get()

        view.allowTouchesOfViewsOutsideBounds = true
        view.axis = .vertical
        let bag = DisposeBag()

        view.edgeInsets = UIEdgeInsets(top: Self.insetTop, left: 15, bottom: 60, right: 15)

        var gradientView = GradientView(
            gradientOption: .init(
                preset: .random,
                shouldShimmer: false,
                shouldAnimate: false
            ),
            shouldShowGradientSignal: .init(true)
        )

        bag += store.stateSignal.compactMap { $0.offerData?.quoteBundle.appConfiguration.gradientOption }
            .onValue { gradientOption in
                switch gradientOption {
                case .one:
                    gradientView.gradientOption = .init(
                        preset: .insuranceOne,
                        shouldShimmer: false,
                        shouldAnimate: false
                    )
                case .two:
                    gradientView.gradientOption =
                        .init(
                            preset: .insuranceTwo,
                            shouldShimmer: false,
                            shouldAnimate: false
                        )
                case .three:
                    gradientView.gradientOption = .init(
                        preset: .insuranceThree,
                        shouldShimmer: false,
                        shouldAnimate: false
                    )
                default:
                    break
                }
            }

        bag += view.add(
            gradientView
        ) { headerBackgroundView in
            headerBackgroundView.layer.masksToBounds = true
            headerBackgroundView.layer.zPosition = -1
            headerBackgroundView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.edges.equalToSuperview()
            }

            bag += scrollView.signal(for: \.contentOffset).atOnce()
                .onValue { contentOffset in
                    let headerScaleFactor: CGFloat =
                        -(contentOffset.y) / headerBackgroundView.bounds.height

                    guard headerScaleFactor > 0 else {
                        headerBackgroundView.layer.transform = CATransform3DIdentity
                        return
                    }

                    var headerTransform = CATransform3DIdentity

                    let headerSizevariation =
                        ((headerBackgroundView.bounds.height * (1.0 + headerScaleFactor))
                            - headerBackgroundView.bounds.height) / 2.0

                    headerTransform = CATransform3DTranslate(
                        headerTransform,
                        0,
                        -headerSizevariation,
                        0
                    )
                    headerTransform = CATransform3DScale(
                        headerTransform,
                        1.0 + headerScaleFactor,
                        1.0 + headerScaleFactor,
                        0
                    )

                    headerBackgroundView.layer.transform = headerTransform
                }
        }

        let formContainer = UIStackView()
        formContainer.axis = .vertical
        formContainer.alignment = .trailing
        formContainer.distribution = .equalSpacing
        formContainer.isLayoutMarginsRelativeArrangement = true
        formContainer.insetsLayoutMarginsFromSafeArea = true
        view.addArrangedSubview(formContainer)

        let spacerView = UIView()
        formContainer.addArrangedSubview(spacerView)

        let loadingIndicator = UIActivityIndicatorView()
        if #available(iOS 13.0, *) {
            loadingIndicator.style = .large
        } else {
            loadingIndicator.style = .whiteLarge
        }
        loadingIndicator.tintColor = .brand(.primaryText())
        scrollView.addSubview(loadingIndicator)

        let isLoadingSignal = store.stateSignal.map { $0.isLoading }

        bag +=
            isLoadingSignal
            .animated(style: .easeOut(duration: 0.25)) { isLoading in
                if isLoading {
                    loadingIndicator.alpha = 1
                } else {
                    loadingIndicator.alpha = 0
                }
            }
            .onValue { isLoading in
                if !isLoading {
                    loadingIndicator.removeFromSuperview()
                }
            }

        loadingIndicator.startAnimating()

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(scrollView.frameLayoutGuide.snp.center)
        }

        bag += formContainer.didMoveToWindowSignal.onValueDisposePrevious { _ in
            let innerBag = DisposeBag()
            scrollView.isScrollEnabled = false

            formContainer.snp.remakeConstraints { make in
                make.height.equalTo(scrollView.frameLayoutGuide.snp.height)
            }

            innerBag += isLoadingSignal.animated(
                style: SpringAnimationStyle.lightBounce(duration: 0.8)
            ) { isLoading in
                scrollView.isScrollEnabled = !isLoading

                formContainer.snp.remakeConstraints { make in
                    if isLoading {
                        make.height.equalTo(scrollView.frameLayoutGuide.snp.height)
                    }
                }

                formContainer.layoutIfNeeded()
                formContainer.layoutSuperviewsIfNeeded()

                view.subviews.forEach { view in
                    view.layoutIfNeeded()
                }
            }

            return innerBag
        }

        bag += formContainer.addArrangedSubview(HeaderForm()) { form, _ in
            form.alpha = 0

            bag += isLoadingSignal.animated(style: .easeOut(duration: 0.25)) { isLoading in
                form.alpha = isLoading ? 0 : 1
            }

            bag += merge(
                formContainer.didLayoutSignal,
                view.didLayoutSignal
            )
            .onValue {
                form.snp.remakeConstraints { make in
                    if view.frame.width > Self.trailingAlignmentBreakpoint {
                        formContainer.layoutMargins = UIEdgeInsets(
                            top: 0,
                            left: 0,
                            bottom: 0,
                            right: 15
                        )
                        make.width.equalTo(
                            view.frame.width * Self.trailingAlignmentFormPercentageWidth
                                - max(view.safeAreaInsets.right, 15) - 15
                        )
                    } else {
                        formContainer.layoutMargins = .zero
                        make.width.equalToSuperview()
                    }
                }
            }

            bag += scrollView.signal(for: \.contentOffset).atOnce()
                .onValue { contentOffset in
                    if let navigationBar = view.viewController?.navigationController?.navigationBar,
                        let insetTop = view.viewController?.navigationController?.view
                            .safeAreaInsets.top
                    {
                        let contentOffsetY =
                            contentOffset.y + navigationBar.frame.height + insetTop
                        if view.frame.width > Self.trailingAlignmentBreakpoint,
                            contentOffsetY > 0
                        {
                            formContainer.transform = CGAffineTransform(
                                translationX: 0,
                                y: contentOffsetY
                            )
                        } else {
                            formContainer.transform = CGAffineTransform.identity
                        }
                    }

                }
        }

        return (view, bag)
    }
}
