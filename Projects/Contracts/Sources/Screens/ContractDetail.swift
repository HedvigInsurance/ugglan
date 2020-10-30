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

        let form = FormView()

        form.appendSpacing(.inbetween)

        let (contractRowView, configureContractRow) = ContractRow.makeAndConfigure()
        bag += configureContractRow(contractRow)

        form.append(contractRowView)

        form.appendSpacing(.inbetween)

        let segmentedControlContainer = UIStackView()
        segmentedControlContainer.edgeInsets = UIEdgeInsets(horizontalInset: 15, verticalInset: 0)
        form.append(segmentedControlContainer)

        let segmentedControl = UISegmentedControl(titles: ["Your info", "Coverage", "Documents"])
        segmentedControl.hero.modifiers = [
            .translate(x: 0, y: 40, z: 0),
            .opacity(0),
            .spring(stiffness: 250, damping: 30),
        ]
        segmentedControlContainer.addArrangedSubview(segmentedControl)

        return (viewController, Future { completion in
            bag += viewController.install(form) { scrollView in
                let panGR = scrollView.panGestureRecognizer
                bag += panGR.onValue { _ in
                    let translation = panGR.translation(in: nil)

                    if translation.y > 200 {
                        completion(.success)
                    }
                }
            }

            return bag
        })
    }
}
