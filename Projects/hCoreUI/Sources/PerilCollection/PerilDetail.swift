import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hGraphQL

public struct PerilDetail {
    let peril: Perils

    public init(
        peril: Perils
    ) {
        self.peril = peril
    }
}

extension PerilDetail: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let scrollView = FormScrollView()
        let form = FormView()

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.edgeInsets = UIEdgeInsets(horizontalInset: 20, verticalInset: 24)

        form.append(stackView)

        bag += stackView.addArranged(RemoteVectorIcon(peril.icon)) { iconView in
            iconView.snp.makeConstraints { make in make.height.width.equalTo(80) }
        }

        bag += stackView.addArranged(Spacing(height: 20))

        bag += stackView.addArranged(
            MultilineLabel(value: peril.title, style: .brand(.title1(color: .primary)).centerAligned)
        )

        bag += stackView.addArranged(Spacing(height: 15))

        bag += stackView.addArranged(
            MultilineLabel(
                value: peril.description,
                style: TextStyle.brand(.body(color: .secondary)).centerAligned
            )
        )

        if !peril.covered.isEmpty {
            let coveredSection = form.appendSection(
                header: L10n.perilModalCoverageTitle,
                footer: nil,
                style: .default
            )

            peril.covered.forEach { covered in let row = RowView()

                let checkmarkImageView = UIImageView()
                checkmarkImageView.contentMode = .scaleAspectFit
                checkmarkImageView.image = hCoreUIAssets.circularCheckmark.image

                checkmarkImageView.snp.makeConstraints { make in make.width.equalTo(21) }

                row.prepend(checkmarkImageView)

                bag += row.append(
                    MultilineLabel(value: covered, style: .brand(.headline(color: .primary)))
                )

                coveredSection.append(row)
            }
        }

        if !peril.exceptions.isEmpty {
            let exceptionsSection = form.appendSection(
                header: L10n.perilModalExceptionsTitle,
                footer: nil,
                style: .default
            )

            peril.exceptions.forEach { exception in let row = RowView()

                let crossImageView = UIImageView()
                crossImageView.contentMode = .scaleAspectFit
                crossImageView.image = hCoreUIAssets.circularCross.image

                crossImageView.snp.makeConstraints { make in make.width.equalTo(21) }

                row.prepend(crossImageView)

                bag += row.append(
                    MultilineLabel(value: exception, style: .brand(.headline(color: .primary)))
                )

                exceptionsSection.append(row)
            }
        }

        // only show swipe hint if detents are available on system which is iOS 13+
        if #available(iOS 13, *) {
            let swipeHintBackgroundView = UIView()
            scrollView.addSubview(swipeHintBackgroundView)

            swipeHintBackgroundView.snp.makeConstraints { make in
                make.bottom.equalTo(scrollView.frameLayoutGuide.snp.bottom)
                make.left.equalTo(scrollView.frameLayoutGuide.snp.left)
                make.right.equalTo(scrollView.frameLayoutGuide.snp.right)
            }

            let gradient = CAGradientLayer()
            gradient.locations = [0, 0.3, 1]
            swipeHintBackgroundView.layer.addSublayer(gradient)

            bag += swipeHintBackgroundView.traitCollectionSignal.atOnce()
                .onValue { _ in
                    gradient.colors = [
                        UIColor.brand(.secondaryBackground()).withAlphaComponent(0).cgColor,
                        UIColor.brand(.secondaryBackground()).cgColor,
                        UIColor.brand(.secondaryBackground()).cgColor,
                    ]
                }

            bag += swipeHintBackgroundView.didLayoutSignal.onValue { _ in
                scrollView.bringSubviewToFront(swipeHintBackgroundView)
                gradient.frame = swipeHintBackgroundView.bounds
            }

            let swipeHintContainer = UIStackView()
            swipeHintContainer.axis = .vertical
            swipeHintContainer.alignment = .center
            swipeHintContainer.spacing = 5
            swipeHintBackgroundView.addSubview(swipeHintContainer)

            bag += swipeHintBackgroundView.windowSignal.atOnce()
                .onValueDisposePrevious { window in
                    guard let window = window else {
                        return NilDisposer()
                    }

                    var bottomSafeArea = window.safeAreaInsets.bottom

                    if window.traitCollection.userInterfaceIdiom == .pad { bottomSafeArea = 0 }

                    swipeHintContainer.edgeInsets = UIEdgeInsets(
                        top: 10,
                        left: 0,
                        bottom: bottomSafeArea != 0 ? bottomSafeArea : 20,
                        right: 0
                    )

                    return stackView.didLayoutSignal.onValue { _ in
                        let mainContentHeight = stackView.frame.size
                        let navigationBarHeight =
                            viewController.navigationController?.navigationBar.frame.height ?? 0
                        viewController.preferredContentSize = CGSize(
                            width: mainContentHeight.width,
                            height: mainContentHeight.height
                                + (swipeHintContainer.frame.height - bottomSafeArea)
                                + navigationBarHeight
                        )
                    }
                }

            swipeHintContainer.snp.makeConstraints { make in
                make.top.bottom.trailing.leading.equalToSuperview()
            }

            let swipeHintTapGestureRecognizer = UITapGestureRecognizer()
            swipeHintContainer.addGestureRecognizer(swipeHintTapGestureRecognizer)

            bag += swipeHintTapGestureRecognizer.signal(forState: .recognized)
                .compactMap { viewController.appliedDetents.last }
                .bindTo(viewController.currentDetentSignal)

            let chevronUpImageView = UIImageView()
            chevronUpImageView.image = hCoreUIAssets.chevronUp.image
            chevronUpImageView.contentMode = .scaleAspectFit
            swipeHintContainer.addArrangedSubview(chevronUpImageView)

            let swipeHintLabel = UILabel(
                value: L10n.PerilDetail.moreInfo,
                style: TextStyle.brand(.footnote(color: .primary)).centerAligned
            )
            swipeHintContainer.addArrangedSubview(swipeHintLabel)

            bag += viewController.install(form, scrollView: scrollView)

            bag += viewController.currentDetentSignal.animated(style: .lightBounce()) { detent in
                swipeHintBackgroundView.alpha = detent == .large ? 0 : 1
            }
        }

        return (viewController, bag)
    }
}
