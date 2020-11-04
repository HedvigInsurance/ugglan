import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Hero
import Presentation

struct ContractDetail {
    var contractRow: ContractRow

    init(contractRow: ContractRow) {
        self.contractRow = contractRow
        self.contractRow.allowDetailNavigation = false
    }
}

extension ContractDetail: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let scrollView = FormScrollView()
        let form = FormView()

        form.appendSpacing(.inbetween)

        let (contractRowView, configureContractRow) = ContractRow.makeAndConfigure()
        bag += configureContractRow(contractRow)

        form.append(contractRowView)

        let contractInformation = ContractInformation(contract: contractRow.contract)

        let contractCoverage = ContractCoverage(
            perilFragments:
            contractRow.contract.perils.compactMap { $0.fragments.perilFragment },
            insurableLimitFragments:
            contractRow.contract.insurableLimits.compactMap { $0.fragments.insurableLimitFragment }
        )

        let contractDocuments = ContractDocuments(contract: contractRow.contract)

        var contractDetailCollection = ContractDetailCollection(rows: [
            ContractDetailPresentableRow(presentable: AnyPresentable(contractInformation)),
            ContractDetailPresentableRow(presentable: AnyPresentable(contractCoverage)),
            ContractDetailPresentableRow(presentable: AnyPresentable(contractDocuments)),
        ], currentIndex: IndexPath(row: 0, section: 0))

        let segmentedControlBackgroundView = UIView()
        segmentedControlBackgroundView.hero.modifiers = [
            .translate(x: 0, y: 40, z: 0),
            .opacity(0),
            .spring(stiffness: 250, damping: 30),
        ]
        segmentedControlBackgroundView.backgroundColor = .brand(.primaryBackground())
        form.append(segmentedControlBackgroundView)

        let segmentedControlBorderView = UIView()
        segmentedControlBorderView.alpha = 0
        segmentedControlBorderView.backgroundColor = .brand(.primaryBorderColor)

        segmentedControlBackgroundView.addSubview(segmentedControlBorderView)

        segmentedControlBorderView.snp.makeConstraints { make in
            make.height.equalTo(CGFloat.hairlineWidth)
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        let segmentedControlContainer = UIStackView()
        segmentedControlContainer.edgeInsets = UIEdgeInsets(
            horizontalInset: 15,
            verticalInset: SpacingType.inbetween.height
        )

        segmentedControlBackgroundView.addSubview(segmentedControlContainer)

        segmentedControlContainer.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }

        let segmentedControl = UISegmentedControl(titles: [
            L10n.InsuranceDetailsView.tab1Title,
            L10n.InsuranceDetailsView.tab2Title,
            L10n.InsuranceDetailsView.tab3Title,
        ])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControlContainer.addArrangedSubview(segmentedControl)

        bag += scrollView.signal(for: \.contentOffset).onValue { contentOffset in
            form.bringSubviewToFront(segmentedControlBackgroundView)

            let originY = segmentedControlBackgroundView.frameWithoutTransform.origin.y
            let contentOffsetY = contentOffset.y + scrollView.adjustedContentInset.top

            if contentOffsetY > originY {
                segmentedControlBorderView.alpha = 1
                segmentedControlBackgroundView.transform = CGAffineTransform(
                    translationX: 0,
                    y: contentOffsetY - originY
                )
            } else {
                segmentedControlBorderView.alpha = 0
                segmentedControlBackgroundView.transform = .identity
            }
        }

        bag += segmentedControl.onValue { index in
            scrollView.scrollToTop(animated: true)
            contractDetailCollection.currentIndex = IndexPath(item: index, section: 0)
        }

        bag += form.append(contractDetailCollection) { contractDetailCollectionView in
            contractDetailCollectionView.hero.modifiers = [
                .translate(x: 0, y: 40, z: 0),
                .opacity(0),
                .spring(stiffness: 250, damping: 30),
            ]
        }

        return (viewController, Future { completion in
            bag += viewController.install(form, scrollView: scrollView) { scrollView in
                let panGR = scrollView.panGestureRecognizer
                bag += panGR.onValue { _ in
                    let translation = panGR.translation(in: nil)

                    if translation.y > 200 {
                        panGR.state = .cancelled
                        completion(.success)
                    }
                }
            }

            return bag
        })
    }
}
